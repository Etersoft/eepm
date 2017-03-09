#!/bin/sh
#
# Copyright (C) 2012-2013, 2016  Etersoft
# Copyright (C) 2012-2013, 2016  Vitaly Lipatov <lav@etersoft.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

PROGDIR=$(dirname $0)
[ "$PROGDIR" = "." ] && PROGDIR=$(pwd)

# will replaced to /usr/share/eepm during install
SHAREDIR=$(dirname $0)

load_helper()
{
    local CMD="$SHAREDIR/$1"
    [ -r "$CMD" ] || fatal "Have no $CMD helper file"
    . $CMD
}


# File bin/epm-sh-functions:


inputisatty()
{
	# check stdin
	tty -s 2>/dev/null
}

isatty()
{
	# check stdout
	test -t 1
}

isatty2()
{
	# check stderr
	test -t 2
}

check_tty()
{
	isatty2 || return

	# Set a sane TERM required for tput
	[ -n "$TERM" ] || TERM=dumb
	export TERM

	# egrep from busybox may not --color
	# egrep from MacOS print help to stderr
	if egrep --help 2>&1 | grep -q -- "--color" ; then
		export EGREPCOLOR="--color"
	fi

	which tput >/dev/null 2>/dev/null || return
	# FreeBSD does not support tput -S
	echo | tput -S >/dev/null 2>/dev/null || return
	[ -z "$USETTY" ] || return
	export USETTY=1
}

: ${BLACK:=0} ${RED:=1} ${GREEN:=2} ${YELLOW:=3} ${BLUE:=4} ${MAGENTA:=5} ${CYAN:=6} ${WHITE:=7}

set_boldcolor()
{
	[ "$USETTY" = "1" ] || return
	{
		echo bold
		echo setaf $1
	} |tput -S
}

restore_color()
{
	[ "$USETTY" = "1" ] || return
	{
		echo op; # set Original color Pair.
		echo sgr0; # turn off all special graphics mode (bold in our case).
	} |tput -S
}

echover()
{
    [ -z "$verbose" ] && return
    echo "$*" >&2
}

echon()
{
	# default /bin/sh on MacOS does not recognize -n
	/bin/echo -n "$@"
}


set_target_pkg_env()
{
	[ -n "$DISTRNAME" ] || fatal "Missing DISTRNAME in set_target_pkg_env."
	PKGFORMAT=$($DISTRVENDOR -p "$DISTRNAME")
	PKGVENDOR=$($DISTRVENDOR -s "$DISTRNAME")
	RPMVENDOR=$($DISTRVENDOR -n "$DISTRNAME")
}

showcmd()
{
	if [ -z "$quiet" ] ; then
		set_boldcolor $GREEN
		local PROMTSIG="\$"
		[ "$EFFUID" = 0 ] && PROMTSIG="#"
		echo " $PROMTSIG $@"
		restore_color
	fi >&2
}

docmd()
{
	showcmd "$@$EXTRA_SHOWDOCMD"
	$@
}

docmd_foreach()
{
	local cmd pkg
	cmd="$1"
	#showcmd "$@"
	shift
	for pkg in "$@" ; do
		docmd "$cmd" $pkg
	done
}

sudocmd()
{
	showcmd "$SUDO $@"
	$SUDO $@
}

sudocmd_foreach()
{
	local cmd pkg
	cmd="$1"
	#showcmd "$@"
	shift
	for pkg in "$@" ; do
		sudocmd "$cmd" $pkg || return
	done
}

if ! which realpath 2>/dev/null >/dev/null ; then
realpath()
{
	readlink -f "$@"
}
fi

get_firstarg()
{
	echon "$1"
}

get_lastarg()
{
	local lastarg
	eval lastarg=\${$#}
	echon "$lastarg"
}


filter_strip_spaces()
{
        # possible use just
        #xargs echo
        sed -e "s| \+| |g" | \
                sed -e "s|^ ||" | sed -e "s| \$||"
}

strip_spaces()
{
        echo "$*" | filter_strip_spaces
}

subst_option()
{
	eval "[ -n \"\$$1\" ]" && echo "$2" || echo "$3"
}

store_output()
{
    # use make_temp_file from etersoft-build-utils
    RC_STDOUT=$(mktemp)
    local CMDSTATUS=$RC_STDOUT.pipestatus
    echo 1 >$CMDSTATUS
    #RC_STDERR=$(mktemp)
    ( $@ 2>&1 ; echo $? >$CMDSTATUS ) | tee $RC_STDOUT
    return $(cat $CMDSTATUS)
    # bashism
    # http://tldp.org/LDP/abs/html/bashver3.html#PIPEFAILREF
    #return $PIPESTATUS
}

showcmd_store_output()
{
    showcmd "$@"
    store_output "$@"
}

clean_store_output()
{
    rm -f $RC_STDOUT $RC_STDOUT.pipestatus
}

epm()
{
	[ -n "$PROGNAME" ] || fatal "Can't use epm call from the piped script"
	$PROGDIR/$PROGNAME $@
}

fatal()
{
	if [ -z "$TEXTDOMAIN" ] ; then
		echo "Error: $@" >&2
	fi
	exit 1
}

warning()
{
	if [ -z "$TEXTDOMAIN" ] ; then
		echo "Warning: $@" >&2
	fi
}

info()
{
	[ -n "$quiet" ] && return

	# print message to stderr if stderr forwarded to (a file)
	if isatty2 ; then
		isatty || return 0
		echo "$@"
	else
		echo "$@" >&2
	fi
}

set_sudo()
{
	SUDO=""
	# skip SUDO if disabled
	[ -n "$EPMNOSUDO" ] && return
	if [ "$DISTRNAME" = "Cygwin" ] || [ "$DISTRNAME" = "Windows" ] ; then
		# skip sudo using on Windows
		return
	fi

	EFFUID=`id -u`

	# do not need sudo
	[ $EFFUID = "0" ] && return

	# use sudo if possible
	if which sudo >/dev/null 2>/dev/null ; then
		SUDO="sudo --"
		# check for < 1.7 version which do not support -- (and --help possible too)
		sudo -h 2>/dev/null | grep -q "  --" || SUDO="sudo"
		return
	fi

	SUDO="fatal 'Can't find sudo. Please install sudo or run epm under root.'"
}

withtimeout()
{
	local TO=$(which timeout 2>/dev/null || which gtimeout 2>/dev/null)
	if [ -x "$TO" ] ; then
		$TO $@
		return
	fi
	# fallback: drop time arg and run without timeout
	shift
	$@
}

set_eatmydata()
{
	# skip if disabled
	[ -n "$EPMNOEATMYDATA" ] && return
	# use if possible
	which eatmydata >/dev/null 2>/dev/null || return
	SUDO="$SUDO eatmydata"
	[ -n "$verbose" ] && info "Uwaga! eatmydata is installed, we will use it for disable all sync operations."
	return 0
}

__get_package_for_command()
{
	case "$1" in
		equery|revdep-rebuild)
			echo 'gentoolkit'
			;;
		update-kernel|remove-old-kernels)
			echo 'update-kernel'
			;;
	esac
}

confirm() {
    local response
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

assure_root()
{
	[ "$EFFUID" = 0 ] || fatal "run me only under root"
}

regexp_subst()
{
	local expression="$1"
	shift
	sed -i -r -e "$expression" "$@"
}

assure_exists()
{
	local package="$2"
	local textpackage=
	[ -n "$package" ] || package="$(__get_package_for_command "$1")"
	[ -n "$3" ] && textpackage=" >= $3"
	__epm_assure "$1" $package $3 || fatal "Can't assure in '$1' command from $package$textpackage package"
}

eget()
{
	assure_exists wget
	internal_tools_eget "$@"
}

get_package_type()
{
	local i
	case $1 in
		*.deb)
			echo "deb"
			return
			;;
		*.rpm)
			echo "rpm"
			return
			;;
		*.txz)
			echo "txz"
			return
			;;
		*.tbz)
			echo "tbz"
			return
			;;
		*.exe)
			echo "exe"
			return
			;;
		*.msi)
			echo "msi"
			return
			;;
		*)
			#fatal "Don't know type of $1"
			# return package name for info
			echo "$1"
			return 1
			;;
	esac
}


get_help()
{
    if [ "$0" = "/dev/stdin" ] || [ "$0" = "sh" ] ; then
        return
    fi

    grep -v -- "^#" $0 | grep -- "# $1" | while read n ; do
        opt=$(echo $n | sed -e "s|) # $1:.*||g")
        desc=$(echo $n | sed -e "s|.*) # $1:||g")
        printf "    %-20s %s\n" $opt "$desc"
    done
}


set_pm_type()
{
	local CMD

	# Fill for use: PMTYPE, DISTRNAME, DISTRVERSION, PKGFORMAT, PKGVENDOR, RPMVENDOR
	DISTRVENDOR=internal_distr_info
	[ -n "$DISTRNAME" ] || DISTRNAME=$($DISTRVENDOR -d) || fatal "Can't get distro name."
	[ -n "$DISTRVERSION" ] || DISTRVERSION=$($DISTRVENDOR -v)
	set_target_pkg_env

if [ -n "$FORCEPM" ] ; then
	PMTYPE=$FORCEPM
	return
fi

case $DISTRNAME in
	ALTLinux)
		CMD="apt-rpm"
		#which ds-install 2>/dev/null >/dev/null && CMD=deepsolver-rpm
		;;
	PCLinux)
		CMD="apt-rpm"
		;;
	Ubuntu|Debian|Mint|AstraLinux|Elbrus)
		CMD="apt-dpkg"
		#which aptitude 2>/dev/null >/dev/null && CMD=aptitude-dpkg
		which snappy 2>/dev/null >/dev/null && CMD=snappy
		;;
	Mandriva|ROSA)
		CMD="urpm-rpm"
		;;
	FreeBSD|NetBSD|OpenBSD|Solaris)
		CMD="pkgsrc"
		which pkg 2>/dev/null >/dev/null && CMD=pkgng
		;;
	Gentoo)
		CMD="emerge"
		;;
	ArchLinux)
		CMD="pacman"
		;;
	Fedora|LinuxXP|ASPLinux|CentOS|RHEL|Scientific|GosLinux)
		CMD="yum-rpm"
		which dnf 2>/dev/null >/dev/null && test -d /var/lib/dnf/yumdb && CMD=dnf-rpm
		;;
	Slackware)
		CMD="slackpkg"
		;;
	SUSE|SLED|SLES|Tumbleweed)
		CMD="zypper-rpm"
		;;
	ForesightLinux|rPathLinux)
		CMD="conary"
		;;
	Windows)
		CMD="chocolatey"
		;;
	MacOS)
		CMD="homebrew"
		;;
	OpenWRT)
		CMD="ipkg"
		;;
	GNU/Linux/Guix)
		CMD="guix"
		;;
	Android)
		CMD="android"
		;;
	Cygwin)
		CMD="aptcyg"
		;;
	alpine)
		CMD="apk"
		;;
	TinyCoreLinux)
		CMD="tce"
		;;
	VoidLinux)
		CMD="xbps"
		;;
	*)
		fatal "Have no suitable DISTRNAME $DISTRNAME"
		;;
esac
PMTYPE=$CMD
}


is_active_systemd()
{
	local a
	SYSTEMCTL=/bin/systemctl
	SYSTEMD_CGROUP_DIR=/sys/fs/cgroup/systemd
	[ -x "$SYSTEMCTL" ] || return
	[ -d "$SYSTEMD_CGROUP_DIR" ] || return
	a= mountpoint -q "$SYSTEMD_CGROUP_DIR" || return
	readlink /sbin/init | grep -q 'systemd' || return
	# some hack
	ps ax | grep '[s]ystemd' | grep -q -v 'systemd-udev'
}

# File bin/serv-common:

serv_common()
{
	local SERVICE="$1"
	shift
	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				fatal "Have no idea how to call anyservice service with args"
			fi
			sudocmd service $SERVICE "$@"
			;;
		service-initd|service-update)
			sudocmd $INITDIR/$SERVICE "$@"
			;;
		systemd)
			# run init script directly (for nonstandart commands)
			if [ -x $INITDIR/$SERVICE ] ; then
				sudocmd $INITDIR/$SERVICE "$@"
			else
				sudocmd systemctl "$@" $SERVICE
			fi
			;;
		runit)
			sudocmd sv $SERVICE "$@"
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-disable:


serv_disable()
{
	local SERVICE="$1"

	is_service_running $1 && { serv_stop $1 || return ; }
	is_service_autostart $1 || { info "Service $1 already disabled for startup" && return ; }

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE off
				return
			fi
			sudocmd chkconfig $1 off
			;;
		service-initd|service-update)
			sudocmd update-rc.d $1 remove
			;;
		systemd)
			sudocmd systemctl disable $1
			;;
		runit)
			sudocmd rm -fv /var/service/$SERVICE
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-enable:


__serv_enable()
{
	local SERVICE="$1"

	is_service_autostart $1 && info "Service $1 is already enabled for startup" && return

	case $SERVICETYPE in
		service-chkconfig)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE on
				return
			fi
			sudocmd chkconfig --add $1 || return
			sudocmd chkconfig $1 on
			;;
		service-upstart)
			sudocmd chkconfig --add $1 || return
			sudocmd chkconfig $1 on
			;;
		service-initd|service-update)
			sudocmd update-rc.d $1 defaults
			;;
		systemd)
			sudocmd systemctl enable $1
			;;
		runit)
			epm assure $SERVICE
			[ -r "/etc/sv/$SERVICE" ] || fatal "Can't find /etc/sv/$SERVICE"
			sudocmd ln -s /etc/sv/$SERVICE /var/service/
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac

}

serv_enable()
{
	__serv_enable "$1" || return
	# start if need
	is_service_running $1 && info "Service $1 is already running" && return
	serv_start $1
}

# File bin/serv-list:

serv_list()
{
	case $SERVICETYPE in
		service-upstart)
			sudocmd initctl list
			;;
		service-update)
			sudocmd service --status-all
			;;
		systemd)
			sudocmd systemctl list-units $@
			;;
		*)
			for i in $(serv_list_all) ; do
				is_service_running $i >/dev/null && echo $i
			done
			;;
	esac
}

# File bin/serv-list_all:

serv_list_all()
{
	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			# service --status-all for Ubuntu/Fedora
			sudocmd chkconfig --list | cut -f1

			if [ -n "$ANYSERVICE" ] ; then
				sudocmd anyservice --quiet list
				return
			fi
			;;
		service-initd|service-update)
			sudocmd ls $INITDIR/ | grep -v README
			;;
		systemd)
			sudocmd systemctl list-unit-files $@
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-list_startup:

serv_list_startup()
{
	case $SERVICETYPE in
		*)
			for i in $(serv_list_all | cut -f 1 -d" " | grep "\.service$") ; do
				is_service_autostart >/dev/null $i && echo $i
			done
			;;

	esac
}

# File bin/serv-log:

__serv_log_altlinux()
{
	local SERVICE="$1"

	case "$SERVICE" in
		postfix)
			sudocmd tail -f /var/log/mail/all /var/log/mail/errors
			;;
		cups)
			sudocmd tail -f /var/log/cups/access_log /var/log/cups/error_log
			;;
		fail2ban)
			sudocmd tail -f /var/log/$SERVICE.log
			;;
		*)
			fatal "Have no suitable for $SERVICE service"
			;;
	esac
}

serv_log()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		systemd)
			sudocmd journalctl -f -b -u "$SERVICE" "$@"
			;;
		*)
			case $DISTRNAME in
			ALTLinux)
				__serv_log_altlinux "$SERVICE"
				return ;;
			*)
				fatal "Have no suitable for $DISTRNAME command for $SERVICETYPE"
				;;
			esac
	esac
}

# File bin/serv-print:

serv_print()
{
	echo "Detected init system: $SERVICETYPE"
	[ -n "$ANYSERVICE" ] && echo "anyservice is detected too"
}

# File bin/serv-reload:


serv_reload()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE reload
				return
			fi
			sudocmd service $SERVICE reload "$@"
			;;
		service-initd|service-update)
			sudocmd $INITDIR/$SERVICE reload "$@"
			;;
		systemd)
			sudocmd systemctl reload $SERVICE "$@"
			;;
		*)
			info "Fallback to restart..."
			serv_restart "$SERVICE" "$@"
			;;
	esac
}

# File bin/serv-restart:


serv_restart()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE restart
				return
			fi
			sudocmd service $SERVICE restart "$@"
			;;
		service-initd|service-update)
			sudocmd $INITDIR/$SERVICE restart "$@"
			;;
		systemd)
			sudocmd systemctl restart $SERVICE "$@"
			;;
		runit)
			sudocmd sv restart "$SERVICE"
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-start:

serv_start()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE start
				return
			fi
			sudocmd service $SERVICE start "$@"
			;;
		service-initd|service-update)
			sudocmd $INITDIR/$SERVICE start "$@"
			;;
		systemd)
			sudocmd systemctl start "$SERVICE" "$@"
			;;
		runit)
			sudocmd sv up "$SERVICE"
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-status:

is_service_running()
{
	local SERVICE="$1"

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $1 ; then
				$SUDO anyservice $1 status >/dev/null
				return
			fi
			$SUDO service $1 status >/dev/null
			;;
		service-initd|service-update)
			$SUDO $INITDIR/$1 status >/dev/null
			;;
		systemd)
			$SUDO systemctl status $1 >/dev/null
			;;
		runit)
			$SUDO sv status "$SERVICE" >/dev/null
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

is_service_autostart()
{
	local SERVICE="$1"

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE; then
				$ANYSERVICE $SERVICE isautostarted
				return
			fi

			# FIXME: check for current runlevel
			LANG=C $SUDO chkconfig $1 --list | grep -q "[35]:on"
			;;
		service-initd|service-update)
                        test -L $(echo /etc/rc5.d/S??$1)
			;;
		systemd)
			$SUDO systemctl is-enabled $1
			;;
		runit)
			test -L /var/service/$SERVICE
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

serv_status()
{
	is_service_autostart $1 && echo "Service $1 is scheduled to run on startup" || echo "Service $1 will NOT run on startup"

	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE status
				return
			fi
			sudocmd service $SERVICE status "$@"
			;;
		service-update)
			sudocmd $INITDIR/$SERVICE status "$@"
			;;
		systemd)
			sudocmd systemctl status $SERVICE "$@"
			;;
		runit)
			sudocmd sv status "$SERVICE"
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-stop:

serv_stop()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $SERVICE ; then
				sudocmd anyservice $SERVICE stop
				return
			fi
			sudocmd service $SERVICE stop "$@"
			;;
		service-initd|service-update)
			sudocmd $INITDIR/$SERVICE stop "$@"
			;;
		systemd)
			sudocmd systemctl stop $SERVICE "$@"
			;;
		runit)
			sudocmd sv down "$SERVICE"
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-try_restart:


serv_try_restart()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		systemd)
			sudocmd systemctl try-restart $SERVICE "$@"
			;;
		*)
			info "Fallback to restart..."
			is_service_running $SERVICE || { info "Service $SERVICE is not running, restart skipping…" ; return 0 ; }
			serv_restart "$SERVICE" "$@"
			;;
	esac
}

# File bin/serv-usage:

_print_additional_usage()
{
	echo "serv addition usage: {on|off|try-restart|usage}"
}

serv_usage()
{
	local SERVICE="$1"
	shift
	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			# CHECKME: many services print out usage in stderr, it conflicts with printout command
			#sudocmd service $SERVICE 2>&1
			$SUDO service $SERVICE 2>&1
			;;
		service-initd|service-update)
			#sudocmd /etc/init.d/$SERVICE 2>&1
			$SUDO service $SERVICE 2>&1
			;;
		systemd)
			sudocmd systemctl $SERVICE 2>&1
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac

_print_additional_usage

}

internal_distr_info()
{
# Author: Vitaly Lipatov <lav@etersoft.ru>
# 2007, 2009, 2010, 2012, 2016 (c) Etersoft
# 2007-2016 Public domain

# Detect the distro and version
# Welcome to send updates!

# You can set ROOTDIR to root system dir
#ROOTDIR=

# Check for DISTRO specific file in /etc
distro()
{
	#[ -n "$ROOTDIR" ] || return
	# fill global DISTROFILE
	DISTROFILE="$ROOTDIR/etc/$1"
	[ -f "$DISTROFILE" ]
}

# Has a distro file the specified word?
has()
{
	[ -n "$DISTROFILE" ] || exit 1
	grep "$*" "$DISTROFILE" >/dev/null 2>&1
}

# Translate DISTRIB_ID to vendor name (like %_vendor does)
rpmvendor()
{
	[ "$DISTRIB_ID" = "ALTLinux" ] && echo "alt" && return
	[ "$DISTRIB_ID" = "AstraLinux" ] && echo "astra" && return
	[ "$DISTRIB_ID" = "LinuxXP" ] && echo "lxp" && return
	[ "$DISTRIB_ID" = "TinyCoreLinux" ] && echo "tcl" && return
	[ "$DISTRIB_ID" = "VoidLinux" ] && echo "void" && return
	echo "$DISTRIB_ID" | tr "[A-Z]" "[a-z]"
}

# Translate DISTRIB_ID name to package manner (like in the package release name)
pkgvendor()
{
	[ "$DISTRIB_ID" = "Mandriva" ] && echo "mdv" && return
	rpmvendor
}

# Print pkgtype (need DISTRIB_ID var)
pkgtype()
{
    case `pkgvendor` in
		freebsd) echo "tbz" ;;
		sunos) echo "pkg.gz" ;;
		slackware|mopslinux) echo "tgz" ;;
		archlinux) echo "pkg.tar.xz" ;;
		gentoo) echo "tbz2" ;;
		windows) echo "exe" ;;
		android) echo "apk" ;;
		alpine) echo "apk" ;;
		tinycorelinux) echo "tcz" ;;
		voidlinux) echo "xbps" ;;
		cygwin) echo "tar.xz" ;;
		debian|ubuntu|mint|runtu|mcst|astra) echo "deb" ;;
		alt|asplinux|suse|mandriva|rosa|mandrake|pclinux|sled|sles)
			echo "rpm" ;;
		fedora|redhat|scientific|centos|rhel|goslinux)
			echo "rpm" ;;
		*)  echo "rpm" ;;
	esac
}

get_var()
{
	# get first variable and print it out, drop quotes if exists
	grep -i "^$1 *=" | head -n 1 | sed -e "s/^[^=]*[ \t]*=[ \t]*//" | sed -e "s/^[\'\"]\(.*\)[\'\"]/\1/"
}

# 2010.1 -> 2010
get_major_version()
{
	echo "$1" | sed -e "s/\..*//g"
}

# Default values
DISTRIB_ID="Generic"
DISTRIB_RELEASE=""
DISTRIB_CODENAME=""

# Default with LSB
if distro lsb-release ; then
	DISTRIB_ID=`cat $DISTROFILE | get_var DISTRIB_ID`
	DISTRIB_RELEASE=`cat $DISTROFILE | get_var DISTRIB_RELEASE`
	DISTRIB_CODENAME=`cat $DISTROFILE | get_var DISTRIB_CODENAME`
fi

# ALT Linux based
if distro altlinux-release ; then
	DISTRIB_ID="ALTLinux"
	if has Sisyphus ; then DISTRIB_RELEASE="Sisyphus"
	elif has "ALT Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux 8." ; then DISTRIB_RELEASE="p8"
	elif has "ALT .*8.[0-9]" ; then DISTRIB_RELEASE="p8"
	elif has "Simply Linux 6." ; then DISTRIB_RELEASE="p6"
	elif has "Simply Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "Simply Linux 8." ; then DISTRIB_RELEASE="p8"
	elif has "ALT Linux 6." ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p8"  ; then DISTRIB_RELEASE="p8"
	elif has "ALT Linux p7"  ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux p6"  ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p5"  ; then DISTRIB_RELEASE="p5"
	elif has "ALT Linux 5.1" ; then DISTRIB_RELEASE="5.1"
	elif has "ALT Linux 5.0" ; then DISTRIB_RELEASE="5.0"
	elif has "ALT Linux 4.1" ; then DISTRIB_RELEASE="4.1"
	elif has "ALT Linux 4.0" ; then DISTRIB_RELEASE="4.0"
	elif has Walnut          ; then DISTRIB_RELEASE="4.0"
	elif has 20070810 ; then DISTRIB_RELEASE="4.0"
	elif has Ajuga    ; then DISTRIB_RELEASE="4.0"
	elif has 20050723 ; then DISTRIB_RELEASE="3.0"
	elif has Citron   ; then DISTRIB_RELEASE="2.4"
	fi

elif distro gentoo-release ; then
	DISTRIB_ID="Gentoo"
	MAKEPROFILE=$(readlink $ROOTDIR/etc/portage/make.profile 2>/dev/null) || MAKEPROFILE=$(readlink $ROOTDIR/etc/make.profile)
	DISTRIB_RELEASE=`basename $MAKEPROFILE`
	echo $DISTRIB_RELEASE | grep -q "[0-9]" || DISTRIB_RELEASE=`basename $(dirname $MAKEPROFILE)`

# Slackware based
elif distro mopslinux-version ; then
	DISTRIB_ID="MOPSLinux"
	if   has 4.0 ; then DISTRIB_RELEASE="4.0"
	elif has 5.0 ; then DISTRIB_RELEASE="5.0"
	elif has 5.1 ; then DISTRIB_RELEASE="5.1"
	elif has 6.0 ; then DISTRIB_RELEASE="6.0"
	elif has 6.1 ; then DISTRIB_RELEASE="6.1"
	fi
elif distro slackware-version ; then
	DISTRIB_ID="Slackware"
	DISTRIB_RELEASE="$(grep -Eo [0-9]+\.[0-9]+ $DISTROFILE)"

elif distro os-release && which apk 2>/dev/null >/dev/null ; then
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="$ID"
	DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && which tce-ab 2>/dev/null >/dev/null ; then
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="TinyCoreLinux"
	DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && which xbps-query 2>/dev/null >/dev/null ; then
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="VoidLinux"
	DISTRIB_RELEASE="Live"

elif distro arch-release ; then
	DISTRIB_ID="ArchLinux"
	DISTRIB_RELEASE="2010"
	if grep 2011 -q $ROOTDIR/etc/pacman.d/mirrorlist ; then
		DISTRIB_RELEASE="2011"
	fi

elif distro mcst_version ; then
	DISTRIB_ID="MCST"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "release" | sed -e "s|.*release \([0-9]*\).*|\1|g")

elif distro astra_version ; then
	#DISTRIB_ID=`cat $DISTROFILE | get_var DISTRIB_ID`
	DISTRIB_ID="AstraLinux"
	#DISTRIB_RELEASE=$(cat "$DISTROFILE" | head -n1 | sed -e "s|.* \([a-z]*\).*|\1|g")
	DISTRIB_RELEASE=$DISTRIB_CODENAME

# for Ubuntu use standard LSB info
elif [ "$DISTRIB_ID" = "Ubuntu" ] && [ -n "$DISTRIB_RELEASE" ]; then
	# use LSB version
	true

# Debian based
elif distro debian_version ; then
	DISTRIB_ID="Debian"
	DISTRIB_RELEASE=$(cat $DISTROFILE | sed -e "s/\..*//g")


# Mandriva based
elif distro pclinuxos-release ; then
	DISTRIB_ID="PCLinux"
	if   has "2007" ; then DISTRIB_RELEASE="2007"
	elif has "2008" ; then DISTRIB_RELEASE="2008"
	elif has "2010" ; then DISTRIB_RELEASE="2010"
	fi

elif distro mandriva-release || distro mandrake-release ; then
	DISTRIB_ID="Mandriva"
	if   has 2005 ; then DISTRIB_RELEASE="2005"
	elif has 2006 ; then DISTRIB_RELEASE="2006"
	elif has 2007 ; then DISTRIB_RELEASE="2007"
	elif has 2008 ; then DISTRIB_RELEASE="2008"
	elif has 2009.0 ; then DISTRIB_RELEASE="2009.0"
	elif has 2009.1 ; then DISTRIB_RELEASE="2009.1"
	else
		# use /etc/lsb-release info by default
		if has ROSA ; then
			DISTRIB_ID="ROSA"
		fi
	fi

# Fedora based
elif distro linux-xp-release || distro lxp-release; then
	DISTRIB_ID="LinuxXP"
	if has "Attack of the Clones" ; then DISTRIB_RELEASE="2006"
	elif has "2007" ; then DISTRIB_RELEASE="2007"
	elif has "2008" ; then DISTRIB_RELEASE="2008"
	elif has "2009" ; then DISTRIB_RELEASE="2009"
	fi

elif distro asplinux-release ; then
	DISTRIB_ID="ASPLinux"
	if   has Karelia ; then DISTRIB_RELEASE="10"
	elif has Seliger ; then DISTRIB_RELEASE="11"
	elif has "11.1" ; then DISTRIB_RELEASE="11.1"
	elif has Ladoga ; then DISTRIB_RELEASE="11.2"
	elif has "11.2" ; then DISTRIB_RELEASE="11.2"
	elif has "12" ; then DISTRIB_RELEASE="12"
	elif has "13" ; then DISTRIB_RELEASE="13"
	elif has "14" ; then DISTRIB_RELEASE="14"
	elif has "15" ; then DISTRIB_RELEASE="15"
	fi

elif distro MCBC-release ; then
	DISTRIB_ID="MCBC"
	if   has 3.0 ; then DISTRIB_RELEASE="3.0"
	elif has 3.1 ; then DISTRIB_RELEASE="3.1"
	fi

elif distro fedora-release ; then
	DISTRIB_ID="Fedora"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "release" | sed -e "s|.*release \([0-9]*\).*|\1|g")

elif distro redhat-release ; then
	# FIXME if need
	# actually in the original RHEL: Red Hat Enterprise Linux .. release N
	DISTRIB_ID="RHEL"
	if has CentOS ; then
		DISTRIB_ID="CentOS"
	elif has Scientific ; then
		DISTRIB_ID="Scientific"
	elif has GosLinux ; then
		DISTRIB_ID="GosLinux"
	fi
	if has Beryllium ; then
		DISTRIB_ID="Scientific"
		DISTRIB_RELEASE="4.1"
	elif has Shrike ; then
		DISTRIB_ID="RedHat"
		DISTRIB_RELEASE="9"
	elif has Taroon ; then 	DISTRIB_RELEASE="3"
	elif has "release 4" ; then DISTRIB_RELEASE="4"
	elif has "release 5" ; then DISTRIB_RELEASE="5"
	elif has "release 6" ; then DISTRIB_RELEASE="6"
	elif has "release 7" ; then DISTRIB_RELEASE="7"
	fi

# SUSE based
elif distro SuSe-release || distro SuSE-release ; then
	DISTRIB_ID="SUSE"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "VERSION" | sed -e "s|^VERSION = ||g")
	if   has "SUSE Linux Enterprise Desktop" ; then
		DISTRIB_ID="SLED"
	elif has "SUSE Linux Enterprise Server" ; then
		DISTRIB_ID="SLES"
	fi

# fixme: can we detect by some file?
elif [ `uname` = "FreeBSD" ] ; then
	DISTRIB_ID="FreeBSD"
	UNAME=$(uname -r)
	DISTRIB_RELEASE=$(echo "$UNAME" | grep RELEASE | sed -e "s|\([0-9]\.[0-9]\)-RELEASE|\1|g")

# fixme: can we detect by some file?
elif [ `uname` = "SunOS" ] ; then
	DISTRIB_ID="SunOS"
	DISTRIB_RELEASE=$(uname -r)

# fixme: can we detect by some file?
elif [ `uname -s 2>/dev/null` = "Darwin" ] ; then
	DISTRIB_ID="MacOS"
	DISTRIB_RELEASE=$(uname -r)

# fixme: move to up
elif [ `uname` = "Linux" ] && which guix 2>/dev/null >/dev/null ; then
	DISTRIB_ID="GNU/Linux/Guix"
	DISTRIB_RELEASE=$(uname -r)

# fixme: move to up
elif [ `uname` = "Linux" ] && [ -x $ROOTDIR/system/bin/getprop ] ; then
	DISTRIB_ID="Android"
	DISTRIB_RELEASE=$(getprop | awk -F": " '/build.version.release/ { print $2 }' | tr -d '[]')

elif [ `uname -o 2>/dev/null` = "Cygwin" ] ; then
        DISTRIB_ID="Cygwin"
        DISTRIB_RELEASE="all"

# try use standart LSB info by default
elif distro lsb-release && [ -n "$DISTRIB_RELEASE" ]; then
	# use LSB

	# fix distro name
	case "$DISTRIB_ID" in
		"openSUSE Tumbleweed")
			DISTRIB_ID="Tumbleweed"
			;;
	esac
fi

case $1 in
	-p)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		pkgtype
		exit 0
		;;
	-h)
		echo "distr_vendor - system name and version detection"
		echo "Usage: distr_vendor [options] [args]"
		echo "-p [SystemName] - print type of packaging system"
		echo "-d - print distro name"
		echo "-v - print version of distro"
		echo "-e - print full name of distro with version (by default)"
		echo "-s [SystemName] - print name of distro for build system (like in the package release name)"
		echo "-n [SystemName] - print vendor name (as _vendor macros in rpm)"
		echo "-V - print the version of $0"
		echo "-h - this help"
		exit 0
		;;
	-d)
		echo $DISTRIB_ID
		;;
	-v)
		echo $DISTRIB_RELEASE
		;;
	-s)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		pkgvendor
		exit 0
		;;
	-n)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		rpmvendor
		exit 0
		;;
	-V)
		echo "20161212"
		exit 0
		;;
	*)
		# if run without args, just printout Name/Version of the current system
		[ -n "$DISTRIB_RELEASE" ] && echo $DISTRIB_ID/$DISTRIB_RELEASE || echo $DISTRIB_ID
		;;
esac

}

internal_tools_eget()
{
# eget - simply shell on wget for loading directories over http
# Example use:
# eget ftp://ftp.altlinux.ru/pub/security/ssl/*
#
# Copyright (C) 2014-2014, 2016  Etersoft
# Copyright (C) 2014 Daniil Mikhailov <danil@etersoft.ru>
# Copyright (C) 2016 Vitaly Lipatov <lav@etersoft.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

WGET="wget"

if [ "$1" = "-q" ] ; then
    WGET="wget -q"
    shift
fi

# TODO:
# download to this file
WGET_OPTION_TARGET=
if [ "$1" = "-O" ] ; then
    TARGETFILE="$2"
    WGET_OPTION_TARGET="-O $2"
    shift 2
fi

# TODO:
# -P support

# If ftp protocol or have no asterisk, just download
# TODO: use has()
if echo "$1" | grep -q "\(^ftp://\|[^*]\)" ; then
    $WGET $WGET_OPTION_TARGET "$1"
    return
fi

echo "Fall to http workaround"

URL=$(echo "$1" | grep "/$" || dirname "$1")
# mask allowed only in last part of path
MASK=$(basename "$1")

get_index()
{
    MYTMPDIR="$(mktemp -d)"
    INDEX=$MYTMPDIR/index
    $WGET $URL -O $INDEX
}

print_files()
{
    cat $INDEX | grep -o -E 'href="([^\*/"#]+)"' | cut -d'"' -f2
}

create_fake_files()
{
    DIRALLFILES="$MYTMPDIR/files/"
    mkdir -p "$DIRALLFILES"

    print_files | while read line ; do
        touch $DIRALLFILES/$(basename "$line")
    done
}

download_files()
{
    ERROR=0
    for line in $DIRALLFILES/$MASK ; do
        $WGET $URL/$(basename "$line") || ERROR=1
    done
    return $ERROR
}

get_index || return
create_fake_files
download_files || echo "There was some download errors" >&2
rm -rf "$MYTMPDIR"
}

internal_tools_json()
{

# License: MIT or Apache
# Homepage: http://github.com/dominictarr/JSON.sh

throw() {
  echo "$*" >&2
  exit 1
}

BRIEF=0
LEAFONLY=0
PRUNE=0
NO_HEAD=0
NORMALIZE_SOLIDUS=0

usage() {
  echo
  echo "Usage: JSON.sh [-b] [-l] [-p] [-s] [-h]"
  echo
  echo "-p - Prune empty. Exclude fields with empty values."
  echo "-l - Leaf only. Only show leaf nodes, which stops data duplication."
  echo "-b - Brief. Combines 'Leaf only' and 'Prune empty' options."
  echo "-n - No-head. Do not show nodes that have no path (lines that start with [])."
  echo "-s - Remove escaping of the solidus symbol (straight slash)."
  echo "-h - This help text."
  echo
}

parse_options() {
  set -- "$@"
  local ARGN=$#
  while [ "$ARGN" -ne 0 ]
  do
    case $1 in
      -h) usage
          exit 0
      ;;
      -b) BRIEF=1
          LEAFONLY=1
          PRUNE=1
      ;;
      -l) LEAFONLY=1
      ;;
      -p) PRUNE=1
      ;;
      -n) NO_HEAD=1
      ;;
      -s) NORMALIZE_SOLIDUS=1
      ;;
      ?*) echo "ERROR: Unknown option."
          usage
          exit 0
      ;;
    esac
    shift 1
    ARGN=$((ARGN-1))
  done
}

awk_egrep () {
  local pattern_string=$1

  gawk '{
    while ($0) {
      start=match($0, pattern);
      token=substr($0, start, RLENGTH);
      print token;
      $0=substr($0, start+RLENGTH);
    }
  }' pattern="$pattern_string"
}

tokenize () {
  local GREP
  local ESCAPE
  local CHAR

  if echo "test string" | egrep -ao --color=never "test" >/dev/null 2>&1
  then
    GREP='egrep -ao --color=never'
  else
    GREP='egrep -ao'
  fi

  if echo "test string" | egrep -o "test" >/dev/null 2>&1
  then
    ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\]'
  else
    GREP=awk_egrep
    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\\\]'
  fi

  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'

  # Force zsh to expand $A into multiple words
  local is_wordsplit_disabled=$(unsetopt 2>/dev/null | grep -c '^shwordsplit$')
  if [ $is_wordsplit_disabled != 0 ]; then setopt shwordsplit; fi
  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
  if [ $is_wordsplit_disabled != 0 ]; then unsetopt shwordsplit; fi
}

parse_array () {
  local index=0
  local ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :
      do
        parse_value "$1" "$index"
        index=$((index+1))
        ary="$ary""$value" 
        read -r token
        case "$token" in
          ']') break ;;
          ',') ary="$ary," ;;
          *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=$(printf '[%s]' "$ary") || value=
  :
}

parse_object () {
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :
      do
        case "$token" in
          '"'*'"') key=$token ;;
          *) throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "$token" in
          ':') ;;
          *) throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        parse_value "$1" "$key"
        obj="$obj$key:$value"        
        read -r token
        case "$token" in
          '}') break ;;
          ',') obj="$obj," ;;
          *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=$(printf '{%s}' "$obj") || value=
  :
}

parse_value () {
  local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
  case "$token" in
    '{') parse_object "$jpath" ;;
    '[') parse_array  "$jpath" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[!0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
    *) value=$token
       # if asked, replace solidus ("\/") in json strings with normalized value: "/"
       [ "$NORMALIZE_SOLIDUS" -eq 1 ] && value=$(echo "$value" | sed 's#\\/#/#g')
       isleaf=1
       [ "$value" = '""' ] && isempty=1
       ;;
  esac
  [ "$value" = '' ] && return
  [ "$NO_HEAD" -eq 1 ] && [ -z "$jpath" ] && return

  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && \
    [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1
  [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value"
  :
}

parse () {
  read -r token
  parse_value
  read -r token
  case "$token" in
    '') ;;
    *) throw "EXPECTED EOF GOT $token" ;;
  esac
}

if ([ "$0" = "$BASH_SOURCE" ] || ! [ -n "$BASH_SOURCE" ]);
then
  parse_options "$@"
  tokenize | parse
fi

# vi: expandtab sw=2 ts=2
}

INITDIR=/etc/init.d

PATH=$PATH:/sbin:/usr/sbin

set_sudo

check_tty

#############################

# FIXME: detect by real init system
# FIXME: add upstart support (Ubuntu?)
set_service_type()
{
	local CMD

	# Fill for use: PMTYPE, DISTRNAME, DISTRVERSION, PKGFORMAT, PKGVENDOR, RPMVENDOR
	DISTRVENDOR=internal_distr_info
	[ -n "$DISTRNAME" ] || DISTRNAME=$($DISTRVENDOR -d) || fatal "Can't get distro name."
	[ -n "$DISTRVERSION" ] || DISTRVERSION=$($DISTRVENDOR -v)
	set_target_pkg_env

case $DISTRNAME in
	ALTLinux)
		CMD="service-chkconfig"
		;;
	Ubuntu|Debian|Mint|AstraLinux)
		CMD="service-update"
		;;
	Mandriva|ROSA)
		CMD="service-chkconfig"
		;;
#	FreeBSD)
#		CMD="pkg_add"
#		;;
#	Gentoo)
#		CMD="emerge"
#		;;
#	ArchLinux)
#		CMD="pacman"
#		;;
	Fedora|LinuxXP|ASPLinux|CentOS|RHEL|Scientific|GosLinux)
		CMD="service-chkconfig"
		;;
	VoidLinux)
		CMD="runit"
		;;
	Slackware)
		CMD="service-initd"
		;;
	SUSE|SLED|SLES|Tumbleweed)
		CMD="service-chkconfig"
		;;
#	Windows)
#		CMD="chocolatey"
#		;;
	*)
		fatal "Have no suitable DISTRNAME $DISTRNAME yet"
		;;
esac

# Note: force systemd using if active
is_active_systemd && CMD="systemd"

# override system control detection result
[ -n "$FORCESERVICE" ] && CMD=$FORCESERVICE

SERVICETYPE=$CMD

ANYSERVICE=$(which anyservice 2>/dev/null)

}

# TODO: done it on anyservice part
is_anyservice()
{
	[ -n "$ANYSERVICE" ] || return
	[ -n "$1" ] || return
	# check if anyservice is exists and checkd returns true
	$ANYSERVICE "$1" checkd 2>/dev/null
}


phelp()
{
	echo "$Descr
$Usage
 Commands:
$(get_help HELPCMD)

 Options:
$(get_help HELPOPT)
"
}

print_version()
{
        echo "Service manager version 2.0.4"
        echo "Running on $($DISTRVENDOR) with $SERVICETYPE"
        echo "Copyright (c) Etersoft 2012, 2013, 2016"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}

progname="${0##*/}"

Usage="Usage: $progname [options] [<service>] [<command>] [params]..."
Descr="serv - Service manager"

set_service_type

verbose=
quiet=
non_interactive=
show_command_only=
serv_cmd=
service_name=
params=
withoutservicename=

check_command()
{
    # do not override command
    [ -z "$serv_cmd" ] || return

    case $1 in
    status)                   # HELPCMD: show service status
        serv_cmd=status
        ;;
    usage)                    # HELPCMD: print out usage of the service
        serv_cmd=usage
        withoutservicename=1
        ;;
    restart)                 # HELPCMD: restart service
        serv_cmd=restart
        ;;
    reload)                  # HELPCMD: reload service
        serv_cmd=reload
        ;;
    start)                    # HELPCMD: start service
        serv_cmd=start
        ;;
    try-restart|condrestart)  # HELPCMD: Restart service if running
        serv_cmd=try_restart
        ;;
    stop)                     # HELPCMD: stop service
        serv_cmd=stop
        ;;
    list)                     # HELPCMD: list running services
        serv_cmd=list
        withoutservicename=1
        ;;
    list-all)                 # HELPCMD: list all available services
        serv_cmd=list_all
        withoutservicename=1
        ;;
    list-startup)             # HELPCMD: list all services to run on startup
        serv_cmd=list_startup
        withoutservicename=1
        ;;
    on|enable)                # HELPCMD: add service to run on startup and start it now
        serv_cmd=enable
        ;;
    off|disable)              # HELPCMD: remove service to run on startup and stop it now
        serv_cmd=disable
        ;;
    print)                    # HELPCMD: print some info
        serv_cmd=print
        withoutservicename=1
        ;;
    log|journal)              # HELPCMD: print log for the service
        serv_cmd=log
        ;;
    *)
        return 1
        ;;
    esac
    return 0
}

check_option()
{
    case $1 in
    -h|--help|help)       # HELPOPT: this help
        phelp
        exit 0
        ;;
    -v|--version)         # HELPOPT: print version
        print_version
        exit 0
        ;;
    --verbose)            # HELPOPT: verbose mode
        verbose=1
        ;;
    --show-command-only)  # HELPOPT: show command only, do not any action
        show_command_only=1
        ;;
    --quiet)              # HELPOPT: quiet mode (do not print commands before exec)
        quiet=1
        ;;
    --auto)               # HELPOPT: non interactive mode
        non_interactive=1
        ;;
    *)
        return 1
        ;;
    esac
    return 0
}

for opt in "$@" ; do
    check_command $opt && continue
    check_option $opt && continue
    [ -z "$service_name" ] && service_name=$opt && continue
    params="$params $opt"
done

echover "service: $service_name"
echover "command: $serv_cmd"

# Just printout help if run without args
if [ -z "$withoutservicename" ] && [ -z "$service_name" ] ; then
    print_version
    echo
    fatal "Run $ $progname --help for get help"
fi

# use common way if the command is unknown
if [ -z "$serv_cmd" ] ; then
    serv_cmd=common
fi

# Run helper for command
serv_$serv_cmd $service_name $params
# return last error code (from subroutine)
