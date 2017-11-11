#!/bin/sh
#
# Copyright (C) 2012-2016  Etersoft
# Copyright (C) 2012-2016  Vitaly Lipatov <lav@etersoft.ru>
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

PROGDIR=$(dirname "$0")
PROGNAME=$(basename "$0")
[ "$PROGDIR" = "." ] && PROGDIR=$(pwd)
if [ "$0" = "/dev/stdin" ] || [ "$0" = "sh" ] ; then
    PROGDIR=""
    PROGNAME=""
fi

# will replaced to /usr/share/eepm during install
SHAREDIR=$PROGDIR

load_helper()
{
    local CMD="$SHAREDIR/$1"
    # do not use fatal() here, it can be initial state
    [ -r "$CMD" ] || { echo "FATAL: Have no $CMD helper file" ; exit 1; }
    # shellcheck disable=SC1090
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
	$PROGDIR/$PROGNAME $@
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
	__epm_assure "$1" $package $3 || fatal "Can't assure in '$1' command from $package$textpackage package"
}

disabled_eget()
{
	# use internal eget only if exists
	if [ -s $SHAREDIR/tools_eget ] ; then
		$SHAREDIR/tools_eget "$@"
		return
	fi

	assure_exists eget
	# run external command, not the function
	EGET=$(which eget) || fatal "Missed command eget from installed package eget"
	$EGET "$@"
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

    grep -v -- "^#" $0 | grep -- "# $1" | while read -r n ; do
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
	a='' mountpoint -q "$SYSTEMD_CGROUP_DIR" || return
	readlink /sbin/init | grep -q 'systemd' || return
	# some hack
	# shellcheck disable=SC2009
	ps ax | grep '[s]ystemd' | grep -q -v 'systemd-udev'
}

# File bin/epm-addrepo:


__epm_addrepo_altlinux()
{
	local repo="$@"
	case "$1" in
		etersoft)
			info "add Etersoft's addon repo"
			epm install --skip-installed apt-conf-etersoft-common apt-conf-etersoft-hold
			# TODO: ignore only error code 22 (skipped) || fatal
			local branch="$DISTRVERSION/branch"
			[ "$DISTRVERSION" = "Sisyphus" ] && branch="$DISTRVERSION"
			# FIXME
			[ -n "$DISTRVERSION" ] || fatal "Empty DISTRVERSION"
			# TODO: func?
			local arch=$(uname -m)
			[ "$arch" = "i686" ] && arch="i586"
			# TODO: use apt-repo add ?
			echo "" | sudocmd tee -a /etc/apt/sources.list
			echo "# added with eepm addrepo etersoft" | sudocmd tee -a /etc/apt/sources.list
			echo "rpm [etersoft] http://download.etersoft.ru/pub/Etersoft LINUX@Etersoft/$branch/$arch addon" | sudocmd tee -a /etc/apt/sources.list
			if [ "$arch" = "x86_64" ] ; then
				echo "rpm [etersoft] http://download.etersoft.ru/pub/Etersoft LINUX@Etersoft/$branch/$arch-i586 addon" | sudocmd tee -a /etc/apt/sources.list
			fi
			echo "rpm [etersoft] http://download.etersoft.ru/pub/Etersoft LINUX@Etersoft/$branch/noarch addon" | sudocmd tee -a /etc/apt/sources.list
			repo="$DISTRVERSION"
			return 0
			;;
		autoimports)
			[ -n "$DISTRVERSION" ] || fatal "Empty DISTRVERSION"
			repo="$repo.$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"
			;;
		archive)
			datestr="$2"
			echo "$datestr" | grep -Eq "^20[0-2][0-9]/[01][0-9]/[0-3][0-9]$" || fatal "use follow date format: 2017/12/31"
			# TODO: func?
			local arch=$(uname -m)
			[ "$arch" = "i686" ] && arch="i586"
			echo "" | sudocmd tee -a /etc/apt/sources.list
			echo "rpm [alt] http://ftp.altlinux.org/pub/distributions archive/sisyphus/date/$datestr/$arch classic" | sudocmd tee -a /etc/apt/sources.list
			if [ "$arch" = "x86_64" ] ; then
				echo "rpm [alt] http://ftp.altlinux.org/pub/distributions archive/sisyphus/date/$datestr/$arch-i586 classic" | sudocmd tee -a /etc/apt/sources.list
			fi
			echo "rpm [alt] http://ftp.altlinux.org/pub/distributions archive/sisyphus/date/$datestr/noarch classic" | sudocmd tee -a /etc/apt/sources.list
			return 0
			;;
	esac

	assure_exists apt-repo

	if tasknumber "$repo" >/dev/null ; then
		sudocmd apt-repo add $(tasknumber "$repo")
		return
	fi

	if [ -z "$repo" ] ; then
		info "Add branch repo. TODO?"
		sudocmd apt-repo add branch
		return
	fi

	sudocmd apt-repo add "$repo"

}

epm_addrepo()
{
local repo="$(eval echo "$quoted_args")"

case $DISTRNAME in
	ALTLinux)
		__epm_addrepo_altlinux $repo
		return
		;;
esac

case $PMTYPE in
	apt-dpkg|aptitude-dpkg)
		info "You need manually add repo to /etc/apt/sources.list (TODO)"
		;;
	yum-rpm)
		assure_exists yum-utils
		sudocmd yum-config-manager --add-repo "$repo"
		;;
	urpm-rpm)
		sudocmd urpmi.addmedia "$repo"
		;;
	zypper-rpm)
		sudocmd zypper ar "$repo"
		;;
	emerge)
		sudocmd layman -a "$repo"
		;;
	pacman)
		info "You need manually add repo to /etc/pacman.conf"
		# Only for alone packages:
		#sudocmd repo-add $pkg_filenames
		;;
	npackd)
		sudocmd npackdcl add-repo --url="$repo"
		;;
	slackpkg)
		info "You need manually add repo to /etc/slackpkg/mirrors"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-assure:

__check_command_in_path()
{
    PATH=$PATH:/sbin:/usr/sbin which "$1" 2>/dev/null
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

__epm_need_update()
{
    local PACKAGE="$1"
    local PACKAGEVERSION="$2"

    [ -n "$PACKAGEVERSION" ] || return 0

    is_installed "$PACKAGE" || return 0

    # epm print version for package N
    local INSTALLEDVERSION=$(query_package_field "version" "$PACKAGE")
    # if needed >= installed, return 0
    [ "$(compare_version "$PACKAGEVERSION" "$INSTALLEDVERSION")" -gt 0 ] && return 0

    return 1
}

__epm_assure_checking()
{
    local CMD="$1"
    local PACKAGE="$2"
    local PACKAGEVERSION="$3"

    [ -n "$PACKAGEVERSION" ] && return 1

    if is_dirpath "$CMD" ; then
        if [ -e "$CMD" ] ; then
            if [ -n "$verbose" ] ; then
                info "File or directory $CMD is already exists."
                epm qf "$CMD"
            fi
            return 0
        fi

        [ -n "$PACKAGE" ] || fatal "You need run with package name param when use with absolute path"
        return 1
    fi

    if __check_command_in_path "$CMD" >/dev/null ; then
        if [ -n "$verbose" ] ; then
            local compath="$(__check_command_in_path "$1")"
            info "Command $CMD is exists: $compath"
            epm qf "$compath"
        fi
        return 0
    fi

    return 1
}



__epm_assure()
{
    local CMD="$1"
    local PACKAGE="$2"
    local PACKAGEVERSION="$3"
    [ -n "$PACKAGE" ] || PACKAGE="$1"

    __epm_assure_checking $CMD $PACKAGE $PACKAGEVERSION && return 0

    info "Installing appropriate package for $CMD command..."
    __epm_need_update $PACKAGE $PACKAGEVERSION || return 0

    docmd epm --auto install $PACKAGE || return

    [ -n "$PACKAGEVERSION" ] || return 0
    # check if we couldn't update and still need update
    __epm_need_update $PACKAGE $PACKAGEVERSION && return 1
    return 0
}


epm_assure()
{
    [ -n "$pkg_filenames" ] || fatal "Assure: Missing params. Check $0 --help for info."

    # use helper func for extract separate params
    # shellcheck disable=SC2046
    __epm_assure $(eval echo $quoted_args)
}

# File bin/epm-audit:

epm_audit()
{

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

case $PMTYPE in
	pkgng)
		sudocmd pkg audit -F
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-autoorphans:

__epm_orphan_altrpm()
{
	docmd "apt-cache list-extras"
}

epm_autoorphans()
{

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"


case $PMTYPE in
	apt-rpm)
		# ALT Linux only
		assure_exists /etc/buildreqs/files/ignore.d/apt-scripts apt-scripts
		if [ -z "$dryrun" ] ; then
			echo "We will try remove all installed packages which are missed in repositories"
			warning "Use with caution!"
		fi
		local PKGLIST=$(__epm_orphan_altrpm \
			| sed -e "s/\.32bit//g" \
			| grep -v -- "^eepm$" \
			| grep -v -- "^kernel")

		if [ -n "$quiet" ] ; then
			echo "$PKGLIST"
		else
			docmd epm remove $dryrun $PKGLIST
		fi
		;;
	apt-dpkg|aptitude-dpkg)
		assure_exists deborphan
		showcmd deborphan
		a='' deborphan | docmd epm remove $dryrun
		;;
	#aura)
	#	sudocmd aura -Oj
	#	;;
	yum-rpm)
		showcmd package-cleanup --orphans
		local PKGLIST=$(package-cleanup -q --orphans | grep -v "^eepm-")
		docmd epm remove $dryrun $PKGLIST
		;;
	dnf-rpm)
		# TODO: dnf list extras
		# TODO: Yum-utils package has been deprecated, use dnf instead.
		showcmd package-cleanup --orphans
		local PKGLIST=$(package-cleanup -q --orphans | grep -v "^eepm-")
		docmd epm remove $dryrun $PKGLIST
		;;
	urpm-rpm)
		if [ -n "$dryrun" ] ; then
			fatal "--dry-run is not supported yet"
		else
			showcmd urpme --report-orphans
			sudocmd urpme --auto-orphans
		fi
		;;
	#emerge)
	#	sudocmd emerge --depclean
	#	assure_exists revdep-rebuild
	#	sudocmd revdep-rebuild
	#	;;
	pacman)
		if [ -n "$dryrun" ] ; then
			info "Autoorphans packages list:"
			sudocmd pacman -Qdtq
		else
			sudocmd pacman -Qdtq | sudocmd pacman -Rs -
		fi
		;;
	slackpkg)
		# clean-system removes non official packages
		sudocmd slackpkg clean-system
		;;
	#guix)
	#	sudocmd guix gc
	#	;;
	#pkgng)
	#	sudocmd pkg autoremove
	#	;;
	zypper-rpm)
		# https://www.linux.org.ru/forum/desktop/11931830
		assure_exists zypper zypper 1.9.2
		# For zypper < 1.9.2: zypper se -si | grep 'System Packages'
		sudocmd zypper packages --orphaned
		# FIXME: x86_64/i586 are duplicated
		local PKGLIST=$(zypper packages --orphaned | tail -n +5 | cut -d \| -f 3 | sort -u)
		docmd epm remove $dryrun --clean-deps $PKGLIST
		;;
	xbps)
		if [ -n "$dryrun" ] ; then
			fatal "--dry-run is not supported yet"
		else
			sudocmd xbps-remove -o
		fi
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-autoremove:

__epm_autoremove_altrpm_pp()
{
	local pkgs

	info "Removing unused python/perl modules..."
	#[ -n "$force" ] || info "You can run with --force for more deep removing"
	local force=force

	local libexclude="$1"

	local flag=

	[ -n "$force" ] || libexclude=$libexclude'[^-]*$'

	showcmd "apt-cache list-nodeps | grep -E -- \"$libexclude\""
	pkgs=$(apt-cache list-nodeps | grep -E -- "$libexclude" )

	if [ -n "$dryrun" ] ; then
		info "Packages for autoremoving:"
		echo "$pkgs"
		return 0
	fi
	
	[ -n "$pkgs" ] && sudocmd rpm -v -e $pkgs && flag=1

	if [ -n "$flag" ] ; then
		info ""
		info "call again for next cycle until all modules will be removed"
		__epm_autoremove_altrpm_pp "$libexclude"
	fi

	return 0
}

__epm_autoremove_altrpm_lib()
{
	local pkgs

	local nodevel="$1"

	info
	if [ "$nodevel" = "nodevel" ] ; then
		info "Removing all non -devel/-debuginfo libs packages not need by anything..."
		local develrule='-(devel|devel-static)$'
	else
		info "Removing all non -debuginfo libs packages (-devel too) not need by anything..."
		local develrule='-(NONONO)$'
	fi
	#[ -n "$force" ] || info "You can run with --force for more deep removing"
	local force=force

	local flag=
	local libgrep='^(lib|i586-lib|bzlib|zlib)'
	[ -n "$force" ] || libexclude=$libgrep'[^-]*$'

	# https://www.altlinux.org/APT_в_ALT_Linux/Советы_по_использованию#apt-cache_list-nodeps
	showcmd "apt-cache list-nodeps | grep -E -- \"$libgrep\""
	pkgs=$(apt-cache list-nodeps | grep -E -- "$libgrep" \
		| sed -e "s/[-\.]32bit$//g" \
		| grep -E -v -- "$develrule" \
		| grep -E -v -- "-(debuginfo)$" \
		| grep -E -v -- "-(util|utils|tool|tools|plugin|daemon|help)$" \
		| grep -E -v -- "^(libsystemd|libreoffice|libnss|libvirt-client|libvirt-daemon|libsasl2-plugin|eepm)" )

	if [ -n "$dryrun" ] ; then
		info "Packages for autoremoving:"
		echo "$pkgs"
		return 0
	fi

	# commented, with hi probability user install i586- manually
	# workaround against missed i586- handling in apt-cache list-nodeps
	if epmqp i586-lib >/dev/null ; then
		info "You can try removing i586- with follow command"
		showcmd rpm -v -e $(epmqp i586-lib)
	fi

	[ -n "$pkgs" ] && sudocmd rpm -v -e $pkgs && flag=1

	if [ -n "$flag" ] ; then
		info ""
		info "call again for next cycle until all libs will be removed"
		__epm_autoremove_altrpm_lib $nodevel
	fi

	return 0
}


__epm_autoremove_altrpm()
{
	local i
	assure_exists /etc/buildreqs/files/ignore.d/apt-scripts apt-scripts

	if [ -z "$pkg_names" ] ; then
		__epm_autoremove_altrpm_pp '^(python-module-|python3-module-|python-modules-|python3-modules|perl-)'
		__epm_autoremove_altrpm_lib nodevel
		return 0
	fi

	for i in $pkg_names ; do
		case $i in
		libs)
			__epm_autoremove_altrpm_lib nodevel
			;;
		python)
			__epm_autoremove_altrpm_pp '^(python-module-|python3-module-|python-modules-|python3-modules)'
			;;
		perl)
			__epm_autoremove_altrpm_pp '^(perl-)'
			;;
		libs-devel)
			__epm_autoremove_altrpm_lib
			;;
		*)
			fatal "autoremove: unsupported '$i'. Use libs, python, perl, libs-devel."
			;;
		esac
	done

	return 0
}

epm_autoremove()
{

case $DISTRNAME in
	ALTLinux)
		__epm_autoremove_altrpm

		[ -n "$dryrun" ] && return

		docmd epm remove-old-kernels
		
		if which nvidia-clean-driver 2>/dev/null ; then
			sudocmd nvidia-clean-driver
		fi

		return
		;;
	*)
		;;
esac

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

case $PMTYPE in
	apt-dpkg|aptitude-dpkg)
		sudocmd apt-get autoremove $dryrun
		;;
	aura)
		if [ -n "$dryrun" ] ; then
			fatal "--dry-run is not supported yet"
		fi
		sudocmd aura -Oj
		;;
	yum-rpm)
		# cleanup orphanes?
		while true ; do
			# shellcheck disable=SC2046
			docmd package-cleanup --leaves $(subst_option non_interactive --assumeyes)
			# FIXME: package-cleanup have to use stderr for errors
			local PKGLIST=$(package-cleanup -q --leaves | grep -v "^eepm-")
			[ -n "$PKGLIST" ] || break
			showcmd epm remove $PKGLIST
		done
		;;
	dnf-rpm)
		if [ -n "$dryrun" ] ; then
			fatal "--dry-run is not supported yet"
		fi
		sudocmd dnf autoremove
		;;
	# see autoorhans
	#urpm-rpm)
	#	sudocmd urpme --auto-orphans
	#	;;
	emerge)
		if [ -n "$dryrun" ] ; then
			fatal "--dry-run is not supported yet"
		fi
		sudocmd emerge --depclean
		assure_exists revdep-rebuild
		sudocmd revdep-rebuild
		;;
	# see autoorhans
	#pacman)
	#	sudocmd pacman -Qdtq | sudocmd pacman -Rs -
	#	;;
	slackpkg)
		# clean-system removes non official packages
		#sudocmd slackpkg clean-system
		;;
	guix)
		sudocmd guix gc
		;;
	pkgng)
		sudocmd pkg autoremove
		;;
	zypper-rpm)
		# https://www.linux.org.ru/forum/desktop/11931830
		assure_exists zypper zypper 1.9.3
		sudocmd zypper packages --unneeded
		# FIXME: x86_64/i586 are duplicated
		local PKGLIST=$(zypper packages --unneeded | tail -n +5 | cut -d \| -f 3 | sort -u)
		showcmd epm remove --clean-deps $PKGLIST
		;;
	xbps)
		if [ -n "$dryrun" ] ; then
			fatal "--dry-run is not supported yet"
		fi
		sudocmd xbps-remove -O
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-changelog:


__epm_changelog_apt()
{
	local i
	for i in $@ ; do
		docmd apt-cache show $i | grep -A 1000 "^Changelog:"
	done
}

__epm_changelog_files()
{
	[ -z "$*" ] && return

	# TODO: detect every file
	case $(get_package_type $1) in
		rpm)
			assure_exists rpm
			docmd_foreach "rpm -q -p --changelog" $@ | less
			;;
		*)
			fatal "Have no suitable command for $1"
			;;
	esac
}

__epm_changelog_local_names()
{
	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm|yum-rpm|dnf-rpm|urpm-rpm|zypper-rpm)
			docmd_foreach "rpm -q --changelog" $@ | less
			;;
		apt-dpkg|aptitude-dpkg)
			docmd zcat /usr/share/doc/$1/changelog.Debian.gz | less
			;;
		emerge)
			assure_exists equery
			docmd equery changes -f $1 | less
			;;
		pacman)
			docmd pacman -Qc $1 | less
			;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac
}

__epm_changelog_unlocal_names()
{
	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm)
			__epm_changelog_apt $@ | less
			;;
		#apt-dpkg)
		#	# FIXME: only first pkg
		#	docmd zcat /usr/share/doc/$1/changelog.Debian.gz | less
		#	;;
		#yum-rpm)
		#	sudocmd yum clean all
		#	;;
		urpm-rpm)
			docmd urpmq --changelog $@ | less
			;;
		#zypper-rpm)
		#	sudocmd zypper clean
		#	;;
		emerge)
			assure_exists equery
			docmd equery changes -f $1 | less
			;;
		*)
			fatal "Have no suitable command for $PMTYPE. Try install the package firstly."
			;;
	esac

}


epm_changelog()
{
	[ -n "$pkg_filenames" ] || fatal "Changelog: Missing package(s) name"

	__epm_changelog_files $pkg_files

	local pkg
	for pkg in $pkg_names ; do
		if is_installed $pkg ; then
			__epm_changelog_local_names $pkg
		else
			__epm_changelog_unlocal_names $pkg
		fi
	done
}

# File bin/epm-check:

epm_check()
{
case $PMTYPE in
	apt-rpm|apt-dpkg)
		#sudocmd apt-get check || exit
		#sudocmd apt-get update || exit
		sudocmd apt-get -f install
		;;
	apt-dpkg)
		#sudocmd apt-get update || exit
		#sudocmd apt-get check || exit
		sudocmd apt-get -f install || return
		sudocmd apt-get autoremove
		;;
	aptitude-dpkg)
		sudocmd aptitude -f install || return
		#sudocmd apt-get autoremove
		;;
	yum-rpm)
		docmd yum check
		docmd package-cleanup --problems

		#docmd package-cleanup --dupes
		sudocmd package-cleanup --cleandupes

		docmd rpm -Va --nofiles --nodigest
		;;
	dnf-rpm)
		sudocmd dnf check
		;;
	emerge)
		sudocmd revdep-rebuild
		;;
	#urpm-rpm)
	#	sudocmd urpme --auto-orphans
	#	;;
	zypper-rpm)
		sudocmd zypper verify
		;;
	conary)
		sudocmd conary verify
		;;
	pkgng)
		sudocmd pkg check -d -a
		;;
	homebrew)
		docmd brew doctor
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-checkpkg:

check_pkg_integrity()
{
	local PKG="$1"
	local RET

	case $(get_package_type $PKG) in
	rpm)
		assure_exists rpm
		docmd rpm --checksig $PKG
		;;
	deb)
		assure_exists dpkg
		# FIXME: debsums -ca package ?
		docmd dpkg --contents $PKG >/dev/null && echo "Package $PKG is correct."
		;;
	exe)
		file $PKG | grep -q "executable for MS Windows"
		;;
	msi)
		# TODO: add to patool via cabextract
		assure_exists cabextract
		#file $PKG | grep -q "Microsoft Office Document"
		docmd cabextract -t $PKG
		;;
	ebuild)
		true
		;;
	*)
		assure_exists erc
		docmd erc test "$PKG" && return
		;;
	esac
}

__epm_check_installed_pkg()
{
case $PMTYPE in
	*-rpm)
		docmd rpm -V $@
		;;
	*-dpkg)
		assure_exists debsums
		docmd debsums $@
		;;
	emerge)
		assure_exists equery
		docmd equery check $@
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}


epm_checkpkg()
{
	if [ -n "$pkg_names" ] ; then
		# TODO: если есть / или расширение, это отсутствующий файл
		info "Suggest $pkg_names are name(s) of installed packages"
		__epm_check_installed_pkg $pkg_names
		return
	fi

	# if possible, it will put pkg_urls into pkg_files or pkg_names
	if [ -n "$pkg_urls" ] ; then
		__handle_pkg_urls_to_checking
	fi

	[ -n "$pkg_files" ] || fatal "Checkpkg: missing file or package name(s)"

	local RETVAL=0

	local pkg
	for pkg in $pkg_files ; do
		check_pkg_integrity $pkg || RETVAL=1
	done

	# TODO: reinvent
	[ -n "$to_remove_pkg_files" ] && rm -fv $to_remove_pkg_files
	[ -n "$to_remove_pkg_files" ] && rmdir -v $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null

	#fatal "Broken package $pkg"
	return $RETVAL
}

# File bin/epm-checksystem:


epm_checksystem_ALTLinux()
{
	local TDIR=$(mktemp -d)
	assure_exists time
	touch $TDIR/added
	for ft in $(ls /usr/lib/rpm/*.filetrigger | sort) ; do
		echo "Try run $ft ..."
		echo $TDIR/added $TDIR/removed | a='' time $ft
	done
	rm -f $TDIR/added fatal
	rmdir $TDIR || fatal
	echo "Count lines:"
	wc -l /var/lib/rpm/files-awaiting-filetriggers
}


epm_checksystem()
{

[ $EFFUID = "0" ] && fatal "Do not use checksystem under root"

case $DISTRNAME in
	ALTLinux)
		epm_checksystem_$DISTRNAME
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

if [ "$1" = "--debug" ] ; then
	shift
	SUDO=sudo
	DISTRNAME=ALTLinux
	epm_checksystem
fi

# File bin/epm-check_updated_repo:

__is_repo_info_downloaded()
{
    case $PMTYPE in
        apt-*)
            if [ -r /var/cache/apt ] ; then
                $SUDO test -r /var/cache/apt/pkgcache.bin || return
            fi
            ;;
        *)
            ;;
    esac
    return 0
}

__is_repo_info_uptodate()
{
    case $PMTYPE in
        apt-*)
            # apt-deb do not update lock file date
            #if $SUDO test -r /var/lib/apt/lists ; then
                local LOCKFILE=/var/lib/apt/lists
                $SUDO test -r $LOCKFILE || return
                # if repo older than 1 day, return false
                # find print string if file is obsoleted
                test -z "$(find $LOCKFILE -maxdepth 0 -mtime +1)" || return
            #fi
            ;;
        *)
            ;;
    esac
    return 0
}

update_repo_if_needed()
{
    # check if we need skip update checking
    if [ "$1" = "soft" ] && [ -n "$SUDO" ] ; then
        # if sudo requires a password, skip autoupdate
        sudo -n true 2>/dev/null || { info "sudo requires a password, skip repo status checking" ; return 0 ; }
    fi

    cd / || fatal
    if ! __is_repo_info_downloaded || ! __is_repo_info_uptodate ; then
        pkg_filenames='' epm_update
    fi
    cd - >/dev/null || fatal

}

# File bin/epm-clean:

__remove_alt_apt_cache_file()
{
	sudocmd rm -vf /var/cache/apt/*.bin
	sudocmd rm -vf /var/cache/apt/partial/*
	sudocmd rm -vf /var/lib/apt/lists/*pkglist*
	sudocmd rm -vf /var/lib/apt/lists/*release*
}

__remove_deb_apt_cache_file()
{
	sudocmd rm -vf /var/cache/apt/*.bin
	sudocmd rm -vf /var/cache/apt/archives/partial/*
	sudocmd rm -vf /var/lib/apt/lists/*Packages*
	sudocmd rm -vf /var/lib/apt/lists/*Release*
	sudocmd rm -vf /var/lib/apt/lists/*Translation*
}

epm_clean()
{

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"


case $PMTYPE in
	apt-rpm)
		sudocmd apt-get clean
		[ -n "$force" ] && __remove_alt_apt_cache_file
		;;
	apt-dpkg)
		sudocmd apt-get clean
		[ -n "$force" ] && __remove_deb_apt_cache_file
		;;
	aptitude-dpkg)
		sudocmd aptitude clean
		[ -n "$force" ] && __remove_deb_apt_cache_file
		;;
	yum-rpm)
		sudocmd yum clean all
		#sudocmd yum makecache
		;;
	dnf-rpm)
		sudocmd dnf clean all
		;;
	urpm-rpm)
		sudocmd urpmi --clean
		;;
	pacman)
		sudocmd pacman -Sc --noconfirm
		;;
	zypper-rpm)
		sudocmd zypper clean
		;;
	nix)
		sudocmd nix-collect-garbage
		;;
	slackpkg)
		;;
	pkgng)
		sudocmd pkg clean -a
		;;
	xbps)
		sudocmd xbps-remove -O
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac
	info "It is recommend to run 'epm autoremove' also"

}

# File bin/epm-conflicts:


epm_conflicts_files()
{
	[ -n "$pkg_files" ] || return

	case $(get_package_type $pkg_files) in
		rpm)
			assure_exists rpm
			docmd "rpm -q --conflicts -p" $pkg_files
			;;
		#deb)
		#	a= docmd dpkg -I $pkg_files | grep "^ *Depends:" | sed "s|^ *Depends:||g"
		#	;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac
}

epm_conflicts_names()
{
	local CMD
	[ -n "$pkg_names" ] || return

case $PMTYPE in
	apt-rpm)
		# FIXME: need fix for a few names case
		# FIXME: too low level of requires name (libSOME.so)
		if is_installed $pkg_names ; then
			CMD="rpm -q --conflicts"
		else
			EXTRA_SHOWDOCMD=' | grep "Conflicts:"'
			docmd apt-cache show $pkg_names | grep "Conflicts:"
			return
		fi

		;;
	urpm-rpm|zypper-rpm)
		# FIXME: use hi level commands
		CMD="rpm -q --conflicts"
		;;
	#yum-rpm)
	#	CMD="yum deplist"
	#	;;
	#pacman)
	#	CMD="pactree"
	#	;;
	apt-dpkg)
		# FIXME: need fix for a few names case
		if is_installed $pkg_names ; then
			showcmd dpkg -s $pkg_names
			a='' dpkg -s $pkg_names | grep "^Conflicts:" | sed "s|^Conflicts:||g"
			return
		else
			EXTRA_SHOWDOCMD=' | grep "Conflicts:"'
			docmd apt-cache show $pkg_names | grep "Conflicts:"
			return
		fi
		;;
	# TODO: why-not show who conflicts with us
	#aptitude-dpkg)
	#	docmd aptitude why-not $pkg_names
	#	;;

	#emerge)
	#	assure_exists equery
	#	CMD="equery depgraph"
	#	;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac


docmd $CMD $pkg_names

}

epm_conflicts()
{
	[ -n "$pkg_filenames" ] || fatal "Conflicts: Missing package(s) name"
	epm_conflicts_files
	epm_conflicts_names
}

# File bin/epm-downgrade:


__epm_add_alt_apt_downgrade_preferences()
{
	[ -r /etc/apt/preferences ] && fatal "/etc/apt/preferences already exists"
	cat <<EOF | $SUDO tee /etc/apt/preferences
Package: *
Pin: release c=classic
Pin-Priority: 1001

Package: *
Pin: release c=addon
Pin-Priority: 1101
EOF
}

__epm_add_deb_apt_downgrade_preferences()
{
	[ -r /etc/apt/preferences ] && fatal "/etc/apt/preferences already exists"
	info "Running with /etc/apt/preferences:"
	cat <<EOF | $SUDO tee /etc/apt/preferences
Package: *
Pin: release a=stable
Pin-Priority: 1001

Package: *
Pin: release a=testing
Pin-Priority: 900

Package: *
Pin: release a=unstable
Pin-Priority: 800
EOF
}

__epm_remove_apt_downgrade_preferences()
{
	sudocmd rm -f /etc/apt/preferences
}

epm_downgrade()
{
	local CMD

	# it is useful for first time running
	update_repo_if_needed

	info "Running command for downgrade packages"

	case $PMTYPE in
	apt-rpm)
		__epm_add_alt_apt_downgrade_preferences || return
		if [ -n "$pkg_filenames" ] ; then
			sudocmd apt-get install $pkg_filenames
		else
			sudocmd apt-get dist-upgrade
		fi
		__epm_remove_apt_downgrade_preferences
		;;
	apt-dpkg)
		__epm_add_deb_apt_downgrade_preferences || return
		if [ -n "$pkg_filenames" ] ; then
			sudocmd apt-get install $pkg_filenames
		else
			sudocmd apt-get dist-upgrade
		fi
		__epm_remove_apt_downgrade_preferences
		;;
	yum-rpm)
		# can do update repobase automagically
		if [ -n "$pkg_filenames" ] ; then
			sudocmd yum downgrade $pkg_filenames
		else
			sudocmd yum distro-sync
		fi
		;;
	dnf-rpm)
		if [ -n "$pkg_filenames" ] ; then
			sudocmd dnf downgrade $pkg_filenames
		else
			sudocmd dnf distro-sync
		fi
		;;
	urpm-rpm)
		assure_exists urpm-reposync urpm-tools
		sudocmd urpm-reposync -v
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-download:

alt_base_dist_url="http://ftp.basealt.ru/pub/distributions"

__use_url_install()
{
	case $DISTRNAME in
		"ALTLinux")
			# do not support https yet
			echo "$pkg_urls" | grep -q "https://" && return 1
			# force download if wildcard is used
			echo "$pkg_urls" | grep -q "[?*]" && return 1
			pkg_names="$pkg_names $pkg_urls"
			return 0
			;;
	esac

	case $PMTYPE in
		#apt-rpm)
		#	pkg_names="$pkg_names $pkg_urls"
		#	;;
		#deepsolver-rpm)
		#	pkg_names="$pkg_names $pkg_urls"
		#	;;
		#urpm-rpm)
		#	pkg_names="$pkg_names $pkg_urls"
		#	;;
		pacman)
			pkg_names="$pkg_names $pkg_urls"
			;;
		yum-rpm|dnf-rpm)
			pkg_names="$pkg_names $pkg_urls"
			;;
		#zypper-rpm)
		#	pkg_names="$pkg_names $pkg_urls"
		#	;;
		*)
			return 1
			;;
	esac
	return 0
}

__download_pkg_urls()
{
	local url
	[ -z "$pkg_urls" ] && return
	for url in $pkg_urls ; do
		local tmppkg=$(mktemp -d) || fatal "failed mktemp -d"
		cd $tmppkg || fatal
		if docmd eget "$url" ; then
			local i
			for i in $(basename $url) ; do
				[ -s "$tmppkg/$i" ] || continue
				pkg_files="$pkg_files $tmppkg/$i"
				to_remove_pkg_files="$to_remove_pkg_files $tmppkg/$i"
			done
		else
			warning "Failed to download $url, ignoring"
		fi
		cd - >/dev/null
	done
	# reconstruct
	pkg_filenames=$(strip_spaces "$pkg_files $pkg_names")
}

__handle_pkg_urls_to_install()
{
	#[ -n "$pkg_urls" ] || return

	# TODO: do it correctly
	to_remove_pkg_files=
	# FIXME: check type of pkg_urls separately?
	if [ "$(get_package_type "$pkg_urls")" != $PKGFORMAT ] || ! __use_url_install ; then
		# use workaround with eget: download and put in pkg_files
		__download_pkg_urls
	fi

	pkg_urls=
}

__handle_pkg_urls_to_checking()
{
	#[ -n "$pkg_urls" ] || return

	# TODO: do it correctly
	to_remove_pkg_files=
	
	# use workaround with eget: download and put in pkg_files
	__download_pkg_urls

	pkg_urls=
}


__epm_get_altpkg_url()
{
	info "TODO: https://packages.altlinux.org/api/branches"
	local arch=$(paoapi packages/$1 | get_pao_var arch)
	# FIXME: arch can be list
	[ "$arch" = "noarch" ] || arch=$(arch)
	# HACK: filename can be list
	local filename=$(paoapi packages/$1 | get_pao_var filename | grep $arch)
	[ -n "$filename" ] || fatal "Can't get filename"
	# fixme: get from /branches
	local dv=$DISTRNAME/$DISTRVERSION/branch
	[ "$DISTRVERSION" = "Sisyphus" ] && dv=$DISTRNAME/$DISTRVERSION
	echo "$alt_base_dist_url/$dv/$arch/RPMS.classic/$filename"
}

__epm_print_url_alt()
{
	local url="$1"
	echo "$url"
	echo "$url" | sed -e "s|$alt_base_dist_url/$DISTRNAME|http://mirror.yandex.ru/altlinux|g"
	echo "$url" | sed -e "s|$alt_base_dist_url/$DISTRNAME|http://download.etersoft.ru/pub/ALTLinux|g"
}

__epm_print_url_alt_check()
{
	local pkg=$1
	shift
	local tm=$(mktemp)
	epm assure curl
	quiet=1
	local buildtime=$(paoapi packages/$pkg | get_pao_var buildtime)
	echo
	echo "Latest release: $(paoapi packages/$pkg | get_pao_var sourcepackage) $buildtime"
	__epm_print_url_alt "$1" | while read url ; do
		curl -s --head $url >$tm || { echo "$url: missed" ; continue ; }
		local http=$(cat $tm | grep "^HTTP" | sed -e "s|\r||g")
		local lastdate=$(cat $tm | grep "^Last-Modified:" | sed -e "s|\r||g")
		local size=$(cat $tm | grep "^Content-Length:" | sed -e "s|^Content-Length: ||g"  | sed -e "s|\r||g")
		echo "$url ($http $lastdate) Size: $size"
	done
	rm -f $tm
}

__epm_download_alt()
{
	local pkg
	if [ "$1" = "--check" ] ; then
		local checkflag="$1"
		shift
	fi
	for pkg in "$@" ; do
		local url=$(__epm_get_altpkg_url $pkg)
		[ -n "$url" ] || warning "Can't get URL for $pkg"
		if [ -n "$checkflag" ] ; then
			__epm_print_url_alt_check "$pkg" "$url"
		else
			docmd eget $url || return
		fi
	done
}

epm_download()
{
	local CMD

	case $DISTRNAME in
		ALTLinux)
			__epm_download_alt $pkg_filenames
			return
			;;
	esac

	case $PMTYPE in
	dnf-rpm)
		sudocmd dnf download $pkg_filenames
		;;
	aptcyg)
		sudocmd apt-cyg download $pkg_filenames
		;;
	yum-rpm)
		# TODO: check yum install --downloadonly --downloaddir=/tmp <package-name>
		assure_exists yumdownloader yum-utils
		sudocmd yumdownloader $pkg_filenames
		;;
	dnf-rpm)
		sudocmd dnf download $pkg_filenames
		;;
	urpm-rpm)
		sudocmd urpmi --no-install $URPMOPTIONS $@
		;;
	tce)
		sudocmd tce-load -w $pkg_filenames
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-epm_install:



epm_epm_install(){
    assure_exists wget
    local etersoft_updates_site="http://updates.etersoft.ru/pub/Korinf/$($DISTRVENDOR -e)"
    # FIXME: some way to get latest package
    local download_link=$etersoft_updates_site/$(wget -qO- $etersoft_updates_site/ | grep -m1 -Eo "eepm[^\"]+\.$($DISTRVENDOR -p)" | tail -n1) #"

    pkg_names='' pkg_files='' pkg_urls="$download_link" epm_install
}

# File bin/epm-filelist:


__alt_local_content_filelist()
{

    local CI="$(get_local_alt_contents_index)"
    [ -n "$CI" ] || fatal "Have no local contents index"

    # TODO: safe way to use less
    #local OUTCMD="less"
    #[ -n "$USETTY" ] || OUTCMD="cat"
    OUTCMD="cat"

    {
        [ -n "$USETTY" ] && info "Search in $CI for $1..."
        __local_ercat $CI | grep -h -- ".*$1$" | sed -e "s|\(.*\)\t\(.*\)|\1|g"
    } | $OUTCMD
}

__deb_local_content_filelist()
{
    showcmd "apt-file list $1 | grep '^$1: ' | sed -e 's|$1: ||g'"
    a='' apt-file list "$1" | grep "^$1: " | sed -e "s|$1: ||g"
}


__epm_filelist_remote()
{
	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm)
			# TODO: use RESTful interface to prometeus? See ALT bug #29496
			docmd_foreach __alt_local_content_filelist "$@"
			;;
		apt-dpkg)
			assure_exists apt-file || return
			if sudo -n true 2>/dev/null ; then
				sudocmd apt-file update
			else
				info "sudo requires a password, skip apt-file update"
			fi
			docmd_foreach __deb_local_content_filelist "$@"
			;;
		yum-rpm)
			assure_exists yum-utils || return
			docmd repoquery -q -l "$@"
			;;
		dnf-rpm)
			assure_exists dnf-plugins-core || return
			docmd dnf repoquery -l "$@"
			;;
		*)
			fatal "Query filelist for non installed packages is not implemented yet."
			;;
	esac
}

__epm_filelist_file()
{
	local CMD

	[ -z "$*" ] && return

	# TODO: allow a new packages
	case $(get_package_type $1) in
		rpm)
			assure_exists rpm
			CMD="rpm -qlp"
			;;
		deb)
			assure_exists dpkg
			CMD="dpkg --contents"
			;;
		*)
			fatal "Have no suitable query command for $PMTYPE"
			;;
	esac

	docmd $CMD $@ | less
}

__epm_filelist_name()
{
	local CMD

	[ -z "$*" ] && return

	warmup_lowbase

	case $PMTYPE in
		*-rpm)
			CMD="rpm -ql"
			;;
		*-dpkg)
			CMD="dpkg -L"
			;;
		android)
			CMD="pm list packages -f"
			;;
		conary)
			CMD="conary query --ls"
			;;
		pacman)
			docmd pacman -Ql $@ | sed -e "s|.* ||g" | less
			return
			;;
		emerge)
			assure_exists equery
			CMD="equery files"
			;;
		homebrew)
			CMD="brew list"
			;;
		pkgng)
			CMD="pkg info -l"
			;;
		xbps)
			CMD="xbps-query -f"
			;;
		aptcyg)
			docmd apt-cyg listfiles $@ | sed -e "s|^|/|g"
			return
			;;
		slackpkg)
			is_installed $@ || fatal "Query filelist for non installed packages is not implemented yet"
			docmd awk 'BEGIN{desk=1}{if(/^FILE LIST:$/){desk=0} else if (desk==0) {print}}' /var/log/packages/${pkg_filenames}* | less
			return
			;;
		*)
			fatal "Have no suitable query command for $PMTYPE"
			;;
	esac

	# TODO: add less
	docmd $CMD $@ && return
	# TODO: may be we need check is installed before prev. line?
	is_installed $@ || __epm_filelist_remote $@
}


epm_filelist()
{
	[ -n "$pkg_filenames" ] || fatal "Filelist: missing package(s) name"


	__epm_filelist_file $pkg_files || return
	# shellcheck disable=SC2046
	__epm_filelist_name $(print_name $pkg_names) || return

}

# File bin/epm-info:


__epm_info_rpm_low()
{
	if [ -n "$pkg_files" ] ; then
		docmd rpm -qip $pkg_files
	fi
	[ -z "$pkg_names" ] && return
	is_installed $pkg_names && docmd rpm -qi $pkg_names && return
}

__epm_info_by_pkgtype()
{
	[ -n "$pkg_files" ] || return 1

	case $(get_package_type $pkg_files) in
		rpm)
			__epm_info_rpm_low && return
			;;
		deb)
			docmd dpkg -I $pkg_files
			;;
		*)
			return 1
			;;
	esac
}

__epm_info_by_pmtype()
{
case $PMTYPE in
	apt-rpm)
		__epm_info_rpm_low && return
		docmd apt-cache show $pkg_names
		;;
	apt-dpkg)
		if [ -n "$pkg_files" ] ; then
			docmd dpkg -I $pkg_files
		fi
		[ -z "$pkg_names" ] && return
		is_installed $pkg_names && docmd dpkg -p $pkg_names && return
		docmd apt-cache show $pkg_names
		;;
	aptitude-dpkg)
		if [ -n "$pkg_files" ] ; then
			docmd dpkg -I $pkg_files
		fi
		[ -z "$pkg_names" ] && return
		docmd aptitude show $pkg_names
		;;
	yum-rpm)
		__epm_info_rpm_low && return
		docmd yum info $pkg_names
		;;
	urpmi-rpm)
		__epm_info_rpm_low && return
		docmd urpmq -i $pkg_names
		;;
	dnf-rpm)
		__epm_info_rpm_low && return
		docmd dnf info $pkg_names
		;;
	zypper-rpm)
		__epm_info_rpm_low && return
		docmd zypper info $pkg_names
		;;
	pacman)
		is_installed $pkg_names && docmd pacman -Qi $pkg_names && return
		docmd pacman -Si $pkg_names
		;;
	aura)
		is_installed $pkg_names && docmd pacman -Qi $pkg_names && return
		docmd aura -Ai $pkg_names
		;;
	npackd)
		# FIXME: --version=
		docmd npackdcl info --package=$pkg_names
		;;
	conary)
		is_installed $pkg_names && docmd conary query $pkg_names --info && return
		docmd conary repquery $pkg_names --info
		;;
	emerge)
		assure_exists equery
		docmd equery meta $pkg_names
		docmd equery which $pkg_names
		docmd equery uses $pkg_names
		docmd equery size $pkg_names
		;;
	slackpkg)
		docmd /usr/sbin/slackpkg info $pkg_names
		;;
	ipkg)
		docmd ipkg info $pkg_names
		;;
	pkgng)
		docmd pkg info $pkg_names
		;;
	xbps)
		docmd xbps-query --show $pkg_names
		;;
	homebrew)
		docmd brew info $pkg_names
		;;
	aptcyg)
		docmd apt-cyg show $pkg_names
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac
}


epm_info()
{

if [ -n "$pkg_urls" ] ; then
    __handle_pkg_urls_to_checking
fi

[ -n "$pkg_filenames" ] || fatal "Info: missing package(s) name"

__epm_info_by_pkgtype || __epm_info_by_pmtype

local RETVAL=$?

[ -n "$to_remove_pkg_files" ] && rm -fv $to_remove_pkg_files
[ -n "$to_remove_pkg_files" ] && rmdir -v $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null

return $RETVAL
}

# File bin/epm-install:


filter_out_installed_packages()
{
	[ -z "$skip_installed" ] && cat && return

	case $PKGFORMAT in
		"rpm")
			LANG=C LC_ALL=C xargs -n1 rpm -q 2>&1 | grep 'is not installed' |
				sed -e 's|^.*package \(.*\) is not installed.*|\1|g'
			;;
		# dpkg -l lists some non ii status (un, etc)
		#"deb")
		#	LANG=C LC_ALL=C xargs -n1 dpkg -l 2>&1 | grep -i 'no packages found matching' |
		#		sed -e 's|\.\+$||g' -e 's|^.*[Nn]o packages found matching \(.*\)|\1|g'
		#	;;
		*)
			# shellcheck disable=SC2013
			for i in $(cat) ; do
				is_installed $i || echo $i
			done
			;;
	esac | sed -e "s|rpm-build-altlinux-compat[^ ]*||g" | filter_strip_spaces
}

__use_zypper_no_gpg_checks()
{
    a='' zypper install --help 2>&1 | grep -q -- "--no-gpg-checks" && echo "--no-gpg-checks"
}

__separate_sudocmd_foreach()
{
    local cmd_re=$1
    local cmd_in=$2
    shift 2
    separate_installed $@
    if [ -n "$pkg_noninstalled" ] ; then
        sudocmd_foreach "$cmd_re" $pkg_noninstalled || return
    fi
    if [ -n "$pkg_installed" ] ; then
        sudocmd_foreach "$cmd_in" $pkg_installed || return
    fi
    return 0
}

__separate_sudocmd()
{
    local cmd_re=$1
    local cmd_in=$2
    shift 2
    separate_installed $@
    if [ -n "$pkg_noninstalled" ] ; then
        sudocmd "$cmd_re" $pkg_noninstalled || return
    fi
    if [ -n "$pkg_installed" ] ; then
        sudocmd "$cmd_in" $pkg_installed || return
    fi
    return 0
}

epm_install_names()
{
	[ -z "$1" ] && return

	warmup_hibase

	if [ -n "$non_interactive" ] ; then
		epm_ni_install_names "$@"
		return
	fi

	case $PMTYPE in
		apt-rpm|apt-dpkg)
			APTOPTIONS="$APTOPTIONS $(subst_option verbose "-o Debug::pkgMarkInstall=1 -o Debug::pkgProblemResolver=1")"
			sudocmd apt-get $APTOPTIONS $noremove install $@
			return ;;
		aptitude-dpkg)
			sudocmd aptitude install $@
			return ;;
		deepsolver-rpm)
			sudocmd ds-install $@
			return ;;
		urpm-rpm)
			sudocmd urpmi $URPMOPTIONS $@
			return ;;
		pkgsrc)
			sudocmd pkg_add -r $@
			return ;;
		pkgng)
			sudocmd pkg install $@
			return ;;
		emerge)
			sudocmd emerge -uD $@
			return ;;
		pacman)
			sudocmd pacman -S $force $nodeps $@
			return ;;
		aura)
			sudocmd aura -A $force $nodeps $@
			return ;;
		yum-rpm)
			sudocmd yum $YUMOPTIONS install $@
			return ;;
		dnf-rpm)
			sudocmd dnf install $@
			return ;;
		snappy)
			sudocmd snappy install $@
			return ;;
		zypper-rpm)
			sudocmd zypper install $ZYPPEROPTIONS $@
			return ;;
		mpkg)
			sudocmd mpkg install $@
			return ;;
		conary)
			sudocmd conary update $@
			return ;;
		npackd)
			# FIXME: correct arg
			__separate_sudocmd_foreach "npackdcl add --package=" "npackdcl update --package=" $@
			return ;;
		slackpkg)
			__separate_sudocmd_foreach "/usr/sbin/slackpkg install" "/usr/sbin/slackpkg upgrade" $@
			return ;;
		homebrew)
			# FIXME: sudo and quote
			SUDO='' __separate_sudocmd "brew install" "brew upgrade" "$@"
			return ;;
		ipkg)
			[ -n "$force" ] && force=-force-depends
			sudocmd ipkg $force install $@
			return ;;
		nix)
			__separate_sudocmd "nix-env --install" "nix-env --upgrade" "$@"
			return ;;
		apk)
			sudocmd apk add $@
			return ;;
		tce)
			sudocmd tce-load -wi $@
			return ;;
		guix)
			__separate_sudocmd "guix package -i" "guix package -i" $@
			return ;;
		android)
			fatal "We still have no idea how to use package repository, ever if it is F-Droid."
			return ;;
		aptcyg)
			sudocmd apt-cyg install $@
			return ;;
		xbps)
			sudocmd xbps-install $@
			return ;;
		*)
			fatal "Have no suitable install command for $PMTYPE"
			;;
	esac
}

epm_ni_install_names()
{
	[ -z "$1" ] && return

	case $PMTYPE in
		apt-rpm|apt-dpkg)
			export DEBIAN_FRONTEND=noninteractive
			sudocmd apt-get -y $noremove --force-yes -o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $APTOPTIONS install $@
			return ;;
		aptitude-dpkg)
			sudocmd aptitude -y install $@
			return ;;
		yum-rpm)
			sudocmd yum -y $YUMOPTIONS install $@
			return ;;
		dnf-rpm)
			sudocmd dnf -y $YUMOPTIONS install $@
			return ;;
		urpm-rpm)
			sudocmd urpmi --auto $URPMOPTIONS $@
			return ;;
		zypper-rpm)
			# FIXME: returns true ever no package found, need check for "no found", "Nothing to do."
			yes | sudocmd zypper --non-interactive $ZYPPEROPTIONS install $@
			return ;;
		pkgsrc)
			sudocmd pkg_add -r $@
			return ;;
		pkgng)
			sudocmd pkg install -y $@
			return ;;
		emerge)
			sudocmd emerge -uD $@
			return ;;
		pacman)
			sudocmd pacman -S --noconfirm $force $nodeps $@
			return ;;
		aura)
			sudocmd aura -A $force $nodeps $@
			return ;;
		npackd)
			#  npackdcl update --package=<package> (remove old and install new)
			sudocmd npackdcl add --package="$*"
			return ;;
		chocolatey)
			docmd chocolatey install $@
			return ;;
		ipkg)
			sudocmd ipkg -force-defaults install $@
			return ;;
		nix)
			sudocmd nix-env --install $@
			return ;;
		apk)
			sudocmd apk add $@
			return ;;
		tce)
			sudocmd tce-load -wi $@
			return ;;
		xbps)
			sudocmd xbps-install -y $@
			return ;;
		homebrew)
			# FIXME: sudo and quote
			SUDO='' __separate_sudocmd "brew install" "brew upgrade" $@
			return ;;
		#android)
		#	sudocmd pm install $@
		#	return ;;
		slackpkg)
			# FIXME: broken status when use batch and default answer
			__separate_sudocmd_foreach "/usr/sbin/slackpkg -batch=on -default_answer=yes install" "/usr/sbin/slackpkg -batch=on -default_answer=yes upgrade" $@
			return ;;
		*)
			fatal "Have no suitable appropriate install command for $PMTYPE"
			;;
	esac
}

__epm_check_if_rpm_already_installed()
{
	# Not: we can make optimize if just check version?
	LANG=C $SUDO rpm -Uvh $force $nodeps $@ 2>&1 | grep -q "is already installed"
}

__epm_check_if_try_install_deb()
{
	local pkg
	local debpkgs=""
	for pkg in $@ ; do
		[ "$(get_package_type "$pkg")" = "deb" ] || return 1
		[ -e "$pkg" ] || fatal "Can't read $pkg"
		debpkgs="$debpkgs $(realpath $pkg)"
	done
	[ -n "$debpkgs" ] || return 1

	assure_exists alien

	local TDIR=$(mktemp -d)
	cd $TDIR || fatal
	for pkg in $debpkgs ; do
		# TODO: fakeroot for non ALT?
		showcmd_store_output alien -r -k --scripts "$pkg" || fatal
		local RPMCONVERTED=$(grep "rpm generated" $RC_STDOUT | sed -e "s| generated||g")
		clean_store_output
		epm install $RPMCONVERTED
	done
	rm -f $TDIR/*
	rmdir $TDIR/

	return 0
}

__epm_check_if_try_install_rpm()
{
	local pkg
	local rpmpkgs=""
	for pkg in $@ ; do
		[ "$(get_package_type "$pkg")" = "rpm" ] || return 1
		[ -e "$pkg" ] || fatal "Can't read $pkg"
		rpmpkgs="$rpmpkgs $(realpath $pkg)"
	done
	[ -n "$rpmpkgs" ] || return 1

	assure_exists alien
	assure_exists fakeroot

	local TDIR=$(mktemp -d)
	cd $TDIR || fatal
	for pkg in $rpmpkgs ; do
		showcmd_store_output fakeroot alien -d -k --scripts "$pkg"
		local DEBCONVERTED=$(grep "deb generated" $RC_STDOUT | sed -e "s| generated||g")
		clean_store_output
		epm install $DEBCONVERTED
	done
	rm -f $TDIR/*
	rmdir $TDIR/

	return 0
}

__handle_direct_install()
{
    case "$DISTRNAME" in
        "ALTLinux")
            local pkg url
            for pkg in $pkg_names ; do
                url=$(__epm_get_altpkg_url $pkg)
                [ -n "$url" ] || continue
                # TODO: use estrlist
                pkg_urls="$pkg_urls $url"
            done
            # FIXME: need remove
            pkg_names=""
            ;;
    esac
}

epm_install_files()
{
    [ -z "$1" ] && return

    # TODO: check read permissions
    # sudo test -r FILE
    # do not fallback to install_names if we have no permissions

    case $PMTYPE in
        apt-rpm)
            __epm_check_if_try_install_deb $@ && return

            # do not use low-level for install by file path
            if ! is_dirpath "$@" || [ "$(get_package_type "$@")" = "rpm" ] ; then
                sudocmd rpm -Uvh $force $nodeps $@ && return
                local RES=$?
                # TODO: check rpm result code and convert it to compatible format if possible
                __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level
            [ -n "$nodeps" ] && return $RES
            fi

            # use install_names
            ;;

        apt-dpkg|aptitude-dpkg)
            # the new version of the conf. file is installed with a .dpkg-dist suffix
            if [ -n "$non_interactive" ] ; then
                DPKGOPTIONS="--force-confdef --force-confold"
            fi

            __epm_check_if_try_install_rpm $@ && return

            # FIXME: return false in case no install and in case install with broken deps
            sudocmd dpkg $DPKGOPTIONS -i $@
            local RES=$?
            # if run with --nodeps, do not fallback on hi level

            [ -n "$nodeps" ] && return $RES
            # fall to apt-get -f install for fix deps
            # can't use APTOPTIONS with empty install args
            epm_install_names -f

            # repeat install for get correct status
            sudocmd dpkg $DPKGOPTIONS -i $@
            return
            ;;

        yum-rpm|dnf-rpm)
            __epm_check_if_try_install_deb $@ && return

            sudocmd rpm -Uvh $force $nodeps $@ && return
            # if run with --nodeps, do not fallback on hi level

            __epm_check_if_rpm_already_installed $@ && return

            [ -n "$nodeps" ] && return
            YUMOPTIONS=--nogpgcheck
            # use install_names
            ;;

        zypper-rpm)
            __epm_check_if_try_install_deb $@ && return
            sudocmd rpm -Uvh $force $nodeps $@ && return
            local RES=$?

            __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level

            [ -n "$nodeps" ] && return $RES
            ZYPPEROPTIONS=$(__use_zypper_no_gpg_checks)
            # use install_names
            ;;

        urpm-rpm)
            __epm_check_if_try_install_deb $@ && return
            sudocmd rpm -Uvh $force $nodeps $@ && return
            local RES=$?

            __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level
            [ -n "$nodeps" ] && return $RES

            URPMOPTIONS=--no-verify-rpm
            # use install_names
            ;;
        pkgsrc)
            sudocmd pkg_add $@
            return ;;
        pkgng)
            local PKGTYPE="$(get_package_type $@)"
            case "$PKGTYPE" in
                tbz)
                    sudocmd pkg_add $@
                    ;;
                *)
                    sudocmd pkg add $@
                    ;;
            esac
            return ;;
        android)
            sudocmd pm install $@
            return ;;
        emerge)
            sudocmd epm_install_emerge $@
            return ;;
        pacman)
            sudocmd pacman -U --noconfirm $force $nodeps $@ && return
            local RES=$?

            [ -n "$nodeps" ] && return $RES
            sudocmd pacman -U $force $@
            return ;;
        slackpkg)
            # FIXME: check for full package name
            # FIXME: broken status when use batch and default answer
            __separate_sudocmd_foreach "/sbin/installpkg" "/sbin/upgradepkg" $@
            return ;;
    esac

    # other systems can install file package via ordinary command
    epm_install_names "$@"
}

epm_print_install_command()
{
    # print out low level command by default (wait --low-level for control it)
    #[ -z "$1" ] && return
    [ -z "$1" ] && [ -n "$pkg_names" ] && return
    case $PMTYPE in
        apt-rpm|yum-rpm|urpm-rpm|zypper-rpm|dnf-rpm)
            echo "rpm -Uvh --force $nodeps $*"
            ;;
        apt-dpkg|aptitude-dpkg)
            echo "dpkg -i $*"
            ;;
        pkgsrc)
            echo "pkg_add $*"
            ;;
        pkgng)
            echo "pkg add $*"
            ;;
        emerge)
            # need be placed in /usr/portage/packages/somewhere
            echo "emerge --usepkg $*"
            ;;
        pacman)
            echo "pacman -U --noconfirm --force $nodeps $*"
            ;;
        slackpkg)
            echo "/sbin/installpkg $*"
            ;;
        npackd)
            echo "npackdcl add --package=$*"
            ;;
        ipkg)
            echo "ipkg install $*"
            ;;
        android)
            echo "pm install $*"
            ;;
        aptcyg)
            echo "apt-cyg install $*"
            ;;
        tce)
            echo "tce-load -wi $*"
            ;;
        xbps)
            echo "xbps-install -y $*"
            ;;
        homebrew)
            # FIXME: sudo and quote
            echo "brew install $*"
            ;;

        *)
            fatal "Have no suitable appropriate install command for $PMTYPE"
            ;;
    esac
}

epm_print_install_names_command()
{
	# check for pkg_files to support print out command without pkg names in args
	#[ -z "$1" ] && [ -n "$pkg_files" ] && return
	[ -z "$1" ] && return
	case $PMTYPE in
		apt-rpm|apt-dpkg)
			echo "apt-get -y --force-yes -o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true $APTOPTIONS install $*"
			return ;;
		aptitude-dpkg)
			echo "aptitude -y install $*"
			return ;;
		yum-rpm)
			echo "yum -y $YUMOPTIONS install $*"
			return ;;
		dnf-rpm)
			echo "dnf -y $YUMOPTIONS install $*"
			return ;;
		urpm-rpm)
			echo "urpmi --auto $URPMOPTIONS $*"
			return ;;
		zypper-rpm)
			echo "zypper --non-interactive $ZYPPEROPTIONS install $*"
			return ;;
		pacman)
			echo "pacman -S --noconfirm $force $*"
			return ;;
		chocolatey)
			echo "chocolatey install $*"
			return ;;
		nix)
			echo "nix-env --install $*"
			return ;;
		*)
			fatal "Have no suitable appropriate install command for $PMTYPE"
			;;
	esac
}


epm_install()
{
    if tasknumber "$pkg_names" >/dev/null ; then
        assure_exists apt-repo
        sudocmd apt-repo test $(tasknumber "$pkg_names")
        return
    fi

    if [ -n "$show_command_only" ] ; then
        epm_print_install_command $pkg_files
        epm_print_install_names_command $pkg_names
        return
    fi

    if [ -n "$direct" ] ; then
        __handle_direct_install
    fi

    # if possible, it will put pkg_urls into pkg_files or pkg_names
    if [ -n "$pkg_urls" ] ; then
        __handle_pkg_urls_to_install
    fi

    [ -z "$pkg_files$pkg_names" ] && info "Skip empty install list" && return 22

    # to be filter happy
    warmup_lowbase

    local names="$(echo $pkg_names | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    # can be empty only after skip installed
    if [ -z "$files$names" ] ; then
        # TODO: assert $skip_installed
        [ -n "$verbose" ] && info "Skip empty install list"
        return 22
    fi

    if [ -z "$files" ] && [ -z "$direct" ] ; then
        # it is useful for first time running
        update_repo_if_needed
    fi

    epm_install_names $names || return
    epm_install_files $files
    local RETVAL=$?

    # TODO: reinvent
    [ -n "$to_remove_pkg_files" ] && rm -fv $to_remove_pkg_files
    [ -n "$to_remove_pkg_files" ] && rmdir -v $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null

    return $RETVAL
}

# File bin/epm-Install:


epm_Install()
{
    # copied from epm_install
    local names="$(echo $pkg_names | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    [ -z "$files$names" ] && info "Install: Skip empty install list." && return 22

	# do update only if really need install something
	case $PMTYPE in
		yum-rpm)
			;;
		*)
			pkg_filenames='' epm_update || return
			;;
	esac

    epm_install_names $names || return
    epm_install_files $files

}

# File bin/epm-install-emerge:



__emerge_install_ebuild()
{
	local EBUILD="$1"
	[ -s "$EBUILD" ] || fatal ".ebuild file '$EBUILD' is missing"

	# load ebuild and get vars
	. $(pwd)/$EBUILD
	[ -n "$SRC_URI" ] || fatal "Can't load SRC_URI from $EBUILD"

	# try to detect tarballs
	local TARBALLS=
	local BASEDIR=$(dirname $EBUILD)
	for i in $SRC_URI ; do
		[ -s "$BASEDIR/$(basename $i)" ] || continue
		TARBALLS="$TARBALLS $BASEDIR/$(basename $i)"
	done

	local PORTAGENAME=epm
	local LP=/usr/local/portage/$PORTAGENAME
	docmd mkdir -p $LP/
	MAKECONF=/etc/portage/make.conf
	[ -r "$MAKECONF" ] || MAKECONF=/etc/make.conf
	if ! grep -v "^#" $MAKECONF | grep -q $LP ; then
		echo "PORTDIR_OVERLAY=\"$LP \${PORTDIR_OVERLAY}\"" >>$MAKECONF
		# Overlay name
		mkdir -p $LP/profiles/
		echo "$PORTAGENAME" > $LP/profiles/repo_name
	fi

	# copy tarballs
	local DDIR=/usr/portage/distfiles
	# FIXME: use independent dir
	[ -d /var/calculate/remote/distfiles ] && DDIR=/var/calculate/remote/distfiles
	docmd cp -f $TARBALLS $DDIR/ || return

	# copy ebuild
	docmd cp -f $EBUILD $LP/ || return
	cd $LP
	docmd ebuild $(basename $EBUILD) digest
	cd -
	# FIXME: more correcty get name
	local PKGNAME=$(echo $EBUILD | sed -e "s|-[0-9].*||g")
	docmd emerge -av $PKGNAME || return
}

__emerge_install_tbz2()
{
	local TGDIR=/usr/portage/packages/app-arch
	mkdir -p $TGDIR
	cp $i $TGDIR || return
	docmd emerge --usepkg $TGDIR/$(basename $i) || return
}

epm_install_emerge()
{
	local EBUILD=
	#local TARBALLS=
	local i

	# search ebuild in the args
	for i in $* ; do
		if echo $i | grep -q ebuild ; then
			__emerge_install_ebuild $i || return
		elif echo $i | grep -q "\.tbz2$" ; then
			__emerge_install_tbz2 $i || return
	#	else
	#		TARBALLS="$TARBALLS $i"
		fi
	done
}

# File bin/epm-kernel_update:


epm_kernel_update()
{
	warmup_bases

	info "Updating system kernel to the latest version..."

	case $DISTRNAME in
	ALTLinux)
		if ! __epm_query_package kernel-image >/dev/null ; then
			info "No installed kernel packages, skipping update"
			return
		fi
		assure_exists update-kernel update-kernel 0.9.9
		update_repo_if_needed
		sudocmd update-kernel $pkg_filenames || return
		docmd epm remove-old-kernels $pkg_filenames || fatal
		return ;;
	esac

	case $PMTYPE in
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-optimize:

__repack_rpm_base()
{
	assure_exists db_dump || fatal
	assure_exists db_load || fatal
	cd /var/lib/rpm || fatal
	mv Packages Packages.BACKUP || fatal
	# mask dependencies with a=
	a='' db_dump Packages.BACKUP | a='' db_load Packages || fatal
	rm Packages.BACKUP
}

epm_optimize()
{

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

case $PMTYPE in
	*-rpm)
		#__repack_rpm_base
		#rm -f /var/lib/rpm/__db*
		rpm --rebuilddb
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-packages:


__epm_packages_sort()
{
case $PMTYPE in
	apt-rpm|yum-rpm|urpm-rpm|zypper-rpm|dnf-rpm)
		# FIXME: space with quotes problems, use point instead
		warmup_rpmbase
		docmd rpm -qa --queryformat "%{size}@%{name}-%{version}-%{release}\n" $pkg_filenames | sed -e "s|@| |g" | sort -n -k1
		;;
	apt-dpkg)
		warmup_dpkgbase
		docmd dpkg-query -W --showformat="\${Installed-Size}@\${Package}-\${Version}\n" $pkg_filenames | sed -e "s|@| |g" | sort -n -k1
		;;
	*)
		fatal "Sorted package list function is not implemented for $PMTYPE"
		;;
esac
}

__aptcyg_print_full()
{
	#showcmd apt-cyg show
	local VERSION=$(apt-cyg show "$1" | grep -m1 "^version: " | sed -e "s|^version: ||g")
	echo "$1-$VERSION"
}

__fo_pfn()
{
	grep -v "^$" | grep -- "$pkg_filenames"
}

epm_packages()
{
	local CMD
	[ -n "$sort" ] && __epm_packages_sort && return

case $PMTYPE in
	apt-rpm)
		warmup_rpmbase
		# FIXME: strong equal
		CMD="rpm -qa $pkg_filenames"
		[ -n "$short" ] && CMD="rpm -qa --queryformat %{name}\n $pkg_filenames"
		docmd $CMD
		return ;;
	*-dpkg)
		warmup_dpkgbase
		# FIXME: strong equal
		#CMD="dpkg -l $pkg_filenames"
		CMD="dpkg-query -W --showformat=\${db:Status-Abbrev}\${Package}-\${Version}\n $pkg_filenames"
		[ -n "$short" ] && CMD="dpkg-query -W --showformat=\${db:Status-Abbrev}\${Package}\n $pkg_filenames"
		showcmd $CMD
		$CMD | grep "^i" | sed -e "s|.* ||g" | __fo_pfn
		return ;;
	snappy)
		CMD="snappy info"
		;;
	yum-rpm|urpm-rpm|zypper-rpm|dnf-rpm)
		warmup_rpmbase
		# FIXME: strong equal
		CMD="rpm -qa $pkg_filenames"
		[ -n "$short" ] && CMD="rpm -qa --queryformat %{name}\n $pkg_filenames"
		docmd $CMD
		return ;;
	emerge)
		CMD="qlist -I -C"
		# print with colors for console output
		isatty && CMD="qlist -I"
		;;
	pkgsrc)
		CMD="pkg_info"
		showcmd $CMD
		$CMD | sed -e "s| .*||g" | __fo_pfn
		return ;;
	pkgng)
		if [ -n "$pkg_filenames" ] ; then
			CMD="pkg info -E $pkg_filenames"
		else
			CMD="pkg info"
		fi
		showcmd $CMD
		if [ -n "$short" ] ; then
		    $CMD | sed -e "s| .*||g" | sed -e "s|-[0-9].*||g" | __fo_pfn
		else
		    $CMD | sed -e "s| .*||g" | __fo_pfn
		fi
		return ;;
	pacman)
		CMD="pacman -Qs $pkg_filenames"
		showcmd $CMD
		if [ -n "$short" ] ; then
			$CMD | sed -e "s| .*||g" -e "s|.*/||g" | __fo_pfn
			return
		fi
		;;
	npackd)
		CMD="npackdcl list --status=installed"
		# TODO: use search if pkg_filenames is not empty
		;;
	conary)
		CMD="conary query"
		;;
	chocolatey)
		CMD="chocolatey list"
		;;
	slackpkg)
		CMD="ls -1 /var/log/packages/"
		if [ -n "$short" ] ; then
			# FIXME: does not work for libjpeg-v8a
			# TODO: remove last 3 elements (if arch is second from the last?)
			# FIXME this hack
			docmd ls -1 /var/log/packages/ | sed -e "s|-[0-9].*||g" | sed -e "s|libjpeg-v8a.*|libjpeg|g" | __fo_pfn
			return
		fi
		;;
	homebrew)
		docmd brew list | xargs -n1 echo
		;;
	ipkg)
		CMD="ipkg list"
		;;
	apk)
		CMD="apk info"
		;;
	tce)
		CMD="ls -1 /usr/local/tce.installed"
		;;
	guix)
		CMD="guix package -I"
		;;
	xbps)
		CMD="xbps-query -l"
		showcmd $CMD
		if [ -n "$short" ] ; then
			$CMD | sed -e "s|^ii ||g" -e "s| .*||g" -e "s|\(.*\)-.*|\1|g" | __fo_pfn
		else
			$CMD | sed -e "s|^ii ||g" -e "s| .*||g" | __fo_pfn
		fi
		return 0
		;;
	android)
		CMD="pm list packages"
		showcmd $CMD
		$CMD | sed -e "s|^package:||g" | __fo_pfn
		return
		;;
	aptcyg)
		CMD="apt-cyg list $pkg_filenames"
		if [ -z "$short" ] ; then
			showcmd $CMD
			# TODO: fix this slow way
			for i in $($CMD) ; do
				__aptcyg_print_full $i
			done
			return
		fi
		;;
	*)
		fatal "Have no suitable query command for $PMTYPE"
		;;
esac

docmd $CMD | __fo_pfn

}

# File bin/epm-policy:


epm_policy()
{

[ -n "$pkg_names" ] || fatal "Info: missing package(s) name"

warmup_bases

pkg_names=$(__epm_get_hilevel_name $pkg_names)

case $PMTYPE in
	apt-rpm)
		docmd apt-cache policy $pkg_names
		;;
	apt-dpkg)
		docmd apt-cache policy $pkg_names
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-print:


query_package_field()
{
	local FORMAT="%{$1}\n"
	shift
	local INSTALLED="-p"
	# if not file, drop -p for get from rpm base
	[ -e "$1" ] || INSTALLED=""
	rpmquery $INSTALLED --queryformat "$FORMAT" "$@"
}


print_binpkgfilelist()
{
	local PKGDIR=$1
	local PKGNAME=$(basename $2)
	find "$PKGDIR" ! -name '*\.src\.rpm' -name '*\.rpm' -execdir \
		rpmquery -p --qf='%{sourcerpm}\t%{name}-%{version}-%{release}.%{arch}.rpm\n' "{}" \; \
		| grep "^$PKGNAME[[:space:]].*" \
		| cut -f2 \
		| xargs -n1 -I "{}" echo -n "$PKGDIR/{} "
}

PKGNAMEMASK="\(.*\)-\([0-9].*\)-\(.*[0-9].*\)"

print_name()
{
    echo "$@" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK|\1|g"
}

print_version()
{
    echo "$1" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK|\2|g"
}

print_release()
{
    echo "$1" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK|\3|g"
}

print_pkgname()
{
    local i
    for i in $@ ; do
        # TODO: deb and other, arch string
        echo "$(basename "$i") " | sed -e "s|\.[a-z_0-9]*\.rpm||g" -e "s|\(.*\)_\(.*\)_[a-z_0-9]*\.deb|\1-\2|g"
    done
}

print_srcname()
{
    print_name "$(print_srcpkgname "$@")"
}

print_specname()
{
    # CHECKME: it is possible to have two or more specs in one package?
    rpm -qlp "$@" | grep "\.spec\$"
}

print_srcpkgname()
{
    query_package_field sourcerpm "$@"
}

compare_version()
{
    which rpmevrcmp 2>/dev/null >/dev/null || fatal "rpmevrcmp exists in ALT Linux only"
    rpmevrcmp "$@"
}

__epm_print()
{
    local WHAT="$1"
    shift
    local FNFLAG=
    local PKFLAG=
    [ "$1" = "from" ] && shift
    [ "$1" = "for" ] && shift
    [ "$1" = "in" ] && shift
    if [ "$1" = "filename" ] ; then
        FNFLAG="$1"
        shift
    fi

    if [ "$1" = "package" ] ; then
        PKFLAG="$1"
        shift
    fi

    case "$WHAT" in
        "")
            fatal "Use epm print help for get help."
            ;;
        "-h"|"--help"|"help")
cat <<EOF
  Examples:
    epm print name [from filename|for package] NN        print only name of package name or package file
    epm print version [from filename|for package] NN     print only version of package name or package file
    epm print release [from filename|for package] NN     print only release of package name or package file
    epm print field FF for package NN        print field of the package
    epm print pkgname from filename NN       print package name for the package file
    epm print srcname from filename NN       print source name for the package file
    epm print srcpkgname from [filename|package] NN    print source package name for the binary package file
    epm print specname from filename NN      print spec filename for the source package file
    epm print binpkgfilelist in DIR for NN   list binary package(s) filename(s) from DIR for the source package file
    epm print compare [package] version N1 N2          compare (package) versions and print -1, 0, 1
EOF
            ;;
        "name")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_name "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                query_package_field "name" "$@"
            else
                print_name "$@"
            fi
            ;;
        "version")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_version "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                query_package_field "version" "$@"
            else
                print_version "$@"
            fi
            ;;
        "release")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_release "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                query_package_field "release" "$@"
            else
                print_release "$@"
            fi
            ;;
        "field")
            [ -n "$1" ] || fatal "Arg is missed"
            local FIELD="$1"
            shift
            [ "$1" = "for" ] && shift
            query_package_field "$FIELD" "$@"
            ;;
        "pkgname")
            [ -n "$FNFLAG" ] || fatal "print $WHAT works only for filename(s)"
            [ -n "$1" ] || fatal "Arg is missed"
            # TODO: drop_pkg_extensions
            print_pkgname "$@"
            ;;
        "srcname")
            [ -n "$FNFLAG" ] || fatal "print $WHAT works only for filename(s)"
            [ -n "$1" ] || fatal "Arg is missed"
            print_srcname "$@"
            ;;
        "srcpkgname")
            [ -n "$FNFLAG" ] || [ -n "$PKFLAG" ] || fatal "print $WHAT works only for filename(s)"
            [ -n "$1" ] || fatal "Arg is missed"
            print_srcpkgname "$@"
            ;;
        "specname")
            [ -n "$FNFLAG" ] || [ -n "$PKFLAG" ] || fatal "print $WHAT works only for filename(s)"
            [ -n "$1" ] || fatal "Arg is missed"
            print_specname "$@"
            ;;
        "binpkgfilelist")
            # TODO: rpm only
            # TODO: replace get_binpkg_list
            local DIR="$1"
            shift
            [ "$1" = "for" ] && shift
            [ -n "$DIR" ] || fatal "DIR arg is missed"
            [ -n "$1" ] || fatal "source package filename is missed"
            print_binpkgfilelist "$DIR" "$1"
            ;;
        "compare")
            [ "$1" = "version" ] && shift
            [ -n "$1" ] || fatal "Arg is missed"
            #if [ -n "$PKFLAG" ] ; then
            #    query_package_field "name" "$@"
            #else
                 compare_version "$1" "$2"
            #fi
            ;;
        *)
            fatal "Unknown command $ epm print $WHAT. Use epm print help for get help."
            ;;
    esac
}


epm_print()
{

    [ -n "$pkg_filenames" ] || fatal "Missed args. Use epm print help for get help."
    # Note! do not quote args below (see eterbug #11863)
    # shellcheck disable=SC2046
    __epm_print $(eval echo $quoted_args)
}


# File bin/epm-programs:


epm_programs()
{
	case $DISTRNAME in
		FreeBSD|NetBSD|OpenBSD|Solaris)
			local DESKTOPDIR=/usr/local/share/applications
			;;
		*)
			local DESKTOPDIR=/usr/share/applications
			;;
	esac

	[ -d "$DESKTOPDIR" ] || fatal "There is no $DESKTOPDIR dir on the system."
	#find /usr/share/applications -type f -name "*.desktop" | while read f; do pkg_files="$f" quiet=1 short=1 epm_query_file ; done | sort -u
	showcmd "find $DESKTOPDIR -type f -print0 -name "*.desktop" | xargs -0 $0 -qf --quiet --short | sort -u"
	find $DESKTOPDIR -type f -print0 -name "*.desktop" | \
		xargs -0 $0 -qf --quiet --short | sort -u
}

# File bin/epm-provides:


epm_provides_files()
{
	local pkg_files="$*"
	[ -n "$pkg_files" ] || return

	local PKGTYPE="$(get_package_type $pkg_files)"

	case $PKGTYPE in
		rpm)
			assure_exists rpm
			docmd rpm -q --provides -p $pkg_files
			;;
		deb)
			assure_exists dpkg
			# FIXME: will we provide ourself?
			docmd dpkg -I $pkg_files | grep "^ *Provides:" | sed "s|^ *Provides:||g"
			;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac
}


epm_provides_names()
{
	local pkg_names="$*"
	local CMD
	[ -n "$pkg_names" ] || return

case $PMTYPE in
	apt-rpm)
		# FIXME: need fix for a few names case
		# TODO: separate this function to two section
		if is_installed $pkg_names ; then
			CMD="rpm -q --provides"
		else
			EXTRA_SHOWDOCMD=' | grep "Provides:"'
			docmd apt-cache show $pkg_names | grep "Provides:"
			return
		fi
		;;
	urpm-rpm|zypper-rpm|yum-rpm|dnf-rpm)
		if is_installed $pkg_names ; then
			CMD="rpm -q --provides"
		else
			fatal "FIXME: use hi level commands"
		fi
		;;
	emerge)
		assure_exists equery
		CMD="equery files"
		;;
	pkgng)
		CMD="pkg info -b"
		;;
	apt-dpkg)
		# FIXME: need fix for a few names case
		if is_installed $pkg_names ; then
			info "Please inform the author how to get provides from dpkg"
		fi
		#	CMD="rpm -q --provides"
		#else
			EXTRA_SHOWDOCMD=' | grep "Provides:"'
			docmd apt-cache show $pkg_names | grep "Provides:"
			return
		#fi
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

docmd $CMD $pkg_names

}

epm_provides()
{
	[ -n "$pkg_filenames" ] || fatal "Provides: missing package(s) name"

	epm_provides_files $pkg_files
	# shellcheck disable=SC2046
	epm_provides_names $(print_name $pkg_names)
}

# File bin/epm-query:



_get_grep_exp()
{
	local def="^$1$"
	[ "$PMTYPE" != "emerge" ] && echo "$def" && return
	# Gentoo hack: support for short package form
	echo "$1" | grep -q "/" && echo "$def" && return
	echo "/$1$"
}

_shortquery_via_packages_list()
{
	local res=1
	local grepexp
	local firstpkg=$1
	shift

	grepexp=$(_get_grep_exp $firstpkg)

	# TODO: we miss status due grep
	# Note: double call due stderr redirect
	# Note: we use short=1 here due grep by ^name$
	# separate first line for print out command
	short=1 pkg_filenames=$firstpkg epm_packages | grep -- "$grepexp" && res=0 || res=1

	local pkg
	for pkg in "$@" ; do
		grepexp=$(_get_grep_exp $pkg)
		short=1 pkg_filenames=$pkg epm_packages 2>/dev/null | grep -- "$grepexp" || res=1
	done

	return $res
}

_query_via_packages_list()
{
	local res=1
	local grepexp
	local firstpkg=$1
	shift

	grepexp=$(_get_grep_exp $firstpkg)

	# TODO: we miss status due grep
	# TODO: grep correctly
	# Note: double call due stderr redirect
	# Note: we use short=1 here due grep by ^name$
	# separate first line for print out command
	short=1 pkg_filenames=$firstpkg epm_packages | grep -q -- "$grepexp" && quiet=1 pkg_filenames=$firstpkg epm_packages && res=0 || res=1

	local pkg
	for pkg in "$@" ; do
		grepexp=$(_get_grep_exp $pkg)
		short=1 pkg_filenames=$pkg epm_packages 2>/dev/null | grep -q -- "$grepexp" && quiet=1 pkg_filenames=$pkg epm_packages || res=1
	done

	return $res
}

__epm_get_hilevel_nameform()
{
	[ -n "$*" ] || return

	case $PMTYPE in
		apt-rpm)
			# use # as delimeter for apt
			local pkg
			pkg=$(rpm -q --queryformat "%{NAME}#%{SERIAL}:%{VERSION}-%{RELEASE}\n" $1)
			echo $pkg | grep -q "(none)" && pkg=$(rpm -q --queryformat "%{NAME}#%{VERSION}-%{RELEASE}\n" $1)
			# HACK: can use only for multiple install packages like kernel
			echo $pkg | grep -q kernel || return 1
			echo $pkg
			return
			;;
		yum-rpm|dnf-rpm)
			# just use strict version with Epoch and Serial
			local pkg
			pkg=$(rpm -q --queryformat "%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" $1)
			echo $pkg | grep -q "(none)" && pkg=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" $1)
			echo $pkg
			return
			;;
		*)
			return 1
			;;
	esac
}

__epm_get_hilevel_name()
{
	local i
	for i in $@ ; do
		local pkg
		# get short form in pkg
		# FIXME: where we use it? continue or pkg=$i?
		quiet=1 pkg=$(__epm_query_shortname "$i") || pkg="$i" #continue # drop not installed packages
		# if already short form, skipped
		[ "$pkg" = "$i" ] && echo "$i" && continue
		# try get long form or use short form
		__epm_get_hilevel_nameform "$i" || echo $pkg
	done
}

__epm_query_file()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		*-rpm)
			CMD="rpm -qp"
			[ -n "$short" ] && CMD="rpm -qp --queryformat %{name}\n"
			;;
		*-dpkg)
			CMD="dpkg-deb --show --showformat=\${Package}-\${Version}\n"
			[ -n "$short" ] && CMD="dpkg-query --show --showformat=\${Package}\n"
			;;
		*)
			fatal "Do not know command for query file package"
			;;
	esac

	docmd $CMD $@
}

__epm_query_dpkg_check()
{
	local i
	for i in $@ ; do
		a='' dpkg -s $i >/dev/null 2>/dev/null || return
	done
	return 0
}

__epm_query_name()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		*-rpm)
			CMD="rpm -q"
			;;
		*-dpkg)
			#docmd dpkg -l $@ | grep "^ii"
			#CMD="dpkg-query -W --showformat=\${Package}-\${Version}\n"
			docmd dpkg-query -W "--showformat=\${Package}-\${Version}\n" $@ || return
			__epm_query_dpkg_check $@ || return
			return
			;;
		npackd)
			docmd "npackdcl path --package=$1"
			return
			;;
		conary)
			CMD="conary query"
			;;
		homebrew)
			docmd brew info "$1" >/dev/null 2>/dev/null && echo "$1" && return
			return 1
			;;
		pacman)
			docmd pacman -Q $@
			return
			;;
		# TODO: need to print name if exists
		#pkgng)
		#	CMD="pkg info -e"
		#	;;
		# Note: slackpkg info pkgname
		*)
			# default slow workaround
			_query_via_packages_list $@
			return
			;;
	esac

	docmd $CMD $@
}

__epm_query_shortname()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		*-rpm)
			CMD="rpm -q --queryformat %{name}\n"
			;;
		*-dpkg)
			#CMD="dpkg-query -W --showformat=\${Package}\n"
			docmd dpkg-query -W "--showformat=\${Package}\n" $@ || return
			__epm_query_dpkg_check $@ || return
			return
			;;
		npackd)
			docmd "npackdcl path --package=$1"
			return
			;;
		conary)
			CMD="conary query"
			;;
		homebrew)
			docmd brew info "$1" >/dev/null 2>/dev/null && echo "$1" && return
			return 1
			;;
		# TODO: check status
		#pacman)
		#	docmd pacman -Q $@ | sed -e "s| .*||g"
		#	return
		#	;;

		# TODO: need to print name if exists
		#pkgng)
		#	CMD="pkg info -e"
		#	;;
		# Note: slackpkg info pkgname
		*)
			# default slow workaround
			_shortquery_via_packages_list $@
			return
			;;
	esac

	docmd $CMD $@
}

is_installed()
{
	__epm_query_shortname "$@" >/dev/null 2>/dev/null
	# broken way to recursive call here (overhead!)
	#epm installed $@ >/dev/null 2>/dev/null
}

separate_installed()
{
	pkg_installed=
	pkg_noninstalled=
	for i in "$@" ; do
		is_installed $i && pkg_installed="$pkg_installed $i" || pkg_noninstalled="$pkg_noninstalled $i"
	done
}

epm_query()
{
	[ -n "$pkg_filenames" ] || fatal "Query: missing package(s) name"

	__epm_query_file $pkg_files || return

	if [ -n "$short" ] ; then
		# shellcheck disable=SC2046
		__epm_query_shortname $(print_name $pkg_names) || return
	else
		# shellcheck disable=SC2046
		__epm_query_name $(print_name $pkg_names) || return
	fi
}

# File bin/epm-query_file:


__abs_filename()
{
	if echo "$1" | grep -q "/" ; then
		echo "$1"
		return
	fi
	if [ -e "$1" ] ; then
		echo "$(pwd)/$1"
		return
	fi
	echo "$1"
}

__do_query_real_file()
{
	local TOFILE
	
	# get canonical path
	if [ -e "$1" ] ; then
		TOFILE="$(__abs_filename "$1")"
	else
		TOFILE=$(which "$1" 2>/dev/null || echo "$1")
		if [ "$TOFILE" != "$1" ] ; then
			info "Note: $1 is placed as $TOFILE"
		fi
	fi
	
	# get value of symbolic link
	if [ -L "$TOFILE" ] ; then
		local LINKTO
		__do_query "$TOFILE"
		LINKTO=$(readlink -f "$TOFILE")
		info "Note: $TOFILE is link to $LINKTO"
		__do_query_real_file "$LINKTO"
		return
	fi

	FULLFILEPATH="$TOFILE"
}

dpkg_print_name_version()
{
	local ver i
	for i in "$@" ; do
		ver=$(dpkg -s $i 2>/dev/null | grep "Version:" | sed -e "s|Version: ||g")
		if [ -z "$ver" ] ; then
			echo "$i"
		else
			echo "$i-$ver"
		fi
	done
}


__do_query()
{
    local CMD
    case $PMTYPE in
        apt-rpm)
            CMD="rpm -qf"
            ;;
        *-dpkg)
            showcmd dpkg -S "$1"
            dpkg_print_name_version "$(dpkg -S $1 | grep -v "^diversion by" | sed -e "s|:.*||")"
            return ;;
        yum-rpm|dnf-rpm|urpm-rpm)
            CMD="rpm -qf"
            ;;
        zypper-rpm)
            CMD="rpm -qf"
            ;;
        emerge)
            assure_exists equery
            CMD="equery belongs"
            ;;
        pacman)
            CMD="pacman -Qo"
            ;;
        pkgng)
            CMD="pkg which"
            ;;
        conary)
            CMD="conary query --path"
            ;;
        slackpkg)
            # note: need remove leading slash for grep
            docmd grep -R -- "$(echo $@ | sed -e 's|^/\+||g')" /var/log/packages | sed -e "s|/var/log/packages/||g"
            return
            ;;
        ipkg)
            CMD="ipkg files"
            ;;
        xbps)
            # FIXME: maybe it is search file?
            CMD="xbps-query -o"
            ;;
        aptcyg)
            #CMD="apt-cyg packageof"
            # is not implemented locally
            return 1
            ;;
        *)
            fatal "Have no suitable query command for $PMTYPE"
            ;;
    esac

    docmd $CMD $@
}


__do_short_query()
{
    local CMD
    case $PMTYPE in
        *-rpm)
            CMD="rpm -qf --queryformat %{NAME}\n"
            ;;
        NOapt-dpkg)
            showcmd dpkg -S "$1"
            dpkg_print_name_version "$(dpkg -S $1 | sed -e "s|:.*||" | grep -v "^diversion by")"
            return ;;
        NOemerge)
            assure_exists equery
            CMD="equery belongs"
            ;;
        NOpacman)
            CMD="pacman -Qo"
            ;;
        NOslackpkg)
            # note: need remove leading slash for grep
            docmd grep -R "$(echo $@ | sed -e 's|^/\+||g')" /var/log/packages | sed -e "s|/var/log/packages/||g"
            return
            ;;
        *)
            fatal "Have no suitable query command for $PMTYPE"
            ;;
    esac

    docmd $CMD $@
}


epm_query_file()
{
    # И где это используется?
    # in short mode print handle only real names and do short output
    # TODO: move to separate command?
    # FIXME: it is possible use query
    if [ -n "$short" ] ; then
        [ -n "$pkg_files$pkg_dirs" ] || fatal "Run query without file names (needed path to files)"
        __do_short_query $pkg_files $pkg_dirs
         return
    fi

    # file can exists or not
    [ -n "$pkg_filenames" ] || fatal "Run query without file names"



    for pkg in $pkg_filenames ; do
        __do_query_real_file "$pkg"
        __do_query "$FULLFILEPATH" || pkg_filenames="$FULLFILEPATH" epm_search_file
    done

}

# File bin/epm-query_package:


__epm_query_package()
{
	pkg_filenames="$*" quoted_args="$*" quiet=1 epm_query_package
}

epm_query_package()
{
	[ -n "$pkg_filenames" ] || fatal "Please, use search with some argument or run epmqa for get all packages."
	# FIXME: do it better
	local MGS
	MGS=$(eval __epm_search_make_grep $quoted_args)
	EXTRA_SHOWDOCMD=$MGS
	# Note: get all packages list and do grep
	eval "pkg_filenames='' epm_packages \"$(eval get_firstarg $quoted_args)\" $MGS"
}

# File bin/epm-reinstall:


epm_reinstall_names()
{
	[ -n "$1" ] || return

	case $PMTYPE in
		apt-rpm|apt-dpkg)
			local APTOPTIONS="$(subst_option non_interactive -y)"
			sudocmd apt-get --reinstall $APTOPTIONS install $@
			return ;;
		aptitude-dpkg)
			sudocmd aptitude reinstall $@
			return ;;
		yum-rpm)
			sudocmd yum reinstall $@
			return ;;
		dnf-rpm)
			sudocmd dnf reinstall $@
			return ;;
		pkgng)
			sudocmd pkg install -f $@
			return ;;
		slackpkg)
			sudocmd_foreach "/usr/sbin/slackpkg reinstall" $@
			return ;;
	esac

	# fallback to generic install
	epm_install_names $@
}

epm_reinstall_files()
{
    [ -z "$1" ] && return

    case $PMTYPE in
        apt-rpm)
            sudocmd rpm -Uvh --force $@ && return
            sudocmd apt-get --reinstall install $@
            return ;;
        apt-dpkg|aptitude-dpkg)
            sudocmd dpkg -i $@
            return ;;
        slackpkg)
            sudocmd_foreach "/sbin/installpkg" $@
            return ;;
    esac

    # other systems can install file package via ordinary command
    epm_reinstall_names $@
}


epm_reinstall()
{
    [ -n "$pkg_filenames" ] || fatal "Reinstall: missing package(s) name."

    warmup_lowbase

    # get package name for hi level package management command (with version if supported and if possible)
    pkg_names=$(__epm_get_hilevel_name $pkg_names)

    warmup_hibase

    epm_reinstall_names $pkg_names
    epm_reinstall_files $pkg_files
}


# File bin/epm-release_upgrade:


__replace_text_in_alt_repo()
{
	local i
	for i in /etc/apt/sources.list /etc/apt/sources.list.d/*.list ; do
		[ -s "$i" ] || continue
		regexp_subst "$1" "$i"
	done
}

__wcount()
{
	echo "$*" | wc -w
}

__detect_alt_release_by_repo()
{
	local BRD=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list \
		| grep -v "^#" \
		| grep "[tp][5-9]/branch/" \
		| sed -e "s|.*\([tp][5-9]\)/branch.*|\1|g" \
		| sort -u )
	if [ "$(__wcount $BRD)" = "1" ] ; then
		echo "$BRD"
		return
	fi

	local BRD=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list \
		| grep -v "^#" \
		| grep "Sisyphus/" \
		| sed -e "s|.*\(Sisyphus\).*|\1|g" \
		| sort -u )
	if [ "$(__wcount $BRD)" = "1" ] ; then
		echo "$BRD"
		return
	fi

	return 1
}

__replace_alt_version_in_repo()
{
	local i
	assure_exists apt-repo
	#echo "Upgrading $DISTRNAME from $1 to $2 ..."
	docmd apt-repo list | sed -e "s|\($1\)|{\1}->{$2}|g" | grep -E --color -- "$1"
	# ask and replace only we will have changes
	if a='' apt-repo list | grep -E -q -- "$1" ; then
		confirm "Are these correct changes? [y/N]" || fatal "Exiting"
		__replace_text_in_alt_repo "/^ *#/! s!$1!$2!g"
	fi
	docmd apt-repo list
}

__alt_repofix()
{
	showcmd epm repofix
	quiet=1 pkg_filenames='' epm_repofix >/dev/null
	__replace_text_in_alt_repo "/^ *#/! s!\[[tpc][6-9]\]![updates]!g"
}

__get_conflict_release_pkg()
{
	epmqf --quiet --short /etc/fedora-release | head -n1
}

get_fix_release_pkg()
{
	local TOINSTALL=''

	local FORCE=''
	if [ "$1" == "--force" ] ; then
		FORCE="$1"
		shift
	fi

	local TO="$1"

	echo "rpm apt"

	if [ "$TO" = "Sisyphus" ] ; then
		TO="sisyphus"
		echo "apt-conf-$TO"
	else
		echo "apt-conf-branch"
	fi

	if [ "$FORCE" == "--force" ] ; then
		# assure we have set needed release
		TOINSTALL="altlinux-release-$TO"
	else
		# just assure we have /etc/altlinux-release and switched from sisyphus
		if [ ! -s /etc/altlinux-release ] || epmqf /etc/altlinux-release | grep -q sisyphus ; then
			TOINSTALL="altlinux-release-$TO"
		fi
	fi

	# workaround against obsoleted altlinux-release-sisyphus package from 2008 year
	[ "$TOINSTALL" = "altlinux-release-sisyphus" ] && TOINSTALL="branding-alt-sisyphus-release"

	if [ -n "$TOINSTALL" ] ; then
		echo "$TOINSTALL"

		# workaround against
		#    file /etc/fedora-release from install of altlinux-release-p8-20160414-alt1 conflicts with file from package branding-simply-linux-release-8.2.0-alt1
		# problem
		if __get_conflict_release_pkg | grep -q -v "^altlinux-release" && [ "$TOINSTALL" != "$(__get_conflict_release_pkg)" ] ; then
			echo $(__get_conflict_release_pkg)-
		fi
	fi
}

__update_to_the_distro()
{
	local TO="$1"
	__alt_repofix
	case "$TO" in
		p7)
			docmd epm update || fatal
			docmd epm install "$(get_fix_release_pkg --force "$TO")" || fatal "Check an error and run epm release-upgrade again"
			__alt_repofix
			__replace_text_in_alt_repo "/^ *#/! s!\[updates\]![$TO]!g"
			docmd epm update || fatal
			docmd epm upgrade || fatal "Check an error and run epm release-upgrade again"
			;;
		p8)
			docmd epm update || fatal
			docmd epm install "$(get_fix_release_pkg --force "$TO")" || fatal "Check an error and run epm release-upgrade again"
			__alt_repofix
			__replace_text_in_alt_repo "/^ *#/! s!\[updates\]![$TO]!g"
			docmd epm update || fatal
			# sure we have systemd if systemd is running
			if is_installed systemd && is_active_systemd systemd ; then
				docmd epm install systemd || fatal
			fi
			docmd epm upgrade || fatal "Check an error and run epm release-upgrade again"
			;;
		Sisyphus)
			docmd epm update || fatal
			docmd epm install librpm7 librpm "$(get_fix_release_pkg --force "$TO")" || fatal "Check an error and run again"
			docmd epm upgrade || fatal "Check an error and run epm release-upgrade again"
			;;
		*)
	esac
}


__update_alt_to_next_distro()
{
	local TO="$2"
	local FROM="$1"
	[ -n "$TO" ] || TO="$FROM"
	info
 	case "$*" in
		"p6"|"p6 p7"|"t6 p7"|"c6 c7")
			TO="p7"
			info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")" || fatal
			__replace_alt_version_in_repo "$FROM/branch/" "$TO/branch/"
			__update_to_the_distro "$TO"
			docmd epm update-kernel
			info "Done."
			info "Run epm release-upgrade again for update to p8"
			;;
		"p7"|"p7 p8"|"t7 p8"|"c7 c8"|"p8 p8")
			TO="p8"
			info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")" || fatal
			__replace_alt_version_in_repo $FROM/branch/ $TO/branch/
			__update_to_the_distro $TO
			docmd epm update-kernel || fatal
			info "Done."
			;;
		"Sisyphus p8")
			TO="p8"
			info "Downgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")" || fatal
			__replace_alt_version_in_repo "$FROM/" "$FROM/branch/"
			__replace_text_in_alt_repo "/^ *#/! s!\[alt\]![$TO]!g"
			__update_to_the_distro $TO
			docmd epm downgrade || fatal
			info "Done."
			;;
		"p8 Sisyphus"|"Sisyphus Sisyphus")
			TO="Sisyphus"
			info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")" || fatal
			docmd epm upgrade || fatal
			__replace_alt_version_in_repo "$FROM/branch/" "$TO/"
			__alt_repofix
			__replace_text_in_alt_repo "/^ *#/! s!\[updates\]![alt]!g"
			__update_to_the_distro $TO
			docmd epm update-kernel || fatal
			info "Done."
			;;
		*)
			if [ "$FROM" = "$TO" ] ; then
				info "It seems your system is already updated to newest $DISTRNAME $TO"
			else
				warning "Have no idea how to update from $DISTRNAME $FROM to $DISTRNAME $TO."
			fi
			info "Try run f.i. # epm release-upgrade p8 or # epm release-upgrade Sisyphus"
			info "Also possible you need install altlinux-release-p? package for correct distro version detecting"
			return 1
	esac
}

epm_release_upgrade()
{
	assure_root
	info "Starting upgrade whole system to the next release"
	info "Check also http://wiki.etersoft.ru/Admin/UpdateLinux"

	# TODO: it is possible eatmydata does not do his work
	export EPMNOEATMYDATA=1

	case $DISTRNAME in
	ALTLinux)
		docmd epm update

		# try to detect current release by repo
		if [ "$DISTRVERSION" = "Sisyphus" ] || [ -z "$DISTRVERSION" ] ; then
			local dv
			dv="$(__detect_alt_release_by_repo)"
			if [ -n "$dv" ] && [ "$dv" != "$DISTRVERSION" ] ; then
				DISTRVERSION="$dv"
				info "Detected running $DISTRNAME $DISTRVERSION (according to using repos)"
			fi
		fi

		__alt_repofix

		# check forced target
		if [ -n "$pkg_filenames" ] ; then
			[ "$(__wcount $pkg_filenames)" = "1" ] || fatal "Too many args: $pkg_filenames"
		fi

		# TODO: ask before upgrade
		__update_alt_to_next_distro $DISTRVERSION $pkg_filenames
		return
		;;
	*)
		;;
	esac

	case $PMTYPE in
	apt-rpm)
		#docmd epm update
		info "Have no idea how to upgrade $DISTRNAME"
		;;
	*-dpkg)
		assure_exists do-release-upgrade update-manager-core
		sudocmd do-release-upgrade -d
		;;
	yum-rpm)
		docmd epm install rpm yum
		sudocmd yum clean all
		# TODO
		showcmd rpm -Uvh http://mirror.yandex.ru/fedora/linux/releases/16/Fedora/x86_64/os/Packages/fedora-release-16-1.noarch.rpm
		docmd epm Upgrade
		;;
	dnf-rpm)
		info "Check https://fedoraproject.org/wiki/DNF_system_upgrade for an additional info"
		docmd epm install dnf
		sudocmd dnf clean all
		assure_exists dnf-plugin-system-upgrade
		sudocmd dnf system-upgrade
		local RELEASEVER="$pkg_filenames"
		[ -n "$RELEASEVER" ] || RELEASEVER=$(($DISTRVERSION + 1))
		#[ -n "$RELEASEVER" ] || fatal "Run me with new version"
		info "Upgrate to $DISTRNAME/$RELEASEVER"
		sudocmd dnf system-upgrade download --refresh --releasever=$RELEASEVER
		sudocmd dnf distro-sync --releasever=$RELEASEVER
		info "Run epm autoorphans to remove orphaned packages"
		;;
	urpm-rpm)
		sudocmd urpmi.removemedia -av
		# TODO
		showcmd urpmi.addmedia --distrib http://mirror.yandex.ru/mandriva/devel/2010.2/i586/
		sudocmd urpmi --auto-update --replacefiles
		;;
	zypper-rpm)
		docmd epm repolist
		# TODO
		# sudocmd zypper rr <номер_репозитория>
		showcmd rr N
		showcmd epm ar http://mirror.yandex.ru/opensuse/distribution/11.1/repo/oss 11.1oss
		showcmd zypper ref
		docmd epm update
		docmd epm install rpm zypper
		docmd epm upgrade
		;;
	pacman)
		epm Upgrade
		;;
	conary)
		epm Upgrade
		;;
	emerge)
		epm Upgrade
		;;
	guix)
		sudocmd guix pull --verbose
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac

}

# File bin/epm-remove:


epm_remove_low()
{
	[ -z "$1" ] && return

	warmup_lowbase

	case $PMTYPE in
		apt-rpm|yum-rpm|zypper-rpm|urpm-rpm|dnf-rpm)
			sudocmd rpm -ev $nodeps $@
			return ;;
		apt-dpkg|aptitude-dpkg)
			# shellcheck disable=SC2046
			sudocmd dpkg -P $(subst_option nodeps --force-all) $(print_name "$@")
			return ;;
		pkgsrc)
			sudocmd pkg_delete -r $@
			return ;;
		pkgng)
			sudocmd pkg delete -R $@
			return ;;
		emerge)
			sudocmd emerge --unmerge $@
			return ;;
		pacman)
			sudocmd pacman -R $@
			return ;;
		slackpkg)
			sudocmd /sbin/removepkg $@
			return ;;
	esac
	return 1
}

epm_remove_names()
{
	[ -z "$1" ] && return

	warmup_bases

	case $PMTYPE in
		apt-dpkg)
			sudocmd apt-get remove --purge $APTOPTIONS $@
			return ;;
		aptitude-dpkg)
			sudocmd aptitude purge $@
			return ;;
		apt-rpm)
			sudocmd apt-get remove $APTOPTIONS $@
			return ;;
		deepsolver-rpm)
			sudocmd ds-remove $@
			return ;;
		urpm-rpm)
			sudocmd urpme $@
			return ;;
		pkgsrc) # without dependencies
			sudocmd pkg_delete $@
			return ;;
		pkgng)
			sudocmd pkg delete -R $@
			return ;;
		emerge)
			#sudocmd emerge --unmerge $@
			sudocmd emerge -aC $@
			return ;;
		pacman)
			sudocmd pacman -Rc $@
			return ;;
		yum-rpm)
			sudocmd yum remove $@
			return ;;
		dnf-rpm)
			sudocmd dnf remove $@
			return ;;
		snappy)
			sudocmd snappy uninstall $@
			return ;;
		zypper-rpm)
			sudocmd zypper remove --clean-deps $@
			return ;;
		mpkg)
			sudocmd mpkg remove $@
			return ;;
		conary)
			sudocmd conary erase $@
			return ;;
		npackd)
			sudocmd npackdcl remove --package=$1
			return ;;
		nix)
			sudocmd nix-env --uninstall $@
			return ;;
		apk)
			sudocmd apk del $@
			return ;;
		guix)
			sudocmd guix package -r $@
			return ;;
		android)
			sudocmd pm uninstall $@
			return ;;
		chocolatey)
			sudocmd chocolatey uninstall $@
			return ;;
		slackpkg)
			sudocmd /usr/sbin/slackpkg remove $@
			return ;;
		homebrew)
			docmd brew remove $@
			return ;;
		aptcyg)
			sudocmd apt-cyg remove $@
			return ;;
		xbps)
			sudocmd xbps remove -R $@
			return ;;
		ipkg)
			# shellcheck disable=SC2046
			sudocmd ipkg $(subst_option force -force-depends) remove $@
			return ;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac
}

epm_remove_nonint()
{
	warmup_bases

	case $PMTYPE in
		apt-dpkg)
			sudocmd apt-get -y --force-yes remove --purge $@
			return ;;
		aptitude-dpkg)
			sudocmd aptitude -y purge $@
			return ;;
		apt-rpm)
			sudocmd apt-get -y --force-yes remove $@
			return ;;
		urpm-rpm)
			sudocmd urpme --auto $@
			return ;;
		pacman)
			sudocmd pacman -Rc --noconfirm $@
			return ;;
		yum-rpm)
			sudocmd yum -y remove $@
			return ;;
		zypper-rpm)
			sudocmd zypper --non-interactive remove --clean-deps $@
			return ;;
		slackpkg)
			sudocmd /usr/sbin/slackpkg -batch=on -default_answer=yes remove $@
			return ;;
		pkgng)
			sudocmd pkg delete -y -R $@
			return ;;
		ipkg)
			sudocmd ipkg -force-defaults remove $@
			return ;;
		xbps)
			sudocmd xbps remove -y $@
			return ;;
	esac
	return 5
}

epm_print_remove_command()
{
	case $PMTYPE in
		apt-rpm|yum-rpm|zypper-rpm|urpm-rpm|dnf-rpm)
			echo "rpm -ev $nodeps $*"
			;;
		apt-dpkg|aptitude-dpkg)
			echo "dpkg -P $*"
			;;
		pkgsrc)
			echo "pkg_delete -r $*"
			;;
		pkgng)
			echo "pkg delete -R $*"
			;;
		pacman)
			echo "pacman -R $*"
			;;
		emerge)
			echo "emerge --unmerge $*"
			;;
		slackpkg)
			echo "/sbin/removepkg $*"
			;;
		ipkg)
			echo "ipkg remove $*"
			;;
		aptcyg)
			echo "apt-cyg remove $*"
			;;
		xbps)
			echo "xbps remove -y $*"
			;;
		*)
			fatal "Have no suitable appropriate remove command for $PMTYPE"
			;;
	esac
}


epm_remove()
{
	if [ -n "$show_command_only" ] ; then
		epm_print_remove_command $pkg_filenames
		return
	fi

	local tn=$(tasknumber "$pkg_names")
	if [ -n "$tn" ] ; then
		assure_exists apt-repo
		pkg_names=$(showcmd apt-repo list $tn)
		#docmd epm remove $dryrun
		return
	fi

	# get full package name(s) from the package file(s)
	[ -n "$pkg_files" ] && pkg_names="$pkg_names $(epm query $pkg_files)"

	[ -n "$pkg_names" ] || fatal "Remove: missing package(s) name."

	if [ -n "$dryrun" ] ; then
		info "Packages for removing:"
		echo "$pkg_names"
		case $PMTYPE in
			apt-rpm)
				nodeps="--test"
				APTOPTIONS="--simulate"
				;;
			*
				return
				;;
		esac
	fi

	epm_remove_low $pkg_names && return
	local STATUS=$?

	if [ -n "$direct" ] ; then
		return $STATUS
	fi

	# get package name for hi level package management command (with version if supported and if possible)
	pkg_names=$(__epm_get_hilevel_name $pkg_names)

	if [ -n "$non_interactive" ] ; then
		epm_remove_nonint $pkg_names
		local RET=$?
		# if not separate command, use usual command
		[ "$RET" = "5" ] || return $RET
	fi

	epm_remove_names $pkg_names
}


# File bin/epm-remove_old_kernels:


epm_remove_old_kernels()
{

	warmup_bases

	case $DISTRNAME in
	ALTLinux)
		if ! __epm_query_package kernel-image >/dev/null ; then
			info "No installed kernel packages, skipping cleaning"
			return
		fi
		assure_exists update-kernel update-kernel 0.9.9
		sudocmd remove-old-kernels $pkg_filenames
		return ;;
	Ubuntu)
		if ! __epm_query_package linux-image >/dev/null ; then
			info "No installed kernel packages, skipping cleaning"
			return
		fi
		info "Note: it is enough to use eepm autoremove for old kernel removing..."
		info "Check also http://ubuntuhandbook.org/index.php/2016/05/remove-old-kernels-ubuntu-16-04/"
		# http://www.opennet.ru/tips/2980_ubuntu_apt_clean_kernel_packet.shtml
		case $DISTRVERSION in
		10.04|12.04|14.04|15.04|15.10)
			assure_exists purge-old-kernels bikeshed
			;;
		*)
			# since Ubuntu 16.04
			assure_exists purge-old-kernels byobu
			;;
		esac
		sudocmd purge-old-kernels $pkg_filenames
		return ;;
	Gentoo)
		sudocmd emerge -P gentoo-sources
		return ;;
	VoidLinux)
		sudocmd vkpurge rm all
		return ;;
	esac

	case $PMTYPE in
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-removerepo:


epm_removerepo()
{
local repo="$(eval echo $quoted_args)"

case $DISTRNAME in
	ALTLinux)
		case "$repo" in
			autoimports)
				info "remove autoimports repo"
				[ -n "$DISTRVERSION" ] || fatal "Empty DISTRVERSION"
				repo="$repo.$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"
				;;
			archive)
				info "remove archive repos"
				assure_exists apt-repo
				epm repolist | grep "archive/" | while read repo ; do
					sudocmd apt-repo rm "$repo"
				done
				return 0
				;;
			tasks)
				info "remove task repos"
				assure_exists apt-repo
				epm repolist | grep "/repo/" | while read repo ; do
					sudocmd apt-repo rm "$repo"
				done
				return 0
				;;
			*)
				if tasknumber "$repo" >/dev/null ; then
					repo="$(epm repolist | grep "repo/$(tasknumber "$repo")" | line)"
					# "
				fi
				;;
		esac

		[ -n "$repo" ] || fatal "No such repo or task. Use epm remove repo [autoimports|archive|TASK]"
		assure_exists apt-repo
		sudocmd apt-repo rm "$repo"
		return
		;;
esac;

case $PMTYPE in
	apt-dpkg|aptitude-dpkg)
		info "You need remove repo from /etc/apt/sources.list"
		;;
	yum-rpm)
		assure_exists yum-utils
		sudocmd yum-config-manager --disable "$repo"
		;;
	urpm-rpm)
		sudocmd urpmi.removemedia "$repo"
		;;
	zypper-rpm)
		sudocmd zypper removerepo "$repo"
		;;
	emerge)
		sudocmd layman "-d$repo"
		;;
	pacman)
		info "You need remove repo from /etc/pacman.conf"
		;;
	npackd)
		sudocmd npackdcl remove-repo --url="$repo"
		;;
	slackpkg)
		info "You need remove repo from /etc/slackpkg/mirrors"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-repofix:


__repofix_check_vendor()
{
	local i
	for i in /etc/apt/vendors.list.d/*.list; do
		[ -e "$i" ] || continue
		grep -q "^simple-key \"$1\"" $i && return
	done
	return 1
}

__try_fix_apt_source_list()
{
	local list="$1"
	local br="$2"
	local path="$3"
	if grep -q -e "^[^#].*$path" $list ; then
		if __repofix_check_vendor $br ; then
			regexp_subst "/$path/s/^rpm[[:space:]]*([fhr])/rpm [$br] \1/" $list
		else
			warning "Skip set $br vendor key (it misssed) for $list"
			regexp_subst "/$path/s/^rpm[[:space:]]*\[$br\][[:space:]]*([fhr])/rpm \1/" $list
		fi
	fi
}

__fix_apt_sources_list()
{
	# for beauty spaces
	local SUBST_ALT_RULE='s!^(.*)[/ ](ALTLinux|LINUX\@Etersoft)[/ ](Sisyphus|p8[/ ]branch|p7[/ ]branch|t7[/ ]branch|c7[/ ]branch|p6[/ ]branch|t6[/ ]branch)[/ ](x86_64|i586|x86_64-i586|noarch) !\1 \2/\3/\4 !gi'
	local i
	assure_root
	for i in "$@" ; do
		[ -s "$i" ] || continue
		#perl -i.bak -pe "$SUBST_ALT_RULE" $i
		# TODO: only for uncommented strings
		#sed -i -r -e "$SUBST_ALT_RULE" $i
		regexp_subst "/^ *#/! $SUBST_ALT_RULE" $i

		# Sisyphus uses 'alt' vendor key
		__try_fix_apt_source_list $i alt "ALTLinux\/Sisyphus"
		__try_fix_apt_source_list $i etersoft "Etersoft\/Sisyphus"

		# skip branch replacement for ALT Linux Sisyphus
		[ "$DISTRVERSION" = "Sisyphus" ] && continue

		# add signs for branches
		__try_fix_apt_source_list $i $DISTRVERSION "ALTLinux\/$DISTRVERSION\/branch"
		__try_fix_apt_source_list $i etersoft "Etersoft\/$DISTRVERSION\/branch"
	done
}

epm_repofix()
{

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

case $PMTYPE in
	apt-rpm)
		assure_exists apt-repo
		[ -n "$quiet" ] || docmd apt-repo list
		__fix_apt_sources_list /etc/apt/sources.list
		__fix_apt_sources_list /etc/apt/sources.list.d/*.list
		docmd apt-repo list
		# FIXME: what the best place?
		# rebuild rpm database
		#sudocmd rm -fv /var/lib/rpm/__db*
		#sudocmd rpm --rebuilddb
		;;
	yum-rpm|dnf-rpm)
		# FIXME: what the best place?
		#sudocmd rm -fv /var/lib/rpm/__db*
		#sudocmd rpm --rebuilddb
		;;
	xbps)
		sudocmd xbps-pkgdb -a
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-repolist:

print_apt_sources_list()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        #echo
        #echo "$i:"
        grep -v -- "^#" $i
    done | grep -v -- "^ *\$"
}

epm_repolist()
{
case $PMTYPE in
	apt-rpm)
		assure_exists apt-repo
		docmd apt-repo list
		;;
	deepsolver-rpm)
		docmd ds-conf
		;;
	apt-dpkg|aptitude-dpkg)
		showcmd cat /etc/apt/sources.list*
		print_apt_sources_list /etc/apt/sources.list /etc/apt/sources.list.d/*.list
		;;
	yum-rpm)
		docmd yum repolist -v
		;;
	dnf-rpm)
		docmd dnf repolist -v
		;;
	urpm-rpm)
		docmd urpmq --list-url
		;;
	zypper-rpm)
		docmd zypper sl -d
		;;
	emerge)
		docmd eselect profile list
		docmd layman -L
		;;
	xbps)
		docmd xbps-query -L
		;;
	pacman)
		docmd grep -v -- "^#\|^$" /etc/pacman.conf
		;;
	slackpkg)
		docmd grep -v -- "^#\|^$" /etc/slackpkg/mirrors
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-requires:


epm_requires_files()
{
	local pkg_files="$*"
	[ -n "$pkg_files" ] || return

	local PKGTYPE="$(get_package_type $pkg_files)"

	case "$PKGTYPE" in
		rpm)
			assure_exists rpm
			docmd rpm -q --requires -p $pkg_files
			;;
		deb)
			assure_exists dpkg
			a='' docmd dpkg -I $pkg_files | grep "^ *Depends:" | sed "s|^ *Depends:||g"
			;;
		*)
			fatal "Have no suitable command for $PKGTYPE"
			;;
	esac
}

epm_requires_names()
{
	local pkg_names="$*"
	local CMD
	[ -n "$pkg_names" ] || return

case $PMTYPE in
	apt-rpm)
		# FIXME: need fix for a few names case
		# FIXME: too low level of requires name (libSOME.so)
		if is_installed $pkg_names ; then
			CMD="rpm -q --requires"
		else
			#EXTRA_SHOWDOCMD=' | grep "Depends:"'
			#docmd apt-cache show $pkg_names | grep "Depends:"
			#return
			CMD="apt-cache depends"
		fi

		;;
	#zypper-rpm)
	#	# FIXME: use hi level commands
	#	CMD="rpm -q --requires"
	#	;;
	urpm-rpm)
		CMD="urpmq --requires"
		;;
	yum-rpm)
		if is_installed $pkg_names ; then
			CMD="rpm -q --requires"
		else
			CMD="yum deplist"
		fi
		;;
	dnf-rpm)
		if is_installed $pkg_names ; then
			CMD="rpm -q --requires"
		else
			CMD="dnf repoquery --requires"
		fi
		;;
	pacman)
		CMD="pactree"
		;;
	apt-dpkg|aptitude-dpkg)
		# FIXME: need fix for a few names case
		if is_installed $pkg_names ; then
			showcmd dpkg -s $pkg_names
			a='' dpkg -s $pkg_names | grep "^Depends:" | sed "s|^Depends:||g"
			return
		else
			CMD="apt-cache depends"
		fi
		;;
	emerge)
		assure_exists equery
		CMD="equery depgraph"
		;;
	pkgng)
		#CMD="pkg rquery '%dn-%dv'"
		CMD="pkg info -d"
		;;
	xbps)
		CMD="xbps-query -x"
		;;
	aptcyg)
		#CMD="apt-cyg depends"
		# print show version
		docmd apt-cyg show $pkg_names | grep "^requires: " | sed "s|^requires: ||g"
		return
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac


docmd $CMD $pkg_names

}

epm_requires()
{
	[ -n "$pkg_filenames" ] || fatal "Requires: missing package(s) name"
	epm_requires_files $pkg_files
	# shellcheck disable=SC2046
	epm_requires_names $(print_name $pkg_names)
}

# File bin/epm-search:


__epm_search_output()
{
local CMD
local string="$1"
case $PMTYPE in
	apt-rpm|apt-dpkg)
		CMD="apt-cache search --"
		;;
	aptitude-dpkg)
		CMD="aptitude search --"
		;;
	deepsolver-rpm)
		CMD="ds-require --"
		;;
	urpm-rpm)
		# urpmq does not support --
		CMD="urpmq -y"
		;;
	pkgsrc)
		CMD="pkg_info -x --"
		;;
	pkgng)
		CMD="pkg search -i --"
		;;
	emerge)
		CMD="emerge --search --"
		;;
	pacman)
		CMD="pacman -Ss --"
		;;
	aura)
		CMD="aura -As --"
		;;
	yum-rpm)
		CMD="yum search --"
		;;
	dnf-rpm)
		CMD="dnf search --"
		;;
	zypper-rpm)
		CMD="zypper search --"
		;;
	mpkg)
		CMD="mpkg search"
		;;
	apk)
		CMD="apk search"
		;;
	tce)
		CMD="tce-ab"
		;;
	conary)
		CMD="conary repquery"
		;;
	npackd)
		docmd npackdcl search --query="$string" --status=all
		return
		;;
	chocolatey)
		CMD="chocolatey list"
		;;
	slackpkg)
		# FIXME
		echo "Note: case sensitive search"
		CMD="/usr/sbin/slackpkg search"
		;;
	homebrew)
		CMD="brew search"
		;;
	guix)
		CMD="guix package -A"
		;;
	android)
		CMD="pm list packages"
		;;
	aptcyg)
		CMD="apt-cyg searchall"
		;;
	xbps)
		CMD="xbps-query -s"
		;;
	*)
		fatal "Have no suitable search command for $PMTYPE"
		;;
esac

LANG=C docmd $CMD $string
}

__epm_search_make_grep()
{
	local i
	[ -z "$*" ] && return

	local list=
	local listN=
	for i in $@ ; do
		case "$i" in
			~*)
				# will clean from ~ later (and have the bug here with empty arg if run with one ~ only)
				listN="$listN $i"
				;;
			*)
				list="$list $i"
				;;
		esac
	done

	#list=$(strip_spaces $list | sed -e "s/ /|/g")
	listN=$(strip_spaces $listN | sed -e "s/ /|/g" | sed -e "s/~//g")

	if [ -n "$short" ] ; then
		echon " | sed -e \"s| .*||g\""
	fi

	[ -n "$listN" ] && echon " | egrep -i -v -- \"$listN\""

	# FIXME: The World has not idea how to do grep both string
	# http://stackoverflow.com/questions/10110051/grep-with-two-strings-logical-and-in-regex?rq=1

	# Need only if we have more than one word (with one word we will grep for colorify)
	if [ "$(echo "$list" | wc -w)" -gt 1 ] ; then
		for i in $list ; do
			# FIXME -n on MacOS?
			echon " | egrep -i -- \"$i\""
		done
	fi

	# FIXME: move from it
	#isatty || return

	# TODO: sorts word by length from large to short

	local COLO=""
	# rule for colorife
	for i in $list $listN; do
		[ -n "$COLO" ] && COLO="$COLO|"
		COLO="$COLO$i"
	done

	# TODO: use some colorifer instead grep (check grep adove too)
	if [ -n "$list" ] ; then
		echon " | egrep -i $EGREPCOLOR -- \"($COLO)\""
	fi
}


epm_search()
{
	[ -n "$pkg_filenames" ] || fatal "Search: missing search argument(s)"

	# it is useful for first time running
	update_repo_if_needed soft

	warmup_bases

	# FIXME: do it better
	local MGS
	MGS=$(eval __epm_search_make_grep $quoted_args)
	EXTRA_SHOWDOCMD="$MGS"
	eval "__epm_search_output \"$(eval get_firstarg $quoted_args)\" $MGS"
}

# File bin/epm-search_file:


__alt_search_file_output()
{
    # grep only on left part (filename), then revert order and grep with color
    __local_ercat $1 | grep -h -- ".*$2.*[[:space:]]" | sed -e "s|\(.*\)\t\(.*\)|\2: \1|g" $3
}

__alt_local_content_search()
{

    info "Locate contents index file(s) ..."
    local CI="$(get_local_alt_contents_index)"
    # TODO use something like
    [ -n "$CI" ] || fatal "Have no local contents index"

    info "Searching in"
    echo "$CI"
    echo "for $1... "

    # FIXME: do it better
    local MGS
    MGS=$(eval __epm_search_make_grep $quoted_args)
    showcmd "$ cat contents_index $MGS"
    eval "__alt_search_file_output \"$CI\" \"$(eval get_firstarg $quoted_args)\" $MGS"
}

epm_search_file()
{
	local CMD
	[ -n "$pkg_filenames" ] || fatal "Search file: missing file name(s)"

case $PMTYPE in
	apt-rpm)
		__alt_local_content_search $pkg_filenames
		return ;;
	apt-dpkg|aptitude-dpkg)
		assure_exists apt-file
		sudocmd apt-file update
		docmd apt-file search $pkg_filenames
		return ;;
	yum-rpm)
		# TODO
		info "Search by full packages list is not implemented yet"
		CMD="yum provides"
		;;
	dnf-rpm)
		# TODO
		info "Search by full packages list is not implemented yet"
		CMD="dnf provides"
		;;
	urpm-rpm)
		CMD="urpmf"
		;;
	zypper-rpm)
		CMD="zypper wp vi"
		;;
	pacman)
		CMD="pacman -Qo"
		;;
	slackpkg)
		CMD="/usr/sbin/slackpkg file-search"
		;;
	ipkg)
		CMD="ipkg search"
		;;
	xbps)
		CMD="xbps-query -Ro"
		;;
	aptcyg)
		docmd apt-cyg searchall "$(echo " $pkg_filenames" | sed -e "s| /| |g")"
		return
		;;
	*)
		fatal "Have no suitable search file command for $PMTYPE"
		;;
esac

docmd $CMD $pkg_filenames

}

# File bin/epm-sh-altlinux:


get_local_alt_mirror_path()
{
    local DN1=$(dirname "$1")
    local DN2=$(dirname $DN1)
    local DN3=$(dirname $DN2)

    local BN0=$(basename "$1") # arch
    local BN1=$(basename $DN1) # branch/Sisyphus
    local BN2=$(basename $DN2) # p8/ALTLinux
    local BN3=$(basename $DN3) # ALTLinux/

    [ "$BN1" = "branch" ] && echo "/tmp/eepm/$BN3/$BN2/$BN1/$BN0" || echo "/tmp/eepm/$BN2/$BN1/$BN0"
}

__local_ercat()
{
   local i
   for i in "$@" ; do
       case "$i" in
           *.xz)
               a='' xzcat $i
               ;;
           *.lz4)
               a='' lz4cat $i
               ;;
           *.failed)
               # just ignore
               ;;
           *)
               cat $i
               ;;
       esac
   done
}

compress_file_inplace()
{
    local OFILE="$1"
    if epm assure lz4 </dev/null ; then
        #docmd lz4 --rm "$OFILE" "$OFILE.lz4" || return
        # due old lz4
        docmd lz4 -f "$OFILE" "$OFILE.lz4" || return
        rm -fv "$OFILE"
    else
        epm assure xz </dev/null || return
        docmd xz -f "$OFILE" || return
    fi
    return 0
}

download_alt_contents_index()
{
    local URL="$1"
    local TD="$2"
    local OFILE="$TD/$(basename "$URL")"

    local DONE=$(echo $OFILE*)
    # TODO: check if too old
    if [ -r "$DONE" ] ; then
        return
    fi

    mkdir -p "$TD"

    if echo "$URL" | grep -q "^file:/" ; then
        URL=$(echo "$URL" | sed -e "s|^file:||")
        [ -s "$URL" ] || { touch $OFILE.failed ; return 1; }
        ln -sf "$URL" "$OFILE" || { touch $OFILE.failed ; return 1; }
    else
        docmd eget -O "$OFILE" "$URL" || { rm -fv $OFILE ; touch $OFILE.failed ; return 1; }
    fi

    rm -f $OFILE.failed
    compress_file_inplace "$OFILE"
}

get_local_alt_contents_index()
{

    local LOCALPATH

    epm_repolist | grep -E "rpm.*(ftp://|http://|https://|file:/)" | sed -e "s@^rpm.*\(ftp://\|http://\|https://\|file:\)@\1@g" | while read -r URL ARCH other ; do
        LOCALPATH=$(get_local_alt_mirror_path "$URL/$ARCH")
        download_alt_contents_index $URL/$ARCH/base/contents_index $LOCALPATH >&2 || continue
        echo "$LOCALPATH/contents_index*"
    done

}

tasknumber()
{
    local num="$(echo "$*" | sed -e "s| *#*||g")"
    isnumber "$num" && echo "$num"
}


# File bin/epm-sh-warmup:

is_warmup_allowed()
{
    local MEM
    MEM=$($DISTRVENDOR -m)
    # disable warm if have no enough memory
    [ $MEM -le 1024 ] && return 1
    return 0
}

__warmup_files()
{
    local D="$1"
    shift
    #showcmd "$*"
    [ -n "$D" ] && info "Warming up $D ..."
    # TODO: use progress, calc files size before
    docmd cat $* >/dev/null 2>/dev/null
}

warmup_rpmbase()
{
    is_warmup_allowed || return
    __warmup_files "rpm" "/var/lib/rpm/*"
}

warmup_dpkgbase()
{
    is_warmup_allowed || { warning "Skipping warmup bases due low memory size" ; return ; }
    __warmup_files "dpkg" "/var/lib/dpkg/*"
}

warmup_lowbase()
{
    case $PKGFORMAT in
        "rpm")
            warmup_rpmbase "$@"
            ;;
        "dpkg")
            warmup_dpkgbase "$@"
            ;;
        *)
            ;;
    esac
}

warmup_aptbase()
{
    is_warmup_allowed || return
    __warmup_files "apt" "/var/lib/apt/lists/* /var/cache/apt/*.bin"
}

warmup_hibase()
{
    case $PMTYPE in
        "apt-rpm"|"apt-dpkg")
            warmup_aptbase "$@"
            ;;
        *)
            ;;
    esac
}

warmup_bases()
{
    DISquiet=1 warmup_lowbase
    DISquiet=1 warmup_hibase
}

# File bin/epm-simulate:


__use_zypper_dry_run()
{
    a='' zypper install --help 2>&1 | grep -q -- "--dry-run" && echo "--dry-run"
}

__use_yum_assumeno()
{
    a='' yum --help 2>&1 | grep -q -- "--assumeno"
}


__check_yum_result()
{
    grep "^No package" $1 && return 1
    grep "^Complete!" $1 && return 0
    grep "Exiting on user [Cc]ommand" $1 && return 0
    # dnf issue
    grep "^Operation aborted." $1 && return 0
    # return default result by default
    return $2
}

__check_pacman_result()
{
    grep "^error: target not found:" $1 && return 1
    grep "^Total Installed Size:" $1 && return 0
    grep "^Total Download Size:" $1 && return 0
    # return default result by default
    return $2
}


_epm_do_simulate()
{
    local CMD
    local RES=0
    local filenames="$*"

    case $PMTYPE in
    	apt-rpm|apt-dpkg)
    		CMD="apt-get --simulate install"
    		;;
    	aptitude-dpkg)
    		CMD="aptitude -s install"
    		;;
    	yum-rpm)
    		if __use_yum_assumeno ; then
    			LC_ALL=C store_output sudocmd yum --assumeno install $filenames
    			__check_yum_result $RC_STDOUT $?
    		else
    			LC_ALL=C store_output sudocmd yum install $filenames <<EOF
n
EOF
    			__check_yum_result $RC_STDOUT $?
    		fi
    		RES=$?
    		clean_store_output
    		return $RES ;;
    	dnf-rpm)
    		LC_ALL=C store_output sudocmd dnf --assumeno install $filenames
    		__check_yum_result $RC_STDOUT $?
    		RES=$?
    		clean_store_output
    		return $RES ;;
    	urpm-rpm)
    		CMD="urpmi --test --auto"
    		;;
    	zypper-rpm)
    		if ! __use_zypper_dry_run >/dev/null ; then
    			fatal "zypper is too old: does not support --dry-run"
    		fi
    		CMD="zypper --non-interactive install --dry-run"
    		;;
    	emerge)
    		local res=0
    		for pkg in $filenames ; do
			is_installed $pkg && continue
			docmd emerge --pretend $pkg && continue
			pkg=1
			break
    		done
    		return $res ;;
    	pacman)
    		LC_ALL=C store_output sudocmd pacman -v -S $filenames <<EOF
no
EOF
    		__check_pacman_result $RC_STDOUT $?
    		RES=$?
    		clean_store_output
    		return $RES ;;
    	slackpkg)
    		#docmd /usr/sbin/slackpkg -batch=on -default_answer=yes download
    		# just try search every package
    		# FIXME: epm_search have to return false status code if the package does not found
    		local pkg res
    		res=0
    		for pkg in $filenames ; do
    			# FIXME: -[0-0] does not work in search!
    			# FIXME: we need strict search here (not find gst-plugins-base if search for gst-plugins
    			pkg_filenames="$pkg-[0-9]" epm_search | grep -E "(installed|upgrade)" && continue
    			pkg_filenames="$pkg" epm_search | grep -E "(installed|upgrade)" && continue
    			res=1
    			info "Package '$pkg' does not found in repository."
    		done
    		return $res ;;
    	*)
    		fatal "Have no suitable simulate command for $PMTYPE"
    		;;
    esac

    sudocmd $CMD $filenames
}

epm_simulate()
{
    [ -z "$pkg_filenames" ] && info "Simulate: Skip empty list" && return 22

    local filenames="$(echo $pkg_filenames | filter_out_installed_packages)"

    [ -z "$filenames" ] && info "Simulate: All packages are already installed" && return 0

    _epm_do_simulate $filenames
    local RES=$?
    if [ -z "$quiet" ] ; then
        if [ "$RES" = 0 ] ; then
            info "Simulate result: $filenames package(s) CAN BE installed"
        else
            info "Simulate result: There are PROBLEMS with install some package(s)"
        fi
    fi
    return $RES
}


# File bin/epm-site:


PAOURL="https://packages.altlinux.org"

paoapi()
{
	# http://petstore.swagger.io/?url=http://packages.altlinux.org/api/docs
	epm assure curl || return 1
	showcmd curl "$PAOURL/api/$1"
	a='' curl -s --header "Accept: application/json" "$PAOURL/api/$1"
}

get_pao_var()
{
	local FIELD="$1"
	#grep '"$FIELD"' | sed -e 's|.*"$FIELD":"||g' | sed -e 's|".*||g'
	internal_tools_json -b | grep -E "\[.*\"$FIELD\"\]" | sed -e 's|.*[[:space:]]"\(.*\)"|\1|g'
	return 0
}


run_command_if_exists()
{
	local CMD="$1"
	shift
	if which "$CMD" 2>/dev/null >/dev/null ; then
		docmd "$CMD" "$@"
		return 0
	fi
	return 1
}

open_browser()
{
	local i
	for i in xdg-open firefox chromium links ; do
		run_command_if_exists $i "$@" && return
	done
}

__query_package_hl_url()
{
	case $DISTRNAME in
		ALTLinux)
			paoapi srpms/$1 | get_pao_var url
			;;
	esac
	return 1
}

query_package_url()
{
	local URL

	case $PMTYPE in
		*-rpm)
			# TODO: for binary packages?
			query_package_field URL "$1" || __query_package_hl_url "$1"
			#LANG=C epm info "$1"
			return
			;;
	esac
	fatal "rpm based distro supported only. TODO: Realize via web service?"
}

get_locale()
{
	local loc
	loc=$(a='' natspec --locale 2>/dev/null)
	[ -n "$loc" ] || loc=$LANG
	echo $loc
}

get_pao_url()
{
	local loc
	loc=$(get_locale | cut -c1-2)
	case $loc in
		en|ru|uk|br)
			loc=$loc
			;;
		*)
			loc=en
	esac
	echo "$PAOURL/$loc/Sisyphus/srpms"
}

query_altlinux_url()
{
	local URL
	case $PMTYPE in
		*-rpm)
			local srpm=$(print_srcname "$1")
			[ -n "$srpm" ] || fatal "Can't get source name for $1"
			echo "$(get_pao_url)/$srpm"
			return
			;;
	esac
	fatal "rpm based distro supported only. TODO: Realize via web service?"
}

epm_site()
{

[ -n "$pkg_filenames" ] || fatal "Info: missing package(s) name"

local PAO=""
for f in $pkg_names $pkg_files ; do
	[ "$f" = "-p" ] && PAO="$f" && continue
	if [ -n "$PAO" ] ; then
		pkg_url=$(query_altlinux_url $f)
	else
		pkg_url=$(query_package_url $f)
	fi
	[ -n "$pkg_url" ] && open_browser "$pkg_url" && continue
	warning "Can't get URL for $f package"
done



}

# File bin/epm-update:



epm_update()
{
	[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"
	info "Running command for update remote package repository database"

warmup_hibase

case $PMTYPE in
	apt-rpm)
		sudocmd apt-get update || return
		#sudocmd apt-get -f install || exit
		;;
	apt-dpkg)
		sudocmd apt-get update || return
		#sudocmd apt-get -f install || exit
		#sudocmd apt-get autoremove
		;;
	#snappy)
	#	sudocmd snappy
	#	;;
	aptitude-dpkg)
		sudocmd aptitude update || return
		;;
	yum-rpm)
		info "update command is stubbed for yum"
		# yum makecache
		#sudocmd yum check-update
		;;
	dnf-rpm)
		info "update command is stubbed for dnf"
		# dnf makecache
		#sudocmd dnf check-update
		;;
	urpm-rpm)
		sudocmd urpmi.update -a
		;;
	pacman)
		sudocmd pacman -S -y
		;;
	aura)
		sudocmd aura -A -y
		;;
	zypper-rpm)
		sudocmd zypper refresh
		;;
	emerge)
		sudocmd emerge --sync
		;;
	slackpkg)
		sudocmd /usr/sbin/slackpkg -batch=on update
		;;
	deepsolver-rpm)
		sudocmd ds-update
		;;
	npackd)
		sudocmd packdcl detect # get packages from MSI database
		;;
	homebrew)
		docmd brew update
		;;
	ipkg)
		sudocmd ipkg update
		;;
	apk)
		sudocmd apk update
		;;
	pkgsrc)
		# portsnap extract for the first time?
		sudocmd portsnap fetch update
		;;
	aptcyg)
		sudocmd apt-cyg update
		;;
	xbps)
		sudocmd xbps-install -S
		;;
	*)
		fatal "Have no suitable update command for $PMTYPE"
		;;
esac

}

# File bin/epm-upgrade:


epm_upgrade()
{
	local CMD

	#[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

	# it is useful for first time running
	update_repo_if_needed

	warmup_bases
	info "Running command for upgrade packages"

	case $PMTYPE in
	apt-rpm|apt-dpkg)
		local APTOPTIONS="$(subst_option non_interactive -y) $(subst_option verbose "-o Debug::pkgMarkInstall=1 -o Debug::pkgProblemResolver=1")"
		# Функцию добавления параметра при условии
		CMD="apt-get $APTOPTIONS dist-upgrade $noremove"
		;;
	aptitude-dpkg)
		CMD="aptitude dist-upgrade"
		;;
	yum-rpm)
		local OPTIONS="$(subst_option non_interactive -y)"
		# can do update repobase automagically
		CMD="yum $OPTIONS update $pkg_filenames"
		;;
	dnf-rpm)
		local OPTIONS="$(subst_option non_interactive -y)"
		CMD="dnf $OPTIONS distro-sync $pkg_filenames"
		;;
	snappy)
		CMD="snappy update"
		;;
	urpm-rpm)
		# or --auto-select --replace-files
		CMD="urpmi --update --auto-select $pkg_filenames"
		;;
	zypper-rpm)
		CMD="zypper dist-upgrade"
		;;
	pacman)
		CMD="pacman -S -u $force"
		;;
	aura)
		CMD="aura -A -u"
		;;
	emerge)
		CMD="emerge -NuDa world"
		;;
	conary)
		CMD="conary updateall"
		;;
	pkgsrc)
		CMD="freebsd-update fetch install"
		;;
	pkgng)
		CMD="pkg upgrade"
		;;
	chocolatey)
		CMD="chocolatey update all"
		;;
	homebrew)
		#CMD="brew upgrade"
		docmd "brew upgrade $(brew outdated)"
		return
		;;
	ipkg)
		CMD="ipkg upgrade"
		;;
	slackpkg)
		CMD="/usr/sbin/slackpkg upgrade-all"
		;;
	guix)
		CMD="guix package -u"
		;;
	aptcyg)
		# shellcheck disable=SC2046
		docmd_foreach "epm install" $(short=1 epm packages)
		return
		;;
	xbps)
		CMD="xbps-install -Su"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac

	sudocmd $CMD $pkg_filenames
}

# File bin/epm-Upgrade:


epm_Upgrade()
{
	case $PMTYPE in
		yum-rpm)
			;;
		*)
			pkg_filenames='' epm_update || return
			;;
	esac

	epm_upgrade
}

# File bin/epm-whatdepends:



epm_whatdepends()
{
	local CMD
	[ -n "$pkg_files" ] && fatal "whatdepends do not handle files"
	[ -n "$pkg_names" ] || fatal "whatdepends: missing package(s) name"
	local pkg=$(print_name $pkg_names)

case $PMTYPE in
	apt-rpm)
		CMD="apt-cache whatdepends"
		;;
	apt-dpkg|aptitude-dpkg)
		CMD="apt-cache rdepends"
		;;
	aptitude-dpkg)
		CMD="aptitude why"
		;;
	yum-rpm)
		CMD="repoquery --whatrequires"
		;;
	urpm-rpm)
		CMD="urpmq --whatrequires"
		;;
	dnf-rpm)
		# check command: dnf repoquery --whatrequires
		CMD="repoquery --whatrequires"
		;;
	emerge)
		assure_exists equery
		CMD="equery depends -a"
		;;
	pkgng)
		CMD="pkg info -r"
		;;
	aptcyg)
		CMD="apt-cyg rdepends"
		;;
	xbps)
		CMD="xbps-query -X"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

docmd $CMD $pkg

}

# File bin/epm-whatprovides:


epm_whatprovides()
{
	local CMD
	[ -n "$pkg_files" ] && fatal "whatprovides does not handle files"
	[ -n "$pkg_names" ] || fatal "whatprovides: missing package(s) name"
	local pkg=$(print_name $pkg_names)

case $PMTYPE in
	conary)
		CMD="conary repquery --what-provides"
		;;
	apt-rpm|apt-dpkg|aptitude-dpkg)
		LANG=C docmd apt-get install --print-uris $pkg | grep "^Selecting" | cut -f2 -d" "
		return
		;;
	yum-rpm)
		CMD="yum whatprovides"
		;;
	urpm-rpm)
		CMD="urpmq --whatprovides"
		;;
	dnf-rpm)
		CMD="yum provides"
		;;
	zypper-rpm)
		CMD="zypper what-provides"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

docmd $CMD $pkg

}

################# incorporate bin/distr_info #################
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

firstupper()
{
	echo "$*" | sed 's/.*/\u&/'
}

# Translate DISTRIB_ID to vendor name (like %_vendor does)
rpmvendor()
{
	[ "$DISTRIB_ID" = "ALTLinux" ] && echo "alt" && return
	[ "$DISTRIB_ID" = "AstraLinux" ] && echo "astra" && return
	[ "$DISTRIB_ID" = "LinuxXP" ] && echo "lxp" && return
	[ "$DISTRIB_ID" = "TinyCoreLinux" ] && echo "tcl" && return
	[ "$DISTRIB_ID" = "VoidLinux" ] && echo "void" && return
	echo "$DISTRIB_ID" | tr "[:upper:]" "[:lower:]"
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
	DISTRIB_ID=$(cat $DISTROFILE | get_var DISTRIB_ID)
	DISTRIB_RELEASE=$(cat $DISTROFILE | get_var DISTRIB_RELEASE)
	DISTRIB_CODENAME=$(cat $DISTROFILE | get_var DISTRIB_CODENAME)
fi

# ALT Linux based
if distro altlinux-release ; then
	DISTRIB_ID="ALTLinux"
	if has Sisyphus ; then DISTRIB_RELEASE="Sisyphus"
	elif has "ALT Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux t7." ; then DISTRIB_RELEASE="t7"
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
	DISTRIB_RELEASE=$(basename $MAKEPROFILE)
	echo $DISTRIB_RELEASE | grep -q "[0-9]" || DISTRIB_RELEASE=$(basename "$(dirname $MAKEPROFILE)")

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
	DISTRIB_RELEASE="$(grep -Eo '[0-9]+\.[0-9]+' $DISTROFILE)"

elif distro os-release && which apk 2>/dev/null >/dev/null ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="$(firstupper "$ID")"
	DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && which tce-ab 2>/dev/null >/dev/null ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="TinyCoreLinux"
	DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && which xbps-query 2>/dev/null >/dev/null ; then
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

# https://www.freedesktop.org/software/systemd/man/os-release.html
elif distro os-release ; then
	# shellcheck disable=SC1090
	. $ROOTDIR/etc/os-release
	DISTRIB_ID="$(firstupper "$ID")"
	DISTRIB_RELEASE="$VERSION_ID"
	[ -n "$DISTRIB_RELEASE" ] || DISTRIB_RELEASE="CUR"

# fixme: can we detect by some file?
elif [ "$(uname)" = "FreeBSD" ] ; then
	DISTRIB_ID="FreeBSD"
	UNAME=$(uname -r)
	DISTRIB_RELEASE=$(echo "$UNAME" | grep RELEASE | sed -e "s|\([0-9]\.[0-9]\)-RELEASE|\1|g")

# fixme: can we detect by some file?
elif [ "$(uname)" = "SunOS" ] ; then
	DISTRIB_ID="SunOS"
	DISTRIB_RELEASE=$(uname -r)

# fixme: can we detect by some file?
elif [ "$(uname -s 2>/dev/null)" = "Darwin" ] ; then
	DISTRIB_ID="MacOS"
	DISTRIB_RELEASE=$(uname -r)

# fixme: move to up
elif [ "$(uname)" = "Linux" ] && which guix 2>/dev/null >/dev/null ; then
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
			DISTRIB_ID="Tumbleweed"
			;;
	esac
fi

get_base_os_name()
{
local DIST_OS
# Resolve the os
DIST_OS=`uname -s | tr [:upper:] [:lower:] | tr -d " \t\r\n"`
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
DIST_ARCH=`uname -m | tr [:upper:] [:lower:] | tr -d " \t\r\n"`
case "$DIST_ARCH" in
    'amd64' | 'ia32' | 'i386' | 'i486' | 'i586' | 'i686' | 'x86_64')
        DIST_ARCH="x86"
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
        if [ -z "`readelf -A /proc/self/exe | grep Tag_ABI_VFP_args`" ] ; then
            DIST_ARCH="armel"
        else
            DIST_ARCH="armhf"
        fi
        ;;
esac
echo "$DIST_ARCH"
}

get_bit_size()
{
local DIST_BIT
# Check if we are running on 64bit platform, seems like a workaround for now...
DIST_BIT=`uname -m | tr [:upper:] [:lower:] | tr -d " \t\r\n"`
case "$DIST_BIT" in
    'amd64' | 'ia64' | 'x86_64' | 'ppc64')
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

get_memory_size() {
    local detected=0
    local DIST_OS=$(get_base_os_name)
    if [ $DIST_OS = "macosx" ]
    then
       detected=$((`sysctl hw.memsize | sed s/"hw.memsize: "//`/1024/1024))
    elif [ $DIST_OS = "freebsd" ]
    then
       detected=$((`sysctl hw.physmem | sed s/"hw.physmem: "//`/1024/1024))
    elif [ $DIST_OS = "linux" ]
    then
       detected=$((`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`/1024))
    fi
# Exit codes only support values between 0 and 255. So use stdout.
    echo $detected
}


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
		echo "-a - print hardware architecture"
		echo "-b - print size of arch bit (32/64)"
		echo "-m - print system memory size (in MB)"
		echo "-o - print base os name"
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
	-a)
		get_arch
		;;
	-b)
		get_bit_size
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
################# end of incorporated bin/distr_info #################


################# incorporate bin/tools_eget #################
internal_tools_eget()
{
# eget - simply shell on wget for loading directories over http (wget does not support wildcard for http)
# Example use:
# eget http://ftp.altlinux.ru/pub/security/ssl/*
#
# Copyright (C) 2014-2014, 2016  Etersoft
# Copyright (C) 2014 Daniil Mikhailov <danil@etersoft.ru>
# Copyright (C) 2016-2017 Vitaly Lipatov <lav@etersoft.ru>
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

if [ -z "$1" ] ; then
    echo "eget - wget wrapper" >&2
    echo "Run with URL, like http://somesite.ru/dir/*.log" >&2
    exit 1
fi

# If ftp protocol, just download
if echo "$1" | grep -q "^ftp://" ; then
    $WGET $WGET_OPTION_TARGET "$1"
    return
fi

# drop mask part (if has /$, not changed)
URL=$(echo "$1" | grep "/$" || dirname "$1")

# If have no wildcard symbol like asterisk and no / at the end, just download
if [ "$URL" != "$1" ] && echo "$1" | grep -qv "[*?]" ; then
    $WGET $WGET_OPTION_TARGET "$1"
    return
fi

echo "Fall to http workaround"

# mask allowed only in last part of path
MASK=$(basename "$1")
# TODO: skip create_fake_files for full dir
# add * if full dir
#[ "$URL" != "$1" ] && MASK="*"

print_files()
{
    $WGET -O- $URL | \
        grep -o -E 'href="([^\*/"#]+)"' | cut -d'"' -f2
}

create_fake_files()
{
    DIRALLFILES="$MYTMPDIR/files/"
    mkdir -p "$DIRALLFILES"

    print_files | while read -r line ; do
        touch $DIRALLFILES/$(basename "$line")
    done
}

download_files()
{
    ERROR=0
    # TODO: test fix / at the end
    for line in $DIRALLFILES/$MASK ; do
        [ -r "$line" ] || { ERROR=1 ; break ; }
        $WGET $URL/$(basename "$line") || ERROR=1
    done
    return $ERROR
}

MYTMPDIR="$(mktemp -d)"
create_fake_files
download_files || echo "There was some download errors" >&2
rm -rf "$MYTMPDIR"
}
################# end of incorporated bin/tools_eget #################


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


#PATH=$PATH:/sbin:/usr/sbin

set_pm_type

set_sudo

check_tty

#############################

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
        echo "EPM package manager version 2.3.0"
        echo "Running on $($DISTRVENDOR) ('$PMTYPE' package manager uses '$PKGFORMAT' package format)"
        echo "Copyright (c) Etersoft 2012-2017"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}


Usage="Usage: epm [options] <command> [package name(s), package files]..."
Descr="epm - EPM package manager"


verbose=
quiet=
nodeps=
noremove=
dryrun=
force=
short=
direct=
sort=
non_interactive=
skip_installed=
show_command_only=
epm_cmd=
pkg_files=
pkg_dirs=
pkg_names=
pkg_urls=
quoted_args=

case $PROGNAME in
    epmi)
        epm_cmd=install
        ;;
    epmI)
        epm_cmd=Install
        ;;
    epme)
        epm_cmd=remove
        ;;
    epmcl)
        epm_cmd=changelog
        ;;
    epms)
        epm_cmd=search
        ;;
    epmsf)
        epm_cmd=search_file
        ;;
    epmq)
        epm_cmd=query
        ;;
    epmqi)
        epm_cmd=info
        ;;
    epmqf)
        epm_cmd=query_file
        ;;
    epmqa)
        epm_cmd=packages
        ;;
    epmqp)
        epm_cmd=query_package
        ;;
    epmql)
        epm_cmd=filelist
        ;;
    epmrl)
        epm_cmd=repolist
        ;;
    epmu)
        epm_cmd=update
        ;;
    epm|upm|eepm)
        ;;
    epm.sh)
        ;;
    *)
        # epm by default
        # fatal "Unknown command: $progname"
        ;;
esac

# was called with alias name
[ -n "$epm_cmd" ] && PROGNAME="epm"

check_command()
{
    # do not override command
    [ -z "$epm_cmd" ] || return

# Base commands
    case $1 in
    -i|install|add|i)         # HELPCMD: install package(s) from remote repositories or from local file
        epm_cmd=install
        ;;
    -e|-P|rm|del|remove|delete|uninstall|erase|e)  # HELPCMD: remove (delete) package(s) from the database and the system
        epm_cmd=remove
        ;;
    -s|search|s)                # HELPCMD: search in remote package repositories
        epm_cmd=search
        ;;
    -qp|qp|query_package)     # HELPCMD: search in the list of installed packages
        epm_cmd=query_package
        ;;
    -qf|qf|-S|which|belongs)     # HELPCMD: query package(s) owning file
        epm_cmd=query_file
        ;;

# Useful commands
    reinstall)                # HELPCMD: reinstall package(s) from remote repositories or from local file
        epm_cmd=reinstall
        ;;
    Install)                  # HELPCMD: perform update package repo info and install package(s) via install command
        epm_cmd=Install
        ;;
    -q|q|installed|query)     # HELPCMD: check presence of package(s) and print this name (also --short is supported)
        epm_cmd=query
        ;;
    -sf|sf|filesearch)        # HELPCMD: search in which package a file is included
        epm_cmd=search_file
        ;;
    -ql|ql|filelist)          # HELPCMD: print package file list
        epm_cmd=filelist
        ;;
    check|fix|verify)         # HELPCMD: check local package base integrity and fix it
        epm_cmd=check
        ;;
    -cl|cl|changelog)         # HELPCMD: show changelog for package
        epm_cmd=changelog
        ;;
    -qi|qi|info|show)         # HELPCMD: print package detail info
        epm_cmd=info
        ;;
    requires|deplist|req)     # HELPCMD: print package requires
        epm_cmd=requires
        ;;
    provides|prov)            # HELPCMD: print package provides
        epm_cmd=provides
        ;;
    whatdepends|wd)           # HELPCMD: print packages dependences on that
        epm_cmd=whatdepends
        ;;
    whatprovides)             # HELPCMD: print packages provides that target
        epm_cmd=whatprovides
        ;;
    conflicts)                # HELPCMD: print package conflicts
        epm_cmd=conflicts
        ;;
    -qa|qa|-l|list|packages)  # HELPCMD: print list of installed package(s)
        epm_cmd=packages
        ;;
    programs)                 # HELPCMD: print list of installed GUI program(s) (they have .desktop files)
        epm_cmd=programs
        ;;
    assure)                   # HELPCMD: <command> [package]: install package if command does not exist
        epm_cmd=assure
        ;;
    policy)                   # HELPCMD: print detailed information about the priority selection of package
        epm_cmd=policy
        ;;

# Repository control
    update)                   # HELPCMD: update remote package repository databases
        epm_cmd=update
        ;;
    addrepo|ar)               # HELPCMD: add package repo
        epm_cmd=addrepo
        ;;
    repolist|sl|rl|listrepo)  # HELPCMD: print repo list
        epm_cmd=repolist
        ;;
    repofix)                  # HELPCMD: fix paths in sources lists (ALT Linux only)
        epm_cmd=repofix
        ;;
    removerepo|rr)            # HELPCMD: remove package repo
        epm_cmd=removerepo
        ;;
    release-upgrade|upgrade-release)          # HELPCMD: update whole system to the next release
        epm_cmd=release_upgrade
        ;;
    kernel-update|kernel-upgrade|update-kernel|upgrade-kernel)      # HELPCMD: update system kernel to the last repo version
        epm_cmd=kernel_update
        ;;
    remove-old-kernels|remove-old-kernel)      # HELPCMD: remove old system kernels (exclude current or last two kernels)
        epm_cmd=remove_old_kernels
        ;;

# Other commands
    clean)                    # HELPCMD: clean local package cache
        epm_cmd=clean
        ;;
    autoremove|package-cleanup)   # HELPCMD: auto remove unneeded package(s) Supports args for ALT: [libs|python|perl|libs-devel]
        epm_cmd=autoremove
        ;;
    autoorphans|--orphans)    # HELPCMD: remove all packages not from the repository
        epm_cmd=autoorphans
        ;;
    upgrade|dist-upgrade)     # HELPCMD: performs upgrades of package software distributions
        epm_cmd=upgrade
        ;;
    Upgrade)                  # HELPCMD: force update package base, then run upgrade
        epm_cmd=Upgrade
        ;;
    downgrade)                # HELPCMD: downgrade [all] packages to the repo state
        epm_cmd=downgrade
        ;;
    download)                 # HELPCMD: download package(s) file to the current dir
        epm_cmd=download
        ;;
# TODO: replace with install --simulate
    simulate)                 # HELPCMD: simulate install with check requires
        epm_cmd=simulate
        ;;
    audit)                    # HELPCMD: audits installed packages against known vulnerabilities
        epm_cmd=audit
        ;;
    #checksystem)              # HELPCMD: check system for known errors (package management related)
    #    epm_cmd=checksystem
    #    ;;
    site|url)                 # HELPCMD: open package's site in a browser (use -p for open packages.altlinux.org site)
        epm_cmd=site
        ;;
    ei|epminstall|epm-install|selfinstall) # HELPCMD: install or update eepm package from all in one script
        epm_cmd=epm_install
        ;;
    print)                    # HELPCMD: print various info, run epm print help for details
        epm_cmd=print
        ;;
    -V|checkpkg|integrity)    # HELPCMD: check package file integrity (checksum)
        epm_cmd=checkpkg
        ;;
    -h|--help|help)           # HELPOPT: print this help
        help=1
        phelp
        exit 0
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
    -v|--version)         # HELPOPT: print version
        print_version
        exit 0
        ;;
    --verbose)            # HELPOPT: verbose mode
        verbose=1
        ;;
    --skip-installed)     # HELPOPT: skip already installed packages during install
        skip_installed=1
        ;;
    --show-command-only)  # HELPOPT: show command only, do not any action (supports install and remove ONLY)
        show_command_only=1
        ;;
    --quiet|--silent)     # HELPOPT: quiet mode (do not print commands before exec)
        quiet=1
        ;;
    --nodeps)             # HELPOPT: skip dependency check (during install/simulate and so on)
        nodeps="--nodeps"
        ;;
    --force)              # HELPOPT: force install/remove package (f.i., override)
        force="--force"
        ;;
    --noremove|--no-remove)  # HELPOPT: exit if any packages are to be removed during upgrade
        noremove="--no-remove"
        ;;
    --dry-run|--simulate|--just-print|-recon--no-act) # HELPOPT: print only (autoremove/autoorphans/remove only)
        dryrun="--dry-run"
        ;;
    --short)              # HELPOPT: short output (just 'package' instead 'package-version-release')
        short="--short"
        ;;
    --direct)              # HELPOPT: direct install package file from ftp (not via hilevel repository manager)
        direct="--direct"
        ;;
    --sort)               # HELPOPT: sort output, f.i. --sort=size (supported only for packages command)
        # TODO: how to read arg?
        sort="$1"
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

check_filenames()
{
    local opt
    for opt in "$@" ; do
        # files can be with full path or have extension via .
        if [ -f "$opt" ] && echo "$opt" | grep -q "[/\.]" ; then
            pkg_files="$pkg_files $opt"
        elif [ -d "$opt" ] ; then
            pkg_dirs="$pkg_dirs $opt"
        elif echo "$opt" | grep -q "://" ; then
            pkg_urls="$pkg_urls $opt"
        else
            pkg_names="$pkg_names $opt"
        fi
        quoted_args="$quoted_args \"$opt\""
    done
}

FLAGENDOPTS=
for opt in "$@" ; do
    [ "$opt" = "--" ] && FLAGENDOPTS=1 && continue
    if [ -z "$FLAGENDOPTS" ] ; then
        check_command $opt && continue
        check_option $opt && continue
    fi
    # Note: will parse all params separately (no package names with spaces!)
    check_filenames $opt
done

# if input is not console and run script from file, get pkgs from stdin too
if ! inputisatty && [ -n "$PROGDIR" ] ; then
    for opt in $(withtimeout 1 cat) ; do
        # FIXME: do not work
        # workaround against # yes | epme
        [ "$opt" = "y" ] && break;
        [ "$opt" = "yes" ] && break;
        check_filenames $opt
    done
fi

pkg_files=$(strip_spaces "$pkg_files")
pkg_dirs=$(strip_spaces "$pkg_dirs")
# in common case dirs equals to names only suddenly
pkg_names=$(strip_spaces "$pkg_names $pkg_dirs")
pkg_urls=$(strip_spaces "$pkg_urls")

pkg_filenames=$(strip_spaces "$pkg_files $pkg_names")

# Just debug
#echover "command: $epm_cmd"
#echover "pkg_files=$pkg_files"
#echover "pkg_names=$pkg_names"

# Just printout help if run without args
if [ -z "$epm_cmd" ] ; then
    print_version
    echo
    fatstr="Unknown command in $* arg(s)"
    [ -n "$*" ] || fatstr="That program needs be running with some command"
    fatal "$fatstr. Run $ $PROGNAME --help to get help."
fi

# Use eatmydata for write specific operations
case $epm_cmd in
    update|upgrade|Upgrade|install|reinstall|Install|remove|autoremove|kernel_update|release_upgrade|check)
        set_eatmydata
        ;;
esac

# Run helper for command
epm_$epm_cmd
# return last error code (from subroutine)
