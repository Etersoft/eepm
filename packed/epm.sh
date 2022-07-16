#!/bin/sh
#
# Copyright (C) 2012-2021  Etersoft
# Copyright (C) 2012-2021  Vitaly Lipatov <lav@etersoft.ru>
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
CONFIGDIR=$PROGDIR/..

load_helper()
{
    local CMD="$SHAREDIR/$1"
    # do not use fatal() here, it can be initial state
    [ -r "$CMD" ] || { echo "FATAL: Have no $CMD helper file" ; exit 1; }
    # shellcheck disable=SC1090
    . $CMD
}



# File bin/epm-sh-functions:


check_core_commands()
{
	#which --help >/dev/null || fatal "Can't find which command (which package is missed?)"
	# broken which on Debian systems
	which which >/dev/null || fatal "Can't find which command (which or debianutils package is missed?)"
	which grep >/dev/null || fatal "Can't find grep command (coreutils package is missed?)"
	which sed >/dev/null || fatal "Can't find sed command (sed package is missed?)"
}


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

	check_core_commands

	# grep -E from busybox may not --color
	# grep -E from MacOS print help to stderr
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
	local ver="$DISTRVERSION"
	[ -n "$ver" ] && ver="/$ver"
	PKGFORMAT=$($DISTRVENDOR -p "$DISTRNAME$ver")
	PKGVENDOR=$($DISTRVENDOR -s "$DISTRNAME$ver")
	RPMVENDOR=$($DISTRVENDOR -n "$DISTRNAME$ver")
}

showcmd()
{
	if [ -z "$quiet" ] ; then
		set_boldcolor $GREEN
		local PROMTSIG="\$"
		is_root && PROMTSIG="#"
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

sudorun()
{
	set_sudo
	if [ -z "$SUDO" ] ; then
		"$@"
		return
	fi
	$SUDO "$@"
}

sudocmd()
{
	set_sudo
	[ -n "$SUDO" ] && showcmd "$SUDO $*" || showcmd "$*"
	sudorun "$@"
}

sudocmd_foreach()
{
	local cmd pkg
	cmd="$1"
	#showcmd "$@"
	shift
	for pkg in "$@" ; do
		# don't quote $cmd here: it can be a command with an args
		sudocmd $cmd $pkg || return
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
	$PROGDIR/$PROGNAME --inscript "$@"
}

sudoepm()
{
	[ -n "$PROGNAME" ] || fatal "Can't use epm call from the piped script"
	sudorun $PROGDIR/$PROGNAME --inscript "$@"
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

SUDO_TESTED=''
SUDO_CMD='sudo'
set_sudo()
{
	local nofail="$1"

	# cache the result
	[ -n "$SUDO_TESTED" ] && return "$SUDO_TESTED"
	SUDO_TESTED="0"

	SUDO=""
	# skip SUDO if disabled
	[ -n "$EPMNOSUDO" ] && return
	if [ "$DISTRNAME" = "Cygwin" ] || [ "$DISTRNAME" = "Windows" ] ; then
		# skip sudo using on Windows
		return
	fi

	# if we are root, do not need sudo
	is_root && return

	# start error section
	SUDO_TESTED="1"

	if ! which $SUDO_CMD >/dev/null 2>/dev/null ; then
		[ "$nofail" = "nofail" ] || SUDO="fatal 'Can't find sudo. Please install and tune sudo ('# epm install sudo') or run epm under root.'"
		return "$SUDO_TESTED"
	fi

	# if input is a console
	if inputisatty && isatty && isatty2 ; then
		if ! $SUDO_CMD -l >/dev/null ; then
			[ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only without password sudo is supported in non interactive using). Please run epm under root.'"
			return "$SUDO_TESTED"
		fi
	else
		# use sudo if one is tuned and tuned without password
		if ! $SUDO_CMD -l -n >/dev/null 2>/dev/null ; then
			[ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only without password sudo is supported). Please run epm under root or check http://altlinux.org/sudo.'"
			return "$SUDO_TESTED"
		fi
	fi

	SUDO_TESTED="0"
	SUDO="$SUDO_CMD --"
	# check for < 1.7 version which do not support -- (and --help possible too)
	$SUDO_CMD -h 2>/dev/null | grep -q "  --" || SUDO="$SUDO_CMD"

}

withtimeout()
{
	local TO=$(which timeout 2>/dev/null || which gtimeout 2>/dev/null)
	if [ -x "$TO" ] ; then
		$TO "$@"
		return
	fi
	fatal "Possible indefinite wait due timeout command is missed"
	# fallback: drop time arg and run without timeout
	#shift
	#"$@"
}

set_eatmydata()
{
	# skip if disabled
	[ -n "$EPMNOEATMYDATA" ] && return
	# use if possible
	which eatmydata >/dev/null 2>/dev/null || return
	set_sudo
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


confirm_info()
{
	info "$*"
	if [ -z "$non_interactive" ] ; then
		confirm "Are you sure? [y/N]" || fatal "Exiting"
	fi

}


is_root()
{
	local EFFUID="$(id -u)"
	[ "$EFFUID" = "0" ]
}

assure_root()
{
	is_root || fatal "run me only under root"
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

disabled_eget()
{
	local EGET
	# use internal eget only if exists
	if [ -s $SHAREDIR/tools_eget ] ; then
		$SHAREDIR/tools_eget "$@"
		return
	fi
	fatal "Internal error: missed tools_eget"

	# FIXME: we need disable output here, eget can be used for get output
	assure_exists eget eget 3.3 >/dev/null
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
		*.AppImage)
			echo "AppImage"
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
        opt=`echo $n | sed -e "s|) # $1:.*||g" -e 's|"||g' -e 's@^|@@'`
        desc=`echo $n | sed -e "s|.*) # $1:||g"`
        printf "    %-20s %s\n" "$opt" "$desc"
    done
}

set_distro_info()
{
	# use external distro_info if internal one is missed
	DISTRVENDOR=internal_distr_info
	[ -x $DISTRVENDOR ] || DISTRVENDOR=internal_distr_info
	export DISTRVENDOR

	[ -n "$DISTRNAME" ] || DISTRNAME=$($DISTRVENDOR -d) || fatal "Can't get distro name."
	[ -n "$DISTRVERSION" ] || DISTRVERSION=$($DISTRVENDOR -v)
	if [ -z "$DISTRARCH" ] ; then
		DISTRARCH=$($DISTRVENDOR --distro-arch)
	fi
	DISTRCONTROL="$($DISTRVENDOR -y)"
}

set_pm_type()
{
	local CMD
	set_distro_info
	set_target_pkg_env

if [ -n "$FORCEPM" ] ; then
	PMTYPE=$FORCEPM
	return
fi

	PMTYPE="$($DISTRVENDOR -g $DISTRNAME/$DISTRVERSION)"
}

is_active_systemd()
{
	[ "$DISTRCONTROL" = "systemd" ]
}

assure_distr()
{
	local TEXT="this option"
	[ -n "$2" ] && TEXT="$2"
	[ "$DISTRNAME" = "$1" ] || fatal "$TEXT supported only for $1 distro"
}

get_pkg_name_delimiter()
{
   local pkgtype="$1"
   [ -n "$pkgtype" ] || pkgtype="$($DISTRVENDOR -p)"

   [ "$pkgtype" = "deb" ] && echo "_" && return
   echo "-"
}

has_space()
{
    estrlist -- has_space "$@"
}

# File bin/epm-addrepo:


ETERSOFTPUBURL=http://download.etersoft.ru/pub
ALTLINUXPUBURL=http://ftp.altlinux.org/pub/distributions

__epm_addrepo_rhel()
{
	local repo="$@"
	if [ -z "$repo" ] ; then
		echo "Add repo."
		echo "1. Use with repository URL, f.i. http://www.example.com/example.repo"
		echo "2. Use with epel to add EPEL repository"
		return 1
	fi
	case "$1" in
		epel)
			epm install epel-release
			return 1
			;;
	esac
	return 0
}

__epm_addrepo_etersoft_addon()
{
	epm install --skip-installed apt-conf-etersoft-common apt-conf-etersoft-hold || fatal
	# TODO: ignore only error code 22 (skipped) || fatal

	local pb="$DISTRVERSION/branch"
	[ "$DISTRVERSION" = "Sisyphus" ] && pb="$DISTRVERSION"

	# FIXME
	[ -n "$DISTRVERSION" ] || fatal "Empty DISTRVERSION"

	# TODO: use apt-repo add ?
	echo "" | sudocmd tee -a /etc/apt/sources.list
	echo "# added with eepm addrepo etersoft" | sudocmd tee -a /etc/apt/sources.list
	echo "rpm [etersoft] $ETERSOFTPUBURL/Etersoft LINUX@Etersoft/$pb/$DISTRARCH addon" | sudocmd tee -a /etc/apt/sources.list
	if [ "$DISTRARCH" = "x86_64" ] ; then
		echo "rpm [etersoft] $ETERSOFTPUBURL/Etersoft LINUX@Etersoft/$pb/x86_64-i586 addon" | sudocmd tee -a /etc/apt/sources.list
	fi
	echo "rpm [etersoft] $ETERSOFTPUBURL/Etersoft LINUX@Etersoft/$pb/noarch addon" | sudocmd tee -a /etc/apt/sources.list
}

__epm_addrepo_altlinux()
{
	local repo="$*"
	local branch="$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"
	[ -n "$branch" ] || fatal "Empty DISTRVERSION"

	if [ -z "$repo" ] || [ "$repo" == "--help" ] ; then
		info "Add branch repo. Use follow params:"
		sudocmd apt-repo $dryrun add branch
		echo "etersoft           - for LINUX@Etersoft repo"
		echo "basealt            - for BaseALT repo"
		echo "yandex             - for BaseALT repo mirror on yandex (recommended)"
		echo "<task number>      - add task repo"
		echo "archive 2018/02/09 - for archive from that date"
		echo "autoimports        - for BaseALT autoimports repo"
		return
	fi

	case "$1" in
		etersoft)
			info "add Etersoft's addon repo"
			assure_exists apt-repo
			__epm_addrepo_etersoft_addon
			sudocmd apt-repo add $branch
			epm repofix etersoft
			return 0
			;;
		basealt|ALTLinux|ALTServer)
			# TODO: setrepo?
			assure_exists apt-repo
			sudocmd apt-repo add $branch
			return 0
			;;
		yandex)
			assure_exists apt-repo
			sudocmd apt-repo add $branch
			epm repofix yandex
			return 0
			;;
		autoimports)
			repo="autoimports.$branch"
			;;
		archive)
			datestr="$2"
			echo "$datestr" | grep -Eq "^20[0-2][0-9]/[01][0-9]/[0-3][0-9]$" || fatal "use follow date format: 2017/12/31"

			echo "" | sudocmd tee -a /etc/apt/sources.list
			local distrversion="$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"
			local rpmsign='[alt]'
			[ "$distrversion" != "sisyphus" ] && rpmsign="[$distrversion]"
			echo "rpm $rpmsign $ALTLINUXPUBURL archive/$distrversion/date/$datestr/$DISTRARCH classic" | sudocmd tee -a /etc/apt/sources.list
			if [ "$DISTRARCH" = "x86_64" ] ; then
				echo "rpm $rpmsign $ALTLINUXPUBURL archive/$distrversion/date/$datestr/x86_64-i586 classic" | sudocmd tee -a /etc/apt/sources.list
			fi
			echo "rpm $rpmsign $ALTLINUXPUBURL archive/$distrversion/date/$datestr/noarch classic" | sudocmd tee -a /etc/apt/sources.list
			return 0
			;;
	esac

	assure_exists apt-repo

	if tasknumber "$repo" >/dev/null ; then
		sudocmd_foreach "apt-repo $dryrun add" $(tasknumber "$repo")
		return
	fi

	sudocmd apt-repo $dryrun add "$repo"

}

__epm_addkey_deb()
{
    local url="$1"
    local fingerprint="$2"
    if [ -z "$fingerprint" ] ; then
        assure_exists curl
        set_sudo
        showcmd "curl -fsSL '$url' | $SUDO apt-key add -"
        a= curl -fsSL "$url" | sudorun apt-key add -
        return
    fi
    sudocmd apt-key adv --keyserver "$url" --recv "$fingerprint"
}

__epm_addrepo_deb()
{
	assure_exists apt-add-repository software-properties-common
	local ad="$($DISTRVENDOR --distro-arch)"
	# TODO: move to distro_info
	local nd="$(lsb_release -cs)"
	local repo="$*"

	if [ -z "$repo" ] || [ "$repo" = "--help" ]; then
		info "Add repo. You can use follow params:"
		echo "  docker - add official docker repo"
		echo "  ppa:<user>/<ppa-name> - add PPA repo"
		echo "  distribution component name"
		echo "  full sources list line"
		echo "  URL version component"
		return
	fi

	if [ "$DISTRNAME" = "AstraLinux" ] ; then
		echo "Use workaround for AstraLinux"
		# aptsources.distro.NoDistroTemplateException: Error: could not find a distribution template for AstraLinuxCE/orel
		echo "" | sudocmd tee -a /etc/apt/sources.list
		echo "$repo" | sudocmd tee -a /etc/apt/sources.list
		exit
	fi


	# keywords
	case "$1" in
		docker)
			__epm_addkey_deb https://download.docker.com/linux/$PKGVENDOR/gpg "9DC858229FC7DD38854AE2D88D81803C0EBFCD88"
			repo="https://download.docker.com/linux/$PKGVENDOR $nd stable"
			;;
	esac

	# if started from url, use heroistic
	if echo "$repo" | grep -E -q "^https?://" ; then
		repo="deb [arch=$ad] $repo"
	fi

	if echo "$repo" | grep -q "https://" ; then
		assure_exists /usr/share/doc/apt-transport-https apt-transport-https
		assure_exists /usr/sbin/update-ca-certificates ca-certificates 
	fi

	# FIXME: quotes in showcmd/sudocmd
	showcmd apt-add-repository "$repo"
	sudorun apt-add-repository "$repo"
	info "Check file /etc/apt/sources.list if needed"
}

epm_addrepo()
{
local repo="$*"

case $DISTRNAME in
	ALTLinux|ALTServer)
		# Note! Don't use quotes here
		__epm_addrepo_altlinux $repo
		return
		;;
esac

case $PMTYPE in
	apt-dpkg)
		# Note! Don't use quotes here
		__epm_addrepo_deb $repo
		;;
	aptitude-dpkg)
		info "You need manually add repo to /etc/apt/sources.list (TODO)"
		;;
	yum-rpm)
		assure_exists yum-utils
		__epm_addrepo_rhel "$repo" || return
		sudocmd yum-config-manager --add-repo "$repo"
		;;
	dnf-rpm)
		__epm_addrepo_rhel "$repo" || return
		sudocmd dnf config-manager --add-repo "$repo"
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
	winget)
		sudocmd winget source add "$repo"
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
        # TODO: check for /usr/bin, /bin, /usr/sbin, /sbin
        if [ -e "$CMD" ] ; then
            if [ -n "$verbose" ] ; then
                info "File or directory $CMD is already exists."
                epm qf "$CMD"
            fi
            return 0
        fi

        [ -n "$PACKAGE" ] || fatal "You need run with package name param when use with absolute path to non executable file"
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



epm_assure()
{
    local CMD="$1"
    local PACKAGE="$2"
    local PACKAGEVERSION="$3"
    [ -n "$PACKAGE" ] || PACKAGE="$1"

    __epm_assure_checking $CMD $PACKAGE $PACKAGEVERSION && return 0

    info "Installing appropriate package for $CMD command..."
    __epm_need_update $PACKAGE $PACKAGEVERSION || return 0

    # can't be used in epm ei case
    #docmd epm --auto install $PACKAGE || return
    # TODO: HACK: DEBUG=1 for skip to_remove_pkg handling
    (DEBUG=1 repack='' non_interactive=1 pkg_names="$PACKAGE" pkg_files='' pkg_urls='' epm_install ) || return

    # no check if we don't need a version
    [ -n "$PACKAGEVERSION" ] || return 0

    # check if we couldn't update and still need update
    __epm_need_update $PACKAGE $PACKAGEVERSION && return 1
    return 0
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

[ -z "$*" ] || fatal "No arguments are allowed here"


case $PMTYPE in
	apt-rpm)
		# ALT Linux only
		assure_exists /usr/share/apt/scripts/list-extras.lua apt-scripts
		if [ -z "$dryrun" ] ; then
			echo "We will try remove all installed packages which are missed in repositories"
			warning "Use with caution!"
		fi
		epm Upgrade || fatal
		local PKGLIST=$(__epm_orphan_altrpm \
			| sed -e "s/\.32bit//g" \
			| grep -v -- "^eepm$" \
			| grep -v -- "^distro_info$" \
			| grep -v -- "^kernel")

		if [ -z "$dryrun" ] && [ -n "$PKGLIST" ] ; then
			showcmd epm remove $dryrun $force $PKGLIST
			confirm_info "We will remove packages above."
		fi

			docmd epm remove $dryrun $force $(subst_option non_interactive --auto) $PKGLIST
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
		docmd epm upgrade
		assure_exists package-cleanup yum-utils
		showcmd package-cleanup --orphans
		local PKGLIST=$(package-cleanup -q --orphans | grep -v "^eepm-")
		docmd epm remove $dryrun $PKGLIST
		;;
	dnf-rpm)
		# TODO: dnf list extras
		docmd epm upgrade
		assure_exists package-cleanup dnf-utils
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


__epm_print_excluded()
{
	local pkgs="$1"
	local fullpkgs="$2"
	local excluded
	excluded="$(estrlist exclude "$pkgs" "$fullpkgs")"
	if [ -n "$excluded" ] ; then
		echo "Skipped manually installed:"
		estrlist union $excluded
	fi
}

__epm_autoremove_altrpm_pp()
{
	local pkgs fullpkgs

	info "Removing unused python/perl modules..."

	local libexclude="$1"

	local flag=

	showcmd "apt-cache list-nodeps | grep -E -- \"$libexclude\""
	fullpkgs=$(apt-cache list-nodeps | grep -E -- "$libexclude" )
	pkgs=$(skip_manually_installed $fullpkgs)

	if [ -n "$dryrun" ] ; then
		info "Packages for autoremoving:"
		echo "$pkgs"
		__epm_print_excluded "$pkgs" "$fullpkgs"
		return 0
	fi

	if [ -n "$pkgs" ] ; then
		info "The command we will run:"
		showcmd rpm -v -e $pkgs
		__epm_print_excluded "$pkgs" "$fullpkgs"

		confirm_info "We will remove unused (without dependencies) packages above."

		sudocmd rpm -v -e $pkgs && flag=1
	fi


	if [ -n "$flag" ] ; then
		info ""
		info "call again for next cycle until all modules will be removed"
		__epm_autoremove_altrpm_pp "$libexclude"
	fi

	return 0
}

__epm_autoremove_altrpm_package_group()
{
	if epmqp "$*" ; then
		confirm_info "We will remove unused (without dependencies) packages above."
		docmd epm remove $(epmqp --short "$*")
	fi
}

__epm_autoremove_altrpm_lib()
{
	local pkgs fullpkgs

	local flag=''
	local opt="$1"
	local libgrep=''
	info
	case "$opt" in
		libs)
			info "Removing all non -devel/-debuginfo libs packages not need by anything..."
			local develrule='-(devel|devel-static)$'
			libgrep='^(lib|bzlib|zlib)'
			;;
		i586-libs)
			info "Removing all non -devel/-debuginfo i586-libs packages not need by anything..."
			local develrule='-(devel|devel-static)$'
			libgrep='^(i586-lib|i586-bzlib|i586-zlib)'
			;;
		devel)
			info "Removing all non -debuginfo libs packages (-devel too) not need by anything..."
			local develrule='-(NONONO)$'
			libgrep='^(lib|bzlib|zlib)'
			;;
		*)
			fatal "Internal error: unsupported opt $opt"
	esac

	# https://www.altlinux.org/APT_в_ALT_Linux/Советы_по_использованию#apt-cache_list-nodeps
	showcmd "apt-cache list-nodeps | grep -E -- \"$libgrep\""
	fullpkgs=$(apt-cache list-nodeps | grep -E -- "$libgrep" \
		| sed -e "s/[-\.]32bit$//g" \
		| grep -E -v -- "$develrule" \
		| grep -E -v -- "-(debuginfo)$" \
		| grep -E -v -- "-(util|utils|tool|tools|plugin|daemon|help)$" \
		| grep -E -v -- "^(libsystemd|libreoffice|libnss|libvirt-client|libvirt-daemon|libsasl2-plugin|eepm|distro_info)" )
	pkgs=$(skip_manually_installed $fullpkgs)

	if [ -n "$dryrun" ] ; then
		info "Packages for autoremoving:"
		echo "$pkgs"
		__epm_print_excluded "$pkgs" "$fullpkgs"
		return 0
	fi

	if [ -n "$pkgs" ] ; then
		info "The command we will run:"
		showcmd rpm -v -e $pkgs
		__epm_print_excluded "$pkgs" "$fullpkgs"
		confirm_info "We will remove unused (without dependencies) packages above."

		sudocmd rpm -v -e $pkgs && flag=1
	fi

	if [ -n "$flag" ] ; then
		info ""
		info "call again for next cycle until all libs will be removed"
		__epm_autoremove_altrpm_lib $opt
	fi

	return 0
}


epm_autoremove_default_groups="python2 python3 perl gem ruby libs"

__epm_autoremove_altrpm()
{
	local i
	assure_exists /usr/share/apt/scripts/list-nodeps.lua apt-scripts

	if [ -z "$pkg_names" ] ; then
		pkg_names="$epm_autoremove_default_groups"
	elif [ "$pkg_names" = "python" ] ; then
		pkg_names="python2 python3"
	fi

	for i in $pkg_names ; do
		case $i in
		libs)
			__epm_autoremove_altrpm_lib libs
			;;
		i586-libs)
			__epm_autoremove_altrpm_lib i586-libs
			;;
		debuginfo)
			__epm_autoremove_altrpm_package_group '-debuginfo-'
			;;
		devel)
			__epm_autoremove_altrpm_package_group '^(rpm-build-|gcc-|glibc-devel-)'
			;;
		python2)
			__epm_autoremove_altrpm_pp '^(python-module-|python-modules-)'
			;;
		python3)
			__epm_autoremove_altrpm_pp '^(python3-module-|python3-modules-)'
			;;
		php)
			__epm_autoremove_altrpm_pp '^(php7-|php5-|php8-)'
			;;
		gem)
			__epm_autoremove_altrpm_pp '^(gem-)'
			;;
		ruby)
			__epm_autoremove_altrpm_pp '^(ruby-)'
			;;
		perl)
			__epm_autoremove_altrpm_pp '^(perl-)'
			;;
		libs-devel)
			__epm_autoremove_altrpm_lib devel
			;;
		*)
			fatal "autoremove: unsupported '$i'. Use epm autoremove --help to list supported ones"
			;;
		esac
	done

	return 0
}

epm_autoremove_print_help()
{
	echo "epm autoremove removes unneeded packages from the system"
	echo "run 'epm autoremove' to use apt-get autoremove"
	echo "or run 'epm autoremove --direct [group1] [group2] ...' to use epm implementation"
	echo "Default groups: $epm_autoremove_default_groups"
	cat <<EOF
Supported package groups:
    libs       - unused libraries
    libs-devel - unused -devel packages
    i586-libs  - unused i586-libs libraries
    debuginfo  - all debuginfo packages
    devel      - all packages used for build/developing
    python     - all python modules
    python2    - python2 modules
    python3    - python3 modules
    perl       - perl modules
    gem        - gem modules
    ruby       - ruby modules

Use
--auto|--assumeyes|--non-interactive  for non interactive mode
EOF
}


epm_autoremove()
{

case $DISTRNAME in
	ALTLinux|ALTServer)
		if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ] ; then
			epm_autoremove_print_help
			return 0
		fi

		if [ -z "$direct" ] ; then
			[ -n "$1" ] && fatal "Run autoremove without args or with --direct. Check epm autoremove --help to available commands."
			sudocmd apt-get $(subst_option non_interactive -y) autoremove $dryrun
			local RET=$?
			if [ "$RET" != 0 ] ; then
				echo
				info "Also you can run 'epm autoremove --direct' to use epm implementation of autoremove (see --help)"
				return
			fi
		else
			__epm_autoremove_altrpm "$@"
		fi

		[ -n "$dryrun" ] && return

		# remove old kernels only by a default way
		[ -n "$1" ] && return

		docmd epm remove-old-kernels $(subst_option non_interactive --auto)

		if [ -z "$direct" ] ; then
			echo
			info "Also you can run 'epm autoremove --direct' to use epm implementation of autoremove (see --help)"
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
	packagekit)
		docmd pkcon repair --autoremove
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
	opkg)
		if [ -n "$dryrun" ] ; then
			sudocmd opkg --noaction --autoremove
		else
			sudocmd opkg --autoremove
		fi
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
	apt-rpm)
		#sudocmd apt-get check || exit
		#sudocmd apt-get update || exit
		sudocmd apt-get -f install || return
		info "You can use epm dedup also"
		;;
	apt-dpkg)
		#sudocmd apt-get check || exit
		#sudocmd apt-get update || exit
		sudocmd apt-get -f install || return
		;;
	apt-dpkg)
		#sudocmd apt-get update || exit
		#sudocmd apt-get check || exit
		sudocmd apt-get -f install || return
		#sudocmd apt-get autoremove
		;;
	packagekit)
		docmd pkcon repair
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
	xbps)
		sudocmd xbps-pkgdb -a
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-checkpkg:

__rpm_allows_nosignature()
{
    a= rpm --help | grep -q -- "--nosignature"
}

check_pkg_integrity()
{
	local PKG="$1"
	local RET
	local NOSIGNATURE

	case $(get_package_type $PKG) in
	rpm)
		assure_exists rpm
		__rpm_allows_nosignature && NOSIGNATURE="--nosignature" || NOSIGNATURE="--nogpg"
		docmd rpm --checksig $NOSIGNATURE $PKG
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
		info "Suggest $pkg_names are name(s) of installed package(s)"
		__epm_check_installed_pkg $pkg_names
		return
	fi

	# if possible, it will put pkg_urls into pkg_files or pkg_names
	if [ -n "$pkg_urls" ] ; then
		__handle_pkg_urls_to_checking
	fi

	[ -n "$pkg_files" ] || fatal "Checkpkg: filename(s) is missed"

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

is_root && fatal "Do not use checksystem under root"

case $PMTYPE in
	homebrew)
		sudocmd brew doctor
		return
		;;
esac

case $DISTRNAME in
	ALTLinux|ALTServer)
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
            #if [ -r /var/cache/apt ] ; then
            #    sudorun test -r /var/cache/apt/pkgcache.bin || return
            #fi
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
                sudorun test -r $LOCKFILE || return
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
    if [ "$1" = "soft" ] && ! set_sudo nofail ; then
        # if sudo requires a password, skip autoupdate
        info "can't use sudo, so skip repo status checking"
        return 1
    fi

    cd / || fatal
    if ! __is_repo_info_downloaded || ! __is_repo_info_uptodate ; then
        # FIXME: cleans!!!
        epm_update
    fi
    cd - >/dev/null || fatal

}

save_installed_packages()
{
	[ -d /var/lib/rpm ] || return 0
	estrlist list "$@" | sudorun tee /var/lib/rpm/EPM-installed >/dev/null
}

check_manually_installed()
{
	[ -r /var/lib/rpm/EPM-installed ] || return 1
	grep -q -- "^$1\$" /var/lib/rpm/EPM-installed
}

skip_manually_installed()
{
	local i
	for i in "$@" ; do
		check_manually_installed "$i" && continue
		echo "$i"
	done
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

[ -z "$*" ] || fatal "No arguments are allowed here"


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
	homebrew)
		sudocmd brew cleanup -s
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
	appget|winget)
		sudocmd $PMTYPE clean
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

# File bin/epm-commentrepo:


__epm_commentrepo_alt_grepremove()
{
	local rl
	__replace_text_in_alt_repo "/^ *#/! s! *(.*$1)!# \1!g"
	exit
	# TODO
	# ^rpm means full string
	if rhas "$1" "^rpm" ; then
		rl="$1"
	else
		rl="$( (epm --quiet repo list) 2>/dev/null | grep -E "$1")"
		[ -z "$rl" ] && warning "Can't find '$1' in the repos (see '# epm repolist' output)" && return 1
	fi
	echo "$rl" | while read rp ; do
		if [ -n "$dryrun" ] ; then
			echo "$rp" | grep -E --color -- "$1"
			continue
		fi
		#if [ -n "$verbose" ] ; then
		#	sudocmd apt-repo $dryrun rm "$rp"
		#else
		__replace_text_in_alt_repo "s! *$rp!# $rp!g"
		#fi
	done
}

__epm_commentrepo_alt()
{
	local repo="$*"
	[ -n "$repo" ] || fatal "No such repo or task. Use epm repo comment <regexp|archive|tasks|TASKNUMBER>"

	assure_exists apt-repo

	if tasknumber "$repo" >/dev/null ; then
		local tn
		for tn in $(tasknumber "$repo") ; do
			__epm_commentrepo_alt_grepremove " repo/$tn/"
		done
		return
	fi

	case "$1" in
		archive)
			info "remove archive repos"
			__epm_commentrepo_alt_grepremove "archive/"
			;;
		tasks)
			info "remove task repos"
			__epm_commentrepo_alt_grepremove " repo/[0-9]+/"
			;;
		task)
			shift
			__epm_commentrepo_alt_grepremove " repo/$1/"
			;;
		-*)
			fatal "epm commentrepo: no options are supported"
			;;
		*)
			__epm_commentrepo_alt_grepremove "$*"
			;;
	esac

}

epm_commentrepo()
{

case $DISTRNAME in
	ALTLinux|ALTServer)
		__epm_commentrepo_alt "$@"
		return
		;;
esac;

fatal "Have no suitable command for $PMTYPE"

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

# File bin/epm-dedup:

try_fix_apt_rpm_dupls()
{
	info "Check for duplicates (internal implementation) ..."
	local TESTPKG="ignoreflock"
	local has_testpkg=""
	if epm --quiet installed $TESTPKG ; then
		has_testpkg=1
		sudocmd epm remove --auto $TESTPKG || return
	fi
	local PKGLIST
	PKGLIST=$(LANG=C sudorun apt-get install $TESTPKG 2>&1 | grep "W: There are multiple versions of" | \
		sed -e 's|W: There are multiple versions of "\(.*\)" in your system.|\1|')
	local TODEL
	for i in $PKGLIST ; do
		local pkg=${i/.32bit/}
		local todel="$(rpm -q $pkg | head -n1)"
		local todel2="$(rpm -q $pkg | head -n2 | tail -n1)"
		if [ "$todel" = "$todel2" ] ; then
			echo "Fix the same name duplicates for $pkg..."
			sudocmd rpm -e "$todel" --allmatches --nodeps --justdb && epm install $pkg && continue
		fi
                # first use older package
                [ "$(rpmevrcmp "$todel" "$todel2")" = "1" ] && todel="$todel2"
		sudocmd rpm -e "$todel" || TODEL="$TODEL $todel"
	done
	[ -n "$TODEL" ] && sudocmd rpm -e $TODEL
	[ -n "$has_testpkg" ] && epm install $TESTPKG
}

epm_dedup()
{
case "$DISTRNAME" in
	ALTLinux|ALTServer)
		assure_exists /usr/share/apt/scripts/dedup.lua apt-scripts
		if [ -z "$direct" ] && [ -f /usr/share/apt/scripts/dedup.lua ] ; then
			info "Check for duplicates via apt-get dedup from apt-scripts (also you can use internal EPM dedup implementation with --direct option)"
			sudocmd apt-get dedup
		else
			info "You can use dedup from apt-scripts package"
			try_fix_apt_rpm_dupls
		fi
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-downgrade:


__epm_add_alt_apt_downgrade_preferences()
{
	[ -r /etc/apt/preferences ] && fatal "/etc/apt/preferences already exists"
	cat <<EOF | sudocmd tee /etc/apt/preferences
Package: *
Pin: release c=classic
Pin-Priority: 1001

Package: *
Pin: release c=addon
Pin-Priority: 1101

Package: *
Pin: release c=task
Pin-Priority: 1201
EOF
}

__epm_add_deb_apt_downgrade_preferences()
{
	[ -r /etc/apt/preferences ] && fatal "/etc/apt/preferences already exists"
	info "Running with /etc/apt/preferences:"
	cat <<EOF | sudorun tee /etc/apt/preferences
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
		# pass pkg_filenames too
		if [ -n "$pkg_names" ] ; then
			__epm_add_alt_apt_downgrade_preferences || return
			(pkg_names=$(get_only_installed_packages $pkg_names) epm_install)
			__epm_remove_apt_downgrade_preferences
		elif [ -n "$pkg_files" ] ; then
			(pkg_files=$pkg_files force="$force -F --oldpackage" epm_install)
		else
			__epm_add_alt_apt_downgrade_preferences || return
			epm_upgrade "$@"
			__epm_remove_apt_downgrade_preferences
		fi
		;;
	apt-dpkg)
		local APTOPTIONS="$(subst_option non_interactive -y) $force_yes"
		__epm_add_deb_apt_downgrade_preferences || return
		if [ -n "$pkg_filenames" ] ; then
			sudocmd apt-get $APTOPTIONS install $pkg_filenames
		else
			sudocmd apt-get $APTOPTIONS dist-upgrade
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
	# force download if wildcard is used
	echo "$pkg_urls" | grep -q "[?*]" && return 1

	# install of remote files has a side affect
	# (more fresh package from a repo can be installed instead of the file)
	#case $DISTRNAME in
	#	"ALTLinux")
	#		# do not support https yet
	#		echo "$pkg_urls" | grep -q "https://" && return 1
	#		pkg_names="$pkg_names $pkg_urls"
	#		return 0
	#		;;
	#esac

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
		showcmd cd $tmppkg
		cd $tmppkg || fatal
		if docmd eget --latest "$url" ; then
			local i
			# use downloaded file
			i=$(echo *.*)
			[ -s "$tmppkg/$i" ] || continue
			pkg_files="$pkg_files $tmppkg/$i"
			to_remove_pkg_files="$to_remove_pkg_files $tmppkg/$i"
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
	assure_exists curl
	quiet=1
	local buildtime=$(paoapi packages/$pkg | get_pao_var buildtime)
	echo
	echo "Latest release: $(paoapi packages/$pkg | get_pao_var sourcepackage) $buildtime"
	__epm_print_url_alt "$1" | while read url ; do
		a='' curl -s --head $url >$tm || { echo "$url: missed" ; continue ; }
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

	case $DISTRNAME-$PMTYPE in
		ALTLinux-apt-rpm|ALTServer-apt-rpm)
			__epm_download_alt $*
			return
			;;
	esac

	case $PMTYPE in
	apt-dpkg)
		docmd apt-get download $*
		;;
	dnf-rpm)
		sudocmd dnf download $*
		;;
	aptcyg)
		sudocmd apt-cyg download $*
		;;
	packagekit)
		docmd pkcon download $*
		;;
	yum-rpm)
		# TODO: check yum install --downloadonly --downloaddir=/tmp <package-name>
		assure_exists yumdownloader yum-utils
		sudocmd yumdownloader $*
		;;
	dnf-rpm)
		sudocmd dnf download $*
		;;
	urpm-rpm)
		sudocmd urpmi --no-install $URPMOPTIONS $@
		;;
	tce)
		sudocmd tce-load -w $*
		;;
	opkg)
		docmd opkg $*
		;;
	homebrew)
		docmd brew fetch $*
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-epm_install:



__epm_korinf_site_mask() {
    local MASK="$1"
    local archprefix=""
    # short hack to install needed package
    rhas "$MASK" "[-_]" || MASK="$MASK[-_][0-9]"
    # set arch for Korinf compatibility
    [ "$($DISTRVENDOR -a)" = "x86_64" ] && archprefix="x86_64/"
    echo "http://updates.etersoft.ru/pub/Korinf/$archprefix$($DISTRVENDOR -e)/$MASK*.$($DISTRVENDOR -p)"
}

__epm_korinf_list() {
    local MASK="$1"
    MASK="$(__epm_korinf_site_mask "$MASK")"
    showcmd eget --list "$MASK"
    eget --list "$MASK" | sort
}


__epm_korinf_install() {
    local PACKAGE="$1"
    # due Error: Can't use epm call from the piped script
    #epm install $(__epm_korinf_site_mask "$PACKAGE")
    pkg_names='' pkg_files='' pkg_urls="$(__epm_korinf_site_mask "$PACKAGE")" epm_install
}

epm_epm_install() {
    local i
    local pkglist="$*"

    # install epm by default
    if [ -z "$pkglist" ] || [ "$pkglist" = "epm" ] || [ "$pkglist" = "eepm" ]; then
            pkglist="eepm"
    fi

    case "$pkglist" in
        --list*)
            shift
            __epm_korinf_list "$1"
            return
            ;;
    esac

    for i in $pkglist ; do
        __epm_korinf_install $i
    done
}

# File bin/epm-filelist:


__alt_local_content_filelist()
{

    update_alt_contents_index
    local CI="$(cat $ALT_CONTENTS_INDEX_LIST)"

    # TODO: safe way to use less
    #local OUTCMD="less"
    #[ -n "$USETTY" ] || OUTCMD="cat"
    OUTCMD="cat"

    {
        [ -n "$USETTY" ] && info "Search in $CI for $1..."
        __local_ercat $CI | grep -h -P -- ".*\t$1$" | sed -e "s|\(.*\)\t\(.*\)|\1|g"
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
			# TODO: improve me
			if sudorun -n true 2>/dev/null ; then
				sudocmd apt-file update
			else
				info "sudo requires a password, skip apt-file update"
			fi
			docmd_foreach __deb_local_content_filelist "$@"
			;;
		packagekit)
			docmd pkcon get-files "$@"
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
		packagekit)
			CMD="pkcon get-files"
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
		opkg)
			CMD="opkg files"
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
	[ -n "$pkg_filenames" ] || fatal "Filelist: package name is missed"


	__epm_filelist_file $pkg_files || return
	# shellcheck disable=SC2046
	__epm_filelist_name $(print_name $pkg_names) || return

}

# File bin/epm-full_upgrade:

epm_full_upgrade()
{
	docmd epm update || return

	[ -n "$quiet" ] || echo
	docmd epm upgrade || return

	[ -n "$quiet" ] || echo
	docmd epm update-kernel || return

	[ -n "$quiet" ] || echo
	docmd epm play --update all || return
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
	*-rpm)
		__epm_info_rpm_low && return
		case $PMTYPE in
			apt-rpm)
				docmd apt-cache show $pkg_names
				;;
			packagekit)
				docmd pkcon get-details $pkg_names
				;;
			yum-rpm)
				docmd yum info $pkg_names
				;;
			urpmi-rpm)
				docmd urpmq -i $pkg_names
				;;
			dnf-rpm)
				docmd dnf info $pkg_names
				;;
			zypper-rpm)
				docmd zypper info $pkg_names
				;;
			*)
				warning "Unknown command for $PMTYPE"
				;;
		esac
		;;
	packagekit)
		# TODO: get-details-local
		docmd pkcon get-details $pkg_names
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
	opkg)
		docmd opkg info $pkg_names
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
	winget)
		docmd winget show $pkg_names
		;;
	appget)
		docmd appget view $pkg_names
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

[ -n "$pkg_filenames" ] || fatal "Info: package name is missed"

__epm_info_by_pkgtype || __epm_info_by_pmtype

local RETVAL=$?

[ -n "$to_remove_pkg_files" ] && rm -fv $to_remove_pkg_files
[ -n "$to_remove_pkg_files" ] && rmdir -v $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null

return $RETVAL
}

# File bin/epm-install:



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
        sudocmd $cmd_re $pkg_noninstalled || return
    fi
    if [ -n "$pkg_installed" ] ; then
        sudocmd $cmd_in $pkg_installed || return
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
			sudocmd apt-get $APTOPTIONS $noremove install $@ && save_installed_packages $@
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
		packagekit)
			docmd pkcon install $@
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
			sudocmd pacman -S $nodeps $@
			return ;;
		aura)
			sudocmd aura -A $force $nodeps $@
			return ;;
		yum-rpm)
			sudocmd yum $YUMOPTIONS install $(echo "$*" | exp_with_arch_suffix)
			return ;;
		dnf-rpm)
			sudocmd dnf install $(echo "$*" | exp_with_arch_suffix)
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
		opkg)
			[ -n "$force" ] && force=-force-depends
			sudocmd opkg $force install $@
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
		appget|winget)
			sudocmd $PMTYPE install $@
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
			sudocmd yum -y $YUMOPTIONS install $(echo "$*" | exp_with_arch_suffix)
			return ;;
		dnf-rpm)
			sudocmd dnf -y $YUMOPTIONS install $(echo "$*" | exp_with_arch_suffix)
			return ;;
		urpm-rpm)
			sudocmd urpmi --auto $URPMOPTIONS $@
			return ;;
		zypper-rpm)
			# FIXME: returns true ever no package found, need check for "no found", "Nothing to do."
			yes | sudocmd zypper --non-interactive $ZYPPEROPTIONS install $@
			return ;;
		packagekit)
			docmd pkcon install --noninteractive $@
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
			sudocmd pacman -S --noconfirm $nodeps $@
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
		opkg)
			sudocmd opkg -force-defaults install $@
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
		appget|winget)
			sudocmd $PMTYPE -s install $@
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
	LANG=C sudorun rpm -Uvh $force $nodeps $@ 2>&1 | grep -q "is already installed"
}

__handle_direct_install()
{
    case "$DISTRNAME" in
        ALTLinux|ALTServer)
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

__epm_check_if_src_rpm()
{
    local pkg
    for pkg in $@ ; do
        echo "$pkg" | grep -q "\.src.\rpm" && fatal "Installation of a source packages (like '$pkg') is not supported."
    done
}

__epm_check_if_needed_repack()
{
    local pkgname="$(epm print name from "$1")"
    local repackcode="$CONFIGDIR/repack.d/$pkgname.sh"
    [ -x "$repackcode" ] || return
    warning "There is exists repack rules for $pkgname package. It is better install this package via epm --repack install or epm play."
}

epm_install_files()
{
    [ -z "$1" ] && return

    # TODO: check read permissions
    # sudo test -r FILE
    # do not fallback to install_names if we have no permissions
    case "$DISTRNAME" in
        ALTLinux|ALTServer)

            # TODO: replace with name changed function
            __epm_check_if_try_install_pkgtype deb $@ && return $RES
            __epm_check_if_try_install_pkgtype AppImage $@ && return $RES
            __epm_check_if_src_rpm $@

            # do not use low-level for install by file path (FIXME: reasons?)
            if ! is_dirpath "$@" || [ "$(get_package_type "$@")" = "rpm" ] ; then
                __epm_check_vendor $@
                __epm_check_if_needed_repack $@
                sudocmd rpm -Uvh $force $noscripts $nodeps $@ && save_installed_packages $@ && return
                local RES=$?
                # TODO: check rpm result code and convert it to compatible format if possible
                __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level
            [ -n "$nodeps" ] && return $RES
            fi

            epm_install_names "$@"
            return
            ;;
    esac

    case $PMTYPE in
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

       *-rpm)
            __epm_check_if_try_install_pkgtype deb $@ && return $RES
            __epm_check_if_try_install_pkgtype AppImage $@ && return $RES
            __epm_check_if_src_rpm $@
            sudocmd rpm -Uvh $force $noscripts $nodeps $@ && return
            local RES=$?

            __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level
            [ -n "$nodeps" ] && return $RES

            case $PMTYPE in
                yum-rpm|dnf-rpm)
                    YUMOPTIONS=--nogpgcheck
                    # use install_names
                    ;;
                zypper-rpm)
                    ZYPPEROPTIONS=$(__use_zypper_no_gpg_checks)
                    # use install_names
                    ;;
                urpm-rpm)
                    URPMOPTIONS=--no-verify-rpm
                    # use install_names
                    ;;
                *)
                    # use install_names
                    ;;
            esac
            ;;
        packagekit)
            docmd pkcon install-local $@
            return ;;
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
            sudocmd pacman -U --noconfirm $nodeps $@ && return
            local RES=$?

            [ -n "$nodeps" ] && return $RES
            sudocmd pacman -U $@
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
        *-rpm)
            echo "rpm -Uvh --force $nodeps $*"
            ;;
        *-dpkg)
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
            echo "pacman -U --noconfirm $nodeps $*"
            ;;
        slackpkg)
            echo "/sbin/installpkg $*"
            ;;
        npackd)
            echo "npackdcl add --package=$*"
            ;;
        opkg)
            echo "opkg install $*"
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
        appget|winget)
            echo "$PMTYPE install -s $*"
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
		packagekit)
			echo "pkcon --noninteractive $*"
			return ;;
		pacman)
			echo "pacman -S --noconfirm $*"
			return ;;
		chocolatey)
			echo "chocolatey install $*"
			return ;;
		nix)
			echo "nix-env --install $*"
			return ;;
		appget|winget)
			echo "$PMTYPE install $*"
			return ;;
		*)
			fatal "Have no suitable appropriate install command for $PMTYPE"
			;;
	esac
}


epm_install()
{
    if [ "$DISTRNAME" = "ALTLinux" ] || [ "$DISTRNAME" = "ALTServer" ] ; then
        if tasknumber "$pkg_names" >/dev/null ; then
            assure_exists apt-repo
            # TODO: add --auto support
            sudocmd_foreach "apt-repo test" $(tasknumber $pkg_names)
            return
        fi
    fi

    if [ -n "$show_command_only" ] ; then
        epm_print_install_command $pkg_files
        epm_print_install_names_command $pkg_names
        return
    fi

    if [ -n "$direct" ] && [ -z "$repack" ] ; then
        __handle_direct_install
    fi

    # if possible, it will put pkg_urls into pkg_files and reconstruct pkg_filenames
    if [ -n "$pkg_urls" ] ; then
        __handle_pkg_urls_to_install
    fi

    [ -z "$pkg_files$pkg_names" ] && info "Skip empty install list" && return 22

    # to be filter happy
    warmup_lowbase

    # Note: filter_out_installed_packages depends on skip_installed flag
    local names="$(echo $pkg_names | filter_out_installed_packages)"
    #local names="$(echo $pkg_names | exp_with_arch_suffix | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    # can be empty only after skip installed
    if [ -z "$files$names" ] ; then
        # TODO: assert $skip_installed
        [ -n "$verbose" ] && info "Skip empty install list (filtered out)"
        # FIXME: see to_remove below
        return 0
    fi

    if [ -z "$files" ] && [ -z "$direct" ] ; then
        # it is useful for first time running
        update_repo_if_needed
    fi

    # FIXME: see to_remove below
    epm_install_names $names || return

    # repack binary files
    if [ -n "$repack" ] ; then
        # FIXME: see to_remove below
        __epm_repack_to_rpm $files || fatal
        files="$repacked_rpms"
    fi

    epm_install_files $files
    local RETVAL=$?

    # TODO: move it to exit handler
    if [ -z "$DEBUG" ] ; then
    # TODO: reinvent
    [ -n "$to_remove_pkg_files" ] && rm -fv $to_remove_pkg_files
    [ -n "$to_remove_pkg_files" ] && rmdir -v $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null
    fi

    return $RETVAL
}

# File bin/epm-Install:


epm_Install()
{
    # copied from epm_install
    local names="$(echo $pkg_names | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    [ -z "$files$names" ] && info "Install: Skip empty install list." && return 22

    epm_update || { [ -n "$force" ] || return ; }

    epm_install_names $names || return

    epm_install_files $files
}

# File bin/epm-installed:



separate_installed()
{
	pkg_installed=
	pkg_noninstalled=
	for i in "$@" ; do
		is_installed $i && pkg_installed="$pkg_installed $i" || pkg_noninstalled="$pkg_noninstalled $i"
	done
}

epm_installed()
{
	[ -n "$pkg_names" ] || fatal "is_installed: package name is missed"
	is_installed "$pkg_names"
}

# File bin/epm-install-emerge:



__emerge_install_ebuild()
{
	local EBUILD="$1"
	[ -s "$EBUILD" ] || fatal ".ebuild file '$EBUILD' is missed"

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
	ALTLinux|ALTServer)
		if ! __epm_query_package kernel-image >/dev/null ; then
			info "No installed kernel packages, skipping update"
			return
		fi
		assure_exists update-kernel update-kernel 0.9.9
		update_repo_if_needed
		sudocmd update-kernel $(subst_option non_interactive -y) "$@" || return
		docmd epm remove-old-kernels $(subst_option non_interactive -y) "$@" || fatal
		return ;;
	esac

	case $PMTYPE in
	dnf-rpm)
		docmd epm install kernel
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-mark:

epm_mark()
{

case $PMTYPE in
	apt-rpm|apt-dpkg)
		sudocmd apt-mark "$@"
		;;
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

[ -z "$*" ] || fatal "No arguments are allowed here"

case $PMTYPE in
	*-rpm)
		#__repack_rpm_base
		#rm -f /var/lib/rpm/__db*
		a= rpm --rebuilddb
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
	*-rpm)
		# FIXME: space with quotes problems, use point instead
		warmup_rpmbase
		docmd rpm -qa --queryformat "%{size}@%{name}-%{version}-%{release}\n" $pkg_filenames | sed -e "s|@| |g" | sort -n -k1
		;;
	*-dpkg)
		warmup_dpkgbase
		docmd dpkg-query -W --showformat="\${Installed-Size}@\${Package}-\${Version}:\${Architecture}\n" $pkg_filenames | sed -e "s|@| |g" | sort -n -k1
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
	*-dpkg)
		warmup_dpkgbase
		# FIXME: strong equal
		#CMD="dpkg -l $pkg_filenames"
		CMD="dpkg-query -W --showformat=\${db:Status-Abbrev}\${Package}-\${Version}:\${Architecture}\n $pkg_filenames"
		# TODO: ${Architecture}
		[ -n "$short" ] && CMD="dpkg-query -W --showformat=\${db:Status-Abbrev}\${Package}\n $pkg_filenames"
		showcmd $CMD
		$CMD | grep "^i" | sed -e "s|.* ||g" | __fo_pfn
		return ;;
	*-rpm)
		warmup_rpmbase
		# FIXME: strong equal
		CMD="rpm -qa $pkg_filenames"
		[ -n "$short" ] && CMD="rpm -qa --queryformat %{name}\n $pkg_filenames"
		docmd $CMD
		return ;;
	packagekit)
		docmd pkcon get-packages --filter installed
		;;
	snappy)
		CMD="snappy info"
		;;
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
	opkg)
		CMD="opkg list-installed"
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
	appget)
		CMD="appget list"
		;;
	winget)
	        info "Use appget instead of winget"
		return 0
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

# File bin/epm-play:

epm_vardir=/var/lib/eepm


__save_installed_app()
{
	return 0 # stub
	[ -d "$epm_vardir" ] || return 0
	__check_installed_app "$1" && return 0
	echo "$1" | sudorun tee -a $epm_vardir/installed-app >/dev/null
}

__remove_installed_app()
{
	return 0 # stub
	[ -s $epm_vardir/installed-app ] || return 0
	local i
	for i in $* ; do
		sudorun sed -i "/^$i$/d" $epm_vardir/installed-app
	done
	return 0
}

__run_script()
{
	local script="$psdir/$1.sh"
	[ -x "$script" ] || return
	shift
	$script "$@"
	return
}

__get_app_package()
{
	__run_script "$1" --package-name "$2" 2>/dev/null
}

__check_installed_app()
{
	__run_script "$1" --installed "$2"
	return

	[ -s $epm_vardir/installed-app ] || return 1
	grep -q -- "^$1\$" $epm_vardir/installed-app
}


__list_all_app()
{
    for i in $psdir/*.sh ; do
       local name=$(basename $i .sh)
       [ -n "$IGNOREi586" ] && rhas "$name" "^i586-" && continue
       rhas "$name" "^common" && continue
       echo "$name"
    done
}

__list_all_packages()
{
    local name
    for name in $(__list_all_app) ; do
        __get_app_package $name
    done
}

__list_app_packages_table()
{
    local name
    for name in $(__list_all_app) ; do
        echo "$(__get_app_package $name) $name"
    done
}

__list_installed_app()
{
    local i
    local tapt=$(mktemp) || fatal
    __list_app_packages_table >$tapt
    # get all installed packages and convert it to a apps list
    for i in $(epm query --short $(cat $tapt | sed -e 's| .*$||') 2>/dev/null) ; do
        grep "^$i " $tapt | sed -e 's|^.* ||'
    done
    rm -f $tapt
    return

    cat $epm_vardir/installed-app 2>/dev/null
}


__get_app_description()
{
    __run_script "$1" --description 2>/dev/null
}

__check_play_script()
{
    local script="$psdir/$1.sh"
    shift

    [ -x "$script" ]
}


__epm_play_run()
{
    local script="$psdir/$1.sh"
    shift

    # TODO: use epm print info instead of one?
    # we will have DISTRVENDOR there
    export PATH=$PROGDIR:$PATH

    set_sudo
    export SUDO

    [ -n "$non_interactive" ] && export EPM_AUTO="--auto"

    local bashopt=''
    [ -n "$verbose" ] && bashopt='-x' && export EPM_VERBOSE="$verbose"
    #info "Running $($script --description 2>/dev/null) ..."
    docmd bash $bashopt $script "$@"
}

__epm_play_list_installed()
{
    local i
    if [ -n "$short" ] ; then
        for i in $(__list_installed_app) ; do
            echo "$i"
        done
        exit
    fi
    [ -n "$quiet" ] || echo "Installed applications:"
    for i in $(__list_installed_app) ; do
        local desc="$(__get_app_description $i)"
        [ -n "$desc" ] || continue
        [ -n "$quiet" ] || echo -n "  "
        printf "%-20s - %s\n" "$i" "$desc"
    done
}


__epm_play_list()
{
    local psdir="$1"
    local i
    local IGNOREi586
    [ "$($DISTRVENDOR -a)" = "x86_64" ] && IGNOREi586='' || IGNOREi586=1

    if [ -n "$short" ] ; then
        for i in $(__list_all_app) ; do
            local desc="$(__get_app_description $i)"
            [ -n "$desc" ] || continue
            echo "$i"
        done
        exit
    fi
    for i in $(__list_all_app) ; do
        local desc="$(__get_app_description $i)"
        [ -n "$desc" ] || continue
        [ -n "$quiet" ] || echo -n "  "
        printf "%-20s - %s\n" "$i" "$desc"
    done
}


__epm_play_help()
{
    cat <<EOF
Usage: epm play [options] [<app>]
Options:
    <app>                 - install <app>
    --remove <app>        - uninstall <app>
    --update [<app>|all]  - update <app> (or all installed apps) if there is new version
    --list                - list all installed apps
    --list-all            - list all available apps
    --list-scripts        - list all available scripts
    --short (with --list) - list names only"
    --installed <app>     - check if the app is installed"
EOF
}

epm_play()
{
local psdir="$(realpath $CONFIGDIR/play.d)"
local prsdir="$(realpath $CONFIGDIR/prescription.d)"

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    __epm_play_help
    exit
fi


if [ "$1" = "--remove" ] || [ "$1" = "remove" ]  ; then
    shift
    #__check_installed_app "$1" || warning "$1 is not installed"
    prescription="$1"
    shift
    if __check_play_script "$prescription" ; then
        __epm_play_run $prescription --remove "$@"
        __remove_installed_app "$prescription"
    else
        psdir=$prsdir
        __check_play_script "$prescription" || fatal "We have no idea how to remove $prescription (checked in $psdir and $prsdir)"
        __epm_play_run "$prescription" --remove "$@" || fatal "There was some error during run the script."
    fi
    exit
fi


if [ "$1" = "--update" ] ; then
    shift
    if [ "$1" = "all" ] ; then
        shift
        RES=0
        for i in $(__list_installed_app) ; do
            echo
            echo "$i"
            prescription="$i"
            if ! __check_play_script $prescription ; then
                warning "Can't find executable play script for $prescription. Try epm play --remove $prescription if you don't need it anymore."
                RES=1
                continue
            fi
            __epm_play_run $prescription --update "$@" || RES=$?
        done
        exit $RES
    fi
    if [ -z "$1" ] ; then
        fatal "run --update with 'all' or a project name"
    fi
    __check_installed_app "$1" || fatal "$1 is not installed"
    prescription="$1"
    shift
    __epm_play_run $prescription --update "$@"
    exit
fi

if [ "$1" = "--installed" ] || [ "$1" = "installed" ]  ; then
    shift
    __check_installed_app "$1" "$2"
    #[ -n "$quiet" ] && exit
    exit
fi

case "$1" in
    "--installed-version"|"--package-name"|"--product-alternatives")
        __run_script "$2" "$1" "$3"
        exit
        ;;
    "--help"|"help")
        __run_script "$2" "$1" "$3"
        exit
        ;;
esac


if [ "$1" = "--list" ] || [ "$1" = "--list-installed" ] || [ "$1" = "list" ] || [ "$1" = "list-installed" ]  ; then
    __epm_play_list_installed
    exit
fi

if [ "$1" = "--list-all" ] || [ "$1" = "list-all" ] || [ -z "$*" ] ; then
    [ -n "$short" ] || [ -n "$quiet" ] || echo "Available applications:"
    __epm_play_list $psdir
    [ -n "$quiet" ] || [ -n "$*" ] && exit
    echo
    #echo "Run epm play --help for help"
    __epm_play_help
    exit
fi

if [ "$1" = "--list-scripts" ] || [ "$1" = "list-scripts" ] ; then
    [ -n "$short" ] || [ -n "$quiet" ] || echo "Run with a name of a play script to run:"
    __epm_play_list $prsdir
    exit
fi

prescription="$1"
shift

if __check_play_script "$prescription" ; then
    #__check_installed_app "$prescription" && info "$$prescription is already installed (use --remove to remove)" && exit 1
    __epm_play_run "$prescription" --run "$@" && __save_installed_app "$prescription" || fatal "There was some error during install the application."
else
    psdir=$prsdir
    __check_play_script "$prescription" || fatal "We have no idea how to play $prescription (checked in $psdir and $prsdir)"
    __epm_play_run "$prescription" --run "$@" || fatal "There was some error during run the script."
fi
}

# File bin/epm-policy:


epm_policy()
{

[ -n "$pkg_names" ] || fatal "Info: package name is missed"

warmup_bases

pkg_names=$(__epm_get_hilevel_name $pkg_names)

case $PMTYPE in
	apt-*)
		docmd apt-cache policy $pkg_names
		;;
	packagekit)
		docmd pkcon resolve $pkg_names
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-prescription:


epm_prescription()
{

local psdir="$CONFIGDIR/prescription.d"

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    cat <<EOF
Options:
    <receipt>      - run <receipt>
    --list-all     - list all available receipts
EOF
    exit
fi

if [ "$1" == "--list-all" ] || [ -z "$*" ] ; then
    [ -n "$short" ] || [ -n "$quiet" ] || echo "Run with a name of a prescription to run:"
    __epm_play_list $psdir
    exit
fi

prescription="$1"
shift

__check_play_script "$prescription" || fatal "We have no idea how to play $prescription (checked in $psdir)"
__epm_play_run "$prescription" --run "$@" || fatal "There was some error during run the script."

}

# File bin/epm-print:


rpm_query_package_format_field()
{
	local FORMAT="$1\n"
	shift
	local INSTALLED=""
	# if a file, ad -p for get from rpm base
	if [ -f "$1" ] ; then
		INSTALLED="-p"
	fi
	a= rpmquery $INSTALLED --queryformat "$FORMAT" "$@"
}

rpm_query_package_field()
{
	local FORMAT="%{$1}"
	shift
	rpm_query_package_format_field "$FORMAT" "$@"
}

dpkg_query_package_format_field()
{
        local field="$1"
        shift
        if [ -f "$1" ] ; then
            a= dpkg-deb --show --showformat="$field\n" "$@"
        else
            #a= dpkg -s "$1" | grep "^$field: " | sed -e "s|^$field: ||"
            a= dpkg-query -W --showformat="$field\n" -- "$@"
        fi
}

dpkg_query_package_field()
{
        local field="$1"
        shift
        #if [ -f "$1" ] ; then
        #    a= dpkg -I "$@" | grep "^.*$field: " | sed -e "s|^.*$field: ||"
        #else
            dpkg_query_package_format_field "\${$field}" "$@"
        #fi
}

query_package_field()
{
    local field="$1"
    shift
    case $PMTYPE in
        *-dpkg)
            dpkg_query_package_field "$field" "$@"
            ;;
        *-rpm)
            rpm_query_package_field "$field" "$@"
            ;;
    esac
}


print_pkg_version()
{
    case $PMTYPE in
        *-dpkg)
            dpkg_query_package_field "Version" "$@" | sed -e "s|-.*||" -e "s|.*:||"
            ;;
        *-rpm)
            rpm_query_package_field "version" "$@"
            ;;
    esac
}

print_pkg_release()
{
    case $PMTYPE in
        *-dpkg)
            dpkg_query_package_field "Version" "$@" | sed -e "s|.*-||"
            ;;
        *-rpm)
            rpm_query_package_field "release" "$@"
            ;;
    esac
}

print_pkg_version_release()
{
    case $PMTYPE in
        *-dpkg)
            dpkg_query_package_field "Version" "$@" | sed -e "s|.*:||"
            ;;
        *-rpm)
            rpm_query_package_format-field "%{version}-%{release}" "$@"
            ;;
    esac
}

print_pkg_name()
{
    case $PMTYPE in
        *-dpkg)
            dpkg_query_package_field "Package" "$@"
            ;;
        *-rpm)
            rpm_query_package_field "name" "$@"
            ;;
    esac
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

PKGNAMEMASK="\(.*\)-\([0-9].*\)-\(.*[0-9].*\)\.\(.*\)\.\(.*\)"

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

print_version_release()
{
    echo "$1" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK|\2-\3|g"
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
    a= rpm -qlp "$@" | grep "\.spec\$"
}

print_srcpkgname()
{

    if [ -n "$FNFLAG" ] ; then
        rpm_query_package_field "sourcerpm" "$@"
        return
    fi

    # if PKFLAG
    case $PMTYPE in
        apt-dpkg)
            fatal "Unknown command for get source package name via dpkg"
            ;;
        urpm-rpm)
            docmd urpmq --sourcerpm "$@"
            return
            ;;
        dnf-rpm)
            showcmd dnf repoquery --qf '%{SOURCERPM}' "$@"
            a= dnf repoquery --qf '%{SOURCERPM}' "$@"
            return
            ;;
    esac

    # FIXME: only for installed rpm packages
    rpm_query_package_field "sourcerpm" "$@"
}

compare_version()
{
    which rpmevrcmp 2>/dev/null >/dev/null || fatal "rpmevrcmp exists in ALT Linux only"
    a= rpmevrcmp "$@"
}

construct_name()
{
    local name="$1"
    local version="$2"
    local arch="$3"
    local pkgtype="$4"
    local ds="$5"
    local pds

    [ -n "$arch" ] || arch="$($DISTRVENDOR --distro-arch)"
    [ -n "$pkgtype" ] || pkgtype="$($DISTRVENDOR -p)"
    [ -n "$ds" ] || ds=$(get_pkg_name_delimiter $pkgtype)
    pds="$ds"
    [ "$pds" = "-" ] && pds="."
    [ -n "$version" ] && version="$ds$version"
    echo "${name}${version}${pds}$arch.$pkgtype"
}

epm_print()
{
    local WHAT="$1"
    shift
    local FNFLAG=
    local PKFLAG=
    [ "$1" = "from" ] && shift
    [ "$1" = "for" ] && shift
    [ "$1" = "of" ] && shift
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
            fatal "Use epm print help to get help."
            ;;
        "-h"|"--help"|"help")
cat <<EOF
  Examples:
    epm print info [args]                    print system and distro info (via distro_info command)
    epm print name [from filename|for package] NN        print only name of package name or package file
    epm print version [from filename|for package] NN     print only version of package name or package file
    epm print release [from filename|for package] NN     print only release of package name or package file
    epm print version-release [from filename|for package] NN     print only release-release of package name or package file
    epm print field FF for package NN        print field of the package
    epm print pkgname from filename NN       print package name for the package file
    epm print srcname from filename NN       print source name for the package file
    epm print srcpkgname from [filename|package] NN    print source package name for the binary package file
    epm print specname from filename NN      print spec filename for the source package file
    epm print binpkgfilelist in DIR for NN   list binary package(s) filename(s) from DIR for the source package file
    epm print compare [package] version N1 N2          compare (package) versions and print -1, 0, 1
    epm print constructname <name> <version> [arch] [ pkgtype]  print distro dependend package filename from args name version arch pkgtype
EOF
            ;;
        "name")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_name "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                print_pkg_name "$@"
            else
                print_name "$@"
            fi
            ;;
        "version")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_version "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                print_pkg_version "$@"
            else
                print_version "$@"
            fi
            ;;
        "release")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_release "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                print_pkg_release "$@"
            else
                print_release "$@"
            fi
            ;;
        "version-release")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_version_release "$(print_pkgname "$@")"
            elif [ -n "$PKFLAG" ] ; then
                print_pkg_version_release "$@"
            else
                print_version_release "$@"
            fi
            ;;
        "field")
            [ -n "$1" ] || fatal "Arg is missed"
            local FIELD="$1"
            shift
            [ "$1" = "for" ] && shift
            [ "$1" = "package" ] && shift
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
        "constructname")
            construct_name "$@"
            ;;
        "info")
            $DISTRVENDOR "$@"
            ;;
        *)
            fatal "Unknown command $ epm print $WHAT. Use epm print help for get help."
            ;;
    esac
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
			showcmd dpkg -s $pkg_names
			a='' dpkg -s $pkg_names | grep "^Provides:" | sed "s|^Provides:||g"
			return
		else
			EXTRA_SHOWDOCMD=' | grep "Provides:"'
			docmd apt-cache show $pkg_names | grep "Provides:" | sed -e 's|, |\n|g' | grep -v "^Provides:"
			return
		fi
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

docmd $CMD $pkg_names

}

epm_provides()
{
	[ -n "$pkg_filenames" ] || fatal "Provides: package name is missed"

	epm_provides_files $pkg_files
	# shellcheck disable=SC2046
	epm_provides_names $(print_name $pkg_names)
}

# File bin/epm-query:


__print_with_arch_suffix()
{
	local pkg="$1"
	local suffix="$2"
	[ -n "$pkg" ] || return 1
	# do not change if some suffix already exists
	echo "$pkg" | grep -q "(x86-32)$" && echo "$pkg" | sed -e "s|(x86-32)$|.i686|" && return 1
	echo "$pkg" | grep "\.x86_64$" && return 1
	echo "$pkg" | grep "\.noarch$" && return 1
	echo "$pkg" | grep "\.i[56]86$" && return 1
	echo "$pkg$suffix"
}

exp_with_arch_suffix()
{
	local suffix

	[ "$($DISTRVENDOR -a)" = "x86_64" ] || { cat ; return ; }
	# TODO: it is ok for ALT rpm to remove with this suffix
	# TODO: separate install and remove?
	case $PMTYPE in
		yum-rpm|dnf-rpm)
			suffix=".x86_64"
			;;
		*)
			cat
			return
			;;
	esac

	# TODO: use estrlist or some function to do it
	local pkg
	for pkg in $(cat) ; do
		local p
		# check only packages without arch
		p="$(__print_with_arch_suffix "$pkg" .i686)" || { echo "$pkg" ; continue ; }
		# add arch suffix only if arch package already installed (otherwise we don't know package arch)
		is_installed "$p" || { echo "$pkg" ; continue ; }
		echo "$pkg.x86_64"
	done
}


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
	(short=1 pkg_filenames=$firstpkg epm_packages | grep -- "$grepexp") && res=0 || res=1

	local pkg
	for pkg in "$@" ; do
		grepexp=$(_get_grep_exp $pkg)
		(short=1 pkg_filenames=$pkg epm_packages 2>/dev/null) | grep -- "$grepexp" || res=1
	done

	# TODO: print in query (for user): 'warning: package $pkg is not installed'
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
	(short=1 pkg_filenames=$firstpkg epm_packages) | grep -q -- "$grepexp" && (quiet=1 pkg_filenames=$firstpkg epm_packages) && res=0 || res=1

	local pkg
	for pkg in "$@" ; do
		grepexp=$(_get_grep_exp $pkg)
		(short=1 pkg_filenames=$pkg epm_packages 2>/dev/null) | grep -q -- "$grepexp" && (quiet=1 pkg_filenames=$pkg epm_packages) || res=1
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
			pkg=$(rpm -q --queryformat "%{NAME}=%{SERIAL}:%{VERSION}-%{RELEASE}\n" -- $1)
			# for case if serial is missed
			echo $pkg | grep -q "(none)" && pkg=$(rpm -q --queryformat "%{NAME}#%{VERSION}-%{RELEASE}\n" -- $1)
			# HACK: can use only for multiple install packages like kernel
			echo $pkg | grep -q kernel || return 1
			echo $pkg
			return
			;;
		yum-rpm|dnf-rpm)
			# just use strict version with Epoch and Serial
			local pkg
			pkg=$(rpm -q --queryformat "%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" -- $1)
			echo $pkg | grep -q "(none)" && pkg=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" -- $1)
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

	docmd $CMD -- $@
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
			docmd dpkg-query -W "--showformat=\${Package}-\${Version}\n" -- $@ || return
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
		#homebrew)
		#	showcmd "brew info $1"
		#	local HBRESULT
		#	HBRESULT="$(brew info "$1" 2>/dev/null)" || return
		#	echo "$HBRESULT" | grep -q "Not installed" && return 1
		#	echo "$1"
		#	return 0
		#	;;
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
			showcmd rpm -q --queryformat '%{name} \n' -- $@
			a='' rpm -q --queryformat '%{name} \n' -- $@
			return
			;;
		*-dpkg)
			#CMD="dpkg-query -W --showformat=\${Package}\n"
			docmd dpkg-query -W "--showformat=\${Package}\n" -- $@ || return
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
	(quiet=1 __epm_query_name "$@") >/dev/null 2>/dev/null
}


epm_query()
{
	[ -n "$pkg_filenames" ] || fatal "Query: package name is missed"

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
		TOFILE=$(which -- "$1" 2>/dev/null || echo "$1")
		if [ "$TOFILE" != "$1" ] ; then
			info " > $1 is placed as $TOFILE"
		fi
	fi

	if [ -n "$short" ] ; then
		__do_short_query "$TOFILE" || return
	else
		__do_query "$TOFILE" || return
	fi

	# get value of symbolic link
	if [ -n "$TOFILE" ] && [ -L "$TOFILE" ] ; then
		local LINKTO
		LINKTO=$(readlink -- "$TOFILE")
		info " > $TOFILE is link to $LINKTO"
		LINKTO=$(readlink -f -- "$TOFILE")
		__do_query_real_file "$LINKTO"
		return
	fi
}

dpkg_print_name_version()
{
	local ver i
	for i in "$@" ; do
		[ -n "$i" ] || continue
		ver=$(dpkg -s "$i" 2>/dev/null | grep "Version:" | sed -e "s|Version: ||g")
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
        *-dpkg)
            showcmd dpkg -S "$1"
            dpkg_print_name_version "$(dpkg -S "$1" | grep -v "^diversion by" | sed -e "s|:.*||")"
            return ;;
        *-rpm)
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
        opkg)
            CMD="opkg search"
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
    # file can exists or not
    [ -n "$pkg_filenames" ] || fatal "Run query without file names"


    #load_helper epm-search_file

    res=0
    for pkg in $pkg_filenames ; do
        __do_query_real_file "$pkg" || res=$?
    done

    [ "$res" = "0" ] || info "Try epm sf for search file in all packages of the repositories"
    #|| pkg_filenames="$FULLFILEPATH" epm_search_file
    return $res
}

# File bin/epm-query_package:


__epm_query_package()
{
	(pkg_filenames="$*" quoted_args="$*" quiet=1 epm_query_package)
}

epm_query_package()
{
	[ -n "$pkg_filenames" ] || fatal "Please, use search with some argument or run epmqa for get all packages."
	# FIXME: do it better
	local MGS
	MGS=$(eval __epm_search_make_grep $quoted_args)
	EXTRA_SHOWDOCMD=$MGS
	# Note: get all packages list and do grep
	(eval "pkg_filenames='' epm_packages \"$(eval get_firstarg $quoted_args)\" $MGS")
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
		packagekit)
			warning "Please send me the correct command form for it"
			docmd pkcon install --allow-reinstall $@
			return ;;
		yum-rpm)
			sudocmd yum reinstall $@
			return ;;
		dnf-rpm)
			sudocmd dnf reinstall $@
			return ;;
		homebrew)
			sudocmd brew reinstall $@
			return ;;
		pkgng)
			sudocmd pkg install -f $@
			return ;;
		opkg)
			sudocmd opkg --force-reinstall install $@
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
    [ -n "$pkg_filenames" ] || fatal "Reinstall: package name is missed."

    warmup_lowbase

    # get package name for hi level package management command (with version if supported and if possible)
    pkg_names=$(__epm_get_hilevel_name $pkg_names)

    warmup_hibase

    epm_reinstall_names $pkg_names
    epm_reinstall_files $pkg_files
}


# File bin/epm-release_downgrade:


get_prev_release()
{
	local FROM="$1"
	case "$FROM" in
	"p8")
		echo "p7" ;;
	"p9")
		echo "p8" ;;
	"p10")
		echo "p9" ;;
	"c7")
		echo "c6" ;;
	"c8")
		echo "c7" ;;
	"c8.1")
		echo "c8" ;;
	"c8.2")
		echo "c8.1" ;;
	"c9")
		echo "c8.2" ;;
	*)
		echo "$FROM" ;;
	esac
}

epm_release_downgrade()
{
	assure_root
	assure_safe_run
	info "Starting upgrade/switch whole system to other release"
	info "Check also http://wiki.etersoft.ru/Admin/UpdateLinux"

	cd /tmp || fatal
	# TODO: it is possible eatmydata does not do his work
	export EPMNOEATMYDATA=1

	case $DISTRNAME in
	ALTLinux|ALTServer)
		__epm_ru_update || fatal

		# try to detect current release by repo
		if [ "$DISTRVERSION" = "Sisyphus" ] || [ -z "$DISTRVERSION" ] ; then
			local dv
			dv="$(__detect_alt_release_by_repo)"
			if [ -n "$dv" ] && [ "$dv" != "$DISTRVERSION" ] ; then
				DISTRVERSION="$dv"
				info "Detected running $DISTRNAME $DISTRVERSION (according to using repos)"
			fi
		fi

		TARGET=""
		[ -n "$3" ] && fatal "Too many args: $*"
		if [ -n "$2" ] ; then
			DISTRVERSION="$1"
			info "Force current distro version as $DISTRVERSION"
			TARGET="$2"
		elif [ -n "$1" ] ; then
			TARGET="$1"
		fi

		[ -n "$TARGET" ] || TARGET="$(get_prev_release $DISTRVERSION)"

		__alt_repofix

		__switch_alt_to_distro $DISTRVERSION $TARGET && info "Done. The system has been successfully downgraded to the previous release '$TARGET'."

		return 0
		;;
	*)
		;;
	esac

	case $PMTYPE in
	apt-rpm)
		#docmd epm update
		info "Have no idea how to downgrade $DISTRNAME"
		;;
	*-dpkg)
		assure_exists do-release-upgrade update-manager-core
		sudocmd do-release-upgrade
		;;
	packagekit)
		docmd pkcon upgrade-system "$@"
		;;
	yum-rpm)
		docmd epm install rpm yum
		sudocmd yum clean all
		# TODO
		showcmd rpm -Uvh http://mirror.yandex.ru/fedora/linux/releases/16/Fedora/x86_64/os/Packages/fedora-release-16-1.noarch.rpm
		showcmd epm Upgrade
		;;
	dnf-rpm)
		info "Check https://fedoraproject.org/wiki/DNF_system_upgrade for an additional info"
		docmd epm install dnf
		#docmd epm install epel-release yum-utils
		sudocmd dnf --refresh upgrade
		sudocmd dnf clean all
		assure_exists dnf-plugin-system-upgrade
		sudocmd dnf upgrade --refresh
		local RELEASEVER="$1"
		[ -n "$RELEASEVER" ] || RELEASEVER=$(($DISTRVERSION + 1))
		#[ -n "$RELEASEVER" ] || fatal "Run me with new version"
		confirm_info "Upgrade to $DISTRNAME/$RELEASEVER"
		sudocmd dnf system-upgrade download --refresh --releasever=$RELEASEVER
		# TODO: from docs:
		# dnf system-upgrade reboot
		# FIXME: download all packages again
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

# File bin/epm-release_upgrade:


assure_safe_run()
{
	if [ "$TERM" = "linux" ] ; then
		echo "You have the best choise to run the '# epm release-upgrade' from text console."
		return
	fi
	if [ "$TERM" != "screen" ] ; then
		if [ -n "$force" ] ; then
			echo "You force me running not under screen (TERM=$TERM now)! You can lost your system!"
			return
		else
			warning "It is very dangerous to upgrade to next release from a GUI (your TERM=$TERM)."
			if is_installed screen ; then
				warning "You have 'screen' already installed, just run upgrade via screen (check https://losst.ru/komanda-screen-linux if needed)."
			else
				warning "It is recommended install 'screen' and run upgrade via screen (check https://losst.ru/komanda-screen-linux if needed)."
			fi
			fatal "or run me with --force if you understand the risk."
		fi
	fi

	# run under screen, check if systemd will not kill our processes
	local res
	if ! is_active_systemd systemd ; then
		return
	fi

	res="$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager KillUserProcesses)"
	if [ "$res" = "b false" ] ; then
		echo "Good news: systemd-logind will not kill your screen processes (KillUserProcesses=false)"
		return
	else
		if [ -n "$force" ] ; then
			warning "You force runnning even if systemd-logind kills screen on disconnect"
		else
			if ! epm installed systemd-settings-disable-kill-user-processes ; then
				docmd epm install systemd-settings-disable-kill-user-processes || fatal "Can't install the package above. Fix it or run with --force."
			fi
			# commented, will kick off the user from the system (ALT issue 50580)
			#docmd serv systemd-logind restart || fatal "Can't restart systemd-logind service. Fix it or run with --force."
			fatal "Now you need relogin to the system. In this session your screen still will be killed."
		fi
	fi

	# check too: KillExcludeUsers

	# can continue
	return 0
}

__wcount()
{
	echo "$*" | wc -w
}

__detect_alt_release_by_repo()
{
	local BRD=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list \
		| grep -v "^#" \
		| grep -E "[tpc][5-9]\.?[0-9]?/branch/" \
		| sed -e "s|.*\([tpc][5-9]\.\?[0-9]\?\)/branch.*|\1|g" \
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


__get_conflict_release_pkg()
{
	epm qf --quiet --short /etc/fedora-release | head -n1
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

	if [ "$TO" = "Sisyphus" ] ; then
		TO="sisyphus"
		echo "apt-conf-$TO"
	else
		epm installed apt-conf-branch && echo "apt-conf-branch"
	fi

	if [ "$FORCE" == "--force" ] ; then
		# assure we have set needed release
		TOINSTALL="altlinux-release-$TO"
	else
		# just assure we have /etc/altlinux-release and switched from sisyphus
		if [ ! -s /etc/altlinux-release ] || epm qf /etc/altlinux-release | grep -q sisyphus ; then
			TOINSTALL="altlinux-release-$TO"
		fi
	fi

	#local AR="$(epm --short qf /etc/altlinux-release)"
	#if [ -n "$AR" ] && [ "$AR" != "$TOINSTALL" ] ; then
	#	echo "$AR-"
	#fi

	# TODO: add bug?
	# workaround against obsoleted altlinux-release-sisyphus package from 2008 year
	[ "$TOINSTALL" = "altlinux-release-sisyphus" ] && TOINSTALL="branding-alt-sisyphus-release"

	if epm installed etersoft-gpgkeys ; then
		# TODO: we don't support LINUX@Etersoft for now
		# leave etersoft-gpgkeys only if we have LINUX@Etersoft repo
		#epm repo list | grep -q "LINUX@Etersoft" && echo "etersoft-gpgkeys" || echo "alt-gpgkeys"
		epm --quiet repo comment "LINUX@Etersoft"
		echo "alt-gpgkeys"
	else
		# update if installed (just print package name here to include in the install list)
		epm query --short alt-gpgkeys 2>/dev/null
	fi

	if [ -n "$TOINSTALL" ] ; then
		echo "$TOINSTALL"

		# workaround against
		#    file /etc/fedora-release from install of altlinux-release-p8-20160414-alt1 conflicts with file from package branding-simply-linux-release-8.2.0-alt1
		# problem
		local AR="$(__get_conflict_release_pkg)"
		if [ -n "$AR" ] && [ "$TOINSTALL" != "$AR" ] ; then
			echo $AR-
		fi
	fi
}

__check_system()
{
	local TO="$1"
	shift

	# sure we have systemd if systemd is running
	if is_active_systemd systemd ; then
		docmd epm --skip-installed install systemd || fatal
	fi

	if [ "$TO" != "Sisyphus" ] ; then
		# we could miss DISTRVENDOR script during downgrade, reread
		set_distro_info
		if [ "$($DISTRVENDOR -v)" != "$TO" ] || epm installed altlinux-release-sisyphus >/dev/null ; then
			warning "Current distro still is not $TO, or altlinux-release-sisyphus package is installed."
			warning "Trying to fix with altlinux-release-$TO"
			docmd epm install altlinux-release-$TO
		fi
	fi

	# switch from prefdm: https://bugzilla.altlinux.org/show_bug.cgi?id=26405#c47
	if is_active_systemd systemd ; then
		if serv display-manager exists || serv prefdm exists ; then
			# don't stop running X server!
			# docmd serv dm off
			docmd serv disable prefdm
			docmd serv disable display-manager
			docmd serv enable display-manager

			# enable first available DM
			for i in lightdm sddm lxde-lxdm gdm ; do
				serv $i exists && docmd serv enable $i && break
			done
		fi
	fi

}

__epm_ru_update()
{
    docmd epm update && return
    # TODO: there can be errors due obsoleted alt-gpgkeys
    epm update 2>&1 | grep "E: Unknown vendor ID" || return
    info "Drop vendor signs"
    __alt_replace_sign_name ""
    docmd epm update
}

__switch_repo_to()
{
    epm_reposwitch "$@"
    __epm_ru_update || fatal
}

get_next_release()
{
	local FROM="$1"
	case "$FROM" in
	"p6")
		echo "p7" ;;
	"p7")
		echo "p8" ;;
	"p8")
		echo "p9" ;;
	"p9")
		echo "p10" ;;
	"c6")
		echo "c7" ;;
	"c7")
		echo "c8" ;;
	"c8")
		echo "c8.1" ;;
	"c8.1")
		echo "c8.2" ;;
	"c8.2")
		echo "c9" ;;
	*)
		echo "$FROM" ;;
	esac
}

__do_upgrade()
{
	docmd epm $non_interactive $force_yes upgrade || fatal "Check the errors and run '# $0' again"
}

__switch_alt_to_distro()
{
	local TO="$2"
	local FROM="$1"
	info

	try_change_alt_repo

	case "$*" in
		"p6"|"p6 p7"|"t6 p7"|"c6 c7")
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			__switch_repo_to $TO
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			__do_upgrade
			end_change_alt_repo
			docmd epm update-kernel
			info "Run epm release-upgrade again for update to p8"
			;;
		"p7"|"p7 p8"|"t7 p8"|"c7 c8")
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			__switch_repo_to $TO
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			__do_upgrade
			end_change_alt_repo
			__check_system "$TO"
			docmd epm update-kernel || fatal
			info "Run epm release-upgrade again for update to p9"
			;;
		"c8"|"c8.1"|"c8.2"|"c8 c8.1"|"c8.1 c8.2"|"c8 c8.2")
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			__switch_repo_to $TO
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			__do_upgrade
			end_change_alt_repo
			__check_system "$TO"
			docmd epm update-kernel || fatal
			;;
		"p8 c8"|"p8 c8.1"|"p8 c8.2")
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			__switch_repo_to $TO
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			if epm installed libcrypt ; then
				# glibc-core coflicts libcrypt
				docmd epm downgrade apt pam pam0_passwdqc glibc-core libcrypt- || fatal
			fi
			docmd epm $non_interactive $force_yes downgrade || fatal
			__do_upgrade
			end_change_alt_repo
			__check_system "$TO"
			docmd epm update-kernel || fatal
			;;
		"p8"|"p8 p9"|"t8 p9"|"c8 c9"|"c8 p9"|"c8.1 p9"|"c8.2 p9"|"p9 p9")
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			info "Workaround for https://bugzilla.altlinux.org/show_bug.cgi?id=35492 ..."
			if epm installed gdb >/dev/null ; then
				docmd epm remove gdb || fatal
			fi
			__switch_repo_to $TO
			__do_upgrade
			end_change_alt_repo
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			__check_system "$TO"
			docmd epm update-kernel || fatal
			info "Run epm release-upgrade again for update to p10"
			;;
		"p9"|"p9 p10"|"p10 p10")
			info "Upgrade all packages to current $FROM repository"
			__do_upgrade
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			__switch_repo_to $TO
			__do_upgrade
			end_change_alt_repo
			docmd epm install rpm apt "$(get_fix_release_pkg "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			__check_system "$TO"
			docmd epm update-kernel -t std-def || fatal
			;;
		"p9 p8"|"c8.1 c8"|"c8.1 p8"|"p8 p8")
			confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")"
			__switch_repo_to $TO
			docmd epm downgrade rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			if epm installed libcrypt >/dev/null ; then
				# glibc-core coflicts libcrypt
				docmd epm downgrade apt rpm pam pam0_passwdqc glibc-core libcrypt- || fatal
			fi
			docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
			end_change_alt_repo
			__check_system "$TO"
			docmd epm upgrade || fatal
			;;
		"p9 c8"|"p9 c8.1"|"p9 c8.2")
			confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")"
			__switch_repo_to $TO
			docmd epm downgrade rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			#if epm installed libcrypt >/dev/null ; then
			#	# glibc-core coflicts libcrypt
			#	docmd epm downgrade apt rpm pam pam0_passwdqc glibc-core libcrypt- || fatal
			#fi
			docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
			end_change_alt_repo
			__check_system "$TO"
			docmd epm upgrade || fatal
			;;
		"p10 p9")
			confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")"
			__switch_repo_to $TO
			docmd epm downgrade rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
			end_change_alt_repo
			__check_system "$TO"
			docmd epm upgrade || fatal
			;;
		"Sisyphus p8"|"Sisyphus p9"|"Sisyphus p10"|"Sisyphus c8"|"Sisyphus c8.1")
			confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install "$(get_fix_release_pkg "$FROM")"
			__switch_repo_to $TO
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
			end_change_alt_repo
			__check_system "$TO"
			docmd epm upgrade || fatal
			;;
		"p8 Sisyphus"|"p9 Sisyphus"|"p10 Sisyphus"|"10 Sisyphus"|"Sisyphus Sisyphus")
			confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
			docmd epm install rpm apt "$(get_fix_release_pkg "$FROM")" || fatal
			docmd epm upgrade || fatal
			# TODO: epm_reposwitch??
			__replace_alt_version_in_repo "$FROM/branch/" "$TO/"
			__alt_repofix "alt"
			[ -s /etc/rpm/macros.d/p10 ] && rm -fv /etc/rpm/macros.d/p10
			__epm_ru_update || fatal
			docmd epm install rpm apt "$(get_fix_release_pkg --force "$TO")" || fatal "Check the errors and run '# epm release-upgrade' again"
			#local ADDPKG
			#ADDPKG=$(epm -q --short make-initrd sssd-ad 2>/dev/null)
			#docmd epm install librpm7 librpm rpm apt $ADDPKG "$(get_fix_release_pkg --force "$TO")" ConsoleKit2- || fatal "Check an error and run again"
			docmd epm $force_yes $non_interactive upgrade || fatal "Check the error and run '# epm release-upgrade' again or just '# epm upgrade'"
			docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
			end_change_alt_repo
			__check_system "$TO"
			docmd epm update-kernel || fatal
			;;
		*)
			if [ "$FROM" = "$TO" ] ; then
				info "It seems your system is already $DISTRNAME $TO"
			else
				warning "Unknown distro version. Have no idea how to switch from $DISTRNAME $FROM to $DISTRNAME $TO."
			fi
			end_change_alt_repo
			info "Try run f.i. '# epm release-upgrade p10' or '# epm release-downgrade p9' or '# epm release-upgrade Sisyphus'"
			info "Also possible you need install altlinux-release-p? package for correct distro version detecting"
			return 1
	esac
	docmd epm clean
	docmd epm update
	info "Note: Also you can try '# epm autoremove' and '# epm autoorphans' commands to remove obsoleted and unused packages."
}

epm_release_upgrade()
{
	assure_root
	assure_safe_run
	info "Starting upgrade/switch whole system to other release"
	info "Check also http://wiki.etersoft.ru/Admin/UpdateLinux"

	cd / || fatal
	# TODO: it is possible eatmydata does not do his work
	export EPMNOEATMYDATA=1

	case $DISTRNAME in
	ALTLinux|ALTServer)
		__epm_ru_update || fatal

		# TODO: remove this hack (or move it to distro_info)
		# try to detect current release by repo
		if [ "$DISTRVERSION" = "Sisyphus" ] || [ -z "$DISTRVERSION" ] ; then
			local dv
			dv="$(__detect_alt_release_by_repo)"
			if [ -n "$dv" ] && [ "$dv" != "$DISTRVERSION" ] ; then
				DISTRVERSION="$dv"
				info "Detected running $DISTRNAME $DISTRVERSION (according to using repos)"
			fi
		fi

		TARGET=""
		[ -n "$3" ] && fatal "Too many args: $*"
		if [ -n "$2" ] ; then
			DISTRVERSION="$1"
			info "Force current distro version as $DISTRVERSION"
			TARGET="$2"
		elif [ -n "$1" ] ; then
			TARGET="$1"
		fi

		[ -n "$TARGET" ] || TARGET="$(get_next_release $DISTRVERSION)"

		__alt_repofix

		__switch_alt_to_distro $DISTRVERSION $TARGET && info "Done. The system has been successfully upgraded to the next release '$TO'."

		return 0
		;;
	*)
		;;
	esac

	case $PMTYPE in
	apt-rpm)
		#docmd epm update
		info "Have no idea how to upgrade $DISTRNAME. It is possible you need use 'release-downgrade'"
		;;
	*-dpkg)
		assure_exists do-release-upgrade update-manager-core
		sudocmd do-release-upgrade
		;;
	packagekit)
		docmd pkcon upgrade-system "$@"
		;;
	yum-rpm)
		docmd epm install rpm yum
		sudocmd yum clean all
		# TODO
		showcmd rpm -Uvh http://mirror.yandex.ru/fedora/linux/releases/16/Fedora/x86_64/os/Packages/fedora-release-16-1.noarch.rpm
		showcmd epm Upgrade
		;;
	dnf-rpm)
		if [ "$DISTRNAME/$DISTRVERSION" = "CentOS/8" ] ; then
			if [ "$1" = "RockyLinux" ] ; then
				info "https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky/"
				confirm_info "Switch to Rocky Linux 8.x"
				cd /tmp
				showcmd epm install git
				sudocmd git clone https://github.com/rocky-linux/rocky-tools.git || fatal
				sudocmd bash rocky-tools/migrate2rocky/migrate2rocky.sh -r
				exit
			fi

			if [ "$1" = "OracleLinux" ] ; then
				info "Check https://t.me/srv_admin/1630"
				confirm_info "Switch to Oracle Linux 8.x"
				cd /tmp
				showcmd epm install git
				sudocmd sed -i -r \
					-e 's!^mirrorlist=!#mirrorlist=!' \
					-e 's!^#?baseurl=http://(mirror|vault).centos.org/\$contentdir/\$releasever/!baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/!i' \
						/etc/yum.repos.d/CentOS-*.repo
				sudocmd git clone https://github.com/oracle/centos2ol.git || fatal
				a= bash centos2ol/centos2ol.sh
				exit
			fi

			info "Check https://www.cyberciti.biz/howto/upgrade-migrate-from-centos-8-to-centos-stream-conversion/"
			confirm_info "Switch to CentOS Stream?"
			sudocmd sed -i -r \
					-e 's!^mirrorlist=!#mirrorlist=!' \
					-e 's!^#?baseurl=http://(mirror|vault).centos.org/\$contentdir/\$releasever/!baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/!i' \
						/etc/yum.repos.d/CentOS-*.repo
			docmd epm install centos-release-stream
			sudocmd dnf swap centos-{linux,stream}-repos
			sudocmd dnf distro-sync
			info "You can run '# epm autoorphans' to remove orphaned packages"
			exit
		fi
		info "Check https://fedoraproject.org/wiki/DNF_system_upgrade for an additional info"
		#docmd epm install epel-release yum-utils
		sudocmd dnf --refresh upgrade || fatal
		sudocmd dnf clean all
		assure_exists dnf-plugin-system-upgrade
		sudocmd dnf upgrade --refresh
		local RELEASEVER="$1"
		[ -n "$RELEASEVER" ] || RELEASEVER=$(($DISTRVERSION + 1))
		#[ -n "$RELEASEVER" ] || fatal "Run me with new version"
		confirm_info "Upgrade to $DISTRNAME/$RELEASEVER"
		sudocmd dnf system-upgrade download --refresh --releasever=$RELEASEVER
		# TODO: from docs:
		# dnf system-upgrade reboot
		# FIXME: download all packages again
		sudocmd dnf distro-sync --releasever=$RELEASEVER
		info "You can run '# epm autoorphans' to remove orphaned packages"
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


RPMISNOTINSTALLED=202

__check_rpm_e_result()
{
    grep -q "is not installed" $1 && return $RPMISNOTINSTALLED
    return $2
}


epm_remove_low()
{
	[ -z "$1" ] && return

	warmup_lowbase

	case $PMTYPE in
		*-rpm)
			cd /tmp || fatal
			__epm_check_vendor $@
			store_output sudocmd rpm -ev $noscripts $nodeps $@
			# rpm returns number of packages if failed on removing
			__check_rpm_e_result $RC_STDOUT $?
			RES=$?
			clean_store_output
			cd - >/dev/null
			return $RES ;;
		*-dpkg|-dpkg)
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
		appget|winget)
			sudocmd $PMTYPE uninstall $@
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
		packagekit)
			docmd pkcon remove $@
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
		appget|winget)
			sudocmd $PMTYPE uninstall $@
			return ;;
		opkg)
			# shellcheck disable=SC2046
			sudocmd opkg $(subst_option force -force-depends) remove $@
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
		packagekit)
			docmd pkcon remove --noninteractive $@
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
		dnf-rpm)
			sudocmd dnf remove --assumeyes $@
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
		opkg)
			sudocmd opkg -force-defaults remove $@
			return ;;
		appget|winget)
			sudocmd $PMTYPE uninstall -s $@
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
		*-rpm)
			echo "rpm -ev $nodeps $*"
			;;
		*-dpkg)
			echo "dpkg -P $*"
			;;
		packagekit-*)
			echo "pkcon remove --noninteractive $*"
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
		opkg)
			echo "opkg remove $*"
			;;
		aptcyg)
			echo "apt-cyg remove $*"
			;;
		xbps)
			echo "xbps remove -y $*"
			;;
		appget|winget)
			echo "$PMTYPE uninstall -s $*"
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

	if [ "$DISTRNAME" = "ALTLinux" ] || [ "$DISTRNAME" = "ALTServer" ] ; then
		if tasknumber "$pkg_names" >/dev/null ; then
			assure_exists apt-repo
			pkg_names="$(get_task_packages $pkg_names)"
		fi
	fi

	# TODO: fix pkg_names override
	# get full package name(s) from the package file(s)
	[ -n "$pkg_files" ] && pkg_names="$pkg_names $(epm query $pkg_files)"
	pkg_files=''

	if [ -z "$pkg_names" ] ; then
		warning "no package(s) to remove."
		return
	fi
	# remove according current arch (if x86_64) by default
	pkg_names="$(echo $pkg_names | exp_with_arch_suffix)"

	if [ -n "$dryrun" ] ; then
		info "Packages for removing:"
		echo "$pkg_names"
		case $PMTYPE in
			apt-rpm)
				nodeps="--test"
				APTOPTIONS="--simulate"
				;;
			apt-deb)
				nodeps="--simulate"
				APTOPTIONS="--simulate"
				;;
			*)
				return
				;;
		esac
	fi

	if [ -n "$skip_missed" ] ; then
		pkg_names="$(get_only_installed_packages $pkg_names)"
	fi

	epm_remove_low $pkg_names && return
	local STATUS=$?

	if [ -n "$direct" ] || [ -n "$nodeps" ] || [ "$STATUS" = "$RPMISNOTINSTALLED" ]; then
		[ -n "$force" ] || return $STATUS
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
	ALTLinux|ALTServer)
		if ! __epm_query_package kernel-image >/dev/null ; then
			info "No installed kernel packages, skipping cleaning"
			return
		fi
		assure_exists update-kernel update-kernel 0.9.9
		sudocmd remove-old-kernels $(subst_option non_interactive -y) "$@"

		# remove unused nvidia drivers
		if which nvidia-clean-driver 2>/dev/null ; then
			if [ -n "$non_interactive" ] ; then
				yes | sudocmd nvidia-clean-driver
			else
				sudocmd nvidia-clean-driver
			fi
		fi

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
		sudocmd purge-old-kernels "$@"
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


__epm_removerepo_alt_grepremove()
{
	local rl
	# ^rpm means full string
	if [ "$1" = "all" ] || rhas "$1" "^rpm" ; then
		rl="$1"
	else
		rl="$( (epm --quiet repolist) 2>/dev/null | grep -E "$1")"
		[ -z "$rl" ] && warning "Can't find '$1' in the repos (see '# epm repolist' output)" && return 1
	fi
	echo "$rl" | while read rp ; do
		# TODO: print removed lines
		if [ -n "$dryrun" ] ; then
			docmd apt-repo $dryrun rm "$rp"
			continue
		fi
		if [ -n "$verbose" ] ; then
			sudocmd apt-repo $dryrun rm "$rp"
		else
			sudorun apt-repo $dryrun rm "$rp"
		fi
	done
}

__epm_removerepo_alt()
{
	local repo="$*"
	[ -n "$repo" ] || fatal "No such repo or task. Use epm repo remove <regexp|autoimports|archive|tasks|TASKNUMBER>"

	assure_exists apt-repo

	if tasknumber "$repo" >/dev/null ; then
		local tn
		for tn in $(tasknumber "$repo") ; do
			__epm_removerepo_alt_grepremove " repo/$tn/"
		done
		return
	fi

	case "$1" in
		autoimports)
			info "remove autoimports repo"
			[ -n "$DISTRVERSION" ] || fatal "Empty DISTRVERSION"
			repo="autoimports.$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"
			sudocmd apt-repo $dryrun rm "$repo"
			;;
		archive)
			info "remove archive repos"
			__epm_removerepo_alt_grepremove "archive/"
			;;
		tasks)
			info "remove task repos"
			__epm_removerepo_alt_grepremove " repo/[0-9]+/"
			;;
		task)
			shift
			__epm_removerepo_alt_grepremove " repo/$1/"
			;;
		-*)
			fatal "epm removerepo: no options are supported"
			;;
		*)
			__epm_removerepo_alt_grepremove "$*"
			;;
	esac

}

epm_removerepo()
{

case $DISTRNAME in
	ALTLinux|ALTServer)
		__epm_removerepo_alt "$@"
		return
		;;
esac;

case $PMTYPE in
	apt-dpkg)
		assure_exists apt-add-repository software-properties-common
		set_sudo

		if [ "$DISTRNAME" = "AstraLinux" ] ; then
			echo "Use workaround for AstraLinux"
			[ -n "$*" ] || fatal "empty repo name"
			# aptsources.distro.NoDistroTemplateException: Error: could not find a distribution template for AstraLinuxCE/orel
			sudocmd sed -i -e "s|.*$*.*||" /etc/apt/sources.list
			if [ -d /etc/apt/sources.list.d ] && ls /etc/apt/sources.list.d/*.list >/dev/null 2>/dev/null ; then
				sudocmd sed -i -e "s|.*$*.*||" /etc/apt/sources.list.d/*.list
			fi
			exit
		fi

		# FIXME: it is possible there is troubles to pass the args
		sudocmd apt-add-repository --remove "$*"
		info "Check file /etc/apt/sources.list if needed"
		;;
	aptitude-dpkg)
		info "You need remove repo from /etc/apt/sources.list"
		;;
	yum-rpm)
		assure_exists yum-utils
		sudocmd yum-config-manager --disable "$@"
		;;
	urpm-rpm)
		sudocmd urpmi.removemedia "$@"
		;;
	zypper-rpm)
		sudocmd zypper removerepo "$@"
		;;
	emerge)
		sudocmd layman "-d$@"
		;;
	pacman)
		info "You need remove repo from /etc/pacman.conf"
		;;
	npackd)
		sudocmd npackdcl remove-repo --url="$@"
		;;
	winget)
		sudocmd winget source remove "$@"
		;;
	slackpkg)
		info "You need remove repo from /etc/slackpkg/mirrors"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-repack:


__epm_split_by_pkg_type()
{
	local type="$1"
	shift

	split_replaced_pkgs=''

	for pkg in "$@" ; do
		[ "$(get_package_type "$pkg")" = "$type" ] || return 1
		[ -e "$pkg" ] || fatal "Can't read $pkg"
		split_replaced_pkgs="$split_target_pkgs $(realpath "$pkg")"
	done

	[ -n "$split_replaced_pkgs" ]
}

__epm_repack_rpm_to_deb()
{
	local pkg

	assure_exists alien
	assure_exists fakeroot
	assure_exists rpm

	repacked_debs=''

	local TDIR=$(mktemp -d)
	cd $TDIR || fatal

	for pkg in $rpmpkgs ; do
		showcmd_store_output fakeroot alien -d -k $scripts "$pkg"
		local DEBCONVERTED=$(grep "deb generated" $RC_STDOUT | sed -e "s| generated||g")
		repacked_debs="$repacked_rpms $(realpath $DEBCONVERTED)"
		to_remove_pkg_files="$to_remove_pkg_files $(realpath $DEBCONVERTED)"
		clean_store_output
	done

	# TODO: move it to exit handler
	if [ -z "$DEBUG" ] ; then
		# TODO: reinvent
		[ -n "$to_remove_pkg_files" ] && rm -f $to_remove_pkg_files
		[ -n "$to_remove_pkg_files" ] && rmdir $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null
		[ -n "$to_remove_pkg_dirs" ] && rmdir $to_remove_pkg_dirs
	fi

	cd - >/dev/null
	return 0
}


__epm_check_if_try_install_rpm()
{
	__epm_split_by_pkg_type rpm "$@" || return 1
	__epm_repack_rpm_to_deb $split_replaced_pkgs

	# TODO: move to install
	docmd epm install $repacked_debs

	return 0
}

__set_name_version()
{
    SPEC="$1"
    PKGNAME="$2"
    VERSION="$3"
    [ -n "$PKGNAME" ] && subst "s|^Name:.*|Name: $PKGNAME|" $SPEC
    [ -n "$VERSION" ] && subst "s|^Version:.*|Version: $VERSION|" $SPEC
}

__fix_spec()
{
    local pkgname="$1"
    local buildroot="$2"
    local spec="$3"
    local i

    # drop forbidded paths
    # https://bugzilla.altlinux.org/show_bug.cgi?id=38842
    for i in / /etc /etc/init.d /etc/systemd /bin /opt /usr /usr/bin /usr/share /usr/share/doc /var /var/log /var/run \
            /etc/cron.daily /usr/share/icons /usr/share/pixmaps /usr/share/man /usr/share/man/man1 /usr/share/appdata /usr/share/applications /usr/share/menu ; do
        sed -i -e "s|^%dir \"$i/*\"$||" \
            -e "s|^\"$i/*\"$||" \
            -e "s|^$i/*$||" \
            $spec
    done

    # commented out: conflicts with already installed package
    # drop %dir for existed system dirs
    #for i in $(grep '^%dir "' $spec | sed -e 's|^%dir  *"\(.*\)".*|\1|' ) ; do #"
    #    echo "$i" | grep -q '^/opt/' && continue
    #    [ -d "$i" ] && [ -n "$verbose" ] && echo "drop dir $i from packing, it exists in the system"
    #done

    # replace dir "/path/dir" -> %dir /path/dir
    grep '^"/' $spec | sed -e 's|^"\(/.*\)"$|\1|' | while read i ; do
        # add dir as %dir in the filelist
        if [ -d "$buildroot$i" ] ; then
            subst 's|^\("'$i'"\)$|%dir \1|' $spec
        #else
        #    subst 's|^\("'$i'"\)$|\1|' $spec
        fi
    done

    # FIXME: where is a source of the bug with empty Summary?
    subst "s|Summary: *$|Summary: $pkgname (was empty Summary after alien)|" $spec
    subst "s|^\(Version: .*\)~.*|\1|" $spec
    subst "s|^Release: |Release: alt1.repacked.with.epm.|" $spec
    subst "s|^Distribution:.*||" $SPEC
    subst "s|^\((Converted from a\) \(.*\) \(package.*\)|(Repacked from binary \2 package with epm $EPMVERSION)\n\1 \2 \3|" $spec
    #" hack for highlight
}

__check_stoplist()
{
    cat <<EOF | grep -q "^$1$"
kesl
kesl-astra
klnagent
klnagent64
klnagent64-astra
EOF
}


__apply_fix_code()
{
    local repackcode="$(realpath $CONFIGDIR/repack.d/$1.sh)"
    [ -x "$repackcode" ] || return
    shift
    export PATH=$PROGDIR:$PATH
    local bashopt=''
    [ -n "$verbose" ] && bashopt='-x'
    docmd bash $bashopt $repackcode "$1" "$2" || fatal "There is an error from $repackcode script"
}

__create_rpmmacros()
{
[ -n "$TMPDIR" ] || TMPDIR=/tmp

    cat <<EOF >$HOME/.rpmmacros
%_topdir	$HOME/RPM
%_tmppath	$TMPDIR

%packager	EPM <support@etersoft.ru>
%_gpg_name	support@etersoft.ru

%_allow_root_build	1
EOF
    to_remove_pkg_files="$to_remove_pkg_files $HOME/.rpmmacros"
}

__epm_repack_to_rpm()
{
    local pkgs="$*"
    case $DISTRNAME in
        ALTLinux|ALTServer)
            ;;
        *)
            assure_distr ALTLinux "install --repack"
            ;;
    esac

    # install epm-repack for static (package based) dependencies
    assure_exists alien || fatal
    assure_exists /usr/bin/rpmbuild rpm-build || fatal

    # TODO: improve
    if echo "$pkgs" | grep -q "\.deb" ; then
        assure_exists dpkg || fatal
        # TODO: Для установки требует: /usr/share/debconf/confmodule но пакет не может быть установлен
        # assure_exists debconf
    fi

    local pkg
    export HOME=$(mktemp -d)
    __create_rpmmacros

    local alpkg
    local abspkg
    local tmpbuilddir
    repacked_rpms=''
    for pkg in $pkgs ; do
        tmpbuilddir=$HOME/$(basename $pkg).tmpdir
        mkdir $tmpbuilddir
        abspkg="$(realpath $pkg)"
        info ""
        info "Repacking $abspkg to local rpm format ..."
        # alien failed with spaced names
        # alpkg=$abspkg
        alpkg=$(basename $pkg)
        # TODO: use func for get name from deb pkg
        # TODO: epm print name from deb package
        # TODO: use stoplist only for deb?
        [ -z "$force" ] && __check_stoplist $(echo $alpkg | sed -e "s|_.*||") && fatal "Please use official rpm package instead of $alpkg (It is not recommended to use --force to skip this checking."

        # don't use abs package path: copy package to temp dir and use there
        cp $verbose $pkg $tmpbuilddir/../$alpkg

        cd $tmpbuilddir/../ || fatal

        PKGNAME=''
        VERSION=''
        SUBGENERIC=''
        # convert tarballs to tar (for alien)
        if rhas "$pkg" "\.(rpm|deb)$" ; then
            :
        elif rhas "$pkg" "\.AppImage$" ; then
            VERSION="$(echo "$alpkg" | grep -o -P "[-_.]([0-9])([0-9])*(\.[0-9])*" | head -n1 | sed -e 's|^[-_.]||')" #"
            [ -n "$VERSION" ] || fatal "Can't get version from $alpkg."
            PKGNAME="$(echo "$alpkg" | sed -e "s|[-_.]$VERSION.*||")"
            # TODO: move repack archive to erc?
            [ -x "$alpkg" ] || docmd chmod u+x -v "$alpkg"
            #[ -x "$alpkg" ] || sudocmd chmod u+x -v "$abspkg"
            SUBGENERIC='appimage'
            ./$alpkg --appimage-extract || fatal
            alpkg=$PKGNAME-$VERSION.tar
            assure_exists erc || fatal
            a= erc a $alpkg squashfs-root
        else
            VERSION="$(echo "$alpkg" | grep -o -P "[-_.]([0-9])([0-9])*(\.[0-9])*" | head -n1 | sed -e 's|^[-_.]||')" #"
            if [ -n "$VERSION" ] ; then
                PKGNAME="$(echo "$alpkg" | sed -e "s|[-_.]$VERSION.*||")"
                pkgtype="$(a= erc type $alpkg)"
                [ -n "$PKGNAME" ] || PKGNAME=$(basename $alpkg .$pkgtype)
                if [ "$pkgtype" = "tar" ] || [ "$pkgtype" = "tar.gz" ] || [ "$pkgtype" = "tgz" ] ; then
                    :
                else
                    newalpkg=$(basename $alpkg .$pkgtype).tar
                    assure_exists erc || fatal
                    a= erc repack $alpkg $newalpkg || fatal
                    rm -f $verbose $alpkg
                    alpkg=$newalpkg
                fi
            fi
        fi

        cd $tmpbuilddir/ || fatal

        if [ -n "$verbose" ] ; then
            docmd alien --generate --to-rpm $verbose $scripts "../$alpkg" || fatal
        else
            showcmd alien --generate --to-rpm $scripts "../$alpkg"
            a='' alien --generate --to-rpm $scripts "../$alpkg" >/dev/null || fatal
        fi

        local subdir="$(echo *)"
        [ -d "$subdir" ] || fatal "can't find subdir"

        # detect spec and move to prev dir
        local spec="$(echo $tmpbuilddir/$subdir/*.spec)"
        [ -s "$spec" ] || fatal "can't find spec"
        mv $spec $tmpbuilddir || fatal
        spec="$tmpbuilddir/$(basename "$spec")"
        __set_name_version $spec $PKGNAME $VERSION
        local pkgname="$(grep "^Name: " $spec | sed -e "s|Name: ||g" | head -n1)"

        # for tarballs fix permissions
        [ -n "$VERSION" ] && chmod -R a+rX $tmpbuilddir/$subdir/*

        __fix_spec $pkgname $tmpbuilddir/$subdir $spec
        __apply_fix_code "generic" $tmpbuilddir/$subdir $spec
        [ -n "$SUBGENERIC" ] && __apply_fix_code "generic-$SUBGENERIC" $tmpbuilddir/$subdir $spec
        __apply_fix_code $pkgname $tmpbuilddir/$subdir $spec
        # TODO: we need these dirs to be created
        to_remove_pkg_dirs="$to_remove_pkg_dirs $HOME/RPM/BUILD $HOME/RPM"
        showcmd rpmbuild --buildroot $tmpbuilddir/$subdir -bb $spec
        if [ -n "$verbose" ] ; then
            a='' rpmbuild --buildroot $tmpbuilddir/$subdir -bb $spec || fatal
        else
            a='' rpmbuild --buildroot $tmpbuilddir/$subdir -bb $spec >/dev/null || fatal
        fi
        # remove copy of source binary package (don't mix with generated)
        rm -f $tmpbuilddir/../$alpkg
        local repacked_rpm="$(realpath $tmpbuilddir/../*.rpm)"
        if [ -s "$repacked_rpm" ] ; then
            repacked_rpms="$repacked_rpms $repacked_rpm"
            to_remove_pkg_files="$to_remove_pkg_files $repacked_rpm"
        else
            warning "Can't find converted rpm for source binary package '$pkg'"
        fi
        cd - >/dev/null
        rm -rf $tmpbuilddir/$subdir/
        rm -rf $spec
    done

    to_remove_pkg_dirs="$to_remove_pkg_dirs $HOME"
    rmdir $tmpbuilddir
    #rmdir $tmpbuilddir/..
    true
}

__epm_check_if_try_install_pkgtype()
{
	local PKG="$1"
	shift
	__epm_split_by_pkg_type $PKG "$@" || return 1
	__epm_repack_to_rpm $split_replaced_pkgs || { RES=$? ; return 0 ; }

	# TODO: move to install
	docmd epm install $repacked_rpms
	RES=$?
	# TODO: move it to exit handler
	if [ -z "$DEBUG" ] ; then
		# TODO: reinvent
		[ -n "$to_remove_pkg_files" ] && rm -f $to_remove_pkg_files
		[ -n "$to_remove_pkg_files" ] && rmdir $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null
		[ -n "$to_remove_pkg_dirs" ] && rmdir $to_remove_pkg_dirs 2>/dev/null
	fi

	return 0
}


epm_repack()
{
    local CURDIR="$(pwd)"
    # if possible, it will put pkg_urls into pkg_files and reconstruct pkg_filenames
    if [ -n "$pkg_urls" ] ; then
        __handle_pkg_urls_to_install
    fi

    [ -n "$pkg_names" ] && warning "Can't find $pkg_names"
    [ -z "$pkg_files" ] && info "Skip empty repack list" && return 22

    case $PKGFORMAT in
        rpm)
            __epm_repack_to_rpm $pkg_files || fatal
            echo
            echo "Adapted packages:"
            cp $repacked_rpms "$CURDIR"
            for i in $repacked_rpms ; do
                echo "	$(pwd)/$(basename "$i")"
            done
            ;;
        deb)
            if __epm_split_by_pkg_type rpm $pkg_files ; then
                __epm_repack_rpm_to_deb $split_replaced_pkgs
                cp -v $repacked_debs .
                pkg_files="$(estrlist exclude $split_replaced_pkgs $pkg_files)"
                [ -n "$pkg_files" ] && warning "There are left unconverted packages $pkg_files."
            fi
            ;;
        *)
            fatal "$PKGFORMAT is not supported for repack yet"
            ;;
    esac

    # TODO: move it to exit handler
    if [ -z "$DEBUG" ] ; then
        # TODO: reinvent
        [ -n "$to_remove_pkg_files" ] && rm -f $to_remove_pkg_files
        # hack??
        [ -n "$to_remove_pkg_files" ] && rmdir $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null
        [ -n "$to_remove_pkg_dirs" ] && rmdir $to_remove_pkg_dirs 2>/dev/null
    fi

}

# File bin/epm-repo:


epm_repo()
{
	local CMD="$1"
	[ -n "$CMD" ] && shift
	case $CMD in
	"-h"|"--help"|help)               # HELPCMD: help
		get_help HELPCMD $SHAREDIR/epm-repo
cat <<EOF
Examples:
  epm repo set p9
  epm repo add autoimports
  epm repo list
  epm repo change yandex
EOF
		;;
	""|list)                          # HELPCMD: list packages
		epm_repolist "$@"
		;;
	fix)                              # HELPCMD: fix paths in sources lists (ALT Linux only)
		epm_repofix "$@"
		;;
	change)                           # HELPCMD: <mirror>: switch sources to the mirror (supports etersoft/yandex/basealt): rewrite URLs to the specified server
		epm_repofix "$@"
		;;
	set)                              # HELPCMD: <mirror>: remove all existing sources and add mirror for the branch
		epm repo rm all
		epm addrepo "$@"
		;;
	switch)                           # HELPCMD: switch repo to <repo>: rewrite URLs to the repo
		epm_reposwitch "$@"
		;;
	clean)                            # HELPCMD: remove temp. repos (tasks and CD-ROMs)
		# TODO: check for ALT
		sudocmd apt-repo $dryrun clean
		;;
	save)
		epm_reposave "$@"
		;;
	restore)
		epm_reporestore "$@"
		;;
	reset)
		epm_reporeset "$@"
		;;
	add)                              # HELPCMD: add package repo (etersoft, autoimports, archive 2017/12/31); run with param to get list
		epm_addrepo "$@"
		;;
	Add)                              # HELPCMD: like add, but do update after add
		epm_addrepo "$@"
		epm update
		;;
	rm|remove)                           # HELPCMD: remove repository from the sources lists (epm repo remove all for all)
		epm_removerepo "$@"
		;;
	comment)                             # HELPCMD: comment out repository line from the sources lists
		epm_commentrepo "$@"
		;;
	*)
		fatal "Unknown command $ epm repo '$CMD'"
		;;
esac

}

# File bin/epm-repofix:



__replace_text_in_alt_repo()
{
	local i
	for i in /etc/apt/sources.list /etc/apt/sources.list.d/*.list ; do
		[ -s "$i" ] || continue
		# TODO: don't change file if untouched
		#grep -q -- "$1" "$i" || continue
		regexp_subst "$1" "$i"
	done
}

__repofix_check_vendor()
{
	local i
	for i in /etc/apt/vendors.list.d/*.list; do
		[ -e "$i" ] || continue
		grep -q "^simple-key \"$1\"" $i && return
	done
	return 1
}

__repofix_filter_vendor()
{
	local br="$1"
	br="$(echo "$br" | sed -e "s|\..*||")"
	case $br in
		c8)
			br="cert8"
			;;
		c9)
			br="cert9"
			;;
	esac
	echo "$br"
}


__replace_alt_version_in_repo()
{
	local i
	assure_exists apt-repo
	#echo "Upgrading $DISTRNAME from $1 to $2 ..."
	a='' apt-repo list | sed -E -e "s|($1)|{\1}->{$2}|g" | grep -E --color -- "$1"
	# ask and replace only we will have changes
	if a='' apt-repo list | grep -E -q -- "$1" ; then
		__replace_text_in_alt_repo "/^ *#/! s!$1!$2!g"
	fi
	#docmd apt-repo list
}

__alt_replace_sign_name()
{
	local TO="$1"
	__replace_text_in_alt_repo "/^ *#/! s!\[alt\]!$TO!g"
	__replace_text_in_alt_repo "/^ *#/! s!\[sisyphus\]!$TO!g"
	__replace_text_in_alt_repo "/^ *#/! s!\[updates\]!$TO!g"
	__replace_text_in_alt_repo "/^ *#/! s!\[cert[789]\]!$TO!g"
	__replace_text_in_alt_repo "/^ *#/! s!\[p10\.?[0-9]?\]!$TO!g"
	__replace_text_in_alt_repo "/^ *#/! s!\[[tpc][6-9]\.?[0-9]?\]!$TO!g"
}

__alt_repofix()
{
	local TO="$1"
	epm --quiet repo fix >/dev/null
	if [ -n "$TO" ] ; then
		# TODO: switch it in repo code
		TO="$(__repofix_filter_vendor "$TO")"
		__alt_replace_sign_name "[$TO]"
	fi
}

epm_reposwitch()
{
	local TO="$1"
	[ -n "$TO" ] || fatal "run repo switch with arg (p9, p10, Sisyphus)"
	__replace_alt_version_in_repo "Sisyphus/" "$TO/branch/"
	__replace_alt_version_in_repo "[tpc][5-9]\.?[0-9]?/branch/" "$TO/branch/"
	if [ "$TO" != "p10" ] ; then
		__replace_alt_version_in_repo "p10\.?[0-9]?/branch/" "$TO/branch/"
	fi

	__alt_repofix "$TO"

	if [ "$TO" = "p10" ] ; then
		echo '%_priority_distbranch p10' >/etc/rpm/macros.d/p10
	else
		rm -fv /etc/rpm/macros.d/p10
	fi
	#epm repo list
}


__try_fix_apt_source_list()
{
	local list="$1"
	local br="$(__repofix_filter_vendor "$2")"
	local path="$3"
	if grep -q -e "^[^#].*$path" $list ; then
		if __repofix_check_vendor $br ; then
			regexp_subst "/$path/s/^rpm[[:space:]]*([fhr])/rpm [$br] \1/" $list
		else
			warning "Skip set $br vendor key (it is missed) for $list"
			regexp_subst "/$path/s/^rpm[[:space:]]*\[$br\][[:space:]]*([fhr])/rpm \1/" $list
		fi
	fi
}

__fix_alt_sources_list()
{
	# for beauty spaces
	local SUBST_ALT_RULE1='s!^(.*)[/ ](ALTLinux|LINUX\@Etersoft)[/ ]*(Sisyphus)[/ ](x86_64|i586|x86_64-i586|noarch|aarch64) !\1 \2/\3/\4 !gi'
	local SUBST_ALT_RULE2='s!^(.*)[/ ](ALTLinux|LINUX\@Etersoft)[/ ]*([tcp][6-9]\.?[0-9]?[/ ]branch|[tcp]1[012][/ ]branch)[/ ](x86_64|i586|x86_64-i586|noarch|aarch64) !\1 \2/\3/\4 !gi'
	local i

	for i in "$@" ; do
		[ -s "$i" ] || continue
		#perl -i.bak -pe "$SUBST_ALT_RULE" $i
		# TODO: only for uncommented strings
		#sed -i -r -e "$SUBST_ALT_RULE" $i
		regexp_subst "/^ *#/! s| pub|/pub|" $i
		regexp_subst "/^ *#/! $SUBST_ALT_RULE1" $i
		regexp_subst "/^ *#/! $SUBST_ALT_RULE2" $i

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

__subst_with_etersoft_url()
{
	local NURL="http://download.etersoft.ru/pub ALTLinux"
	echo "$1" | sed \
		-e "s|h\?f\?t\?tp://ftp.altlinux.org/pub/distributions/* ALTLinux|$NURL|" \
		-e "s|h\?f\?t\?tp://ftp.basealt.ru/pub/distributions/* ALTLinux|$NURL|" \
		-e "s|h\?f\?t\?tp://mirror.yandex.ru/* altlinux|$NURL|"
}

__subst_with_yandex_url()
{
	local NURL="http://mirror.yandex.ru altlinux"
	echo "$1" | sed \
		-e "s|h\?f\?t\?tp://ftp.altlinux.org/pub/distributions/* ALTLinux|$NURL|" \
		-e "s|h\?f\?t\?tp://ftp.basealt.ru/pub/distributions/* ALTLinux|$NURL|" \
		-e "s|h\?f\?t\?tp://ftp.etersoft.ru/pub/* ALTLinux|$NURL|" \
		-e "s|h\?f\?t\?tp://download.etersoft.ru/pub/* ALTLinux|$NURL|"
}

__subst_with_basealt_url()
{
	local NURL="http://ftp.basealt.ru/pub/distributions ALTLinux"
	echo "$1" | sed \
		-e "s|h\?f\?t\?tp://mirror.yandex.ru/* altlinux|$NURL|" \
		-e "s|h\?f\?t\?tp://ftp.etersoft.ru/pub/* ALTLinux|$NURL|" \
		-e "s|h\?f\?t\?tp://download.etersoft.ru/pub/* ALTLinux|$NURL|"
}

__fix_repo_to_etersoft()
{
	local NN
	a="" apt-repo list | grep -v debuginfo | grep -v etersoft | grep -v "file:/" | while read nn ; do
		NN="$(__subst_with_etersoft_url "$nn")"
		[ "$NN" = "$nn" ] && continue
		epm removerepo "$nn"
		epm addrepo "$NN"
	done
}

__fix_repo_to_yandex()
{
	local NN
	a="" apt-repo list | grep -v debuginfo | grep -v mirror\.yandex | grep -v "file:/" | while read nn ; do
		NN="$(__subst_with_yandex_url "$nn")"
		[ "$NN" = "$nn" ] && continue
		epm removerepo "$nn"
		epm addrepo "$NN"
	done
}

__fix_repo_to_basealt()
{
	local NN
	a="" apt-repo list | grep -v debuginfo | grep -v ftp.basealt | grep -v "file:/" | while read nn ; do
		NN="$(__subst_with_basealt_url "$nn")"
		[ "$NN" = "$nn" ] && continue
		epm removerepo "$nn"
		epm addrepo "$NN"
	done
}


epm_repofix()
{

case $DISTRNAME in
	ALTLinux|ALTServer)
		assure_exists apt-repo
		[ -n "$quiet" ] || docmd apt-repo list
		assure_root
		__fix_alt_sources_list /etc/apt/sources.list
		__fix_alt_sources_list /etc/apt/sources.list.d/*.list
        # TODO: move to repo change
		if [ "$1" = "etersoft" ] ; then
			__fix_repo_to_etersoft /etc/apt/sources.list
			__fix_repo_to_etersoft /etc/apt/sources.list.d/*.list
		fi
		if [ "$1" = "yandex" ] ; then
			__fix_repo_to_yandex /etc/apt/sources.list
			__fix_repo_to_yandex /etc/apt/sources.list.d/*.list
		fi
		if [ "$1" = "basealt" ] ; then
			__fix_repo_to_basealt /etc/apt/sources.list
			__fix_repo_to_basealt /etc/apt/sources.list.d/*.list
		fi
		docmd apt-repo list
		return
		;;
esac

case $PMTYPE in
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-repolist:


__print_apt_sources_list()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        grep -v -- "^.*#" $i
    done | grep -v -- "^ *\$"
}

__print_apt_sources_list_list()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        grep -v -- "^.*#" $i | grep -v -- "^ *\$" | grep -q . && echo "$i"
    done
}

__info_cyan()
{
		set_boldcolor $CYAN
		echo "$*" >&2
		restore_color
}

__print_apt_sources_list_verbose()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        grep -v -- "^.*#" $i | grep -v -- "^ *\$" | grep -q . && __info_cyan "$i:" || continue
        grep -v -- "^.*#" $i | grep -v -- "^ *\$" | sed -e 's|^|    |'
    done
}

print_apt_sources_list()
{
    local LISTS='/etc/apt/sources.list /etc/apt/sources.list.d/*.list'
    if [ -n "$quiet" ] ; then
        __print_apt_sources_list $LISTS
    else
        __print_apt_sources_list_verbose $LISTS
    fi
}


epm_repolist()
{

[ -z "$*" ] || [ "$PMTYPE" = "apt-rpm" ] || fatal "No arguments are allowed here"

case $PMTYPE in
	apt-rpm)
		#assure_exists apt-repo
		if tasknumber "$1" >/dev/null ; then
			get_task_packages "$@"
		else
			print_apt_sources_list
			#docmd apt-repo list
		fi
		;;
	deepsolver-rpm)
		docmd ds-conf
		;;
	apt-dpkg|aptitude-dpkg)
		print_apt_sources_list
		;;
	yum-rpm)
		docmd yum repolist $verbose
		;;
	dnf-rpm)
		docmd dnf repolist $verbose
		;;
	urpm-rpm)
		docmd urpmq --list-url
		;;
	zypper-rpm)
		docmd zypper sl -d
		;;
	packagekit)
		docmd pkcon repo-list
		;;
	emerge)
		docmd eselect profile list
		docmd layman -L
		;;
	xbps)
		docmd xbps-query -L
		;;
	winget)
		docmd winget source list
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

# File bin/epm-reposave:



SAVELISTDIR=/tmp/eepm-etc-save
__save_alt_repo_lists()
{
	assure_root
	info "Creating copy of all sources lists to $SAVELISTDIR ..."
	local i
	rm -rf $verbose $SAVELISTDIR 2>/dev/null
	mkdir -p $SAVELISTDIR/apt/ $SAVELISTDIR/apt/sources.list.d/
	for i in /etc/apt/sources.list /etc/apt/sources.list.d/*.list ; do
		[ -s "$i" ] || continue
		local DD="$(echo "$i" | sed -e "s|/etc|$SAVELISTDIR|")"
		cp -af $verbose "$i" "$DD" || fatal "Can't save apt source list files to $SAVELISTDIR"
	done
}

__restore_alt_repo_lists()
{
	assure_root
	info "Restoring copy of all sources lists from $SAVELISTDIR ..."
	local i
	[ -d "$SAVELISTDIR/apt" ] || return 0
	mkdir -p $SAVELISTDIR/apt/ $SAVELISTDIR/apt/sources.list.d/
	for i in /etc/apt/sources.list /etc/apt/sources.list.d/*.list ; do
		[ -s "$i" ] || continue
		local DD="$(echo "$i" | sed -e "s|/etc|$SAVELISTDIR|")"
		# restore only if there are differences
		if diff -q "$DD" "$i" >/dev/null ; then
			rm -f $verbose "$DD"
		else
			mv $verbose "$DD" "$i" || warning "Can't restore $i file"
		fi
	done
}

__on_error_restore_alt_repo_lists()
{
	warning "An error occurred..."
	epm repo restore
}

try_change_alt_repo()
{
	epm repo save
	trap __on_error_restore_alt_repo_lists EXIT
}

end_change_alt_repo()
{
	trap - EXIT
}



epm_reposave()
{
case $PMTYPE in
	apt-*)
		if ! is_root ; then
			sudoepm repo save
			return
		fi
		__save_alt_repo_lists
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

epm_reporestore()
{
case $PMTYPE in
	apt-*)
		if ! is_root ; then
			sudoepm repo restore
			return
		fi
		__restore_alt_repo_lists
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

epm_reporeset()
{
case $PMTYPE in
	winget)
		sudocmd winget source reset
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
	packagekit)
		CMD="pkcon required-by"
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
	homebrew)
		#docmd brew info $pkg_names | grep "^Required: " | sed -s "|s|^Requires: ||"
		docmd brew deps $pkg_names
		return
		;;
	pkgng)
		#CMD="pkg rquery '%dn-%dv'"
		CMD="pkg info -d"
		;;
	opkg)
		CMD="opkg depends"
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
	[ -n "$pkg_filenames" ] || fatal "Requires: package name is missed"
	epm_requires_files $pkg_files
	# shellcheck disable=SC2046
	epm_requires_names $(print_name $pkg_names)
}

# File bin/epm-restore:


__epm_restore_print_comment()
{
    echo "#$2 generated by 'epm restore --dry-run' from $(basename $(dirname $(realpath "$1")))/$(basename "$1")$3"
}

__epm_filter_pip_to_rpm()
{
    tr "A-Z" "a-z" | sed -e "s|_|-|g" -e "s|^python[-_]||" -e "s|python$||" \
        -e "s|bs4|beautifulsoup4|" \
        -e "s|pillow|Pillow|" \
        -e "s|sqlalchemy|SQLAlchemy|" \
        -e "s|flask-SQLAlchemy|flask_sqlalchemy|" \
        -e "s|redis|redis-py|" \
        -e "s|pyjwt|jwt|" \
        -e "s|pymonetdb|monetdb|" \
        -e "s|pyyaml|yaml|" \
        -e "s|flask-migrate|Flask-Migrate|" \
        -e "s|twisted|twisted-core|" \
        -e "s|pymacaroons|pymacaroons-pynacl|" \
        -e "s|pygments|Pygments|" \
        -e "s|memcached|memcache|" \
        -e "s|pyinstaller||" \
        -e "s|pyopenssl|OpenSSL|"
}

fill_sign()
{
    local sign="$1"
    echo "$2" | grep -E -- "$sign[[:space:]]*[0-9.]+?" | sed -E -e "s|.*$sign[[:space:]]*([0-9.]+?).*|\1|"
}


__epm_pi_sign_to_rpm()
{
    local t="$1"
    local l="$2"
    local equal="$3"
    [ -n "$equal" ] || equal=">="

    local pi=''
    local sign ll
    for sign in "<=" "<" ">=" ">" "==" "!=" "~="; do
        ll=$(fill_sign "$sign" "$l")
        [ -n "$ll" ] || continue
        [ "$sign" = "==" ] && sign="$equal"
        [ "$sign" = "~=" ] && sign="$equal"
        [ "$sign" = "!=" ] && sign=">="
        [ -n "$pi" ] && pi="$pi
"
        pi="$pi$t $sign $ll"
    done
    [ -n "$pi" ] || pi="$t"
    echo "$pi"
}

__epm_get_array_name()
{
    echo "$*" | grep "=" | head -n1 | sed -e 's| *=.*||'
}

__epm_lineprint_python_array()
{
    local a="$*"
    [ -n "$a" ] || return
    local name="$(__epm_get_array_name "$a")"
    (echo "$a" | sed -E -e 's@(\]|\)).*@\1@' ; echo "print('\n'.join($name))" ) | ( a= python3 - || a= python - )
}

__epm_restore_convert_to_rpm_notation()
{
    local equal="$1"
    local l
    while read l ; do
        if echo "$l" | grep -q 'platform_python_implementation != "PyPy"' ; then
            [ -n "$verbose" ] && warning "    $t is not PyPi requirement, skipped"
            continue
        fi
        if echo "$l" | grep -q 'sys_platform == "darwin"' ; then
            [ -n "$verbose" ] && warning "    $t is darwin only requirement, skipped"
            continue
        fi
        if echo "$l" | grep -q 'sys_platform == "win32"' ; then
            [ -n "$verbose" ] && warning "    $t is win32 only requirement, skipped"
            continue
        fi
        if echo "$l" | grep -q "; *python_version *< *['\"]3" ; then
            [ -n "$verbose" ] && warning "    $t is python2 only requirement, skipped"
            continue
        fi
        if echo "$l" | grep -q "; *python_version *<= *['\"]2\." ; then
            [ -n "$verbose" ] && warning "    $t is python2 only requirement, skipped"
            continue
        fi
        # drop various "python_version > '3.5'"
        l="$(echo "$l" | sed -e "s| *;.*||")"
        if echo "$l" | grep -qE "^ *#" || [ -z "$l" ] ; then
            continue
        fi
        local t="$(echo "$l" | sed -E -e "s|[[:space:]]*[<>!=~]+.*||" -e "s| *#.*||" | __epm_filter_pip_to_rpm)"
        [ -n "$t" ] || continue
        # until new section
        if echo "$l" | grep -qE "^\[" ; then
            break
        fi
        # if dependency_links URLs, use egg name
        if echo "$l" | grep -qE "://" ; then
            if echo "$l" | grep -q "#egg=" ; then
                t="$(echo "$l" | sed -e "s|.*#egg=||" -e "s|\[.*||" | __epm_filter_pip_to_rpm)"
            else
                warning "    skipping URL $l ..."
                continue
            fi
        fi

        __epm_pi_sign_to_rpm "$t" "$l" "$equal"
    done
}

__epm_restore_pip()
{
    local req_file="$1"
    local reqmacro
    local ilist

    if [ -n "$dryrun" ] ; then
        reqmacro="%py3_use"
        basename "$req_file" | grep -E -q "(dev|test|coverage)" && reqmacro="%py3_buildrequires"
        echo
        __epm_restore_print_comment "$req_file"
        cat $req_file | __epm_restore_convert_to_rpm_notation | sed -e "s|^|$reqmacro |"
        return
    else
        info "Install requirements from $req_file ..."
        ilist="$(cat $req_file | __epm_restore_convert_to_rpm_notation | cut -d' ' -f 1 | sed -e "s|^|python3-module-|")"
    fi

    ilist="$(estrlist list $ilist)"
    docmd epm install $ilist
}

__eresection()
{
    rhas "$1" "[[:space:]]*$2[[:space:]]*=[[:space:]]*[\[(]"
}

__epm_restore_setup_py()
{
    local req_file="$1"
    if [ -z "$dryrun" ] ; then
        info "Install requirements from $req_file ..."
    fi

    local ar=''
    local ilist=''
    local reqmacro
    local section=''
    while read l ; do
        if rhas "$l" "^ *#" ; then
            continue
        fi
        # start of section
        if __eresection "$l" "REQUIREMENTS" ; then
            reqmacro="%py3_use"
            section="$l"
        fi
        if __eresection "$l" "install_requires" ; then
            reqmacro="%py3_use"
            section="$l"
        fi
        if __eresection "$l" "setup_requires" ; then
            reqmacro="%py3_buildrequires"
            section="$l"
        fi
        if __eresection "$l" "tests_require" ; then
            reqmacro="%py3_buildrequires"
            section="$l"
        fi
        if [ -n "$section" ] ; then
            ar="$ar
$l"
        fi

        # not end of section
        if [ -z "$section" ] || ! rhas "$l" "(\]|\)),*" ; then
            continue
        fi

        if [ -n "$dryrun" ] ; then
            echo
            __epm_restore_print_comment "$req_file" "" " $(__epm_get_array_name "$section")"
            __epm_lineprint_python_array "$ar" | __epm_restore_convert_to_rpm_notation ">=" | sed -e "s|^|$reqmacro |"
        else
            ilist="$ilist $(__epm_lineprint_python_array "$ar" | __epm_restore_convert_to_rpm_notation ">=" | cut -d' ' -f 1 | sed -e "s|^|python3-module-|")"
        fi
        section=''
        ar=''
    done < $req_file

    if [ -n "$dryrun" ] ; then
        return
    fi

    ilist="$(estrlist list $ilist)"
    docmd epm install $ilist
}

__epm_print_npm_list()
{
    local reqmacro="$1"
    local req_file="$2"
    local l
    while read l ; do
        # "tap": "^14.10.7"
        echo "$l" | grep -q '"\(.*\)": "\(.*\)"' || continue
        local name="$(echo "$l" | sed -e 's|.*"\(.*\)": ".*|\1|')"
        [ -z "$name" ] && continue
        local ver="$(echo "$l" | sed -e 's|.*"\(.*\)": "\(.*\)".*|\2|')" #'
        [ -z "$name" ] && continue

        if [ -n "$dryrun" ] ; then
            local pi=''
            local sign
            if echo "$ver" | grep -q "^\^" ; then
                sign=">="
            else
                sign="="
            fi
            ll=$(echo "$ver" | sed -e 's|^[^~]||')
            pi="$pi$reqmacro node-$name $sign $ll"
            echo "$pi"
            continue
        else
            local pi="node-$name"
            #echo "    $l -> $name -> $pi"
        fi
        [ -n "$name" ] || continue
        ilist="$ilist $pi"
    done < $req_file

    [ -n "$dryrun" ] || echo "$ilist"
}


__epm_print_perl_list()
{
    local reqmacro="$1"
    local req_file="$2"
    local l
    for l in $(cat) ; do
        # perl(Class::ErrorHandler)>=0
        echo "$l" | grep -q '^perl(' || continue
        local name="$(echo "$l" | sed -e 's|>=.*||' -e 's|::|/|g' -e 's|)|.pm)|')"
        [ "$name" = "perl(perl.pm)" ] && continue
        [ -z "$name" ] && continue
        local ver="$(echo "$l" | sed -e 's|.*>=||')"
        [ -z "$name" ] && continue

        if [ -n "$dryrun" ] ; then
            local pi=''
            local sign=''
            [ "$ver" = "0" ] || sign=" >= $ver"
            pi="$pi$reqmacro $name$sign"
            echo "$pi"
            continue
        else
            local pi="$name"
            #echo "    $l -> $name -> $pi"
        fi
        [ -n "$name" ] || continue
        ilist="$ilist $pi"
    done < $req_file

    [ -n "$dryrun" ] || echo "$ilist"
}

__epm_print_perl_list_shyaml()
{
    local reqmacro="$1"
    local req_file="$2"
    local l
    while read l ; do
        # Convert::ASN1: 0.10
        echo "$l" | grep -q '^ *\(.*\): \(.*\)' || continue
        local name="$(echo "$l" | sed -e 's| *\(.*\): \(.*\)|\1|' -e 's|::|/|g')".pm
        [ "$name" = "perl.pm" ] && continue
        [ -z "$name" ] && continue
        local ver="$(echo "$l" | sed -e 's| *\(.*\): \(.*\)|\2|')"
        [ -z "$name" ] && continue

        if [ -n "$dryrun" ] ; then
            local pi=''
            local sign=''
            [ "$ver" = "0" ] || sign=" >= $ver"
            pi="$pi$reqmacro perl($name)$sign"
            echo "$pi"
            continue
        else
            local pi="perl($name)"
            #echo "    $l -> $name -> $pi"
        fi
        [ -n "$name" ] || continue
        ilist="$ilist $pi"
    done < $req_file

    [ -n "$dryrun" ] || echo "$ilist"
}


__epm_print_nupkg_list()
{
    a= dotnet list $1 package | grep "^   > " | while read n name req other; do
        if [ -n "$dryrun" ] ; then
            echo "BuildRequires: nupkg($name) >= $req"
        else
            echo "nupkg($name)"
        fi
    done
}

__epm_restore_nupkg()
{
    local req_file="$1"
    if [ -n "$dryrun" ] ; then
        echo "# generated via dotnet list $(basename $(dirname $(realpath "$req_file")))/$(basename "$req_file") package"
        __epm_print_nupkg_list $req_file
        return
    fi

    info "Install requirements from $req_file ..."
    ilist=$(__epm_print_nupkg_list $req_file)
    ilist="$(estrlist list $ilist)"
    docmd epm install $ilist
}

__epm_restore_npm()
{
    local req_file="$1"

    assure_exists jq || fatal

    if [ -n "$dryrun" ] ; then
        local lt=$(mktemp)
        a= jq .dependencies <$req_file >$lt
        echo
        __epm_restore_print_comment "$req_file"
        __epm_print_npm_list "Requires:" $lt

        echo
        __epm_restore_print_comment "$req_file" " devDependencies"
        a= jq .devDependencies <$req_file >$lt
        __epm_print_npm_list "BuildRequires:" $lt
        rm -f $lt
        return
    fi

    info "Install requirements from $req_file ..."
    local lt=$(mktemp)
    a= jq .dependencies <$req_file >$lt
    ilist="$(__epm_print_npm_list "" $lt)"
    a= jq .devDependencies <$req_file >$lt
    ilist="$ilist $(__epm_print_npm_list "" $lt)"
    rm -f $lt
    docmd epm install $ilist
}

__epm_restore_perl()
{
    local req_file="$1"

    if [ -n "$dryrun" ] ; then
        local lt=$(mktemp)
        a= /usr/bin/perl $req_file PRINT_PREREQ=1 >$lt
        # all requirements will autodetected during packing, put it to the buildreq
        echo
        __epm_restore_print_comment "$req_file"
        __epm_print_perl_list "BuildRequires:" $lt
        rm -f $lt
        return
    fi

    info "Install requirements from $req_file ..."
    local lt=$(mktemp)
    a= /usr/bin/perl $req_file PRINT_PREREQ=1 >$lt
    ilist="$(__epm_print_perl_list "" $lt)"
    rm -f $lt
    docmd epm install $ilist
}

__epm_restore_perl_shyaml()
{
    local req_file="$1"

    assure_exists shyaml || fatal

    if [ -n "$dryrun" ] ; then
        local lt=$(mktemp)
        a= shyaml get-value requires <$req_file >$lt
        # all requirements will autodetected during packing, put it to the buildreq
        echo
        __epm_restore_print_comment "$req_file"
        __epm_print_perl_list "BuildRequires:" $lt

        echo
        __epm_restore_print_comment "$req_file" " build_requires"
        a= shyaml get-value build_requires <$req_file >$lt
        __epm_print_perl_list "BuildRequires:" $lt
        rm -f $lt
        return
    fi

    info "Install requirements from $req_file ..."
    local lt=$(mktemp)
    a= shyaml get-value requires <$req_file >$lt
    ilist="$(__epm_print_perl_list "" $lt)"
    a= shyaml get-value build_requires <$req_file >$lt
    ilist="$ilist $(__epm_print_perl_list "" $lt)"
    rm -f $lt
    docmd epm install $ilist
}

__epm_restore_by()
{
    local req_file="$1"
    [ -s "$req_file" ] || return

    if file $req_file | grep -q "ELF [3264]*-bit LSB executable" ; then
        assure_exists ldd-requires
        showcmd ldd-requires $req_file
        local TOINSTALL="$(a= ldd-requires $req_file | grep "^apt-get install" | sed -e "s|^apt-get install ||")"
        if [ -n "$dryrun" ] ; then
            estrlist list $TOINSTALL
            return
        fi
        [ -n "$TOINSTALL" ] || { info "There are no missed packages is found for $req_file binary." ; return ; }
        docmd epm install $TOINSTALL
        return
    fi

    case $req_file in
        requirements/default.txt|requirements/dev.txt|requirements/test.txt|requirements/coverage.txt)
            [ -s "$req_file" ] && __epm_restore_pip "$req_file" && return
            ;;
    esac

    case $(basename $req_file) in
        requirements.txt|dev-requirements.txt|requirements-dev.txt|requirements_dev.txt|requirements_test.txt|requirements-test.txt|test-requirements.txt|requires.txt)
            [ -s "$req_file" ] && __epm_restore_pip "$req_file"
            ;;
        setup.py|python_dependencies.py)
            [ -s "$req_file" ] && __epm_restore_setup_py "$req_file"
            ;;
        package.json)
            [ -s "$req_file" ] && __epm_restore_npm "$req_file"
            ;;
        Makefile.PL)
            [ -s "$req_file" ] && __epm_restore_perl "$req_file"
            ;;
        *.sln|*.csproj)
            local PROJ="$(echo $req_file)"
            [ -s "$PROJ" ] && __epm_restore_nupkg "$PROJ"
            ;;
        Gemfile|package.json)
            info "$req_file support is not implemented yet"
            ;;
    esac
}

epm_restore()
{
    req_file="$pkg_filenames"
    if [ -n "$pkg_urls" ] && echo "$pkg_urls" | grep -qE "^https?://" ; then
        req_file="$(basename "$pkg_urls")"
        #assure eget
        [ -r "$req_file" ] && fatal "File $req_file is already exists in $(pwd)"
        info "Downloading '$req_file' from '$pkg_urls' ..."
        eget "$pkg_urls"
        [ -s "$req_file" ] || fatal "Can't download $req_file from '$pkg_urls'"
    fi

    if [ -n "$req_file" ] ; then
        __epm_restore_by $req_file
        return
    fi


    # if run with empty args
    for i in requirements.txt requirements/default.txt requirements_dev.txt requirements-dev.txt requirements/dev.txt dev-requirements.txt \
             requirements-test.txt requirements_test.txt requirements/test.txt test-requirements.txt requirements/coverage.txt \
             Gemfile requires.txt package.json setup.py python_dependencies.py Makefile.PL \
             *.sln *.csproj ; do
        __epm_restore_by $i
    done

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
	packagekit)
		CMD="pkcon search name"
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
		CMD="zypper search -d --"
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
		if [ -n "$verbose" ] ; then
			CMD="/usr/sbin/slackpkg search"
		else
			LANG=C docmd /usr/sbin/slackpkg search $string | grep " - " | sed -e 's|.* - ||g'
			return
		fi
		;;
	opkg)
		CMD="opkg find"
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
	appget|winget)
		CMD="$PMTYPE search"
		;;
	*)
		fatal "Have no suitable search command for $PMTYPE"
		;;
esac

LANG=C docmd $CMD $string
epm play $short --list-all | sed -e 's|^ *||g' -e 's|[[:space:]]\+| |g' -e "s|\$| (use \'epm play\' to install it)|"
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

	[ -n "$listN" ] && echon " | grep -E -i -v -- \"$listN\""

	# FIXME: The World has not idea how to do grep both string
	# http://stackoverflow.com/questions/10110051/grep-with-two-strings-logical-and-in-regex?rq=1

	# Need only if we have more than one word (with one word we will grep for colorify)
	if [ "$(echo "$list" | wc -w)" -gt 1 ] ; then
		for i in $list ; do
			# FIXME -n on MacOS?
			echon " | grep -E -i -- \"$i\""
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
		echon " | grep -E -i $EGREPCOLOR -- \"($COLO)\""
	fi
}

__epm_search_internal()
{
	[ -n "$pkg_filenames" ] || fatal "Search: search argument(s) is missed"

	# it is useful for first time running
	update_repo_if_needed soft

	warmup_bases

	__epm_search_output $(get_firstarg $pkg_filenames) | grep "$pkg_filenames"
}


epm_search()
{
	[ -n "$pkg_filenames" ] || fatal "Search: search argument(s) is missed"

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

    update_alt_contents_index
    local CI="$(cat $ALT_CONTENTS_INDEX_LIST)"

    info "Searching for $1 ... "

    # FIXME: do it better
    local MGS
    MGS=$(eval __epm_search_make_grep $quoted_args)
    showcmd "$ cat contents_index $MGS"
    eval "__alt_search_file_output \"$CI\" \"$(eval get_firstarg $quoted_args)\" $MGS"
}

epm_search_file()
{
	local CMD
	[ -n "$pkg_filenames" ] || fatal "Search file: file name is missed"

case $PMTYPE in
	apt-rpm)
		__alt_local_content_search $pkg_filenames
		return ;;
	apt-dpkg|aptitude-dpkg)
		assure_exists apt-file
		sudocmd apt-file update
		docmd apt-file search $pkg_filenames
		return ;;
	packagekit)
		CMD="pkcon search file"
		;;
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
		CMD="zypper search --file-list"
		;;
	pacman)
		CMD="pacman -Qo"
		;;
	slackpkg)
		CMD="/usr/sbin/slackpkg file-search"
		;;
	opkg)
		CMD="opkg -A search"
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

tasknumber()
{
    local num="$(echo "$1" | sed -e "s| *#*||g")"
    isnumber "$num" && echo "$*"
}

get_task_arepo_packages()
{
    local res
    assure_exists apt-repo
    assure_exists curl

    info "TODO: please, improve apt-repo to support arepo (i586-) packages for apt-repo list task"
    showcmd "curl -s -f http://git.altlinux.org/tasks/$tn/plan/arepo-add-x86_64-i586 | cut -f1"
    # TODO: retrieve one time
    res="$(a='' curl -s -f http://git.altlinux.org/tasks/$tn/plan/arepo-add-x86_64-i586 2>/dev/null)" || { warning "There is a download error for x86_64-i586 arepo." ; return ; }
    echo "$res" | cut -f1
}

get_task_packages()
{
    local arch="$($DISTRVENDOR -a)"
    local tn
    for tn in $(tasknumber "$@") ; do
        showcmd apt-repo list task "$tn"
        a='' apt-repo list task "$tn" >/dev/null || continue
        a='' apt-repo list task "$tn"
        [ "$arch" = "x86_64" ] && get_task_arepo_packages "$tn"
    done
}

# File bin/epm-sh-altlinux-contents-index:


get_alt_repo_path()
{
    local DN1=$(dirname "$1")
    local DN2=$(dirname $DN1)
    local DN3=$(dirname $DN2)

    local BN0=$(basename "$1") # arch
    local BN1=$(basename $DN1) # branch/Sisyphus
    local BN2=$(basename $DN2) # p8/ALTLinux
    local BN3=$(basename $DN3) # ALTLinux/

    [ "$BN1" = "branch" ] && echo "$BN3/$BN2/$BN1/$BN0" || echo "$BN2/$BN1/$BN0"
}

get_local_alt_mirror_path()
{
    # TODO: /var/cache/eepm
    echo "$TMPDIR/eepm/$(get_alt_repo_path "$1")"
}

ALT_CONTENTS_INDEX_LIST=$TMPDIR/eepm/contents_index_list

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
           *.gz)
               a='' zcat $i
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

rsync_alt_contents_index()
{
    local URL="$1"
    local TD="$2"
    assure_exists rsync
    mkdir -p "$(dirname "$TD")"
    if [ -n "$verbose" ] ; then
        docmd rsync --partial --inplace $3 -a --progress "$URL" "$TD"
    else
        a= rsync --partial --inplace $3 -a --progress "$URL" "$TD" >/dev/null 2>/dev/null
    fi
}

get_url_to_etersoft_mirror()
{
    local REPOPATH
    local ETERSOFT_MIRROR="rsync://download.etersoft.ru/pub"
    local ALTREPO=$(get_alt_repo_path "$1")
    echo "$ALTREPO" | grep -q "^ALTLinux" || return
    echo "$ETERSOFT_MIRROR/$(get_alt_repo_path "$1" | sed -e "s|^ALTLinux/|ALTLinux/contents_index/|")"
}

__init_contents_index_list()
{
    mkdir -p "$(dirname $ALT_CONTENTS_INDEX_LIST)"
    truncate -s0 $ALT_CONTENTS_INDEX_LIST
}

__add_to_contents_index_list()
{
    [ -n "$quiet" ] || echo "  $1 -> $2"
    echo "$2" >>$ALT_CONTENTS_INDEX_LIST
}

__add_better_to_contents_index_list()
{
    if [ -s "$2" ] && [ -s "$3" ] ; then
        [ "$2" -ot "$3" ] && __add_to_contents_index_list "$1" "$3" && return
        __add_to_contents_index_list "$1" "$2" && return
    fi
    [ -s "$2" ] && __add_to_contents_index_list "$1" "$2" && return
    [ -s "$3" ] && __add_to_contents_index_list "$1" "$3" && return
}


update_alt_contents_index()
{
    __init_contents_index_list
    # TODO: fix for Etersoft/LINUX@Etersoft
    # TODO: fix for rsync
    info "Retrieving contents_index ..."
    (quiet=1 epm_repolist) | grep -v " task$" | grep -E "rpm.*(ftp://|http://|https://|rsync://|file:/)" | sed -e "s@^rpm.*\(ftp://\|http://\|https://\)@rsync://@g" | sed -e "s@^rpm.*\(file:\)@@g" | while read -r URL1 URL2 component ; do
        [ "$component" = "debuginfo" ] && continue
        URL="$URL1/$URL2"
        if echo "$URL" | grep -q "^/" ; then
            # first check for local mirror
            local LOCALPATH="$(echo "$URL/base")"
            local LOCALPATHGZIP="$(echo "$LOCALPATH" | sed -e "s|/ALTLinux/|/ALTLinux/contents_index/|")"
            __add_better_to_contents_index_list "$URL" "$LOCALPATHGZIP/contents_index.gz" "$LOCALPATH/contents_index"
        else
            local LOCALPATH="$(get_local_alt_mirror_path "$URL")"
            local REMOTEURL="$(get_url_to_etersoft_mirror "$URL")"
            if [ -n "$REMOTEURL" ] ; then
                rsync_alt_contents_index $REMOTEURL/base/contents_index.gz $LOCALPATH/contents_index.gz && __add_to_contents_index_list "$REMOTEURL" "$LOCALPATH/contents_index.gz" && continue
                [ -n "$verbose" ] && info "Note: Can't retrieve $REMOTEURL/base/contents_index.gz, fallback to $URL/base/contents_index"
            fi
            # fix rsync URL firstly
            local RSYNCURL="$(echo "$URL" | sed -e "s|rsync://\(ftp.basealt.ru\|basealt.org\|altlinux.ru\)/pub/distributions/ALTLinux|rsync://\1/ALTLinux|")" #"
            rsync_alt_contents_index $RSYNCURL/base/contents_index $LOCALPATH/contents_index -z && __add_to_contents_index_list "$RSYNCURL" "$LOCALPATH/contents_index" && continue

            __add_better_to_contents_index_list "(cached)" "$LOCALPATH/contents_index.gz" "$LOCALPATH/contents_index"
        fi
    done
    if [ ! -s "$ALT_CONTENTS_INDEX_LIST" ] ; then
        fatal "Have no local contents index. Check epm repo --help."
    fi
}


# File bin/epm-sh-install:


__fast_hack_for_filter_out_installed_rpm()
{
	LANG=C LC_ALL=C xargs -n1 rpm -q 2>&1 | grep 'is not installed' |
		sed -e 's|^.*package \(.*\) is not installed.*|\1|g'
}

filter_out_installed_packages()
{
	[ -z "$skip_installed" ] && cat && return

	case $PMTYPE in
		yum-rpm|dnf-rpm)
			if [ "$($DISTRVENDOR -a)" = "x86_64" ] ; then
				# shellcheck disable=SC2013
				for i in $(cat) ; do
					is_installed "$(__print_with_arch_suffix $i .x86_64)" && continue
					is_installed "$(__print_with_arch_suffix $i .noarch)" && continue
					echo $i
				done
			else
				__fast_hack_for_filter_out_installed_rpm
			fi
			;;
		*-rpm)
			__fast_hack_for_filter_out_installed_rpm
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

get_only_installed_packages()
{
    local installlist="$*"
    estrlist exclude "$(echo "$installlist" | (skip_installed='yes' filter_out_installed_packages))" "$installlist"
}

__epm_check_vendor()
{
    # don't check vendor if there are forced script options
    [ -n "$scripts$noscripts" ] && return

    # only ALT
    [ "$DISTRNAME" = "ALTLinux" ] || [ "$DISTRNAME" = "ALTServer" ] || return

    local i
    for i in $* ; do
        local vendor rpmversion

        # skip checking if the package is unaccessible
        rpmversion="$(epm print field Version for "$i" 2>/dev/null)"
        [ -n "$rpmversion" ] || continue

        vendor="$(epm print field Vendor for "$i" 2>/dev/null)"
        # TODO: check GPG
        [ "$vendor" = "ALT Linux Team" ] && continue
        warning "Scripts are disabled for package $i from outside vendor '$vendor'. Use --scripts if you need run scripts from such packages."
        noscripts="--noscripts"
    done
}

# File bin/epm-sh-warmup:

is_warmup_allowed()
{
    local MEM
    # disable warming up until set EPM_WARNUP in /etc/eepm/eepm.conf
    [ -n "$EPM_WARMUP" ] || return 1
    MEM="$($DISTRVENDOR -m)"
    # disable warm if have no enough memory
    [ "$MEM" -le 1024 ] && return 1
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
    grep -q "^No package" $1 && return 1
    grep -q "^Complete!" $1 && return 0
    grep -q "Exiting on user [Cc]ommand" $1 && return 0
    # dnf issue
    grep -q "^Operation aborted." $1 && return 0
    # return default result by default
    return $2
}

__check_pacman_result()
{
    grep -q "^error: target not found:" $1 && return 1
    grep -q "^Total Installed Size:" $1 && return 0
    grep -q "^Total Download Size:" $1 && return 0
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
    			store_output sudocmd yum --assumeno install $filenames
    			__check_yum_result $RC_STDOUT $?
    		else
    			store_output sudocmd yum install $filenames <<EOF
n
EOF
    			__check_yum_result $RC_STDOUT $?
    		fi
    		RES=$?
    		clean_store_output
    		return $RES ;;
    	dnf-rpm)
    		store_output sudocmd dnf --assumeno install $filenames
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
    	opkg)
    		docmd --noaction install $filenames
    		return $res ;;
    	pacman)
    		store_output sudocmd pacman -v -S $filenames <<EOF
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
    			# TODO: use short?
    			# use verbose for get package status
    			#pkg_filenames="$pkg-[0-9]" verbose=--verbose __epm_search_internal | grep -E "(installed|upgrade)" && continue
    			#pkg_filenames="$pkg" verbose=--verbose __epm_search_internal | grep -E "(installed|upgrade)" && continue
    			(pkg_filenames="$pkg" __epm_search_internal) | grep -q "^$pkg-[0-9]" && continue
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
	assure_exists curl || return 1
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
		ALTLinux|ALTServer)
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
		homebrew)
			docmd brew "$1" | grep "^From: " | sed -e "s|^From: ||"
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

[ -n "$pkg_filenames" ] || fatal "Info: package name is missed"

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

# File bin/epm-tool:



epm_tool()
{
    local WHAT="$1"
    shift

    case "$WHAT" in
        "")
            fatal "Use epm tool help to get help."
            ;;
        "-h"|"--help"|"help")
cat <<EOF
  Examples:
    epm tool eget
    epm tool estrlist
EOF
            ;;
        "eget")
            showcmd eget "$@"
            eget "$@"
            ;;
        "estrlist")
            showcmd estrlist "$@"
            estrlist "$@"
            ;;
        *)
            fatal "Unknown command $ epm tool $WHAT. Use epm print help for get help."
            ;;
    esac
}

# File bin/epm-update:



epm_update()
{
	[ -z "$*" ] || fatal "No arguments are allowed here"
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
	packagekit)
		docmd pkcon refresh
		;;
	#snappy)
	#	sudocmd snappy
	#	;;
	aptitude-dpkg)
		sudocmd aptitude update || return
		;;
	yum-rpm)
		# just skipped
		[ -z "$verbose" ] || info "update command is stubbed for yum"
		;;
	dnf-rpm)
		# just skipped
		[ -z "$verbose" ] || info "update command is stubbed for dnf"
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
	opkg)
		sudocmd opkg update
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
	winget)
		sudocmd winget source update
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

	# it is useful for first time running
	update_repo_if_needed

	warmup_bases

	if [ "$DISTRNAME" = "ALTLinux" ] || [ "$DISTRNAME" = "ALTServer" ] ; then
		if tasknumber "$@" >/dev/null ; then

			local installlist="$(get_task_packages $*)"
			# hack: drop -devel packages to avoid package provided by multiple packages
			installlist="$(estrlist reg_exclude ".*-devel .*-devel-static" "$installlist")"
			[ -n "$verbose" ] && info "Packages from task(s): $installlist"
			# install only installed packages (simulate upgrade packages)
			installlist="$(get_only_installed_packages "$installlist")"
			[ -n "$verbose" ] && info "Packages to upgrade: $installlist"
			if [ -z "$installlist" ] ; then
				warning "There is no installed packages for upgrade from task $*"
				return 22
			fi

			try_change_alt_repo
			epm_addrepo "$@"
			(pkg_names="$installlist" epm_Install) || fatal "Can't update repo"
			epm_removerepo "$@"
			end_change_alt_repo

			return
		fi
	fi

	info "Running command for upgrade packages"

	case $PMTYPE in
		*-rpm)
			# upgrade only install files from the list
			if [ -n "$pkg_files" ] ; then
				#sudocmd rpm -Fvh $pkg_files
				(pkg_files=$pkg_files force="$force -F" epm_install)
				return
			elif [ -n "$pkg_names" ] ; then
				# hack for https://bugzilla.altlinux.org/41225
				case "$pkg_names" in
					-*)
						fatal "Option $pkg_names is not allowed here"
				esac
				(pkg_names=$(get_only_installed_packages $pkg_names) epm_install)
				return
			fi
		;;
	esac

	case $PMTYPE in
	apt-rpm|apt-dpkg)
		local APTOPTIONS="$(subst_option non_interactive -y) $(subst_option verbose "-o Debug::pkgMarkInstall=1 -o Debug::pkgProblemResolver=1")"
		CMD="apt-get $APTOPTIONS $noremove $force_yes dist-upgrade"
		;;
	aptitude-dpkg)
		CMD="aptitude dist-upgrade"
		;;
	packagekit)
		docmd pkcon update
		return
		;;
	yum-rpm)
		local OPTIONS="$(subst_option non_interactive -y)"
		# can do update repobase automagically
		CMD="yum $OPTIONS update $*"
		;;
	dnf-rpm)
		local OPTIONS="$(subst_option non_interactive -y)"
		CMD="dnf $OPTIONS distro-sync $*"
		;;
	snappy)
		CMD="snappy update"
		;;
	urpm-rpm)
		# or --auto-select --replace-files
		CMD="urpmi --update --auto-select $*"
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
	opkg)
		CMD="opkg upgrade"
		;;
	slackpkg)
		CMD="/usr/sbin/slackpkg upgrade-all"
		;;
	guix)
		CMD="guix package -u"
		;;
	appget|winget)
		CMD="$PMTYPE update-all"
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

	sudocmd $CMD "$@"

}

# File bin/epm-Upgrade:


epm_Upgrade()
{
	epm_update
	epm_upgrade "$@"
}

# File bin/epm-whatdepends:



epm_whatdepends()
{
	local CMD
	[ -n "$pkg_files" ] && fatal "whatdepends does not handle files"
	[ -n "$pkg_names" ] || fatal "whatdepends: package name is missed"
	local pkg=$(print_name $pkg_names)

case $PMTYPE in
	apt-rpm)
		if [ -z "$verbose" ] ; then
			showcmd apt-cache whatdepends $pkg
			if [ -n "$short" ] ; then
				a= apt-cache whatdepends $pkg | grep "^  [^ ]" | sed -e "s|[0-9]*:||" | grep -E -v "(i586-|-debuginfo)" | sed -e 's|[@:].*||' -e "s|-[0-9].*||g" -e 's|^ *||' -e 's/\.32bit//g'
			else
				a= apt-cache whatdepends $pkg | grep "^  [^ ]" | sed -e "s|[0-9]*:||" | grep -E -v "(i586-|-debuginfo)"
			fi
			return
		fi
		CMD="apt-cache whatdepends"
		;;
	apt-dpkg|aptitude-dpkg)
		CMD="apt-cache rdepends"
		;;
	aptitude-dpkg)
		CMD="aptitude why"
		;;
	packagekit)
		CMD="pkcon depends-on"
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
	homebrew)
		CMD="brew uses"
		;;
	pkgng)
		CMD="pkg info -r"
		;;
	aptcyg)
		CMD="apt-cyg rdepends"
		;;
	opkg)
		CMD="opkg whatdepends"
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
	[ -n "$pkg_names" ] || fatal "whatprovides: package name is missed"
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
	opkg)
		CMD="opkg whatprovides"
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
# 2007-2022 (c) Vitaly Lipatov <lav@etersoft.ru>
# 2007-2022 (c) Etersoft
# 2007-2022 Public domain

# You can set ROOTDIR to root system dir
#ROOTDIR=

PROGVERSION="20220713"

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
	which "$1" 2>/dev/null >/dev/null
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

override_distrib()
{
	[ -n "$1" ] || return
	VENDOR_ID=''
	DISTRIB_ID="$(echo "$1" | sed -e 's|/.*||')"
	DISTRIB_RELEASE="$(echo "$1" | sed -e 's|.*/||')"
}

# Translate DISTRIB_ID to vendor name (like %_vendor does or package release name uses), uses VENDOR_ID by default
pkgvendor()
{
	[ "$DISTRIB_ID" = "ALTLinux" ] && echo "alt" && return
	[ "$DISTRIB_ID" = "ALTServer" ] && echo "alt" && return
	[ "$DISTRIB_ID" = "AstraLinux" ] && echo "astra" && return
	[ "$DISTRIB_ID" = "LinuxXP" ] && echo "lxp" && return
	[ "$DISTRIB_ID" = "TinyCoreLinux" ] && echo "tcl" && return
	[ "$DISTRIB_ID" = "VoidLinux" ] && echo "void" && return
	[ "$DISTRIB_ID" = "OpenSUSE" ] && echo "suse" && return
	[ "$DISTRIB_ID" = "openSUSETumbleweed" ] && echo "suse" && return
	[ "$DISTRIB_ID" = "openSUSELeap" ] && echo "suse" && return
	if [ -n "$VENDOR_ID" ] ; then
		[ "$VENDOR_ID" = "altlinux" ] && echo "alt" && return
		echo "$VENDOR_ID"
		return
	fi
	tolower "$DISTRIB_ID"
}

# TODO: in more appropriate way
#which pkcon 2>/dev/null >/dev/null && info "You can run $ PMTYPE=packagekit epm to use packagekit backend"

# Print package manager (need DISTRIB_ID var)
pkgmanager()
{
local CMD
# FIXME: some problems with multibased distros (Server Edition on CentOS and Desktop Edition on Ubuntu)
case $DISTRIB_ID in
	ALTLinux|ALTServer)
		#which ds-install 2>/dev/null >/dev/null && CMD=deepsolver-rpm
		#which pkcon 2>/dev/null >/dev/null && CMD=packagekit-rpm
		CMD="apt-rpm"
		;;
	ALTServer)
		CMD="apt-rpm"
		;;
	PCLinux)
		CMD="apt-rpm"
		;;
	Ubuntu|Debian|Mint|AstraLinux|Elbrus)
		CMD="apt-dpkg"
		#which aptitude 2>/dev/null >/dev/null && CMD=aptitude-dpkg
		hascommand snappy && CMD=snappy
		;;
	Mandriva)
		CMD="urpm-rpm"
		;;
	ROSA)
		CMD="dnf-rpm"
		hascommand dnf || CMD="yum-rpm"
		[ "$DISTRIB_ID/$DISTRIB_RELEASE" = "ROSA/7" ] && CMD="yum-rpm"
		[ "$DISTRIB_ID/$DISTRIB_RELEASE" = "ROSA/2020" ] && CMD="urpm-rpm"
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
	Fedora|CentOS|OracleLinux|RockyLinux|AlmaLinux|RHEL|Scientific|GosLinux|Amzn|RedOS)
		CMD="dnf-rpm"
		hascommand dnf || CMD="yum-rpm"
		[ "$DISTRIB_ID/$DISTRIB_RELEASE" = "CentOS/7" ] && CMD="yum-rpm"
		;;
	Slackware)
		CMD="slackpkg"
		;;
	SUSE|SLED|SLES|openSUSETumbleweed|openSUSELeap)
		CMD="zypper-rpm"
		;;
	ForesightLinux|rPathLinux)
		CMD="conary"
		;;
	Windows)
		CMD="appget"
		hascommand $CMD || CMD="chocolatey"
		hascommand $CMD || CMD="winget"
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
		# try detect firstly
		if hascommand "rpm" ; then
			hascommand "zypper" && echo "zypper-rpm" && return
			hascommand "apt-get" && echo "apt-rpm" && return
			hascommand "dnf" && echo "dnf-rpm" && return
			hascommand "yum" && echo "yum-rpm" && return
			hascommand "urpmi" && echo "urpmi-rpm" && return
		fi
		if hascommand "dpkg" ; then
			hascommand "apt" && echo "apt-dpkg" && return
			hascommand "apt-get" && echo "apt-dpkg" && return
		fi
		echo "We don't support yet DISTRIB_ID $DISTRIB_ID" >&2
		;;
esac
echo "$CMD"
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
		*)
			case $(pkgmanager) in
				*-dpkg)
					echo "deb" ;;
				*-rpm)
					echo "rpm" ;;
				*)
					echo "rpm" ;;
			esac
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

normalize_name()
{
	case "$1" in
		"RED OS")
			echo "RedOS"
			;;
		"CentOS Linux")
			echo "CentOS"
			;;
		"Fedora Linux")
			echo "Fedora"
			;;
		"RedHatEnterpriseLinuxServer")
			echo "RHEL"
			;;
		"ROSA Enterprise Linux Desktop"|"ROSA Enterprise Linux Server")
			echo "ROSA"
			;;
		*)
			#echo "${1// /}"
			echo "$1" | sed -e "s/ //g"
			;;
	esac
}

fill_distr_info()
{
# Default values
PRETTY_NAME=""
DISTRIB_ID=""
DISTRIB_RELEASE=""
DISTRIB_CODENAME=""

# Next default by /etc/os-release
# https://www.freedesktop.org/software/systemd/man/os-release.html
if distro os-release ; then
	# shellcheck disable=SC1090
	. $DISTROFILE
	DISTRIB_ID="$(normalize_name "$NAME")"
#	DISTRIB_ID="$(firstupper "$ID")"
	DISTRIB_RELEASE="$VERSION_ID"
	[ -n "$DISTRIB_RELEASE" ] || DISTRIB_RELEASE="CUR"
	# set by os-release:
	#PRETTY_NAME
	VENDOR_ID="$ID"
	DISTRIB_FULL_RELEASE=$DISTRIB_RELEASE
	DISTRIB_RELEASE=$(echo $DISTRIB_RELEASE | sed -e "s/\.[0-9]$//g")
elif distro lsb-release ; then
	DISTRIB_ID=$(cat $DISTROFILE | get_var DISTRIB_ID)
	DISTRIB_RELEASE=$(cat $DISTROFILE | get_var DISTRIB_RELEASE)
	DISTRIB_CODENAME=$(cat $DISTROFILE | get_var DISTRIB_CODENAME)
	PRETTY_NAME=$(cat $DISTROFILE | get_var DISTRIB_DESCRIPTION)
fi

# TODO:
#if [ -n "$DISTRIB_ID" ] ; then
#	# don't check obsoleted ways
#	;
# ALT Linux based
if distro altlinux-release ; then
	DISTRIB_ID="ALTLinux"
	# FIXME: fast hack for fallback: 10 -> p10 for /etc/os-release
	DISTRIB_RELEASE="$(echo p$DISTRIB_RELEASE | sed -e 's|\..*||' -e 's|^pp|p|')"
	if has Sisyphus ; then DISTRIB_RELEASE="Sisyphus"
	elif has "ALT p10.* p10 " ; then DISTRIB_RELEASE="p10"
	elif has "ALTServer 10." ; then DISTRIB_RELEASE="p10"
	elif has "ALTServer 9." ; then DISTRIB_RELEASE="p9"
	elif has "ALT c10.* c10 " ; then DISTRIB_RELEASE="c10"
	elif has "ALT p9.* p9 " ; then DISTRIB_RELEASE="p9"
	elif has "ALT 9 SP " ; then DISTRIB_RELEASE="c9"
	elif has "ALT c9f1" ; then DISTRIB_RELEASE="c9f1"
	elif has "ALT MED72 " ; then DISTRIB_RELEASE="p8"
	elif has "ALT 8 SP " ; then DISTRIB_RELEASE="c8"
	elif has "ALT c8.2 " ; then DISTRIB_RELEASE="c8.2"
	elif has "ALT c8.1 " ; then DISTRIB_RELEASE="c8.1"
	elif has "ALT c8 " ; then DISTRIB_RELEASE="c8"
	elif has "ALT .*8.[0-9]" ; then DISTRIB_RELEASE="p8"
	elif has "Simply Linux 10." ; then DISTRIB_RELEASE="p10"
	elif has "Simply Linux 9." ; then DISTRIB_RELEASE="p9"
	elif has "Simply Linux 8." ; then DISTRIB_RELEASE="p8"
	elif has "Simply Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "Simply Linux 6." ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p8"  ; then DISTRIB_RELEASE="p8"
	elif has "ALT Linux 8." ; then DISTRIB_RELEASE="p8"
	elif has "ALT Linux p7"  ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux 7." ; then DISTRIB_RELEASE="p7"
	elif has "ALT Linux t7." ; then DISTRIB_RELEASE="t7"
	elif has "ALT Linux 6." ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p6"  ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p5"  ; then DISTRIB_RELEASE="p5"
	elif has "ALT Linux 5.1" ; then DISTRIB_RELEASE="5.1"
	elif has "ALT Linux 5.0" ; then DISTRIB_RELEASE="5.0"
	elif has "ALT Linux 4.1" ; then DISTRIB_RELEASE="4.1"
	elif has "ALT Linux 4.0" ; then DISTRIB_RELEASE="4.0"
	elif has "starter kit"   ; then DISTRIB_RELEASE="Sisyphus"
	elif has Citron   ; then DISTRIB_RELEASE="2.4"
	fi
	PRETTY_NAME="$(cat /etc/altlinux-release)"

elif distro gentoo-release ; then
	DISTRIB_ID="Gentoo"
	MAKEPROFILE=$(readlink $ROOTDIR/etc/portage/make.profile 2>/dev/null) || MAKEPROFILE=$(readlink $ROOTDIR/etc/make.profile)
	DISTRIB_RELEASE=$(basename $MAKEPROFILE)
	echo $DISTRIB_RELEASE | grep -q "[0-9]" || DISTRIB_RELEASE=$(basename "$(dirname $MAKEPROFILE)") #"

elif [ "$DISTRIB_ID" = "ALTServer" ] ; then
	DISTRIB_RELEASE=$(echo $DISTRIB_RELEASE | sed -e "s/\..*//g")

elif [ "$DISTRIB_ID" = "ALTSPWorkstation" ] ; then
	DISTRIB_ID="ALTLinux"
	case "$DISTRIB_RELEASE" in
		8.0|8.1)
			;;
		8.*)
			DISTRIB_RELEASE="c9"
			;;
	esac
	DISTRIB_RELEASE=$(echo $DISTRIB_RELEASE | sed -e "s/\..*//g")

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

# TODO: use standart /etc/os-release or lsb
elif distro arch-release ; then
	DISTRIB_ID="ArchLinux"
	DISTRIB_RELEASE="rolling"

# Elbrus
elif distro mcst_version ; then
	DISTRIB_ID="MCST"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "release" | sed -e "s|.*release \([0-9]*\).*|\1|g") #"

# OpenWrt
elif distro openwrt_release ; then
	. $DISTROFILE
	DISTRIB_RELEASE=$(cat $ROOTDIR/etc/openwrt_version)

# for Ubuntu use standard LSB info
elif [ "$DISTRIB_ID" = "Ubuntu" ] && [ -n "$DISTRIB_RELEASE" ]; then
	# use LSB version
	true

elif distro astra_version ; then
	# use OS release
	DISTRIB_ID="$(echo "$DISTRIB_ID" | sed -e 's|(.*||')"
	DISTRIB_RELEASE="$VERSION_CODENAME"
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

# TODO: drop in favour of /etc/os-release
elif distro redhat-release && [ -z "$PRETTY_NAME" ] ; then
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
fi

[ -n "$DISTRIB_ID" ] || DISTRIB_ID="Generic"

if [ -z "$PRETTY_NAME" ] ; then
	PRETTY_NAME="$DISTRIB_ID $DISTRIB_RELEASE"
fi
}

fill_distr_info

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
    'arm64' | 'aarch64')
        DIST_ARCH='aarch64'
        ;;
    armv7*)
        # TODO: use uname only
        # uses binutils package
        if which readelf >/dev/null 2>/dev/null && [ -z "$(readelf -A /proc/self/exe | grep Tag_ABI_VFP_args)" ] ; then
            DIST_ARCH="armel"
        else
            DIST_ARCH="armhf"
        fi
        ;;
esac
echo "$DIST_ARCH"
}

get_debian_arch()
{
    local arch="$(get_arch)"
    case $arch in
    'x86')
        arch='i386' ;;
    'x86_64')
        arch='amd64' ;;
    'aarch64')
        arch='arm64' ;;
    esac
    echo "$arch"
}

get_distro_arch()
{
    local arch="$(get_arch)"
    case "$(pkgtype)" in
        rpm)
            case $arch in
            'x86')
                arch='i586' ;;
            esac
            ;;
        deb)
            get_debian_arch
            return
            ;;
    esac
    echo "$arch"
}

get_bit_size()
{
local DIST_BIT

DIST_BIT="$(getconf LONG_BIT 2>/dev/null)"
if [ -n "$DIST_BIT" ] ; then
    echo "$DIST_BIT"
    return
fi

# Try detect arch size by arch name
case "$(get_uname -m)" in
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

get_core_mhz()
{
    cat /proc/cpuinfo | grep "cpu MHz" | head -n1 | cut -d':' -f2 | cut -d' ' -f2 | cut -d'.' -f1
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

    if lscpu | grep "Hypervisor vendor:" | grep -q "KVM" ; then
        echo "kvm" && return
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
distro_info v$PROGVERSION : Copyright © 2007-2022 Etersoft
Total system information:
    Pretty distro name (--pretty): $(print_pretty_name)
     Distro name and version (-e): $(print_name_version)
     Package manager/type (-g/-p): $(pkgmanager) / $(pkgtype)
     Running service manager (-y): $(get_service_manager)
              Virtualization (-i): $(get_virt)
            CPU Cores/MHz (-c/-z): $(get_core_count) / $(get_core_mhz) MHz
            CPU Architecture (-a): $(get_arch)
     CPU norm register size  (-b): $(get_bit_size)
     System memory size (MB) (-m): $(get_memory_size)
                Base OS name (-o): $(get_base_os_name)
Base distro (vendor) name (-s|-n): $(pkgvendor)

(run with -h to get help)
EOF
}


case $1 in
	-h|--help)
		echo "distro_info v$PROGVERSION - distro information retriever"
		echo "Usage: distro_info [options] [args]"
		echo "Options:"
		echo " -a - print hardware architecture (--distro-arch for distro depended name)"
		echo " -b - print size of arch bit (32/64)"
		echo " -c - print number of CPU cores"
		echo " -z - print current CPU MHz"
		echo " -d - print distro name"
		echo " -e - print full name of distro with version"
		echo " -i - print virtualization type"
		echo " -h - this help"
		echo " -m - print system memory size (in MB)"
		echo " -o - print base OS name"
		echo " -p [SystemName] - print type of the packaging system"
		echo " -g [SystemName] - print name of the packaging system"
		echo " -s|-n [SystemName] - print base name of the distro (vendor name) (ubuntu for all Ubuntu family, alt for all ALT family) (as _vendor macros in rpm)"
		echo " -y - print running service manager"
		echo " --pretty - print pretty distro name"
		echo " -v - print version of distro"
		echo " -V - print the utility version"
		echo "Run without args to print all information."
		exit 0
		;;
	-p)
		override_distrib "$2"
		pkgtype
		exit 0
		;;
	-g)
		override_distrib "$2"
		pkgmanager
		exit 0
		;;
	--pretty)
		print_pretty_name
		;;
	--distro-arch)
		override_distrib "$2"
		get_distro_arch
		exit 0
		;;
	--debian-arch)
		override_distrib "$2"
		get_debian_arch
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
	-z)
		get_core_mhz
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
	-s|-n)
		override_distrib "$2"
		pkgvendor
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
# Use:
# eget http://ftp.altlinux.ru/pub/security/ssl/*
#
# Copyright (C) 2014-2014, 2016, 2020, 2022  Etersoft
# Copyright (C) 2014 Daniil Mikhailov <danil@etersoft.ru>
# Copyright (C) 2016-2017, 2020, 2022 Vitaly Lipatov <lav@etersoft.ru>
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

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

# TODO:
arch="$(uname -m)"

# copied from eepm project

# copied from /etc/init.d/outformat (ALT Linux)
isatty()
{
	# Set a sane TERM required for tput
	[ -n "$TERM" ] || TERM=dumb
	export TERM
	test -t 1
}

isatty2()
{
	# check stderr
	test -t 2
}


check_tty()
{
	isatty || return
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
    [ -n "$verbose" ] || return
    echo "$*" >&2
}

# Print command line and run command line
showcmd()
{
	if [ -z "$quiet" ] ; then
		set_boldcolor $GREEN
		local PROMTSIG="\$"
		[ "$UID" = 0 ] && PROMTSIG="#"
		echo " $PROMTSIG $@"
		restore_color
	fi >&2
}

# Print command line and run command line
docmd()
{
	showcmd "$@"
	"$@"
}

check_tty

WGETNOSSLCHECK=''
CURLNOSSLCHECK=''
WGETUSERAGENT=''
CURLUSERAGENT=''
WGETQ='' #-q
CURLQ='' #-s
WGETNAMEOPTIONS='--content-disposition'
CURLNAMEOPTIONS='--remote-name --remote-header-name'

set_quiet()
{
    WGETQ='-q'
    CURLQ='-s'
}

# TODO: parse options in a good way

# TODO: passthrou all wget options
if [ "$1" = "-q" ] ; then
    set_quiet
    shift
fi

if [ "$1" = "-k" ] || [ "$1" = "--no-check-certificate" ] ; then
    WGETNOSSLCHECK='--no-check-certificate'
    CURLNOSSLCHECK='-k'
    shift
fi

if [ "$1" = "-U" ] || [ "$1" = "-A" ] || [ "$1" = "--user-agent" ] ; then
    user_agent="Mozilla/5.0 (X11; Linux $arch)"
    WGETUSERAGENT="-U '$user_agent'"
    CURLUSERAGENT="-A '$user_agent'"
    shift
fi


WGET="$(which wget 2>/dev/null)"

if [ -n "$WGET" ] ; then
__wget()
{
    if [ -n "$WGETUSERAGENT" ] ; then
        docmd $WGET $WGETQ $WGETNOSSLCHECK "$WGETUSERAGENT" "$@"
    else
        docmd $WGET $WGETQ $WGETNOSSLCHECK "$@"
    fi
}
# put remote content to stdout
scat()
{
    __wget -O- "$1"
}
# download to default name of to $2
sget()
{
    if [ "$2" = "/dev/stdout" ] || [ "$2" = "-" ] ; then
       scat "$1"
    elif [ -n "$2" ] ; then
       docmd __wget -O "$2" "$1"
    else
# TODO: поддержка rsync для известных хостов?
# Не качать, если одинаковый размер и дата
# -nc
# TODO: overwrite always
       docmd __wget $WGETNAMEOPTIONS "$1"
    fi
}

else
CURL="$(which curl 2>/dev/null)"
[ -n "$CURL" ] || fatal "There are no wget nor curl in the system. Install it with $ epm install curl"
__curl()
{
    if [ -n "$CURLUSERAGENT" ] ; then
        docmd $CURL -L $CURLQ "$CURLUSERAGENT" $CURLNOSSLCHECK "$@"
    else
        docmd $CURL -L $CURLQ $CURLNOSSLCHECK "$@"
    fi
}
# put remote content to stdout
scat()
{
    __curl "$1"
}
# download to default name of to $2
sget()
{
    if [ "$2" = "/dev/stdout" ] || [ "$2" = "-" ] ; then
       scat "$1"
    elif [ -n "$2" ] ; then
       __curl --output "$2" "$1"
    else
       __curl $CURLNAMEOPTIONS "$1"
    fi
}
fi

LISTONLY=''
if [ "$1" = "--list" ] ; then
    LISTONLY="$1"
    set_quiet
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
    sort -V | tail -n1
}

# download to this file
TARGETFILE=''
if [ "$1" = "-O" ] ; then
    TARGETFILE="$2"
    shift 2
elif [ "$1" = "-O-" ] ; then
    TARGETFILE="-"
    shift 1
fi

# TODO:
# -P support

if [ -z "$1" ] ; then
    echo "eget - wget like downloader wrapper with wildcard support" >&2
    fatal "Run $0 --help to get help"
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    echo "eget - wget like downloader wrapper with wildcard support in filename part of URL"
    echo "Usage: eget [-q] [-k] [-U] [-O target file] [--list] http://somesite.ru/dir/na*.log"
    echo
    echo "Options:"
    echo "    -q       - quiet mode"
    echo "    -k|--no-check-certificate - skip SSL certificate chain support"
    echo "    -U|-A|--user-agent - send browser like UserAgent"
    echo "    -O file  - download to this file (use filename from server if missed)"
    echo "    --list   - print files from url with mask"
    echo "    --latest - print only latest version of a file"
    echo
    echo "eget supports --list and download for https://github.com/owner/project urls"
    echo
    echo "Examples:"
    echo "  $ eget --list http://ftp.somesite.ru/package-*.tar"
    echo "  $ eget http://ftp.somesite.ru/package-*.x64.tar"
    echo "  $ eget --list http://download.somesite.ru 'package-*.tar.xz'"
    echo "  $ eget --list --latest https://github.com/telegramdesktop/tdesktop/releases 'tsetup.*.tar.xz'"
#    echo "See $ wget --help for wget options you can use here"
    return
fi

get_github_urls()
{
    # https://github.com/OWNER/PROJECT
    local owner="$(echo "$1" | sed -e "s|^https://github.com/||" -e "s|/.*||")" #"
    local project="$(echo "$1" | sed -e "s|^https://github.com/$owner/||" -e "s|/.*||")" #"
    [ -n "$owner" ] || fatal "Can't get owner from $1"
    [ -n "$project" ] || fatal "Can't get project from $1"
    local URL="https://api.github.com/repos/$owner/$project/releases"
    scat $URL | \
        grep -i -o -E '"browser_download_url": "https://.*"' | cut -d'"' -f4
}

if echo "$1" | grep -q "^https://github.com/" && \
   echo "$1" | grep -q -v "/download/" && [ -n "$2" ] ; then
    MASK="$2"

    if [ -n "$LISTONLY" ] ; then
        get_github_urls "$1" | filter_glob "$MASK" | filter_order
        return
    fi

    for fn in $(get_github_urls "$1" | filter_glob "$MASK" | filter_order) ; do
        sget "$fn" || ERROR=1
    done
    return
fi


# do not support /
if echo "$1" | grep -q "/$" && [ -z "$2" ] ; then
    fatal "Use http://example.com/e/* to download all files in dir"
fi

# TODO: curl?
# If ftp protocol, just download
if echo "$1" | grep -q "^ftp://" ; then
    [ -n "$LISTONLY" ] && fatal "TODO: list files for ftp:// do not supported yet"
    sget "$1" "$TARGETFILE"
    return
fi

# mask allowed only in the last part of path
MASK=$(basename "$1")

# if mask are second arg
if [ -n "$2" ] ; then
    URL="$1"
    MASK="$2"
else
    # drop mask part
    URL="$(dirname "$1")"
fi

if echo "$URL" | grep -q "[*?]" ; then
    fatal "Error: there are globbing symbols (*?) in $URL"
fi

# If have no wildcard symbol like asterisk, just download
if echo "$MASK" | grep -qv "[*?]" || echo "$MASK" | grep -q "[?].*="; then
    sget "$1" "$TARGETFILE"
    return
fi

is_url()
{
    echo "$1" | grep -q "://"
}

get_urls()
{
    # cat html, divide to lines by tags and cut off hrefs only
    scat $URL | sed -e 's|<|<\n|g' | \
         grep -i -o -E 'href="(.+)"' | cut -d'"' -f2
}

if [ -n "$LISTONLY" ] ; then
    for fn in $(get_urls | filter_glob "$MASK" | filter_order) ; do
        is_url "$fn" && echo $fn && continue
        fn="$(echo "$fn" | sed -e 's|^./||' -e 's|^/+||')"
        echo "$URL/$fn"
    done
    return
fi

ERROR=0
for fn in $(get_urls | filter_glob "$MASK" | filter_order) ; do
    is_url "$fn" || fn="$URL/$(basename "$fn")"
    sget "$fn" || ERROR=1
done
 return $ERROR

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

is_empty()
{
        [ "$(strip_spaces "$*")" = "" ]
}

isempty()
{
        is_empty "$@"
}

has_space()
{
        # not for dash:
        # [ "$1" != "${1/ //}" ]
        [ "$(echo "$*" | sed -e "s| ||")" != "$*" ]
}

list()
{
        local i
        set -f
        for i in $@ ; do
                echo "$i"
        done
        set +f
}

count()
{
        set -f
        list $@ | wc -l
        set +f
}

union()
{
        set -f
        strip_spaces $(list $@ | sort -u)
        set +f
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
	echo "$*" | grep -E -q -- "$wd"
}


# remove_from_list "1." "11 12 21 22" -> "21 22"
reg_remove()
{
        local i
        local RES=
        set -f
        for i in $2 ; do
                echo "$i" | grep -q "^$1$" || RES="$RES $i"
        done
        set +f
        strip_spaces "$RES"
}

# remove_from_list "1." "11 12 21 22" -> "21 22"
reg_wordremove()
{
        local i
        local RES=""
        set -f
        for i in $2 ; do
                echo "$i" | grep -q -w "$1" || RES="$RES $i"
        done
        set +f
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
        set -f
        for i in $1 ; do
                RES="$(reg_rqremove "$i" "$RES")"
        done
        set +f
        strip_spaces "$RES"
}

# regexclude_list "22 1." "11 12 21 22" -> "21"
reg_exclude()
{
        local i
        local RES="$2"
        set -f
        for i in $1 ; do
                RES="$(reg_remove "$i" "$RES")"
        done
        set +f
        strip_spaces "$RES"
}

# regexclude_list "22 1." "11 12 21 22" -> "21"
reg_wordexclude()
{
        local i
        local RES="$2"
        set -f
        for i in $1 ; do
                RES=$(reg_wordremove "$i" "$RES")
        done
        set +f
        strip_spaces "$RES"
}

if_contain()
{
        local i
        set -f
        for i in $2 ; do
            [ "$i" = "$1" ] && return
        done
        set +f
        return 1
}

difference()
{
        local RES=""
        local i
        set -f
        for i in $1 ; do
            if_contain $i "$2" || RES="$RES $i"
        done
        for i in $2 ; do
            if_contain $i "$1" || RES="$RES $i"
        done
        set +f
        strip_spaces "$RES"
}


# FIXME:
# reg_include "1." "11 12 21 22" -> "11 12"
reg_include()
{
        local i
        local RES=""
        set -f
        for i in $2 ; do
                echo "$i" | grep -q -w "$1" && RES="$RES $i"
        done
        set +f
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
        echo "  isempty [string] (is_empty)       - true if string has no any symbols (only zero or more spaces)"
        echo "  has_space [string]                - true if string has no spaces"
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
if [ "$COMMAND" = "--" ] ; then
    # ignore all options (-)
    COMMAND="$1"
    shift
    "$COMMAND" "$@"
elif [ "$1" = "-" ] ; then
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

# compatibility
awk_egrep () {
  local pattern_string=$1

  a='' gawk '{
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


epm_main()
{

#PATH=$PATH:/sbin:/usr/sbin

set_pm_type

check_tty

#############################

phelp()
{
	echo "$Descr
$Usage

Options:
$(get_help HELPOPT)

Short commands:
$(get_help HELPSHORT)

$(get_help HELPCMD)

Examples:
    $ epmi etckeeper      install etckeeper package
    $ epmqp lib           print out all installed packages with 'lib' in a name
    $ epmqf ip            print out a package the command 'ip' from is
"
}

print_version()
{
        echo "EPM package manager version 3.19.4  https://wiki.etersoft.ru/Epm"
        echo "Running on $($DISTRVENDOR -e) ('$PMTYPE' package manager uses '$PKGFORMAT' package format)"
        echo "Copyright (c) Etersoft 2012-2021"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}


Usage="Usage: epm [options] <command> [package name(s), package files]..."
Descr="epm - EPM package manager"

EPMVERSION=3.19.4
verbose=$EPM_VERBOSE
quiet=
nodeps=
noremove=
dryrun=
force=
repack=
inscript=
scripts=
noscripts=
short=
direct=
sort=
non_interactive=
force_yes=
skip_installed=
skip_missed=
show_command_only=
epm_cmd=
pkg_files=
pkg_dirs=
pkg_names=
pkg_urls=
quoted_args=
direct_args=

# load system wide config
[ -f /etc/eepm/eepm.conf ] && . /etc/eepm/eepm.conf


case $PROGNAME in
    epmi)                      # HELPSHORT: alias for epm install
        epm_cmd=install
        ;;
    epmI)                      # HELPSHORT: alias for epm Install
        epm_cmd=Install
        ;;
    epme)                      # HELPSHORT: alias for epm remove
        epm_cmd=remove
        ;;
    epmcl)                     # HELPSHORT: alias for epm changelog
        epm_cmd=changelog
        ;;
    epms)                      # HELPSHORT: alias for epm search
        epm_cmd=search
        ;;
    epmsf)                     # HELPSHORT: alias for epm search file
        epm_cmd=search_file
        ;;
    epmwd)                     # HELPSHORT: alias for epm wd
        epm_cmd=whatdepends
        ;;
    epmq)                      # HELPSHORT: alias for epm query
        epm_cmd=query
        ;;
    epmqi)                     # HELPSHORT: alias for epm info
        epm_cmd=info
        ;;
    epmqf)                     # HELPSHORT: alias for epm belongs
        epm_cmd=query_file
        ;;
    epmqa)                     # HELPSHORT: alias for epm packages
        epm_cmd=packages
        ;;
    epmqp)                     # HELPSHORT: alias for epm qp (epm query package)
        epm_cmd=query_package
        ;;
    epmql)                     # HELPSHORT: alias for epm filelist
        epm_cmd=filelist
        ;;
    epmrl)                     # HELPSHORT: alias for epm repo list
        epm_cmd=repolist
        direct_args=1
        ;;
    epmu)                      # HELPSHORT: alias for epm update
        epm_cmd=update
        direct_args=1
        ;;
    epm|upm|eepm)              # HELPSHORT: other aliases for epm command
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

# HELPCMD: PART: Base commands:
    case $1 in
    -i|install|add|i)         # HELPCMD: install package(s) from remote repositories or from local file
        epm_cmd=install
        ;;
    -e|-P|rm|del|remove|delete|uninstall|erase|purge|e)  # HELPCMD: remove (delete) package(s) from the database and the system
        epm_cmd=remove
        ;;
    -s|search|s)                # HELPCMD: search in remote package repositories
        epm_cmd=search
        ;;
    -qp|qp|query_package)     # HELPCMD: search in the list of installed packages
        epm_cmd=query_package
        ;;
    -qf|qf|-S|wp|which|belongs)     # HELPCMD: query package(s) owning file
        epm_cmd=query_file
        ;;

# HELPCMD: PART: Useful commands:
    reinstall)                # HELPCMD: reinstall package(s) from remote repositories or from local file
        epm_cmd=reinstall
        ;;
    Install)                  # HELPCMD: perform update package repo info and install package(s) via install command
        epm_cmd=Install
        ;;
    -q|q|query)               # HELPCMD: check presence of package(s) and print this name (also --short is supported)
        epm_cmd=query
        ;;
    installed)                # HELPCMD: check presence of package(s) (like -q with --quiet)
        epm_cmd=installed
        ;;
    -sf|sf|filesearch)        # HELPCMD: search in which package a file is included
        epm_cmd=search_file
        ;;
    -ql|ql|filelist|get-files)          # HELPCMD: print package file list
        epm_cmd=filelist
        ;;
    check|fix|verify)         # HELPCMD: check local package base integrity and fix it
        epm_cmd=check
        direct_args=1
        ;;
    dedup)                    # HELPCMD: remove unallowed duplicated pkgs (after upgrade crash)
        epm_cmd=dedup
        direct_args=1
        ;;
    -cl|cl|changelog)         # HELPCMD: show changelog for package
        epm_cmd=changelog
        ;;
    -qi|qi|info|show)         # HELPCMD: print package detail info
        epm_cmd=info
        ;;
    requires|deplist|depends|req|depends-on)     # HELPCMD: print package requires
        epm_cmd=requires
        ;;
    provides|prov)            # HELPCMD: print package provides
        epm_cmd=provides
        ;;
    whatdepends|rdepends|whatrequires|wd|required-by)   # HELPCMD: print packages dependences on that
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
        direct_args=1
        ;;
    assure)                   # HELPCMD: <command> [package] [version]: install package if command does not exist
        epm_cmd=assure
        ;;
    policy|resolve)           # HELPCMD: print detailed information about the priority selection of package
        epm_cmd=policy
        ;;

# HELPCMD: PART: Repository control:
    update)                   # HELPCMD: update remote package repository databases
        epm_cmd=update
        direct_args=1
        ;;
    addrepo|ar)               # HELPCMD: add package repo (etersoft, autoimports, archive 2017/12/31); run with param to get list
        epm_cmd=addrepo
        direct_args=1
        ;;
    repolist|sl|rl|listrepo|repo-list)  # HELPCMD: print repo list
        epm_cmd=repolist
        direct_args=1
        ;;
    repofix)                  # HELPCMD: <mirror>: fix paths in sources lists (ALT Linux only). use repofix etersoft/yandex/basealt for rewrite URL to the specified server
        epm_cmd=repofix
        direct_args=1
        ;;
    removerepo|rr)            # HELPCMD: remove package repo (shortcut for epm repo remove)
        epm_cmd=removerepo
        direct_args=1
        ;;
    repo)                     # HELPCMD: manipulate with repository list (run epm repo --help to help)
        epm_cmd=repo
        direct_args=1
        ;;
    full-upgrade)              # HELPCMD: update all system packages and kernel
        epm_cmd=full_upgrade
        direct_args=1
        ;;
    release-upgrade|upgrade-release|upgrade-system|release-switch)  # HELPCMD: upgrade/switch whole system to the release in arg (default: next (latest) release)
        epm_cmd=release_upgrade
        direct_args=1
        ;;
    release-downgrade|downgrade-release|downgrade-system)           # HELPCMD: downgrade whole system to the release in arg (default: previuos release)
        epm_cmd=release_downgrade
        direct_args=1
        ;;
    kernel-update|kernel-upgrade|update-kernel|upgrade-kernel)      # HELPCMD: update system kernel to the last repo version
        epm_cmd=kernel_update
        direct_args=1
        ;;
    remove-old-kernels|remove-old-kernel)      # HELPCMD: remove old system kernels (exclude current or last two kernels)
        epm_cmd=remove_old_kernels
        direct_args=1
        ;;

# HELPCMD: PART: Other commands:
    clean)                    # HELPCMD: clean local package cache
        epm_cmd=clean
        direct_args=1
        ;;
    restore)                  # HELPCMD: install (restore) packages need for the project (f.i. by requirements.txt)
        epm_cmd=restore
        ;;
    autoremove|package-cleanup)   # HELPCMD: auto remove unneeded package(s) Supports args for ALT: [--direct [libs|python|perl|libs-devel]]
        epm_cmd=autoremove
        direct_args=1
        ;;
    mark)                     # HELPCMD: mark package as manually or automatically installed (see epm mark --help)
        epm_cmd=mark
        ;;
    autoorphans|--orphans)    # HELPCMD: remove all packages not from the repository
        epm_cmd=autoorphans
        ;;
    upgrade|dist-upgrade)     # HELPCMD: performs upgrades of package software distributions
        epm_cmd=upgrade
        ;;
    Upgrade)                  # HELPCMD: force update package base, then run upgrade
        epm_cmd=Upgrade
        direct_args=1
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
        direct_args=1
        ;;
    #checksystem)              # HELPCMD: check system for known errors (package management related)
    #    epm_cmd=checksystem
    #    direct_args=1
    #    ;;
    site|url)                 # HELPCMD: open package's site in a browser (use -p for open packages.altlinux.org site)
        epm_cmd=site
        ;;
    ei|ik|epminstall|epm-install|selfinstall) # HELPCMD: install package(s) from Korinf (eepm by default)
        epm_cmd=epm_install
        ;;
    print)                    # HELPCMD: print various info, run epm print help for details
        epm_cmd=print
        direct_args=1
        ;;
    tool)                     # HELPCMD: run embedded tool (f.i., epm tool eget)
        epm_cmd=tool
        direct_args=1
        ;;
    repack)                   # HELPCMD: repack rpm to local compatibility
        epm_cmd=repack
        ;;
    prescription|recipe)      # HELPCMD: run prescription (a script to achieving the goal), run without args to get list
        epm_cmd=prescription
        direct_args=1
        ;;
    play)                     # HELPCMD: install the application from the official site (run without args to get list)
        epm_cmd=play
        direct_args=1
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
        [ -n "$epm_cmd" ] && return 1
        print_version
        exit 0
        ;;
    --verbose)            # HELPOPT: verbose mode
        verbose="--verbose"
        ;;
    --skip-installed)     # HELPOPT: skip already installed packages during install
        skip_installed=1
        ;;
    --skip-missed)        # HELPOPT: skip not installed packages during remove
        skip_missed=1
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
    --no-stdin|--inscript)  # HELPOPT: don't read from stdin for epm args
        inscript=1
        ;;
    --dry-run|--simulate|--just-print|--no-act) # HELPOPT: print only (autoremove/autoorphans/remove only)
        dryrun="--dry-run"
        ;;
    --short)              # HELPOPT: short output (just 'package' instead 'package-version-release')
        short="--short"
        ;;
    --direct)              # HELPOPT: direct install package file from ftp (not via hilevel repository manager)
        direct="--direct"
        ;;
    --repack)              # HELPOPT: repack rpm package(s) before install
        repack="--repack"
        ;;
    --scripts)             # HELPOPT: include scripts in repacked rpm package(s) (see --repack or repacking when foreign package is installed)
        scripts="--scripts"
        ;;
    --noscripts)           # HELPOPT: disable scripts in install packages
        noscripts="--noscripts"
        ;;
    --sort)               # HELPOPT: sort output, f.i. --sort=size (supported only for packages command)
        # TODO: how to read arg?
        sort="$1"
        ;;
    --auto|--assumeyes|--non-interactive)  # HELPOPT: non interactive mode
        non_interactive="--auto"
        ;;
    --force-yes)           # HELPOPT: force yes in a danger cases (f.i., during release upgrade)
        force_yes="--force-yes"
        ;;
    *)
        return 1
        ;;
    esac
    return 0
}

# TODO: skip for commands where we don't need parse args

check_filenames()
{
    local opt
    for opt in "$@" ; do
        # files can be with full path or have extension via .
        if [ -f "$opt" ] && echo "$opt" | grep -q "[/\.]" ; then
            has_space "$opt" && warning "There are space(s) in filename '$opt', it is not supported. Skipped" && continue
            pkg_files="$pkg_files $opt"
        elif [ -d "$opt" ] ; then
            has_space "$opt" && warning "There are space(s) in directory path '$opt', it is not supported. Skipped" && continue
            pkg_dirs="$pkg_dirs $opt"
        elif echo "$opt" | grep -q "^[fhtps]*://" ; then
            has_space "$opt" && warning "There are space(s) in URL '$opt', it is not supported. Skipped" && continue
            pkg_urls="$pkg_urls $opt"
        else
            has_space "$opt" && warning "There are space(s) in package name '$opt', it is not supported. Skipped." && continue
            # TODO: don't add unknown options (like -y, --unknown) to pkg_names
            pkg_names="$pkg_names $opt"
        fi
        quoted_args="$quoted_args \"$opt\""
    done
}

# handle external EPM_OPTIONS
for opt in $EPM_OPTIONS ; do
        check_option "$opt"
done

FLAGENDOPTS=
# NOTE: can't use while read here: set vars inside
for opt in "$@" ; do

    [ "$opt" = "--" ] && FLAGENDOPTS=1 && continue

    if [ -z "$FLAGENDOPTS" ] ; then
        check_command "$opt" && continue
        check_option "$opt" && continue
    fi

    if [ -n "$direct_args" ] ; then
        quoted_args="$quoted_args \"$opt\""
    else
        # Note: will parse all params separately (no package names with spaces!)
        check_filenames "$opt"
    fi
done

# fill
export EPM_OPTIONS="$nodeps $force $non_interactive"

# if input is not console and run script from file, get pkgs from stdin too
if [ ! -n "$inscript" ] && ! inputisatty && [ -n "$PROGDIR" ] ; then
    for opt in $(withtimeout 10 cat) ; do
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
    echo "Run $ $PROGNAME --help  to get help." >&2
    echo "Run $ epm print info  to get some system and distro info." >&2
    fatal "$fatstr."
fi

# Use eatmydata for write specific operations
case $epm_cmd in
    update|upgrade|Upgrade|install|reinstall|Install|remove|autoremove|kernel_update|release_upgrade|release_downgrade|check)
        set_eatmydata
        ;;
esac

[ -n "$verbose$EPM_VERBOSE" ] && showcmd "$0 $*"

# Run helper for command with natural args
eval epm_$epm_cmd $quoted_args
# return last error code (from subroutine)
}
epm_main "$@"
