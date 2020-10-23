#!/bin/sh
#
# Copyright (C) 2012-2013, 2016, 2020  Etersoft
# Copyright (C) 2012-2013, 2016, 2020  Vitaly Lipatov <lav@etersoft.ru>
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
	#tty -s 2>/dev/null
	test -t 0
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
	if grep -E --help 2>&1 | grep -q -- "--color" ; then
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
	/bin/echo -n "$*"
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
		echo " $PROMTSIG $*"
		restore_color
	fi >&2
}

docmd()
{
	showcmd "$*$EXTRA_SHOWDOCMD"
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
	[ -n "$SUDO" ] && showcmd "$SUDO $*" || showcmd "$*"
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
	eval "lastarg=\${$#}"
	echon "$lastarg"
}

isnumber()
{
	echo "$*" | filter_strip_spaces | grep -q "^[0-9]\+$"
}

rhas()
{
	echo "$1" | grep -E -q -- "$2"
}

is_dirpath()
{
    [ "$1" = "." ] && return $?
    rhas "$1" "/"
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
    ( LANG=C $@ 2>&1 ; echo $? >$CMDSTATUS ) | tee $RC_STDOUT
    return "$(cat $CMDSTATUS)"
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
	$PROGDIR/$PROGNAME --inscript $@
}

fatal()
{
	if [ -z "$TEXTDOMAIN" ] ; then
		echo "Error: $*" >&2
	fi
	exit 1
}

warning()
{
	if [ -z "$TEXTDOMAIN" ] ; then
		echo "Warning: $*" >&2
	fi
}

info()
{
	[ -n "$quiet" ] && return

	# print message to stderr if stderr forwarded to (a file)
	if isatty2 ; then
		isatty || return 0
		echo "$*"
	else
		echo "$*" >&2
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

	EFFUID=$(id -u)

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
		$TO "$@"
		return
	fi
	# fallback: drop time arg and run without timeout
	shift
	"$@"
}

set_eatmydata()
{
	# skip if disabled
	[ -n "$EPMNOEATMYDATA" ] && return
	# use if possible
	which eatmydata >/dev/null 2>/dev/null || return
	[ -n "$SUDO" ] && SUDO="$SUDO eatmydata" || SUDO="eatmydata"
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
	( direct='' epm_assure "$1" $package $3 ) || fatal "Can't assure in '$1' command from $package$textpackage package"
}

__set_EGET()
{
	# use internal eget only if exists
	if [ -s $SHAREDIR/tools_eget ] ; then
		export EGET="$SHAREDIR/tools_eget"
		return
	fi

	# FIXME: we need disable output here, eget can be used for get output
	assure_exists eget >/dev/null
	# use external command, not the function
	export EGET="$(which eget)" || fatal "Missed command eget from installed package eget"
}

disabled_eget()
{
	local EGET
	# use internal eget only if exists
	if [ -s $SHAREDIR/tools_eget ] ; then
		$SHAREDIR/tools_eget "$@"
		return
	fi

	# FIXME: we need disable output here, eget can be used for get output
	assure_exists eget >/dev/null
	# run external command, not the function
	EGET=$(which eget) || fatal "Missed command eget from installed package eget"
	$EGET "$@"
}

disabled_estrlist()
{
	if [ -s $SHAREDIR/tools_estrlist ] ; then
		$SHAREDIR/tools_estrlist "$@"
		return
	fi
	fatal "missed tools_estrlist"
}

estrlist()
{
	internal_tools_estrlist "$@"
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
    local F="$0"
    if [ -n "$2" ] ; then
        is_dirpath "$2" && F="$2" || F="$(dirname $0)/$2"
    fi

    cat "$F" | grep -- "# $1" | while read -r n ; do
        if echo "$n" | grep -q "# $1: PART: " ; then
            echo
            echo "$n" | sed -e "s|# $1: PART: ||"
            continue
        fi
        echo "$n" | grep -q "^ *#" && continue
        opt="$(echo $n | sed -e "s|) # $1:.*||g" -e 's|"||g' -e 's@^|@@')" #"
        desc="$(echo $n | sed -e "s|.*) # $1:||g")" #"
        printf "    %-20s %s\n" $opt "$desc"
    done
}


set_pm_type()
{
	local CMD

	# use external distro_info if internal one is missed
	DISTRVENDOR=internal_distr_info
	[ -x $DISTRVENDOR ] || DISTRVENDOR=internal_distr_info
	export DISTRVENDOR
	# Fill for use: PMTYPE, DISTRNAME, DISTRVERSION, PKGFORMAT, PKGVENDOR, RPMVENDOR
	[ -n "$DISTRNAME" ] || DISTRNAME=$($DISTRVENDOR -d) || fatal "Can't get distro name."
	[ -n "$DISTRVERSION" ] || DISTRVERSION=$($DISTRVENDOR -v)
	if [ -z "$DISTRARCH" ] ; then
		DISTRARCH=$($DISTRVENDOR -a)
		# TODO: translate func
		[ "$DISTRARCH" = "x86" ] && DISTRARCH="i586"
	fi
	set_target_pkg_env

if [ -n "$FORCEPM" ] ; then
	PMTYPE=$FORCEPM
	return
fi


case $DISTRNAME in
	ALTLinux)
		CMD="apt-rpm"
		#which ds-install 2>/dev/null >/dev/null && CMD=deepsolver-rpm
		#which pkcon 2>/dev/null >/dev/null && CMD=packagekit-rpm
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
	Fedora|LinuxXP|ASPLinux|CentOS|RHEL|Scientific|GosLinux|Amzn)
		CMD="dnf-rpm"
		which dnf 2>/dev/null >/dev/null || CMD=yum-rpm
		;;
	Slackware)
		CMD="slackpkg"
		;;
	SUSE|SLED|SLES)
		CMD="zypper-rpm"
		;;
	ForesightLinux|rPathLinux)
		CMD="conary"
		;;
	Windows)
		CMD="appget"
		which $CMD 2>/dev/null >/dev/null || CMD="chocolatey"
		which $CMD 2>/dev/null >/dev/null || CMD="winget"
		;;
	MacOS)
		CMD="homebrew"
		;;
	OpenWrt)
		CMD="opkg"
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
	[ "$($DISTRVENDOR -y)" = "systemd" ]
}

assure_distr()
{
	local TEXT="this option"
	[ -n "$2" ] && TEXT="$2"
	[ "$DISTRNAME" = "$1" ] || fatal "$TEXT supported only for $1 distro"
}

# File bin/serv-cat:

serv_cat()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		systemd)
			sudocmd systemctl cat "$SERVICE" "$@"
			;;
		*)
			case $DISTRNAME in
			ALTLinux)
				local INITFILE=/etc/init.d/$SERVICE
				[ -r "$INITFILE" ] || fatal "Can't find init file $INITFILE"
				docmd cat $INITFILE
				return ;;
			*)
				fatal "Have no suitable for $DISTRNAME command for $SERVICETYPE"
				;;
			esac
	esac
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
		openrc)
			sudocmd rc-update del $1 default
			;;
		runit)
			sudocmd rm -fv /var/service/$SERVICE
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-edit:

serv_edit()
{
	local SERVICE="$1"
	shift

	case $SERVICETYPE in
		systemd)
			sudocmd systemctl edit "$@" "$SERVICE"
			;;
		*)
			fatal "Have no suitable for $DISTRNAME command for $SERVICETYPE"
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
		openrc)
			sudocmd rc-update add $1 default
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
	info "Running services:"
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
		openrc)
			sudocmd rc-status
			;;
		*)
			# hack to improve list speed
			[ "$UID" = 0 ] || { sudocmd $PROGDIR/serv --quiet list ; return ; }
			for i in $(quiet=1 serv_list_all) ; do
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
			sudocmd chkconfig --list | cut -f1 | grep -v "^$" | grep -v "xinetd:$"

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
		openrc)
			sudocmd rc-service -l
			;;
		*)
			fatal "Have no suitable command for $SERVICETYPE"
			;;
	esac
}

# File bin/serv-list_failed:

serv_list_failed()
{
	case $SERVICETYPE in
		systemd)
			sudocmd systemctl --failed
			;;
		*)
			for i in $(serv_list_startup | cut -f 1 -d" ") ; do
				is_service_running >/dev/null $i && continue
				echo ; echo $i
				serv_status $i
			done
			;;

	esac
}

# File bin/serv-list_startup:

serv_list_startup()
{
	case $SERVICETYPE in
		systemd)
			#sudocmd systemctl list-unit-files
			# TODO: native command? implement --short for list (only names)
			for i in $(serv_list_all | cut -f 1 -d" " | grep "\.service$") ; do
				is_service_autostart >/dev/null $i && echo $i
			done
			;;
		*)
			for i in $(serv_list_all | cut -f 1 -d" ") ; do
				is_service_autostart >/dev/null $i && echo $i
			done
			;;

	esac
}

# File bin/serv-log:

__serv_log_altlinux()
{
	local SERVICE="$1"
	local PRG="less"
	[ "$2" = "-f" ] && PRG="tail -f"

	case "$SERVICE" in
		postfix)
			sudocmd $PRG /var/log/mail/all /var/log/mail/errors
			;;
		sshd)
			sudocmd $PRG /var/log/auth/all
			;;
		cups)
			sudocmd $PRG /var/log/cups/access_log /var/log/cups/error_log
			;;
		fail2ban)
			sudocmd $PRG /var/log/$SERVICE.log
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
			sudocmd journalctl -b -u "$SERVICE" "$@"
			;;
		*)
			case $DISTRNAME in
			ALTLinux)
				FF="" ; [ "$1" = "-f" ] && FF="-f"
				__serv_log_altlinux "$SERVICE" $FF
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
		openrc)
			sudocmd rc-service restart "$SERVICE"
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
		openrc)
			sudocmd rc-service start "$SERVICE"
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
	local OUTPUT
	# TODO: real status can be checked only with grep output
	case $SERVICETYPE in
		service-chkconfig|service-upstart)
			if is_anyservice $1 ; then
				OUTPUT="$($SUDO anyservice $1 status 2>/dev/null)" || return 1
				echo "$OUTPUT" | grep -q "is stopped" && return 1
				return 0
			fi
			OUTPUT="$($SUDO service $1 status 2>/dev/null)" || return 1
			echo "$OUTPUT" | grep -q "is stopped" && return 1
			return 0
			;;
		service-initd|service-update)
			$SUDO $INITDIR/$1 status >/dev/null 2>/dev/null
			;;
		systemd)
			$SUDO systemctl status $1 >/dev/null 2>/dev/null
			;;
		runit)
			$SUDO sv status "$SERVICE" >/dev/null 2>/dev/null
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
                        test -L "$(echo /etc/rc5.d/S??$1)"
			;;
		systemd)
			$SUDO systemctl is-enabled $1
			;;
		runit)
			test -L "/var/service/$SERVICE"
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
			sudocmd systemctl -l status $SERVICE "$@"
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
		openrc)
			sudocmd rc-service stop "$SERVICE"
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

################# incorporate bin/distr_info #################
internal_distr_info()
{
# 2007-2020 (c) Vitaly Lipatov <lav@etersoft.ru>
# 2007-2020 (c) Etersoft
# 2007-2020 Public domain

# You can set ROOTDIR to root system dir
#ROOTDIR=

PROGVERSION="20201010"

# TODO: check /etc/system-release

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

# Has a system the specified command?
hascommand()
{
	which $1 2>/dev/null >/dev/null
}

firstupper()
{
	echo "$*" | sed 's/.*/\u&/'
}

tolower()
{
	# tr is broken in busybox (checked with OpenWrt)
	#echo "$*" | tr "[:upper:]" "[:lower:]"
	echo "$*" | awk '{print tolower($0)}'
}

# Translate DISTRIB_ID to vendor name (like %_vendor does)
rpmvendor()
{
	[ "$DISTRIB_ID" = "ALTLinux" ] && echo "alt" && return
	[ "$DISTRIB_ID" = "AstraLinux" ] && echo "astra" && return
	[ "$DISTRIB_ID" = "LinuxXP" ] && echo "lxp" && return
	[ "$DISTRIB_ID" = "TinyCoreLinux" ] && echo "tcl" && return
	[ "$DISTRIB_ID" = "VoidLinux" ] && echo "void" && return
	[ "$DISTRIB_ID" = "OpenSUSE" ] && echo "suse" && return
	tolower "$DISTRIB_ID"
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
# TODO: try use generic names
    case $(pkgvendor) in
		freebsd) echo "tbz" ;;
		sunos) echo "pkg.gz" ;;
		slackware|mopslinux) echo "tgz" ;;
		archlinux|manjaro) echo "pkg.tar.xz" ;;
		gentoo) echo "tbz2" ;;
		windows) echo "exe" ;;
		android) echo "apk" ;;
		alpine) echo "apk" ;;
		tinycorelinux) echo "tcz" ;;
		voidlinux) echo "xbps" ;;
		openwrt) echo "ipk" ;;
		cygwin) echo "tar.xz" ;;
		debian|ubuntu|mint|runtu|mcst|astra) echo "deb" ;;
		alt|asplinux|suse|mandriva|rosa|mandrake|pclinux|sled|sles)
			echo "rpm" ;;
		fedora|redhat|scientific|centos|rhel|goslinux|amzn)
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
PRETTY_NAME=""
DISTRIB_ID="Generic"
DISTRIB_RELEASE=""
DISTRIB_CODENAME=""

# Default with LSB
if distro lsb-release ; then
	DISTRIB_ID=$(cat $DISTROFILE | get_var DISTRIB_ID)
	DISTRIB_RELEASE=$(cat $DISTROFILE | get_var DISTRIB_RELEASE)
	DISTRIB_CODENAME=$(cat $DISTROFILE | get_var DISTRIB_CODENAME)
	PRETTY_NAME=$(cat $DISTROFILE | get_var DISTRIB_DESCRIPTION)
fi

# ALT Linux based
if distro altlinux-release ; then
	# TODO: use os-release firsly
	DISTRIB_ID="ALTLinux"
	if has Sisyphus ; then DISTRIB_RELEASE="Sisyphus"
	elif has "ALT Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux t7." ; then DISTRIB_RELEASE="t7"
	elif has "ALT Linux 8." ; then DISTRIB_RELEASE="p8"
	elif has "ALT 8 SP " ; then DISTRIB_RELEASE="c8"
	elif has "ALT 9 SP " ; then DISTRIB_RELEASE="c9"
	elif has "ALT c8 " ; then DISTRIB_RELEASE="c8"
	elif has "ALT c8.1 " ; then DISTRIB_RELEASE="c8.1"
	elif has "ALT c8.2 " ; then DISTRIB_RELEASE="c8.2"
	elif has "ALT .*8.[0-9]" ; then DISTRIB_RELEASE="p8"
	elif has "ALT .*9.[0-9]" ; then DISTRIB_RELEASE="p9"
	elif has "ALT p9.* p9 " ; then DISTRIB_RELEASE="p9"
	elif has "Simply Linux 6." ; then DISTRIB_RELEASE="p6"
	elif has "Simply Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "Simply Linux 8." ; then DISTRIB_RELEASE="p8"
	elif has "Simply Linux 9." ; then DISTRIB_RELEASE="p9"
	elif has "ALT Linux 6." ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p8"  ; then DISTRIB_RELEASE="p8"
	elif has "ALT Linux p7"  ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux p6"  ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p5"  ; then DISTRIB_RELEASE="p5"
	elif has "ALT Linux 5.1" ; then DISTRIB_RELEASE="5.1"
	elif has "ALT Linux 5.0" ; then DISTRIB_RELEASE="5.0"
	elif has "ALT Linux 4.1" ; then DISTRIB_RELEASE="4.1"
	elif has "ALT Linux 4.0" ; then DISTRIB_RELEASE="4.0"
	elif has "starter kit"   ; then DISTRIB_RELEASE="p8"
	elif has Citron   ; then DISTRIB_RELEASE="2.4"
	fi
	PRETTY_NAME="$(cat /etc/altlinux-release)"

elif distro gentoo-release ; then
	DISTRIB_ID="Gentoo"
	MAKEPROFILE=$(readlink $ROOTDIR/etc/portage/make.profile 2>/dev/null) || MAKEPROFILE=$(readlink $ROOTDIR/etc/make.profile)
	DISTRIB_RELEASE=$(basename $MAKEPROFILE)
	echo $DISTRIB_RELEASE | grep -q "[0-9]" || DISTRIB_RELEASE=$(basename "$(dirname $MAKEPROFILE)") #"

elif distro slackware-version ; then
	DISTRIB_ID="Slackware"
	DISTRIB_RELEASE="$(grep -Eo '[0-9]+\.[0-9]+' $DISTROFILE)"

elif distro os-release && hascommand apk ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="$(firstupper "$ID")"
	DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && hascommand tce-ab ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="TinyCoreLinux"
	DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && hascommand xbps-query ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="VoidLinux"
	DISTRIB_RELEASE="Live"

elif distro arch-release ; then
	DISTRIB_ID="ArchLinux"
	DISTRIB_RELEASE="2010"
	if grep 2011 -q $ROOTDIR/etc/pacman.d/mirrorlist ; then
		DISTRIB_RELEASE="2011"
	fi

# Elbrus
elif distro mcst_version ; then
	DISTRIB_ID="MCST"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "release" | sed -e "s|.*release \([0-9]*\).*|\1|g") #"

# OpenWrt
elif distro openwrt_release ; then
	. $DISTROFILE
	DISTRIB_RELEASE=$(cat $ROOTDIR/etc/openwrt_version)

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

elif distro MCBC-release ; then
	DISTRIB_ID="MCBC"
	if   has 3.0 ; then DISTRIB_RELEASE="3.0"
	elif has 3.1 ; then DISTRIB_RELEASE="3.1"
	fi

elif distro fedora-release ; then
	DISTRIB_ID="Fedora"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "release" | sed -e "s|.*release \([0-9]*\).*|\1|g") #"

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
	elif has "release 4" ; then DISTRIB_RELEASE="4"
	elif has "release 5" ; then DISTRIB_RELEASE="5"
	elif has "release 6" ; then DISTRIB_RELEASE="6"
	elif has "release 7" ; then DISTRIB_RELEASE="7"
	elif has "release 8" ; then DISTRIB_RELEASE="8"
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

# https://www.freedesktop.org/software/systemd/man/os-release.html
elif distro os-release ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="$(firstupper "$ID")"
	DISTRIB_RELEASE="$VERSION_ID"
	[ -n "$DISTRIB_RELEASE" ] || DISTRIB_RELEASE="CUR"
	if [ "$ID" = "opensuse-leap" ] ; then
		DISTRIB_ID="SUSE"
	fi

# fixme: can we detect by some file?
elif [ "$(uname)" = "FreeBSD" ] ; then
	DISTRIB_ID="FreeBSD"
	UNAME=$(uname -r)
	DISTRIB_RELEASE=$(echo "$UNAME" | grep RELEASE | sed -e "s|\([0-9]\.[0-9]\)-RELEASE|\1|g") #"

# fixme: can we detect by some file?
elif [ "$(uname)" = "SunOS" ] ; then
	DISTRIB_ID="SunOS"
	DISTRIB_RELEASE=$(uname -r)

# fixme: can we detect by some file?
elif [ "$(uname -s 2>/dev/null)" = "Darwin" ] ; then
	DISTRIB_ID="MacOS"
	DISTRIB_RELEASE=$(uname -r)

# fixme: move to up
elif [ "$(uname)" = "Linux" ] && hascommand guix ; then
	DISTRIB_ID="GNU/Linux/Guix"
	DISTRIB_RELEASE=$(uname -r)

# fixme: move to up
elif [ "$(uname)" = "Linux" ] && [ -x $ROOTDIR/system/bin/getprop ] ; then
	DISTRIB_ID="Android"
	DISTRIB_RELEASE=$(getprop | awk -F": " '/build.version.release/ { print $2 }' | tr -d '[]')

elif [ "$(uname -o 2>/dev/null)" = "Cygwin" ] ; then
        DISTRIB_ID="Cygwin"
        DISTRIB_RELEASE="all"

# try use standart LSB info by default
elif distro lsb-release && [ -n "$DISTRIB_RELEASE" ]; then
	# use LSB

	# fix distro name
	case "$DISTRIB_ID" in
		"openSUSE Tumbleweed")
			DISTRIB_ID="SUSE"
			DISTRIB_RELEASE="Tumbleweed"
			;;
	esac
fi

get_uname()
{
    tolower $(uname $1) | tr -d " \t\r\n"
}

get_base_os_name()
{
local DIST_OS
# Resolve the os
DIST_OS="$(get_uname -s)"
case "$DIST_OS" in
    'sunos')
        DIST_OS="solaris"
        ;;
    'hp-ux' | 'hp-ux64')
        DIST_OS="hpux"
        ;;
    'darwin' | 'oarwin')
        DIST_OS="macosx"
        ;;
    'unix_sv')
        DIST_OS="unixware"
        ;;
    'freebsd' | 'openbsd' | 'netbsd')
        DIST_OS="freebsd"
        ;;
esac
echo "$DIST_OS"
}


get_arch()
{
local DIST_ARCH
# Resolve the architecture
DIST_ARCH="$(get_uname -m)"
case "$DIST_ARCH" in
    'ia32' | 'i386' | 'i486' | 'i586' | 'i686')
        DIST_ARCH="x86"
        ;;
    'amd64' | 'x86_64')
        DIST_ARCH="x86_64"
        ;;
    'ia64' | 'ia-64')
        DIST_ARCH="ia64"
        ;;
    'ip27' | 'mips')
        DIST_ARCH="mips"
        ;;
    'powermacintosh' | 'power' | 'powerpc' | 'power_pc' | 'ppc64')
        DIST_ARCH="ppc"
        ;;
    'pa_risc' | 'pa-risc')
        DIST_ARCH="parisc"
        ;;
    'sun4u' | 'sparcv9')
        DIST_ARCH="sparc"
        ;;
    '9000/800')
        DIST_ARCH="parisc"
        ;;
    armv*)
        if [ -z "$(readelf -A /proc/self/exe | grep Tag_ABI_VFP_args)" ] ; then
            DIST_ARCH="armel"
        else
            DIST_ARCH="armhf"
        fi
        ;;
esac
echo "$DIST_ARCH"
}

get_distro_arch()
{
    local arch="$(get_arch)"
    case "$(pkgtype)" in
        rpm)
            :
            ;;
        deb)
            case $arch in
                'i586')
                    arch='i386' ;;
                'x86_64')
                    arch='amd64' ;;
            esac
            ;;
    esac
    echo "$arch"
}

get_bit_size()
{
local DIST_BIT
# Check if we are running on 64bit platform, seems like a workaround for now...
DIST_BIT="$(get_uname -m)"
case "$DIST_BIT" in
    'amd64' | 'ia64' | 'x86_64' | 'ppc64')
        DIST_BIT="64"
        ;;
    'aarch64')
        DIST_BIT="64"
        ;;
    'e2k')
        DIST_BIT="64"
        ;;
#    'pa_risc' | 'pa-risc') # Are some of these 64bit? Least not all...
#       BIT="64"
#        ;;
    'sun4u' | 'sparcv9') # Are all sparcs 64?
        DIST_BIT="64"
        ;;
#    '9000/800')
#       DIST_BIT="64"
#        ;;
    *) # In any other case default to 32
        DIST_BIT="32"
        ;;
esac
echo "$DIST_BIT"
}

# TODO: check before calc
get_memory_size()
{
    local detected=""
    local DIST_OS="$(get_base_os_name)"
    case "$DIST_OS" in
        macosx)
            detected=$((`sysctl hw.memsize | sed s/"hw.memsize: "//`/1024/1024))
            ;;
        freebsd)
            detected=$((`sysctl hw.physmem | sed s/"hw.physmem: "//`/1024/1024))
            ;;
        linux)
            [ -r /proc/meminfo ] && detected=$((`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`/1024))
            ;;
        solaris)
            detected=$(prtconf | grep Memory | sed -e "s|Memory size: \([0-9][0-9]*\) Megabyte.*|\1|")
            ;;
#        *)
#            fatal "Unsupported OS $DIST_OS"
    esac

    [ -n "$detected" ] || detected=0
    echo $detected
}

print_name_version()
{
    [ -n "$DISTRIB_RELEASE" ] && echo $DISTRIB_ID/$DISTRIB_RELEASE || echo $DISTRIB_ID
}

get_core_count()
{
    local detected=""
    local DIST_OS="$(get_base_os_name)"
    case "$DIST_OS" in
        macos|freebsd)
            detected=$(sysctl hw.ncpu | awk '{print $2}')
            ;;
        linux)
            detected=$(grep -c "^processor" /proc/cpuinfo)
            ;;
        solaris)
            detected=$(prtconf | grep -c 'cpu[^s]')
            ;;
        aix)
            detected=$(lsdev -Cc processor -S A | wc -l)
            ;;
#        *)
#            fatal "Unsupported OS $DIST_OS"
    esac

    [ -n "$detected" ] || detected=0
    echo $detected
}


get_virt()
{
    local VIRT
    local SDCMD
    SDCMD=$(which systemd-detect-virt 2>/dev/null)
    if [ -n "$SDCMD" ] ; then
        VIRT="$($SDCMD)"
        [ "$VIRT" = "none" ] && echo "(host system)" && return
        [ -z "$VIRT" ] && echo "(unknown)" && return
        echo "$VIRT" && return
    fi

    # TODO: use virt-what under root

    # inspired by virt_what
    if [ -d "/proc/vz" -a ! -d "/proc/bc" ]; then
        echo "openvz" && return
    fi

    if [ -r "/sys/bus/xen" ] ; then
        echo "xen" && return
    fi

    echo "(unknown)"
    # TODO: check for openvz
}

# https://unix.stackexchange.com/questions/196166/how-to-find-out-if-a-system-uses-sysv-upstart-or-systemd-initsystem
get_service_manager()
{
    [ -d /run/systemd/system ] && echo "systemd" && return
    # TODO
    #[ -d /usr/share/upstart ] && echo "upstart" && return
    [ -d /etc/init.d ] && echo "sysvinit" && return
    echo "(unknown)"
}

print_pretty_name()
{
    echo "$PRETTY_NAME"
}

print_total_info()
{
cat <<EOF
distro_info v$PROGVERSION : Copyright © 2007-2020 Etersoft
==== Total system information:
Pretty distro name (--pretty): $(print_pretty_name)
 Distro name and version (-e): $(print_name_version)
        Packaging system (-p): $(pkgtype)
 Running service manager (-y): $(get_service_manager)
          Virtualization (-i): $(get_virt)
               CPU Cores (-c): $(get_core_count)
        CPU Architecture (-a): $(get_arch)
 CPU norm register size  (-b): $(get_bit_size)
 System memory size (MB) (-m): $(get_memory_size)
            Base OS name (-o): $(get_base_os_name)
Build system distro name (-s): $(pkgvendor)
Build system vendor name (-n): $(rpmvendor)

(run with -h to get help)
EOF
}


case $1 in
	-h)
		echo "distro_info v$PROGVERSION - distro information retriever"
		echo "Usage: distro_info [options] [args]"
		echo "Options:"
		echo " -a - print hardware architecture (--distro-arch for distro depended name)"
		echo " -b - print size of arch bit (32/64)"
		echo " -c - print number of CPU cores"
		echo " -d - print distro name"
		echo " -e - print full name of distro with version"
		echo " -i - print virtualization type"
		echo " -h - this help"
		echo " -m - print system memory size (in MB)"
		echo " -n [SystemName] - print vendor name (as _vendor macros in rpm)"
		echo " -o - print base OS name"
		echo " -p [SystemName] - print type of the packaging system"
		echo " -s [SystemName] - print name of distro for build system (like in the package release name)"
		echo " -y - print running service manager"
		echo " --pretty - print pretty distro name"
		echo " -v - print version of distro"
		echo " -V - print the utility version"
		echo "Run without args to print all information."
		exit 0
		;;
	-p)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		pkgtype
		exit 0
		;;
	--pretty)
		print_pretty_name
		;;
	--distro-arch)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		get_distro_arch
		exit 0
		;;
	-d)
		echo $DISTRIB_ID
		;;
	-a)
		get_arch
		;;
	-b)
		get_bit_size
		;;
	-c)
		get_core_count
		;;
	-i)
		get_virt
		;;
	-m)
		get_memory_size
		;;
	-o)
		get_base_os_name
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
	-y)
		get_service_manager
		;;
	-V)
		echo "$PROGVERSION"
		exit 0
		;;
	-e)
		print_name_version
		;;
	*)
		print_total_info
		;;
esac

}
################# end of incorporated bin/distr_info #################


################# incorporate bin/tools_eget #################
internal_tools_eget()
{
# eget - simply shell on wget for loading directories over http (wget does not support wildcard for http)
# Example use:
# eget http://ftp.altlinux.ru/pub/security/ssl/*
#
# Copyright (C) 2014-2014, 2016, 2020  Etersoft
# Copyright (C) 2014 Daniil Mikhailov <danil@etersoft.ru>
# Copyright (C) 2016-2017, 2020 Vitaly Lipatov <lav@etersoft.ru>
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

# TODO: passthrou all wget options
if [ "$1" = "-q" ] ; then
    WGET="wget -q"
    shift
fi

LISTONLY=''
if [ "$1" = "--list" ] ; then
    LISTONLY="$1"
    shift
fi

LATEST=''
if [ "$1" = "--latest" ] ; then
    LATEST="$1"
    shift
fi

fatal()
{
    echo "$*" >&2
    exit 1
}

# check man glob
filter_glob()
{
	[ -z "$1" ] && cat && return
	# translate glob to regexp
	grep "$(echo "$1" | sed -e "s|\*|.*|g" -e "s|?|.|g")$"
}

filter_order()
{
    [ -z "$LATEST" ] && cat && return
    sort | tail -n1
}

# download to this file
WGET_OPTION_TARGET=
if [ "$1" = "-O" ] ; then
    TARGETFILE="$2"
    WGET_OPTION_TARGET="-O $2"
    shift 2
fi

# TODO:
# -P support

if [ -z "$1" ] ; then
    echo "eget - wget wrapper" >&2
    fatal "Run with URL, like http://somesite.ru/dir/*.log"
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    echo "eget - wget wrapper, with support"
    echo "Usage: eget [-O target file] [--list] http://somesite.ru/dir/na*.log"
    echo
    echo "Options:"
    echo "    --list   - print files frm url with mask"
    echo "    --latest - print only latest version of file"
    echo
    echo "eget supports --list and download for https://github.com/owner/project urls"
    echo
    echo "See $ wget --help for wget options you can use here"
    return
fi

get_github_urls()
{
    # https://github.com/OWNER/PROJECT
    local owner="$(echo "$1" | sed -e "s|^https://github.com/||" -e "s|/.*||")" #"
    local project="$(echo "$1" | sed -e "s|^https://github.com/$owner/||" -e "s|/.*||")" #"
    [ -n "$owner" ] || fatal "Can't get owner from $1"
    [ -n "$project" ] || fatal "Can't get project from $1"
    local URL="https://api.github.com/repos/$owner/$project/releases/latest"
    local q=''
    [ -n "$LISTONLY" ] && q="-q"
    $WGET $q -O- $URL | \
        grep -i -o -E '"browser_download_url": "https://.*"' | cut -d'"' -f4
}

if echo "$1" | grep -q "^https://github.com/" ; then
    MASK="$2"

    if [ -n "$LISTONLY" ] ; then
        get_github_urls "$1" | filter_glob "$MASK" | filter_order
        return
    fi

    for fn in $(get_github_urls "$1" | filter_glob "$MASK" | filter_order) ; do
        $WGET "$fn" || ERROR=1
    done
    return
fi


# do not support /
if echo "$1" | grep -q "/$" ; then
    fatal "Use http://example.com/e/* to download all files in dir"
fi

# If ftp protocol, just download
if echo "$1" | grep -q "^ftp://" ; then
    [ -n "$LISTONLY" ] && fatal "Error: list files for ftp:// do not supported yet"
    $WGET $WGET_OPTION_TARGET "$1"
    return
fi

# drop mask part
URL="$(dirname "$1")/"

if echo "$URL" | grep -q "[*?]" ; then
    fatal "Error: there are globbing symbols (*?) in $URL"
fi

# mask allowed only in last part of path
MASK=$(basename "$1")

# If have no wildcard symbol like asterisk, just download
if echo "$MASK" | grep -qv "[*?]" ; then
    $WGET $WGET_OPTION_TARGET "$1"
    return
fi

get_urls()
{
    $WGET -O- $URL | \
        grep -i -o -E 'href="([^\*/"#]+)"' | cut -d'"' -f2
}

if [ -n "$LISTONLY" ] ; then
    WGET="$WGET -q"
    for fn in $(get_urls | filter_glob "$MASK" | filter_order) ; do
        echo "$(basename "$fn")"
    done
    return
fi

ERROR=0
for fn in $(get_urls | filter_glob "$MASK" | filter_order) ; do
    $WGET "$URL/$(basename "$fn")" || ERROR=1
done
exit $ERROR

}
################# end of incorporated bin/tools_eget #################


################# incorporate bin/tools_estrlist #################
internal_tools_estrlist()
{
#!/bin/bash
# 2009-2010, 2012, 2017, 2020 Etersoft www.etersoft.ru
# Author: Vitaly Lipatov <lav@etersoft.ru>
# Public domain

# TODO: rewrite with shell commands, perl or C
# Python - http://www.linuxtopia.org/online_books/programming_books/python_programming/python_ch16s03.html
# Shell  - http://linux.byexamples.com/archives/127/uniq-and-basic-set-theory/
#        - http://maiaco.com/articles/shellSetOperations.php
# Perl   - http://docstore.mik.ua/orelly/perl/cookbook/ch04_09.htm
#        - http://blogs.perl.org/users/polettix/2012/03/sets-operations.html
# http://rosettacode.org/wiki/Symmetric_difference
# TODO: add unit tests
# http://ru.wikipedia.org/wiki/Операции_над_множествами

# Base set operations:
# * union
#   "1 2 3" "3 4 5" -> "1 2 3 4 5"
# * intersection
#   "1 2 3" "3 4 5" -> "3"
# * relative complement (substracted, difference) ( A ? B – members in A but not in B )
# http://en.wikipedia.org/wiki/Complement_%28set_theory%29
#   "1 3" "1 2 3 4" -> "2 4"
# * symmetric difference (симметричная разность) ( A ^ B – members in A or B but not both )
# http://en.wikipedia.org/wiki/Symmetric_difference
#   "1 2 3" "3 4 5" -> "1 2 4 5"

fatal()
{
        echo "FATAL: $*" >&2
        exit 1
}

filter_strip_spaces()
{
        # possible use just
        #xargs echo
        sed -e "s| \+| |g" -e "s|^ ||" -e "s| \$||"
}

strip_spaces()
{
        echo "$*" | filter_strip_spaces
}

isempty()
{
        [ "$(strip_spaces "$*")" = "" ]
}

list()
{
        local i
        for i in $@ ; do
                echo "$i"
        done
}

count()
{
         list $@ | wc -l
}

union()
{
         strip_spaces $(list $@ | sort -u)
}

intersection()
{
        local RES=""
        local i j
        for i in $2 ; do
            for j in $1 ; do
                [ "$i" = "$j" ] && RES="$RES $i"
            done
        done
        strip_spaces "$RES"
}

uniq()
{
        union $@
}

has()
{
	local wd="$1"
	shift
	echo "$*" | grep -q -- "$wd"
}

# Note: used egrep! write '[0-9]+(first|two)', not '[0-9]\+...'
match()
{
	local wd="$1"
	shift
	echo "$*" | egrep -q -- "$wd"
}


# remove_from_list "1." "11 12 21 22" -> "21 22"
reg_remove()
{
        local i
        local RES=
        for i in $2 ; do
                echo "$i" | grep -q "^$1$" || RES="$RES $i"
        done
        strip_spaces "$RES"
}

# remove_from_list "1." "11 12 21 22" -> "21 22"
reg_wordremove()
{
        local i
        local RES=""
        for i in $2 ; do
                echo "$i" | grep -q -w "$1" || RES="$RES $i"
        done
        strip_spaces "$RES"
}

reg_rqremove()
{
        local i
        local RES=""
        for i in $2 ; do
                [ "$i" = "$1" ] || RES="$RES $i"
        done
        strip_spaces "$RES"
}

# Args: LIST1 LIST2
# do_exclude_list print LIST2 list exclude fields contains also in LIST1
# Example: exclude "1 3" "1 2 3 4" -> "2 4"
exclude()
{
        local i
        local RES="$2"
        for i in $1 ; do
                RES="$(reg_rqremove "$i" "$RES")"
        done
        strip_spaces "$RES"
}

# regexclude_list "22 1." "11 12 21 22" -> "21"
reg_exclude()
{
        local i
        local RES="$2"
        for i in $1 ; do
                RES="$(reg_remove "$i" "$RES")"
        done
        strip_spaces "$RES"
}

# regexclude_list "22 1." "11 12 21 22" -> "21"
reg_wordexclude()
{
        local i
        local RES="$2"
        for i in $1 ; do
                RES=$(reg_wordremove "$i" "$RES")
        done
        strip_spaces "$RES"
}

if_contain()
{
        local i
        for i in $2 ; do
            [ "$i" = "$1" ] && return
        done
        return 1
}

difference()
{
        local RES=""
        local i
        for i in $1 ; do
            if_contain $i "$2" || RES="$RES $i"
        done
        for i in $2 ; do
            if_contain $i "$1" || RES="$RES $i"
        done
        strip_spaces "$RES"
}


# FIXME:
# reg_include "1." "11 12 21 22" -> "11 12"
reg_include()
{
        local i
        local RES=""
        for i in $2 ; do
                echo "$i" | grep -q -w "$1" && RES="$RES $i"
        done
        strip_spaces "$RES"
}

example()
{
        local CMD="$1"
        local ARG1="$2"
        shift 2
        echo "\$ $0 $CMD \"$ARG1\" \"$@\""
        $0 $CMD "$ARG1" "$@"
}

example_res()
{
	example "$@" && echo TRUE || echo FALSE
}

help()
{
        echo "estrlist developed for string list operations. See also cut, join, paste..."
        echo "Usage: $0 <command> [args]"
        echo "Commands:"
        echo "  strip_spaces [args]               - remove extra spaces"
# TODO: add filter
#        echo "  filter_strip_spaces               - remove extra spaces from words from standart input"
#        echo "  reg_remove  <PATTERN> [word list] - remove words containing a match to the given PATTERN (grep notation)"
#        echo "  reg_wordremove  <PATTERN> [word list] - remove words containing a match to the given PATTERN (grep -w notation)"
        echo "  exclude <list1> <list2>           - print list2 items exclude list1 items"
        echo "  reg_exclude <list PATTERN> [word list] - print only words that do not match PATTERN"
#        echo "  reg_wordexclude <list PATTERN> [word list] - print only words do not match PATTERN"
        echo "  has <PATTERN> string              - check the string for a match to the regular expression given in PATTERN (grep notation)"
        echo "  match <PATTERN> string            - check the string for a match to the regular expression given in PATTERN (egrep notation)"
        echo "  isempty [string]                  - true if string has no any symbols (only zero or more spaces)"
        echo "  union [word list]                 - sort and remove duplicates"
        echo "  intersection <list1> <list2>      - print only intersected items (the same in both lists)"
        echo "  difference <list1> <list2>        - symmetric difference between lists items (not in both lists)"
        echo "  uniq [word list]                  - alias for union"
        echo "  list [word list]                  - just list words line by line"
        echo "  count [word list]                 - print word count"
        echo
        echo "Examples:"
#        example reg_remove "1." "11 12 21 22"
#        example reg_wordremove "1." "11 12 21 22"
        example exclude "1 3" "1 2 3 4"
        example reg_exclude "22 1." "11 12 21 22"
        example reg_wordexclude "wo.* er" "work were more else"
        example union "1 2 2 3 3"
        example count "1 2 3 4 10"
        example_res isempty "  "
        #example_res isempty " 1 "
        example_res has ex "exactly"
        example_res has exo "exactly"
        example_res match "M[0-9]+" "M250"
        example_res match "M[0-9]+" "MI"
}

COMMAND="$1"
if [ -z "$COMMAND" ] ; then
        echo "Run with --help for get command description."
        exit 1
fi

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ] ; then
        COMMAND="help"
fi

#
case "$COMMAND" in
    reg_remove|reg_wordremove)
        fatal "obsoleted command $COMMAND"
        ;;
esac

shift

# FIXME: do to call function directly, use case instead?
if [ "$1" = "-" ] ; then
    shift
    "$COMMAND" "$(cat) $@"
elif [ "$2" = "-" ] ; then
    "$COMMAND" "$1" "$(cat)"
else
    "$COMMAND" "$@"
fi
}
################# end of incorporated bin/tools_estrlist #################


################# incorporate bin/tools_json #################
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
################# end of incorporated bin/tools_json #################


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

	# use external distro_info if internal one is missed
	DISTRVENDOR=internal_distr_info
	[ -x $DISTRVENDOR ] || DISTRVENDOR=internal_distr_info

	# Fill for use: PMTYPE, DISTRNAME, DISTRVERSION, PKGFORMAT, PKGVENDOR, RPMVENDOR
	[ -n "$DISTRNAME" ] || DISTRNAME=$($DISTRVENDOR -d) || fatal "Can't get distro name from $DISTRVENDOR."
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
#		CMD="eselect"
#		;;
#	ArchLinux)
#		CMD="pacman"
#		;;
	Fedora|LinuxXP|ASPLinux|CentOS|RHEL|Scientific|GosLinux|Amzn)
		CMD="service-chkconfig"
		;;
	VoidLinux)
		CMD="runit"
		;;
	Slackware)
		CMD="service-initd"
		;;
	SUSE|SLED|SLES)
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
        local on_text="(host system)"
        local virt="$($DISTRVENDOR -i)"
        [ "$virt" = "(unknown)" ] || [ "$virt" = "(host system)" ] || on_text="(under $virt)"
        echo "Service manager version 3.5.0  https://wiki.etersoft.ru/Epm"
        echo "Running on $($DISTRVENDOR -e) $on_text with $SERVICETYPE"
        echo "Copyright (c) Etersoft 2012-2019"
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

# load system wide config
[ -f /etc/eepm/serv.conf ] && . /etc/eepm/serv.conf

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
    list-failed|--failed)       # HELPCMD: list services failed on startup
        serv_cmd=list_failed
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
    log|journal)              # HELPCMD: print log for the service (-f - follow,  -r - reverse order)
        serv_cmd=log
        ;;
    cat)                      # HELPCMD: print out service file for the service
        serv_cmd=cat
        ;;
    edit)
        serv_cmd=edit         # HELPCMD: edit service file overload (use --full to edit full file)
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
