#!/usr/bin/env bash
#
# Copyright (C) 2012-2023  Etersoft
# Copyright (C) 2012-2023  Vitaly Lipatov <lav@etersoft.ru>
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
[ -n "$EPMCURDIR" ] || export EPMCURDIR="$(pwd)"
CMDENV="/usr/bin/env"
[ -x "$CMDENV" ] && CMDSHELL="/usr/bin/env bash" || CMDSHELL="$SHELL"
# TODO: pwd for ./epm and which for epm
[ "$PROGDIR" = "." ] && PROGDIR="$EPMCURDIR"
if [ "$0" = "/dev/stdin" ] || [ "$0" = "sh" ] ; then
    PROGDIR=""
    PROGNAME=""
fi

# will replaced with /usr/share/eepm during install
SHAREDIR=$PROGDIR
# will replaced with /etc/eepm during install
CONFIGDIR=$PROGDIR/../etc

EPMVERSION="3.62.0"

# package, single (file), pipe, git
EPMMODE="package"
[ "$SHAREDIR" = "$PROGDIR" ] && EPMMODE="single"
[ "$EPMVERSION" = "@""VERSION""@" ] && EPMMODE="git"
[ "$PROGNAME" = "" ] && EPMMODE="pipe"

if [ "$EPMMODE" = "git" ] ; then
    EPMVERSION=$(head $PROGDIR/../eepm.spec | grep "^Version: " | sed -e 's|Version: ||' )
fi

load_helper()
{
    local shieldname="loaded$(echo "$1" | sed -e 's|-||g')"
    # already loaded
    eval "[ -n \"\$$shieldname\" ]" && debug "Already loaded $1" && return

    local CMD="$SHAREDIR/$1"
    # do not use fatal() here, it can be initial state
    [ -r "$CMD" ] || { echo "FATAL: Have no $CMD helper file" ; exit 1; }
    eval "$shieldname=1"
    # shellcheck disable=SC1090
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

    check_core_commands

    # grep -E from busybox may not --color
    # grep -E from MacOS print help to stderr
    if grep -E --help 2>&1 | grep -q -- "--color" ; then
        export EGREPCOLOR="--color"
    fi

    is_command tput || return
    # FreeBSD does not support tput -S
    echo | a= tput -S >/dev/null 2>/dev/null || return
    USETTY="tput -S"
}

: ${BLACK:=0} ${RED:=1} ${GREEN:=2} ${YELLOW:=3} ${BLUE:=4} ${MAGENTA:=5} ${CYAN:=6} ${WHITE:=7}

set_boldcolor()
{
    [ -n "$USETTY" ] || return
    {
        echo bold
        echo setaf $1
    } | $USETTY
}

set_color()
{
    [ -n "$USETTY" ] || return
    {
        echo setaf $1
    } | $USETTY
}

restore_color()
{
    [ -n "$USETTY" ] || return
    {
        echo op; # set Original color Pair.
        echo sgr0; # turn off all special graphics mode (bold in our case).
    } | $USETTY
}

echover()
{
    [ -z "$verbose" ] && return
    echog "$*" >&2
}

echon()
{
    # default /bin/sh on MacOS does not recognize -n
    echo -n "$*" 2>/dev/null || a= /bin/echo -n "$*"
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

echocmd()
{
    set_boldcolor $GREEN
    local PROMTSIG="\$"
    is_root && PROMTSIG="#"
    echo -n "$PROMTSIG $*"
    restore_color
}

docmd()
{
    showcmd "$*$EXTRA_SHOWDOCMD"
    "$@"
}

docmd_foreach()
{
    local cmd pkg
    cmd="$1"
    #showcmd "$@"
    shift
    for pkg in "$@" ; do
        docmd $cmd $pkg
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

make_filepath()
{
    local i
    for i in "$@" ; do
        [ -f "$i" ] || continue
        echo "$i" | grep -q "/" && echo "$i" && continue
        echo "./$i"
    done
}

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

rihas()
{
    echo "$1" | grep -E -i -q -- "$2"
}

startwith()
{
    # rhas "$1" "^$2"
    [[ "$1" = ${2}* ]]
}

is_abs_path()
{
    #echo "$1" | grep -q "^/"
    startwith "$1" "/"
}

is_dirpath()
{
    [ "$1" = "." ] && return $?
    # rhas "$1" "/"
    startwith "$1" "/"
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


sed_escape()
{
    echo "$*" | sed -e 's/[]()$*.^|[]/\\&/g'
}


subst_option()
{
    eval "[ -n \"\$$1\" ]" && echo "$2" || echo "$3"
}

store_output()
{
    # use make_temp_file from etersoft-build-utils
    RC_STDOUT="$(mktemp)" || fatal
    remove_on_exit $RC_STDOUT
    local CMDSTATUS=$RC_STDOUT.pipestatus
    echo 1 >$CMDSTATUS
    #RC_STDERR=$(mktemp)
    ( LC_ALL=C $@ 2>&1 ; echo $? >$CMDSTATUS ) | tee $RC_STDOUT
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
    if [ "$EPMMODE" = "pipe" ] ; then
        epm_main --inscript "$@"
        return
    fi

    # run epm again to full initialization
    local bashopt=''
    [ -n "$debug" ] && bashopt='-x'

    $CMDSHELL $bashopt $PROGDIR/$PROGNAME --inscript "$@"
}

sudoepm()
{
    [ "$EPMMODE" = "pipe" ] && fatal "Can't use sudo epm call from the piped script"

    local bashopt=''
    [ -n "$debug" ] && bashopt='-x'

    sudorun $CMDSHELL $bashopt $PROGDIR/$PROGNAME --inscript "$@"
}

echog()
{
	if [ "$1" = "-n" ] ; then
		shift
		eval_gettext "$*"
	else
		eval_gettext "$*"; echo
	fi
}


fatal()
{
    local PROMOMESSAGE="$EPMPROMOMESSAGE"
    [ -n "$PROMOMESSAGE" ] || PROMOMESSAGE=" (you can discuss the epm $EPMVERSION problem in Telegram: https://t.me/useepm)"

    set_color $RED >&2
    echog -n "ERROR: " >&2
    restore_color >&2
    echog "$* $PROMOMESSAGE" >&2
    exit 1
}

debug()
{
    [ -n "$debug" ] || return

    set_color $YELLOW >&2
    echog -n "WARNING: " >&2
    restore_color >&2
    echog "$*" >&2
}


warning()
{
    set_color $YELLOW >&2
    echog -n "WARNING: " >&2
    restore_color >&2
    echog "$*" >&2
}

info()
{
    [ -n "$quiet" ] && return

    # print message to stderr if stderr forwarded to (a file)
    if isatty2 ; then
        isatty || return 0
        echog "$*"
    else
        echog "$*" >&2
    fi
}


check_su_root()
{
    [ "$BASEDISTRNAME" = "alt" ] || return 0

    is_root || return 0

    echo "$PATH" | grep -q "/usr/sbin" && return 0

    fatal "There is missed /usr/sbin path in PATH. Probably you have used 'su' without '-' to get root access. Use 'esu' or 'su -' command to get root permissions."
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

    check_su_root

    # if we are root, do not need sudo
    is_root && return

    # start error section
    SUDO_TESTED="1"

    if ! is_command $SUDO_CMD ; then
        [ "$nofail" = "nofail" ] || SUDO="fatal 'For this operation run epm under root, or install and tune sudo (http://altlinux.org/sudo)'"
        SUDO_TESTED="2"
        return "$SUDO_TESTED"
    fi

    # if input is a console
    if inputisatty && isatty && isatty2 ; then
        if ! $SUDO_CMD -n true ; then
            info "Please enter sudo user password to use sudo in the current session."
            if ! $SUDO_CMD -l >/dev/null ; then
                [ "$nofail" = "nofail" ] || SUDO="fatal 'For this operation run epm under root, or install and tune sudo (http://altlinux.org/sudo)'"
                SUDO_TESTED="3"
                return "$SUDO_TESTED"
            fi
        fi
    else
        # use sudo if one is tuned and tuned without password
        # hack: check twice
        $SUDO_CMD -l -n >/dev/null 2>/dev/null
        if ! $SUDO_CMD -l -n >/dev/null 2>/dev/null ; then
            [ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only passwordless sudo is supported here). Please run epm under root or check http://altlinux.org/sudo '"
            SUDO_TESTED="4"
            return "$SUDO_TESTED"
        fi
    fi

    SUDO_TESTED="0"
    # FIXME: does not work: sudo -- VARIABLE=some command
    SUDO="$SUDO_CMD"
    #SUDO="$SUDO_CMD --"
    # check for < 1.7 version which do not support -- (and --help possible too)
    #$SUDO_CMD -h 2>/dev/null | grep -q "  --" || SUDO="$SUDO_CMD"

}

sudo_allowed()
{
    set_sudo nofail
}

withtimeout()
{
    local TO=$(print_command_path timeout || print_command_path gtimeout)
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
    # don't use eatmydata (useless)
    return 0
    # skip if disabled
    [ -n "$EPMNOEATMYDATA" ] && return
    # use if possible
    is_command eatmydata || return
    set_sudo
    # FIXME: check if SUDO already has eatmydata
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

check_su_access()
{
    is_command su && return
    [ ! -f /bin/su ] && warning "/bin/su is missed. Try install su package (http://altlinux.org/su)." && return 1
    local group="$(stat -c '%G' /bin/su)" || fatal
    warning "Check if you are in $group group to have access to su command."
    return 1
}

check_sudo_access()
{
    is_command sudo && return
    local cmd=''
    local i
    for i in /bin/sudo /usr/bin/sudo ; do
        [ -f $i ] && cmd="$i"
    done
    [ ! -f "$cmd" ] && warning "sudo command is missed. Try install sudo package (http://altlinux.org/sudo)." && return 1
    local group="$(stat -c '%G' "$cmd")" || fatal
    warning "Check if you are in $group group to have access to sudo command."
    return 1
}

check_sudo_access_only()
{
    is_command sudo && return
    local cmd=''
    local i
    for i in /bin/sudo /usr/bin/sudo ; do
        [ -f $i ] && cmd="$i"
    done
    [ ! -f "$cmd" ] && return 1
    local group="$(stat -c '%G' "$cmd")" || fatal
    warning "sudo command is presence, but is not accessible for you. Check if you are in $group group to have access to sudo command."
    return 1
}

esu()
{
    if is_root ; then
        if [ -n "$*" ] ; then
            [ -n "$quiet" ] || showcmd "$*"
            exec "$@"
        else
            # just shell
            showcmd "su -"
            a= exec su -
        fi
    fi

    set_pm_type



    escape_args()
    {
        local output=''
        while [ -n "$1" ] ; do
            if has_space "$1" ; then
                [ -n "$output" ] && output="$output '$1'" || output="'$1'"
            else
                [ -n "$output" ] && output="$output $1" || output="$1"
            fi
            shift
        done
        echo "$output"
    }

    escaped="$(escape_args "$@")"

    check_sudo_access_only
    # sudo is not accessible, will ask root password
    if ! set_sudo ; then
        check_su_access
        #info "Enter root password:"
        if [ -n "$*" ] ; then
            [ -n "$quiet" ] || showcmd "su - -c $escaped"
            a= exec su - -c "$escaped"
        else
            # just shell
            showcmd "su -"
            a= exec su -
        fi
    fi

    check_sudo_access

    #info "You can be asked about your password:"
    if [ -n "$*" ] ; then
        [ -n "$quiet" ] || showcmd "$SUDO su - -c $escaped"
        $SUDO su - -c "$escaped"
    else
        showcmd "$SUDO su -"
        $SUDO su -
    fi
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
    [ -n "$package" ] || package="$(__get_package_for_command "$1")"

    # ask for install: https://bugzilla.altlinux.org/42240
    local ask=''
    [ -n "$non_interactive" ] || ask=1

    ( verbose='' direct='' interactive=$ask epm_assure "$1" $package $3 ) || fatal
}

assure_exists_erc()
{
    local package="erc"
    ( direct='' epm_assure "$package" ) || epm ei erc || fatal "erc is not available to install."
}

disabled_eget()
{
    # use internal eget only if exists
    if [ -s $SHAREDIR/tools_eget ] ; then
        ( EGET_BACKEND=$eget_backend $CMDSHELL $SHAREDIR/tools_eget "$@" )
        return
    fi
    fatal "Internal error: missed tools_eget"

    local EGET
    # FIXME: we need disable output here, eget can be used for get output
    assure_exists eget eget 3.3 >/dev/null
    # run external command, not the function
    EGET=$(print_command_path eget) || fatal "Missed command eget from installed package eget"
    $EGET "$@"
}


__epm_assure_7zip()
{
    # install 7zip in any case (can be used)
    if is_command 7z || is_command 7za || is_command 7zr || is_command 7zz ; then
        :
    else
        epm install 7-zip || epm install p7zip
    fi
}

disabled_erc()
{

    __epm_assure_7zip

    # use internal eget only if exists
    if [ -s $SHAREDIR/tools_erc ] ; then
        $CMDSHELL $SHAREDIR/tools_erc "$@"
        return
    fi
    fatal "Internal error: missed tools_erc"

    # FIXME: we need disable output here, ercat can be used for get output
    assure_exists_erc >/dev/null
    # run external command, not the function
    local ERC
    ERC=$(print_command_path erc) || fatal "Missed command erc from installed package erc"
    $ERC "$@"
}

disabled_ercat()
{
    local ERCAT
    # use internal eget only if exists
    if [ -s $SHAREDIR/tools_ercat ] ; then
        $CMDSHELL $SHAREDIR/tools_ercat "$@"
        return
    fi
    fatal "Internal error: missed tools_ercat"

    # FIXME: we need disable output here, ercat can be used for get output
    assure_exists_erc >/dev/null
    # run external command, not the function
    ERCAT=$(print_command_path ercat) || fatal "Missed command ercat from installed package erc"
    $ERCAT "$@"
}

disabled_estrlist()
{
    if [ -s $SHAREDIR/tools_estrlist ] ; then
        $CMDSHELL $SHAREDIR/tools_estrlist "$@"
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
    # check for both
    # we really need that cross here,
    is_command curl || assure_exists wget
    is_command wget || assure_exists curl
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
        *.AppImage|*.appimage)
            echo "AppImage"
            return
            ;;
        *)
            if [ -r "$1" ] && file -L "$1" | grep -q " ELF " ; then
                echo "ELF"
                return
            fi
            # print extension by default
            basename "$1" | sed -e 's|.*\.||'
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

set_bigtmpdir()
{
    # TODO: improve BIGTMPDIR conception
    # https://bugzilla.mozilla.org/show_bug.cgi?id=69938
    # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s15.html
    # https://geekpeach.net/ru/%D0%BA%D0%B0%D0%BA-systemd-tmpfiles-%D0%BE%D1%87%D0%B8%D1%89%D0%B0%D0%B5%D1%82-tmp-%D0%B8%D0%BB%D0%B8-var-tmp-%D0%B7%D0%B0%D0%BC%D0%B5%D0%BD%D0%B0-tmpwatch-%D0%B2-centos-rhel-7
    if [ -z "$BIGTMPDIR" ] ; then
        BIGTMPDIR="/var/tmp"
        [ -d "$BIGTMPDIR" ] || BIGTMPDIR="$TMPDIR"
    fi
    export BIGTMPDIR
}

assure_tmpdir()
{
    if [ -z "$TMPDIR" ] ; then
        export TMPDIR="/tmp"
        debug "Your have no TMPDIR defined. Using $TMPDIR as fallback."
    fi

    if [ ! -d "$TMPDIR" ] ; then
        fatal "TMPDIR $TMPDIR does not exist."
    fi

    if [ ! -w "$TMPDIR" ] ; then
        fatal "TMPDIR $TMPDIR is not writable."
    fi
}

test_shell()
{
    local R
    R="$($CMDSHELL /dev/null 2>&1)"
    [ -n "$R" ] && fatal "$CMDSHELL is broken (bash wrongly printing out '$R'). Check ~/.bashrc and /etc/bashrc, run $CMDSHELL manually for test."
}


set_distro_info()
{

    test_shell

    assure_tmpdir

    set_bigtmpdir

    # don't run again in subprocesses
    [ -n "$DISTRVENDOR" ] && return 0

    DISTRVENDOR=internal_distr_info

    # export pack of variables, see epm print info --print-eepm-env
    [ -n "$verbose" ] && $DISTRVENDOR --print-eepm-env
    eval $($DISTRVENDOR --print-eepm-env | grep -v '^ *#')
}

set_pm_type()
{
    local CMD
    set_distro_info

if [ -n "$EPM_BACKEND" ] ; then
    PMTYPE=$EPM_BACKEND
    return
fi
if [ -n "$FORCEPM" ] ; then
    PMTYPE=$FORCEPM
    return
fi

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
   [ -n "$pkgtype" ] || pkgtype="$PKGFORMAT"

   [ "$pkgtype" = "deb" ] && echo "_" && return
   echo "-"
}

__epm_remove_tmp_files()
{
    trap "-" EXIT
    [ -n "$DEBUG" ] && return 0

    [ -n "$verbose" ] && info "Removing tmp files on exit ..."

    if [ -n "$to_clean_tmp_dirs" ] ; then
        echo "$to_clean_tmp_dirs" | while read p ; do
            [ -n "$verbose" ] && echo "rm -rf '$p'"
            rm -rf "$p" 2>/dev/null
        done
    fi

    if [ -n "$to_clean_tmp_files" ] ; then
        echo "$to_clean_tmp_files" | while read p ; do
            rm $verbose -f "$p" 2>/dev/null
        done
    fi

    return 0
}


remove_on_exit()
{
    if [ -z "$set_remove_on_exit" ] ; then
        trap "__epm_remove_tmp_files" EXIT
        set_remove_on_exit=1
    fi
    while [ -n "$1" ] ; do
        if [ -d "$1" ] ; then
            to_clean_tmp_dirs="$to_clean_tmp_dirs
$1"
        elif [ -f "$1" ] ; then
            to_clean_tmp_files="$to_clean_tmp_files
$1"
        fi
        shift
    done
}

has_space()
{
        # not for dash:
        [ "$1" != "${1/ //}" ]
        # [ "$(echo "$*" | sed -e "s| ||")" != "$*" ]
}


is_url()
{
    echo "$1" | grep -q "^[filehtps]*:/"
}

if a= type -a type 2>/dev/null >/dev/null ; then
print_command_path()
{
    a= type -fpP -- "$1" 2>/dev/null
}
elif a= which which 2>/dev/null >/dev/null ; then
    # the best case if we have which command (other ways needs checking)
    # TODO: don't use which at all, it is a binary, not builtin shell command
print_command_path()
{
    a= which -- "$1" 2>/dev/null
}
else
print_command_path()
{
    a= type "$1" 2>/dev/null | sed -e 's|.* /|/|'
}
fi

is_command()
{
    print_command_path "$1" >/dev/null
}


if ! is_command realpath ; then
realpath()
{
    [ -n "$*" ] || return
    if [ "$1" = "-s" ] ; then
        shift
        echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")" #"
        return
    fi
    readlink -f "$@"
}
fi



if ! is_command subst ; then
subst()
{
    sed -i -e "$@"
}
fi

check_core_commands()
{
    #which which >/dev/null || fatal "Can't find which command (which or debianutils package is missed?)"
    is_command grep || fatal "Can't find grep command (coreutils package is missed?)"
    is_command sed || fatal "Can't find sed command (sed package is missed?)"
}

export TEXTDOMAIN=eepm
if [ "$EPMMODE" = "git" ] ; then
    TEXTDOMAINDIR=$PROGDIR/../po
else
    TEXTDOMAINDIR='/usr/share/locale'
fi
export TEXTDOMAINDIR

if [ -d "$TEXTDOMAINDIR" ] && is_command gettext.sh ; then
	. gettext.sh
else
	eval_gettext()
	{
		echo -n $@
	}
fi


# File bin/epm-addrepo:


ETERSOFTPUBURL=http://download.etersoft.ru/pub
ALTLINUXPUBURL=http://ftp.altlinux.org/pub/distributions

__epm_addrepo_rhel()
{
    local repo="$*"
    if [ -z "$repo" ] ; then
        echo "Add repo."
        echo "1. Use with repository URL, f.i. http://www.example.com/example.repo"
        echo "2. Use with epel to add EPEL repository"
        echo "3. Use with powertools to add PowerTools repository"
        echo "4. Use with crb to add Rocky Linux CRB repository"
        return 1
    fi
    case "$1" in
        epel)
            # dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
            epm install epel-release
            return 1
            ;;
        powertools)
            # https://serverfault.com/questions/997896/how-to-enable-powertools-repository-in-centos-8
            epm install --skip-installed dnf-plugins-core
            sudocmd dnf config-manager --set-enabled powertools
            return 1
            ;;
        crb)
            # https://wiki.rockylinux.org/rocky/repo/
            epm install --skip-installed dnf-plugins-core
            sudocmd dnf config-manager --set-enabled crb
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

    docmd epm repo add "rpm [etersoft] $ETERSOFTPUBURL/Etersoft LINUX@Etersoft/$pb/noarch addon"
    docmd epm repo add "rpm [etersoft] $ETERSOFTPUBURL/Etersoft LINUX@Etersoft/$pb/$DISTRARCH addon"
    if [ "$DISTRARCH" = "x86_64" ] ; then
        docmd epm repo add "rpm [etersoft] $ETERSOFTPUBURL/Etersoft LINUX@Etersoft/$pb/x86_64-i586 addon"
    fi
}

__epm_addrepo_altsp()
{
    local comp
    local repo="$1"
    case "$repo" in
        c10f1)
            comp="CF3"
            ;;
        c9f2)
            comp="CF2"
            ;;
        c9f1)
            comp="CF1"
            ;;
        c9)
            comp="cf"
            ;;
        *)
            fatal "Uknown CF comp $repo"
            ;;
    esac

    epm repo add "rpm [cert8] http://update.altsp.su/pub/distributions/ALTLinux $comp/branch/$DISTRARCH classic" || return
    if [ "$DISTRARCH" = "x86_64" ] ; then
        epm repo add "rpm [cert8] http://update.altsp.su/pub/distributions/ALTLinux $comp/branch/x86_64-i586 classic" || return
    fi
    epm repo add "rpm [cert8] http://update.altsp.su/pub/distributions/ALTLinux $comp/branch/noarch classic" || return
}

get_archlist()
{
    echo "noarch"
    echo "$DISTRARCH"
    case $DISTRARCH in
        x86_64)
            echo "i586"
            ;;
    esac
}

__epm_addrepo_altlinux_short()
{
    [ -n "$1" ] || fatal "only for rpm repo"
    local url="$2"
    local REPO_NAME="$3"
    local arch

    arch="$(basename "$url")"
    url="$(dirname "$url")"
    docmd epm repo add "rpm $url $arch $REPO_NAME"
}


__epm_addrepo_altlinux_url()
{
    local url="$1"
    local arch
    local base

    # URL to path/RPMS.addon
    base="$(basename "$url")"
    if echo "$base" | grep -q "^RPMS\." ; then
        REPO_NAME="$(echo $base | sed -e 's|.*\.||')"
        url="$(dirname $url)"
        __epm_addrepo_altlinux_short rpm "$url" "$REPO_NAME"
        return
    fi

    # TODO: add to eget file:/ support and use here
    # URL to path (where RPMS.addon is exists)
    local baseurl="$(eget --list "$url/RPMS.*")"
    base="$(basename "$baseurl")"
    if echo "$base" | grep -q "^RPMS\." ; then
        REPO_NAME="$(echo "$base" | sed -e 's|.*\.||')"
        __epm_addrepo_altlinux_short rpm "$url" "$REPO_NAME"
        return
    fi

    # URL to {i586,x86_64,noarch}/RPMS.addon
    local res=''
    for arch in $(get_archlist) ; do
        local rd="$(eget --list $url/$arch/RPMS.*)"
        [ -n "$rd" ] || continue
        local REPO_NAME="$(echo "$rd" | sed -e 's|/*$||' -e 's|.*\.||')"
        [ "$REPO_NAME" = "*" ] && continue
        docmd epm repo add "rpm $url $arch $REPO_NAME"
        res='1'
    done
    [ -n "$res" ] || warning "There is no arch repos in $url"
}


__epm_addrepo_altlinux_help()
{
    #sudocmd apt-repo $dryrun add branch
cat <<EOF

epm repo add - add branch repo. Use follow params:
    basealt                  - for BaseALT repo
    altsp                    - add ALT SP repo
    yandex                   - for BaseALT repo mirror hosted by Yandex (recommended)
    autoimports              - for BaseALT autoimports repo
    autoports                - for Autoports repo (with packages from Sisyphus rebuilt to the branch)
    altlinuxclub             - for altlinuxclub repo (http://altlinuxclub.ru/)
    deferred                 - for Etersoft Sisyphus Deferred repo
    deferred.org             - for Etersoft Sisyphus Deferred repo (at mirror.eterfund.org)
    etersoft                 - for LINUX@Etersoft repo
    korinf                   - for Korinf repo
    <task number>            - add task repo
    archive 2018/02/09       - add archive of the repo from that date
    /dir/to/repo [component] - add repo dir generated with epm repo index --init
    URL [arch] [component]   - add repo by URL

Examples:
    # epm repo add yandex
    # epm repo add "rpm http://somesite/pub/product x86_64 addon
    # epm repo add /var/ftp/pub/altlinux/p10

EOF
    return
}

__epm_addrepo_altlinux()
{
    local repo="$*"

    if [ -z "$repo" ] || [ "$repo" = "-h" ] || [ "$repo" = "--list" ] || [ "$repo" = "--help" ] ; then
        __epm_addrepo_altlinux_help
        return
    fi

    # 'rpm protocol:/path/to/repo component'
    if [ "$1" = "rpm" ] && [ -n "$2" ] && [ -n "$3" ] && [ -z "$4" ] ; then
        __epm_addrepo_altlinux_short "$@"
        return
    fi

    # /path/to/repo
    if [ -d "$1" ] ; then
        __epm_addrepo_altlinux_url "file:$1"
        return
    fi

    # file:/path/to/repo or http://path/to/repo
    if is_url "$1" ; then
        __epm_addrepo_altlinux_url "$1"
        return
    fi

    local branch="$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"
    [ -n "$branch" ] || fatal "Empty DISTRVERSION"

    case "$1" in
        etersoft)
            # TODO: return when Etersoft improved its repos
            #info "add Etersoft's addon repo"
            #__epm_addrepo_etersoft_addon
            epm repo add $branch
            epm repofix etersoft
            return 0
            ;;
        basealt|alt|altsp)
            repo="$branch"
            ;;
        yandex)
            epm repo add $branch
            epm repofix yandex
            return 0
            ;;
        autoimports)
            repo="autoimports.$branch"
            ;;
        autoports)
            local http="http"
            epm installed apt-https && http="https"
            case $branch in
                p10|p9|p8)
                    ;;
                *)
                    fatal "Autoports is not supported for $DISTRNAME $branch. Check https://www.altlinux.org/Autoports ."
                    ;;
            esac
            epm repo addkey cronbuild "DE73F3444C163CCD751AC483B584C633278EB305" "Cronbuild Service <cronbuild@altlinux.org>"
            epm repo add "rpm [cronbuild] $http://autoports.altlinux.org/pub ALTLinux/autoports/$DISTRVERSION/$DISTRARCH autoports"
            epm repo add "rpm [cronbuild] $http://autoports.altlinux.org/pub ALTLinux/autoports/$DISTRVERSION/noarch autoports"
            return 0
            ;;
        altlinuxclub)
            repo="altlinuxclub.$branch"
            ;;
        autoimports.*|altlinuxclub.*)
            repo="$1"
            ;;
        korinf)
            local http="http"
            epm installed apt-https && http="https"
            epm repo add "rpm $http://download.etersoft.ru/pub Korinf/ALTLinux/$DISTRVERSION main"
            return 0
            ;;
        deferred)
            [ "$DISTRVERSION" = "Sisyphus" ] || fatal "Etersot Sisyphus Deferred supported only for ALT Sisyphus."
            epm repo add "http://download.etersoft.ru/pub Etersoft/Sisyphus/Deferred"
            return 0
            ;;
        deferred.org)
            [ "$DISTRVERSION" = "Sisyphus" ] || fatal "Etersot Sisyphus Deferred supported only for ALT Sisyphus."
            epm repo add "http://mirror.eterfund.org/download.etersoft.ru/pub Etersoft/Sisyphus/Deferred"
            return 0
            ;;
        archive)
            datestr="$2"
            echo "$datestr" | grep -Eq "^20[0-2][0-9]/[01][0-9]/[0-3][0-9]$" || fatal "use follow date format: 2017/01/31"

            local rpmsign='[alt]'
            [ "$branch" != "sisyphus" ] && rpmsign="[$branch]"

            epm repo add "rpm $rpmsign $ALTLINUXPUBURL archive/$branch/date/$datestr/$DISTRARCH classic"
            if [ "$DISTRARCH" = "x86_64" ] ; then
                epm repo add "rpm $rpmsign $ALTLINUXPUBURL archive/$branch/date/$datestr/x86_64-i586 classic"
            fi
            epm repo add "rpm $rpmsign $ALTLINUXPUBURL archive/$branch/date/$datestr/noarch classic"

            return 0
            ;;
    esac

    assure_exists apt-repo

    if tasknumber "$repo" >/dev/null ; then
        sudocmd_foreach "apt-repo $dryrun add" $(tasknumber "$repo")
        return
    fi

    case "$repo" in
        c10f*|c9f*|c9)
            __epm_addrepo_altsp "$repo"
            return
            ;;
    esac

    if [ -z "$force" ] ; then
        # don't add again
        epm repo list --quiet | grep -q -F "$repo" && return 0
    fi

    if echo "$repo" | grep -q "https://" ; then
        local mh="$(echo /usr/lib*/apt/methods/https)"
        assure_exists $mh apt-https
    fi

    sudocmd apt-repo $dryrun add "$repo"

}


__epm_addrepo_astra()
{
    local repo="$*"

    if [ -z "$repo" ] || [ "$repo" = "--help" ]; then
        info "Add repo. You can use follow params:"
        echo "  distribution component name"
        echo "  full sources list line"
        echo "  URL version component"
        return
    fi

    local reponame="$(epm print info --repo-name)"

    # keywords
    # https://wiki.astralinux.ru/pages/viewpage.action?pageId=3276859
    case "$1-$reponame" in
        astra-1.7_x86-64)
            # TODO epm repo change http / https
            epm install --skip-installed apt-transport-https ca-certificates || fatal
            if epm repo list | grep "dl.astralinux.ru/astra/stable/1.7_x86-64" ; then
                fatal "Astra repo is already in the list"
            fi
            # https://wiki.astralinux.ru/pages/viewpage.action?pageId=158598882
            epm repo add "deb [arch-=i386] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main/     1.7_x86-64 main contrib non-free"
            epm repo add "deb [arch-=i386] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-update/   1.7_x86-64 main contrib non-free"
            epm repo add "deb [arch-=i386] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/     1.7_x86-64 main contrib non-free"
            epm repo add "deb [arch-=i386] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 main contrib non-free"
            epm repo add "deb [arch-=i386] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 astra-ce"
            return
            ;;
        astra-orel)
            # TODO epm repo change http / https
            epm install --skip-installed apt-transport-https ca-certificates || fatal
            # https://wiki.astralinux.ru/pages/viewpage.action?pageId=158605543
            epm repo add "deb [arch=amd64] https://dl.astralinux.ru/astra/frozen/$(epm print info -v)_x86-64/$(epm print info --full-version)/repository stable main contrib non-free"
            #epm repo add "deb https://download.astralinux.ru/astra/stable/orel/repository/ orel main contrib non-free"
            return
            ;;
        astra-*)
            fatal "Unsupported distro version $1-$reponame, see '# epm print info' output."
            ;;
    esac

    echo "Use workaround for AstraLinux ..."
    # aptsources.distro.NoDistroTemplateException: Error: could not find a distribution template for AstraLinuxCE/orel
    # don't add again
    epm repo list --quiet | grep -q -F "$repo" && return 0
    [ -z "$(tail -n1 /etc/apt/sources.list)" ] || echo "" | sudocmd tee -a /etc/apt/sources.list
    echo "$repo" | sudocmd tee -a /etc/apt/sources.list
    return
}

__epm_addrepo_alpine()
{
    local repo="$1"
    is_url "$repo" || fatal "Only URL is supported"
    epm repo list --quiet | grep -q -F "$repo" && return 0

    echo "$repo" | sudocmd tee -a /etc/apk/repositories
}

__epm_addrepo_deb()
{
    assure_exists apt-add-repository software-properties-common
    local ad="$DISTRARCH"
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

    if [ -d "$repo" ] ; then
        epm repo add "deb file:$repo ./"
        return
    fi

    # FIXME: quotes in showcmd/sudocmd
    showcmd apt-add-repository "$repo"
    sudorun apt-add-repository "$repo"
    info "Check file /etc/apt/sources.list if needed"
}

epm_addrepo()
{
local repo="$*"

case $BASEDISTRNAME in
    "alt")
        __epm_addrepo_altlinux "$@"
        return
        ;;
    "astra")
        __epm_addrepo_astra "$@"
        return
        ;;
    "apk")
        __epm_addrepo_alpine "$repo" || return
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        __epm_addrepo_deb "$@"
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
        sudocmd urpmi.addmedia "$@"
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
    nix)
        sudocmd nix-channel --add "$repo"
        ;;
    termux-pkg)
        sudocmd pkg install "$repo"
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
    # with hack for sudo case
    ( PATH=$PATH:/sbin:/usr/sbin print_command_path "$1" )
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
                epm qf "$CMD" >&2
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
            epm qf "$compath" >&2
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
    (repack='' pkg_names="$PACKAGE" pkg_files='' pkg_urls='' epm_install ) || return

    # keep auto installed packages
    # https://bugzilla.altlinux.org/42240
    #load_helper epm-mark
    #epm_mark_auto "$PACKAGE"

    # no check if we don't need a version
    [ -n "$PACKAGEVERSION" ] || return 0

    # check if we couldn't update and still need update
    __epm_need_update $PACKAGE $PACKAGEVERSION || return 0

    local textpackage
    [ -n "$PACKAGEVERSION" ] && textpackage=" >= $PACKAGEVERSION"
    warning "Can't assure in '$CMD' command from $PACKAGE$textpackage package"
    return 1
}

# File bin/epm-audit:

epm_audit()
{

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

case $PMTYPE in
    pkgng)
        sudocmd pkg audit -F
        ;;
    apk)
        sudocmd apk audit
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

# File bin/epm-autoorphans:

__epm_orphan_altrpm()
{
    docmd apt-cache list-extras
}

epm_autoorphans()
{

[ -z "$*" ] || fatal "No arguments are allowed here"

case $BASEDISTRNAME in
    alt)
        # ALT Linux only
        assure_exists /usr/share/apt/scripts/list-extras.lua apt-scripts
        if [ -z "$dryrun" ] ; then
            echo "We will try remove all installed packages which are missed in repositories"
            warning "Use with caution!"
        fi
        epm Upgrade || fatal
        info "Retrieving orphaned packages list ..."
        local PKGLIST=$(__epm_orphan_altrpm \
            | sed -e "s/\.32bit//g" \
            | grep -v -- "^eepm$" \
            | grep -v -- "^distro_info$" \
            | grep -v -- "^kernel")

        # TODO: implement for other PMTYPE
        info "Retrieving packages installed via epm play ..."
        local play_installed="$(epm play --list-installed-packages)"
        if [ -n "$play_installed" ] ; then
            echo "Skip follow packages installed via epm play: $(echo $play_installed | xargs -n1000 echo)"
            PKGLIST="$(estrlist exclude "$play_installed" "$PKGLIST")"
        fi

        # TODO: implement for other PMTYPE
        local hold_packages="$(epm mark --short showhold)"
        if [ -n "$hold_packages" ] ; then
            echo "Skip follow packages on hold: $(echo $hold_packages | xargs -n1000 echo)"
            PKGLIST="$(estrlist exclude "$hold_packages" "$PKGLIST")"
        fi

        if [ -n "$PKGLIST" ] ; then
            if [ -z "$dryrun" ] ; then
                showcmd epm remove $dryrun $force $PKGLIST
                confirm_info "We will remove packages above."
            fi
            info
            info
            docmd epm remove $dryrun $force $(subst_option non_interactive --auto) $PKGLIST
        else
            echo "There are no orphan packages in the system."
        fi
        return 0
        ;;
esac

case $PMTYPE in
    apt-dpkg|aptitude-dpkg)
        assure_exists deborphan
        showcmd deborphan
        a='' deborphan | docmd epm remove $dryrun
        ;;
    #aura)
    #    sudocmd aura -Oj
    #    ;;
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
    #    sudocmd emerge --depclean
    #    assure_exists revdep-rebuild
    #    sudocmd revdep-rebuild
    #    ;;
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
    eopkg)
        sudocmd eopkg remove-orphans
        ;;
    #guix)
    #    sudocmd guix gc
    #    ;;
    #pkgng)
    #    sudocmd pkg autoremove
    #    ;;
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

case $BASEDISTRNAME in
    "alt")
        if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ] ; then
            epm_autoremove_print_help
            return 0
        fi

        if [ -z "$direct" ] ; then
            [ -n "$1" ] && fatal "Run autoremove without args or with --direct. Check epm autoremove --help to available commands."
            if epm installed sudo ; then
                epm mark manual sudo || fatal
            fi
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

        #[ -n "$dryrun" ] && return

        # remove old kernels only by a default way
        [ -n "$1" ] && return

        docmd epm remove-old-kernels $dryrun

        if [ -z "$direct" ] ; then
            echo
            info "Also you can run 'epm autoremove --direct' to use epm implementation of autoremove (see --help)"
        fi

        return
        ;;
    "astra")
        [ -n "$force" ] || fatal "It seems AstraLinux does no support autoremove correctly. You can rerun the command with --force option to get into trouble."
        ;;
    *)
        ;;
esac

[ -z "$pkg_filenames" ] || fatal "No arguments are allowed here"

case $PMTYPE in
    apt-dpkg|aptitude-dpkg)
        sudocmd apt-get autoremove $(subst_option non_interactive -y) $dryrun
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
            docmd epm remove $PKGLIST
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
    #    sudocmd urpme --auto-orphans
    #    ;;
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
    #    sudocmd pacman -Qdtq | sudocmd pacman -Rs -
    #    ;;
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
            docmd_foreach "rpm -q -p --changelog" $@
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
            docmd_foreach "rpm -q --changelog" $@
            ;;
        apt-dpkg|aptitude-dpkg)
            docmd zcat /usr/share/doc/$1/changelog.Debian.gz
            ;;
        emerge)
            assure_exists equery
            docmd equery changes -f $1
            ;;
        pacman)
            docmd pacman -Qc $1
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
            __epm_changelog_apt "$1"
            ;;
        #apt-dpkg)
        #    # FIXME: only first pkg
        #    docmd zcat /usr/share/doc/$1/changelog.Debian.gz | less
        #    ;;
        #yum-rpm)
        #    sudocmd yum clean all
        #    ;;
        urpm-rpm)
            docmd urpmq --changelog "$1"
            ;;
        #zypper-rpm)
        #    sudocmd zypper clean
        #    ;;
        emerge)
            assure_exists equery
            docmd equery changes -f "$1"
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

    # TODO: add less or bat
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
update_repo_if_needed
local APTOPTIONS="$(subst_option non_interactive -y)"
local DNFOPTIONS="$(subst_option non_interactive -y) $(subst_option verbose --verbose) "
case $PMTYPE in
    apt-rpm)
        #sudocmd apt-get check || exit
        #sudocmd apt-get update || exit
        sudocmd apt-get -f $APTOPTIONS install || return
        info "You can use epm dedup also"
        ;;
    apt-dpkg)
        #sudocmd apt-get check || exit
        #sudocmd apt-get update || exit
        sudocmd apt-get -f $APTOPTIONS install || return
        ;;
    packagekit)
        docmd pkcon repair
        ;;
    aptitude-dpkg)
        sudocmd aptitude -f $APTOPTIONS install || return
        #sudocmd apt-get autoremove
        ;;
    yum-rpm)
        docmd yum check $DNFOPTIONS
        docmd package-cleanup --problems

        #docmd package-cleanup --dupes
        sudocmd package-cleanup --cleandupes

        docmd rpm -Va --nofiles --nodigest
        ;;
    dnf-rpm)
        sudocmd dnf check $DNFOPTIONS
        ;;
    emerge)
        sudocmd revdep-rebuild
        ;;
    #urpm-rpm)
    #    sudocmd urpme --auto-orphans
    #    ;;
    zypper-rpm)
        sudocmd zypper $(subst_option non_interactive --non-interactive) verify
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
    apk)
        sudocmd apk fix
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
    apk)
        docmd apkg verify $PKG
        ;;
    exe)
        file -L $PKG | grep -q "executable for MS Windows"
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
        docmd erc test "$PKG" && return
        ;;
    esac
}

__epm_check_all_pkgs()
{
case $PMTYPE in
    eopkg)
        sudocmd eopkg check
        return
        ;;
esac

    local j cl
    #local play_installed="$(epm play --list-installed-packages)"
    epm qa --short | xargs -n20 | while read cl ; do
        #cl="$(estrlist exclude "$play_installed" "$i")"
        __epm_check_installed_pkg $cl && continue
        # check each package
        for j in $cl ; do
            __epm_check_installed_pkg $j && continue
            # TODO: check play installed too
            epm --auto reinstall $j </dev/null || exit
        done
    done
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
    eopkg)
        sudocmd eopkg check $@
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_checkpkg()
{
    if [ "$1" = "--all" ] ; then
        __epm_check_all_pkgs
        return
    fi

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

    #fatal "Broken package $pkg"
    return $RETVAL
}

# File bin/epm-checksystem:


__alt_fix_triggers()
{
    local TDIR
    TDIR="$(mktemp -d)" || fatal
    remote_on_exit $TDIR
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

epm_checksystem_ALTLinux()
{
    fatal "Not yet implemented"
    #__alt_fix_triggers
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

case $BASEDISTRNAME in
    "alt")
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

__epm_apt_set_lists_pkg()
{
    # apt-dpkg
    pkg="Packages"

    LISTS='/var/lib/apt/lists'
    if [ "$BASEDISTRNAME" = "alt" ] ; then
        pkg="pkglist"
        # see update-kernel: Use Dir::State::lists for apt update freshness check (ALT bug 46987)
        eval "$(apt-config shell LISTS Dir::State::lists/f)"
    fi
}

__epm_check_apt_db_days()
{
    local pkg
    local pkglists
    __epm_apt_set_lists_pkg
    pkglists=$(find $LISTS -name "*_$pkg*" -ctime +1 2>/dev/null)
    if [ -z "$pkglists" ] ; then
        # note: duplicate __is_repo_info_downloaded
        pkglists=$(find $LISTS -name "*_$pkg*" 2>/dev/null)
        [ -n "$pkglists" ] && return
        echo "never downloaded"
        return 1
    fi

    local i t
    local ts=0
    # set ts to newest file ctime
    # shellcheck disable=SC2044
    for i in $(find $LISTS -name "*_$pkg*" 2>/dev/null); do
        t=$(stat -c%Z "$i")
        [ "$t" -gt "$ts" ] && ts=$t
    done

    if [ "$ts" -gt 0 ]; then
        # shellcheck disable=SC2017
        local now=$(date +%s)
        local days="$(( (now - ts) / (60 * 60 * 24) ))"
        [ "$days" = "0" ] && return 0
        [ "$days" = "1" ] && echo "1 day old" && return 1
        echo "$days days old"
    else
        # no any pkglist
        echo "stalled"
    fi
    return 1
}

__epm_touch_apt_pkg()
{
    local pkg
    __epm_apt_set_lists_pkg
    # ordinal package file have date of latest upstream change, not latest update, so update fake file
    sudorun touch "$LISTS/eepm-fake_$pkg"
}

__epm_touch_pkg()
{
    case $PMTYPE in
        apt-*)
            __epm_touch_apt_pkg
            ;;
    esac
}

__is_repo_info_downloaded()
{
    case $PMTYPE in
        apt-*)
            local pkg
            __epm_apt_set_lists_pkg
            local pkglists
            pkglists=$(find $LIST -name "*_$pkg*" 2>/dev/null)
            [ -n "$pkglists" ] || return 1
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
            __epm_check_apt_db_days >/dev/null
            ;;
        *)
            ;;
    esac
    return 0
}

update_repo_if_needed()
{
    local days

    # for apt only
    case $PMTYPE in
        apt-*)
            ;;
        *)
            return
            ;;
    esac

    days="$(__epm_check_apt_db_days)" && return
    warning "APT database is $days, please run 'epm update'!"

    # TODO: enable __is_repo_info_downloaded

    return
    # check if we need skip update checking
    #if [ "$1" = "soft" ] && ! set_sudo nofail ; then
    #    # if sudo requires a password, skip autoupdate
    #    info "can't use sudo, so skip repo status checking"
    #    return 1
    #fi

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
    return 0
}

__remove_deb_apt_cache_file()
{
    sudocmd rm -vf /var/cache/apt/*.bin
    sudocmd rm -vf /var/cache/apt/archives/partial/*
    sudocmd rm -vf /var/lib/apt/lists/*Packages*
    sudocmd rm -vf /var/lib/apt/lists/*Release*
    sudocmd rm -vf /var/lib/apt/lists/*Translation*
    return 0
}

epm_clean()
{

[ -z "$*" ] || fatal "No arguments are allowed here"


case $PMTYPE in
    apt-rpm)
        sudocmd apt-get clean $dryrun
        [ -n "$direct" ] && __remove_alt_apt_cache_file || info "Use epm clean --direct to remove all downloaded indexes."
        ;;
    apt-dpkg)
        sudocmd apt-get clean $dryrun
        [ -n "$direct" ] && __remove_deb_apt_cache_file || info "Use epm clean --direct to remove all downloaded indexes."
        ;;
    aptitude-dpkg)
        sudocmd aptitude clean
        [ -n "$direct" ] && __remove_deb_apt_cache_file || info "Use epm clean --direct to remove all downloaded indexes."
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
    eopkg)
        sudocmd eopkg delete-cache
        ;;
    pkgng)
        sudocmd pkg clean -a
        ;;
    appget)
        sudocmd appget clean
        ;;
    xbps)
        sudocmd xbps-remove -O
        ;;
    termux-pkg)
        sudocmd pkg clean
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac
    info "Note: Also you can try (with CAUTION) '# epm autoremove' and '# epm autoorphans' commands to remove obsoleted and unused packages."

}

# File bin/epm-conflicts:


epm_conflicts_files()
{
    [ -n "$pkg_files" ] || return

    case $(get_package_type $pkg_files) in
        rpm)
            assure_exists rpm
            docmd rpm -q --conflicts -p $pkg_files
            ;;
        #deb)
        #    a= docmd dpkg -I $pkg_files | grep "^ *Depends:" | sed "s|^ *Depends:||g"
        #    ;;
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
    #    CMD="yum deplist"
    #    ;;
    #pacman)
    #    CMD="pactree"
    #    ;;
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
    #    docmd aptitude why-not $pkg_names
    #    ;;

    #emerge)
    #    assure_exists equery
    #    CMD="equery depgraph"
    #    ;;
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
    PKGLIST=$(LC_ALL=C sudorun apt-get install $TESTPKG 2>&1 | grep "W: There are multiple versions of" | \
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
case "$BASEDISTRNAME" in
    "alt")
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
Pin: release c=main
Pin-Priority: 1201

Package: *
Pin: release c=task
Pin-Priority: 1301
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

    # if possible, it will put pkg_urls into pkg_files and reconstruct pkg_filenames
    if [ -n "$pkg_urls" ] ; then
        info "Downloading packages assigned to downgrade ..."
        __handle_pkg_urls_to_install
    fi

    info "Running command for downgrade packages"

    case $BASEDISTRNAME in
    alt)
        # pass pkg_filenames too
        if [ -n "$pkg_names" ] ; then
            __epm_add_alt_apt_downgrade_preferences || return
            (pkg_names=$(get_only_installed_packages $pkg_names) epm_install)
            __epm_remove_apt_downgrade_preferences
        elif [ -n "$pkg_files" ] ; then
            local pkgs=''
            local i
            for i in $pkg_files ; do
                local pkgname="$(epm print name for package $i)"
                is_installed $pkgname || continue
                pkgs="$pkgs $i"
            done
            (force="$force --oldpackage" epm_install_files $pkgs)
        else
            __epm_add_alt_apt_downgrade_preferences || return
            epm_upgrade "$@"
            __epm_remove_apt_downgrade_preferences
        fi
        return
        ;;
    esac

    case $PMTYPE in
    #apt-rpm)
    #    ;;
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

# File bin/epm-Downgrade:


epm_Downgrade()
{
    epm_update
    epm_downgrade "$@"
}

# File bin/epm-download:

alt_base_dist_url="http://ftp.basealt.ru/pub/distributions"

__use_url_install()
{
    # force download if wildcard is used
    echo "$pkg_urls" | grep -q "[?*]" && return 1

    # force download if repack is asked
    [ -n "$repack" ] && return 1

    # install of remote files has a side affect
    # (more fresh package from a repo can be installed instead of the file)
    #case $DISTRNAME in
    #    "ALTLinux")
    #        # do not support https yet
    #        echo "$pkg_urls" | grep -q "https://" && return 1
    #        pkg_names="$pkg_names $pkg_urls"
    #        return 0
    #        ;;
    #esac

    case $PMTYPE in
        #apt-rpm)
        #    pkg_names="$pkg_names $pkg_urls"
        #    ;;
        #deepsolver-rpm)
        #    pkg_names="$pkg_names $pkg_urls"
        #    ;;
        #urpm-rpm)
        #    pkg_names="$pkg_names $pkg_urls"
        #    ;;
        pacman)
            true
            ;;
        yum-rpm|dnf-rpm)
            true
            ;;
        #zypper-rpm)
        #    pkg_names="$pkg_names $pkg_urls"
        #    ;;
        *)
            return 1
            ;;
    esac
    [ -n "$pkg_names" ] && pkg_names="$pkg_names $pkg_urls" || pkg_names="$pkg_urls"
    return 0
}

__download_pkg_urls()
{
    local url
    [ -z "$pkg_urls" ] && return
    for url in $pkg_urls ; do
        local tmppkg
        tmppkg="$(mktemp -d --tmpdir=$BIGTMPDIR)" || fatal
        remove_on_exit $tmppkg
        chmod $verbose a+rX $tmppkg
        cd $tmppkg || fatal
        local latest='--latest'
        # hack: download all if mask is *.something
        basename "$url" | grep -q "^\*\." && latest=''
        # download packages
        if docmd eget $latest "$url" ; then
            local i
            for i in * ; do
                [ "$i" = "*" ] && warning "Incorrect true status from eget. No saved files from download $url, ignoring" && continue
                [ -s "$tmppkg/$i" ] || continue
                chmod $verbose a+r "$tmppkg/$i"
                [ -n "$pkg_files" ] && pkg_files="$pkg_files $tmppkg/$i" || pkg_files="$tmppkg/$i"
                [ -n "$pkg_urls_downloaded" ] && pkg_urls_downloaded="$pkg_urls_downloaded $url" || pkg_urls_downloaded="$url"
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
    local tm
    tm="$(mktemp)" || fatal
    remove_on_exit $tm
    assure_exists curl
    quiet=1
    local buildtime=$(paoapi packages/$pkg | get_pao_var buildtime)
    echo
    echo "Latest release: $(paoapi packages/$pkg | get_pao_var sourcepackage) $buildtime"
    __epm_print_url_alt "$1" | while read url ; do
        eget --get-response $url >$tm || { echo "$url: missed" ; continue ; }
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


    # TODO: enable if install --download-only will works
    if tasknumber "$@" >/dev/null ; then

        local installlist="$(get_task_packages $*)"
        # hack: drop -devel packages to avoid package provided by multiple packages
        installlist="$(estrlist reg_exclude ".*-devel .*-devel-static .*-checkinstall .*-debuginfo" "$installlist")"
        [ -n "$verbose" ] && info "Packages from task(s): $installlist"

        try_change_alt_repo
        epm_addrepo "$@"
        epm update
        [ -n "$verbose" ] && epm repo list
        docmd epm download $print_url $installlist
        epm_removerepo "$@"
        end_change_alt_repo

        return
    fi

    # old systems ignore reinstall ?
    for pkg in "$@" ; do
        for i in $(sudocmd apt-get install -y --print-uris --reinstall "$pkg" | cut -f1 -d " " | grep ".rpm'$" | sed -e "s|^'||" -e "s|'$||") ; do
            echo "$(basename "$i")" | grep -q "^$pkg" || continue
            [ -n "$print_url" ] && echo "$i" && continue
            eget "$i"
        done
    done
    return

    # old code:
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

    case "$BASEDISTRNAME" in
        "alt")
            __epm_download_alt $*
            return
            ;;
    esac

    case $PMTYPE in
    apt-dpkg)
        if [ -n "$print_url" ] ; then
            docmd apt-get download --print-uris $* | cut -f1 -d " " | grep ".deb'$" | sed -e "s|^'||" -e "s|'$||"
            return
        fi
        docmd apt-get download $*
        ;;
    dnf-rpm)
        sudocmd dnf download $print_url $*
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
    eopkg)
        docmd eopkg fetch $*
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



EPM_KORINF_REPO_URL="https://updates.etersoft.ru/pub/Korinf"

__epm_korinf_site_mask() {
    local MASK="$1"
    local archprefix=""
    # short hack to install needed package
    rhas "$MASK" "[-_]" || MASK="${MASK}[-_][0-9]"
    # set arch for Korinf compatibility
    [ "$SYSTEMARCH" = "x86_64" ] && archprefix="x86_64/"
    local URL="$EPM_KORINF_REPO_URL/$archprefix$DISTRNAME/$DISTRVERSION"
    if ! eget --check-url "$URL" ; then
        tURL="$EPM_KORINF_REPO_URL/$archprefix$BASEDISTRNAME/$DISTRREPONAME"
        docmd eget --check-url "$tURL" && URL="$tURL"
    fi
    eget --list --latest "$URL/$MASK*.$PKGFORMAT"
}

__epm_korinf_list() {
    local MASK="$1"
    MASK="$(__epm_korinf_site_mask "$MASK")"
    showcmd eget --list "$MASK"
    eget --list "$MASK" | sort
}


__epm_korinf_install() {

    local pkg pkgurl
    local pkg_urls=''
    for pkgurl in $* ; do
        pkg="$(__epm_korinf_site_mask "$pkgurl")"
        [ -n "$pkg" ] || fatal "Can't get package url from $pkgurl"
        [ -n "$pkg_urls" ] && pkg_urls="$pkg_urls $pkg" || pkg_urls="$pkg"
    done
    # due Error: Can't use epm call from the piped script
    #epm install $(__epm_korinf_site_mask "$PACKAGE")
    pkg_names='' pkg_files='' epm_install
}

__epm_korinf_install_eepm()
{

    if [ "$BASEDISTRNAME" = "alt" ] && [ "$DISTRVERSION" != "Sisyphus" ] && [ "$EPMMODE" = "package" ] ; then
        if epm status --original eepm ; then
            warning "Using external (Korinf) repo is forbidden for stable ALT branch $DISTRVERSION."
            info "Check https://bugzilla.altlinux.org/44314 for reasons."
            info "You can install eepm package from Korinf manually, check instruction at https://eepm.ru"
            info ""
            info "Trying update eepm from the stable ALT repository ..."
            docmd epm install eepm
            return
        fi
    fi

    # enable interactive for install eepm from console
    if inputisatty && [ "$EPMMODE" != "pipe" ] ; then
        [ -n "$non_interactive" ] || interactive="--interactive"
    else
        [ -n "$interactive" ] || non_interactive="--auto"
    fi

    # as now, can't install one package from task (and old apt-repo can't install one package)
    if false && [ "$BASEDISTRNAME" = "alt" ] && [ -z "$direct" ] ; then
        local task="$(docmd eget -O- https://eepm.ru/vendor/alt/task)"
        if [ -n "$task" ] ; then
            docmd epm install $task
            return
        else
            info "Can't get actual task for ALT, fallback to Korinf"
        fi
    fi

    pkg_list="eepm"
    # TODO: reenable eepm-repack build
    # don't lose epm-repack if installed
    # is_installed epm-repack && pkg_list="$pkg_list eepm-repack"

    # enable scripts to resolve dependencies with apt
    scripts='--scripts' __epm_korinf_install $pkg_list
}

epm_epm_install_help()
{
    echo "epm ei [URL] [packages] - install packages from EPM based Korinf repository"
            get_help HELPCMD $SHAREDIR/epm-epm_install
    cat <<EOF

Default Korinf repository: $EPM_KORINF_REPO_URL

Examples:
  epm ei [epm|eepm]                 - install latest eepm (default action)
  epm ei <package1> [<package2>...] - install package(s) from default Korinf repo
  epm http://someurl.ru <package>   - install package(s) from a repo defined by URL
  epm --list <package mask>         - list available packages by mask
EOF
}


epm_epm_install()
{
    if is_url "$1" ; then
        EPM_KORINF_REPO_URL="$1"
        info "Using $EPM_KORINF_REPO_URL repo ..."
        shift
    fi

    case "$1" in
        ""|epm|eepm)
            # install epm by default
            __epm_korinf_install_eepm
            return
            ;;
        -h|--help)                     # HELPCMD: help
            epm_epm_install_help
            return
            ;;
        --list)                        # HELPCMD: list only packages
            shift
            __epm_korinf_list "$1"
            return
            ;;
    esac

    __epm_korinf_install "$@"
}

# File bin/epm-filelist:


__alt_local_content_filelist()
{

    check_alt_contents_index || init_alt_contents_index
    update_repo_if_needed
    local CI="$(cat $ALT_CONTENTS_INDEX_LIST)"

    # TODO: safe way to use less or bat
    #local OUTCMD="less"
    #[ -n "$USETTY" ] || OUTCMD="cat"
    OUTCMD="cat"

    {
        [ -n "$USETTY" ] && info "Search in $CI for $1..."
        ercat $CI | grep -h -P -- ".*\t$1$" | sed -e "s|\(.*\)\t\(.*\)|\1|g"
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

    case $BASEDISTRNAME in
        alt)
            # TODO: use RESTful interface to prometeus? See ALT bug #29496
            docmd_foreach __alt_local_content_filelist "$@"
            return
            ;;
    esac

    case $PMTYPE in
        apt-dpkg)
            assure_exists apt-file || return
            if sudo_allowed ; then
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
        eopkg)
            assure_exists eopkg
            CMD="eopkg --files info"
            ;;
        *)
            fatal "Have no suitable query command for $PMTYPE"
            ;;
    esac

    # TODO: add less
    docmd $CMD $@
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
        termux-pkg)
            CMD="pkg files"
            ;;
        conary)
            CMD="conary query --ls"
            ;;
        pacman)
            docmd pacman -Ql $@ | sed -e "s|.* ||g"
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
        apk)
            docmd apk manifest $@ | sed -e 's|^sha1.* |/|'
            return
            ;;
        eopkg)
            docmd eopkg --files -s info $@ | grep "^/"
            return
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
            docmd awk 'BEGIN{desk=1}{if(/^FILE LIST:$/){desk=0} else if (desk==0) {print}}' /var/log/packages/${pkg_filenames}*
            return
            ;;
        *)
            fatal "Have no suitable query command for $PMTYPE"
            ;;
    esac

    # TODO: add less or bat (for any output in the function)
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

epm_full_upgrade_help()
{
            get_help HELPCMD $SHAREDIR/epm-full_upgrade
    cat <<EOF
You can run with --interactive if you can skip some steps interactively.
Also you can comment out full_upgrade parts in /etc/eepm/eepm.conf config.
Examples:
  epm full-upgrade [--auto]
  epm full-upgrade [--interactive]
  epm full-upgrade --no-flatpack
EOF
}


epm_full_upgrade()
{

    while [ -n "$1" ] ; do
        case "$1" in
            "-h"|"--help"|"help")      # HELPCMD: help
                epm_full_upgrade_help
                return
                ;;
            "--interactive")           # HELPCMD: ask before every step
                ;;
            "--no-epm-play")           # HELPCMD: skip epm play during full upgrade
                full_upgrade_no_epm_play=1
                ;;
            "--no-flatpack")           # HELPCMD: skip flatpack update during full upgrade
                full_upgrade_no_flatpack=1
                ;;
            "--no-snap")           # HELPCMD: skip snap update during full upgrade
                full_upgrade_no_snap=1
                ;;
            "--no-kernel-update")  # HELPCMD: skip kernel update during full upgrade
                full_upgrade_no_kernel_update=1
                ;;
            "--no-clean")          # HELPCMD: no clean after upgrade
                full_upgrade_no_clean=1
                ;;
        esac
        shift
    done

confirm_action()
{
    [ -n "$interactive" ] || return 0
    local response
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [Y/n]} " response
    case $response in
        [yY][eE][sS]|[yY]|"")
            true
            ;;
        *)
            false
            ;;
    esac
}

    confirm_action "Update repository info? [Y/n]" || full_upgrade_no_update=1
    if [ -z "$full_upgrade_no_update" ] ; then
        [ -n "$quiet" ] || echo
        docmd epm update || fatal "repository updating is failed."
    fi


    confirm_action "Do upgrade installed packages? [Y/n]" || full_upgrade_no_upgrade=1
    if [ -z "$full_upgrade_no_upgrade" ] ; then
        [ -n "$quiet" ] || echo
        docmd epm $dryrun upgrade || fatal "upgrading of the system is failed."
    fi


    confirm_action "Upgrade kernel and kernel modules? [Y/n]" || full_upgrade_no_kernel_update=1
    if [ -z "$full_upgrade_no_kernel_update" ] ; then
        [ -n "$quiet" ] || echo
        docmd epm $dryrun update-kernel || fatal "updating of the kernel is failed."
    fi

    # disable epm play --update for non ALT Systems
    [ "$BASEDISTRNAME" = "alt" ] || full_upgrade_no_epm_play=1


    confirm_action "Upgrade packages installed via epm play? [Y/n]" || full_upgrade_no_epm_play=1
    if [ -z "$full_upgrade_no_epm_play" ] ; then
        [ -n "$quiet" ] || echo
        if [ -n "$force" ] ; then
            docmd epm $dryrun play #|| fatal "updating of applications installed via epm play is failed."
        else
            docmd epm $dryrun play --update all #|| fatal "updating of applications installed via epm play is failed."
        fi
    fi


    if is_command flatpak ; then
        confirm_action "Upgrade installed flatpak packages? [Y/n]" || full_upgrade_no_flatpak=1
        if [ -z "$full_upgrade_no_flatpak" ] ; then
            [ -n "$quiet" ] || echo
            docmd flatpak update $(subst_option non_interactive --assumeyes) $(subst_option dryrun --no-deploy)
        fi
    fi


    if is_command snap && serv snapd exists && serv snapd status >/dev/null ; then
        confirm_action "Upgrade installed snap packages? [Y/n]" || full_upgrade_no_snap=1
        if [ -z "$full_upgrade_no_snap" ] ; then
            [ -n "$quiet" ] || echo
            sudocmd snap refresh $(subst_option dryrun --list)
        fi
    fi


    confirm_action "Do epm clean? [Y/n]" || full_upgrade_no_clean=1
    if [ -z "$full_upgrade_no_clean" ] ; then
        [ -n "$quiet" ] || echo
        docmd epm $dryrun clean
    fi
}

# File bin/epm-history:

EHOG='\(apt-get\|rpm\)'
JCHAN='-t apt-get -t rpm'

__alt_epm_history_journal()
{
    a= journalctl $JCHAN
}

__alt_epm_history_uniq()
{
    __alt_epm_history_journal | grep "$EHOG\[[0-9][0-9]*\]:" | sed -e "s@.*$EHOG\[\([0-9][0-9]*\)\]: .*@\2@" | uniq | tac
}

__alt_epm_history_select()
{
    local pid="$1"
    local verb="$2"
    __alt_epm_history_journal | grep "$EHOG\[$pid\]: .*$verb" | sed -e "s@.*$EHOG\[[0-9][0-9]*\]: @@" | cut -d" " -f 1
}

_alt_epm_history_date()
{
    local pid="$1"
    __alt_epm_history_journal | grep "$EHOG\[$pid\]: " | head -n1 | cut -d" " -f 1-3,5 | sed -e 's|:$||'
}

_alt_epm_history_print_group()
{
    local i

    if [ -n "$2" ] ; then
        echo
        echo "$1 session:"
        shift
    else
        return
    fi

    for i in $* ; do
        echo "    $i"
    done
}


__alt_epm_history_removed()
{
    echo "Removed packages history:"
    __alt_epm_history_uniq | while read pid ; do
        date="$(_alt_epm_history_date $pid)"
        removed="$(epm print shortname for $(__alt_epm_history_select $pid "removed") )"
        installed="$(epm print shortname for $(__alt_epm_history_select $pid "installed") )"
        _alt_epm_history_print_group "$date" $(estrlist exclude "$installed" "$removed")
    done
}

__alt_epm_history_installed()
{
    echo "Installed packages history:"
    __alt_epm_history_uniq | while read pid ; do
        date="$(_alt_epm_history_date $pid)"
        #epm print shortname for $(__alt_epm_history_select $pid "installed") | sed -e "s|^|    |"
        removed="$(epm print shortname for $(__alt_epm_history_select $pid "removed") )"
        installed="$(epm print shortname for $(__alt_epm_history_select $pid "installed") )"
        _alt_epm_history_print_group "$date" $(estrlist exclude "$removed" "$installed")
    done
}

__alt_epm_history_updated()
{
    echo "Updated packages history:"
    __alt_epm_history_uniq | while read pid ; do
        date="$(_alt_epm_history_date $pid)"
        #epm print shortname for $(__alt_epm_history_select $pid "installed") | sed -e "s|^|    |"
        removed="$(epm print shortname for $(__alt_epm_history_select $pid "removed") )"
        installed="$(epm print shortname for $(__alt_epm_history_select $pid "installed") )"
        _alt_epm_history_print_group "$date" $(estrlist intersection "$removed" "$installed")
    done
}

epm_history_help()
{
    echo "package management history"
            get_help HELPCMD $SHAREDIR/epm-history
    cat <<EOF
Examples:
  epm history
  epm history --removed
EOF
}


epm_history()
{

if [ $PMTYPE = "apt-rpm" ] ; then
    case "$1" in
        "-h"|"--help"|"help")      # HELPCMD: help
            epm_history_help
            return
            ;;
        --installed)               # HELPCMD: print only new installed packages
            __alt_epm_history_installed
            return
            ;;
        --removed)                 # HELPCMD: print only removed packages
            __alt_epm_history_removed
            return
            ;;
        --updated)                 # HELPCMD: print only updated packages
            __alt_epm_history_updated
            return
            ;;
        --list)                    # HELPCMD: (or empty) print all history entries
            docmd journalctl $JCHAN
            return
            ;;
        "")
            ;;
        *)
            fatal "Unknown option $1. Use epm history --help to get help."
    esac
fi

[ -z "$*" ] || fatal "No arguments are allowed here"

case $PMTYPE in
    apt-rpm)
        docmd journalctl $JCHAN -r
        ;;
    apt-dpkg)
        docmd cat /var/log/dpkg.log
        ;;
    dnf-rpm)
        sudocmd dnf history
        ;;
    eopkg)
        sudocmd eopkg history
        ;;
    zypper-rpm)
        docmd cat /var/log/zypp/history
        ;;
    pacman)
        docmd cat /var/log/pacman.log
        ;;
    emerge)
        docmd cat /var/log/portage
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

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
                docmd apt-cache show $pkg_names | awk 'BEGIN{desk=1}{if(/^Changelog:$/){desk=0} else if (desk==1) {print}}'
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
    apk)
        docmd apk info $pkg_names
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
    eopkg)
        docmd eopkg info $pkg_files $pkg_names
        ;;
    appget)
        docmd appget view $pkg_names
        ;;
    winget)
        docmd winget show $pkg_names
        ;;
    termux-pkg)
        docmd pkg show $pkg_names
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

    if [ -n "$download_only" ] ; then
        epm download "$@"
        return
    fi

    if [ -n "$dryrun" ] ; then
        epm simulate "$@"
        return
    fi

    if [ -n "$non_interactive" ] ; then
        epm_ni_install_names "$@"
        return
    fi

    case $PMTYPE in
        apt-rpm|apt-dpkg)
            APTOPTIONS="$APTOPTIONS $(subst_option verbose "-o Debug::pkgMarkInstall=1 -o Debug::pkgProblemResolver=1")"
            # https://bugzilla.altlinux.org/44670
            VIRTAPTOPTIONS="-o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true"
            # not for kernel packages
            echo "$*" | grep -q "^kernel-"  && VIRTAPTOPTIONS=''
            sudocmd apt-get $VIRTAPTOPTIONS $APTOPTIONS $noremove install $@ && save_installed_packages $@
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
        eopkg)
            sudocmd eopkg $(subst_option nodeps --ignore-dependency) install $@
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
        termux-pkg)
            sudocmd pkg install $@
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
        nix)
            info "When you ask Nix to install a package, it will first try to get it in pre-compiled form from a binary cache. By default, Nix will use the binary cache https://cache.nixos.org; it contains binaries for most packages in Nixpkgs. Only if no binary is available in the binary cache, Nix will build the package from source."
            sudocmd nix-env -iA $@
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
        apt-rpm)
            sudocmd apt-get -y $noremove --force-yes -o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $APTOPTIONS install $@
            return ;;
        apt-dpkg)
            sudocmd env ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive apt-get -y $noremove --force-yes -o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $APTOPTIONS install $@
            return ;;
        aptitude-dpkg)
            sudocmd env ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive aptitude -y install $@
            return ;;
        yum-rpm)
            sudocmd yum -y $YUMOPTIONS install $(echo "$*" | exp_with_arch_suffix)
            return ;;
        dnf-rpm)
            sudocmd dnf -y --allowerasing $YUMOPTIONS install $(echo "$*" | exp_with_arch_suffix)
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
        choco)
            docmd choco install $@
            return ;;
        opkg)
            sudocmd opkg -force-defaults install $@
            return ;;
        eopkg)
            sudocmd eopkg --yes-all install $@
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
        termux-pkg)
            sudocmd pkg install $@
            return ;;
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
    LC_ALL=C sudorun rpm -Uvh --test "$@" 2>&1 | grep -q "is already installed"
}

__handle_direct_install()
{
    case "$BASEDISTRNAME" in
        "alt")
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
        echo "$pkg" | grep -q "\.src\.rpm" && fatal "Installation of a source packages (like '$pkg') is not supported."
    done
}

__epm_if_command_path()
{
    is_dirpath "$1" && rhas "$1" "bin/" && ! rhas "$1" "/home"
}

__epm_get_replacepkgs()
{
    [ -n "$2" ] && echo '--replacepkgs' && return
    # don't use --replacepkgs when install only one file
}

epm_install_files()
{
    local files="$*"
    [ -z "$files" ] && return

    # on some systems install target can be a real path
    # use hi-level for install by file path (f.i. epm install /usr/bin/git)
    if __epm_if_command_path $files ; then
        epm_install_names $files
        return
    fi

    # TODO: check read permissions
    # sudo test -r FILE
    # do not fallback to install_names if we have no permissions
    case "$BASEDISTRNAME" in
        "alt")
            epm_install_files_alt $files
            return
            ;;
    esac

    case $PMTYPE in
        apt-dpkg|aptitude-dpkg)
            epm_install_files_apt_dpkg $files
            return
            ;;

       *-rpm)
            epm_install_files_rpm $files
            return
            ;;
    esac


    # check save_only before commands without repack supporting
    if [ -n "$save_only" ] ; then
        echo
        cp -v $files "$EPMCURDIR"
        return
    fi

    if [ -n "$put_to_repo" ] ; then
        epm_put_to_repo $files
        return
    fi


    case $PMTYPE in
        packagekit)
            docmd pkcon install-local $files
            return ;;
        pkgsrc)
            sudocmd pkg_add $files
            return ;;
        pkgng)
            local PKGTYPE="$(get_package_type $files)"
            case "$PKGTYPE" in
                tbz)
                    sudocmd pkg_add $files
                    ;;
                *)
                    sudocmd pkg add $files
                    ;;
            esac
            return ;;
        android)
            sudocmd pm install $files
            return ;;
        eopkg)
            sudocmd eopkg install $files
            return ;;
        emerge)
            sudocmd epm_install_emerge $files
            return ;;
        pacman)
            sudocmd pacman -U --noconfirm $nodeps $files && return
            local RES=$?

            [ -n "$nodeps" ] && return $RES
            sudocmd pacman -U $files
            return ;;
        slackpkg)
            # FIXME: check for full package name
            # FIXME: broken status when use batch and default answer
            __separate_sudocmd_foreach "/sbin/installpkg" "/sbin/upgradepkg" $files
            return ;;
    esac

    # other systems can install file package via ordinary command
    epm_install_names $files
}


epm_install()
{
    if [ "$BASEDISTRNAME" = "alt" ] ; then
        if tasknumber "$pkg_names" >/dev/null ; then
            if [ -n "$interactive" ] ; then
                confirm_info "You are about to install $pkg_names task(s) from https://git.altlinux.org."
            fi
            epm_install_alt_tasks "$pkg_names"
            return
        fi
    fi

    if [ -n "$show_command_only" ] ; then
        # TODO: handle pkg_urls too
        epm_print_install_files_command $pkg_files
        epm_print_install_names_command $pkg_names
        return
    fi

    if [ -n "$interactive" ] && [ -n "$pkg_names$pkg_files$pkg_urls" ] ; then
        confirm_info "You are about to install $(echo $pkg_names $pkg_files $pkg_urls) package(s)."
        # TODO: for some packages with dependencies apt will ask later again
    fi

    if [ -n "$direct" ] && [ -z "$repack" ] ; then
        # it will put pkg_urls into pkg_files and reconstruct pkg_filenames
        __handle_direct_install
    fi

    if [ -n "$pkg_urls" ] ; then
        # it will put downloaded by pkg_urls packages to pkg_files and reconstruct pkg_filenames
        __handle_pkg_urls_to_install
    fi

    [ -z "$pkg_files$pkg_names" ] && info "Skip empty install list" && return 22

    # to be filter happy
    warmup_lowbase

    # Note: filter_out_installed_packages depends on skip_installed flag
    local names="$(echo $pkg_names | filter_out_installed_packages)"
    #local names="$(echo $pkg_names | exp_with_arch_suffix | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    # can be empty only after all installed packages were skipped
    if [ -z "$files$names" ] ; then
        # TODO: assert $skip_installed
        [ -n "$verbose" ] && info "Skip empty install list (filtered out, all requested packages is already installed)"
        # FIXME: see to_remove below
        return 0
    fi

    if [ -n "$names" ] && [ -z "$direct" ] ; then
        # it is useful for first time running
        update_repo_if_needed
    fi

    case "$BASEDISTRNAME" in
        "alt")
            epm_install_alt_names $names || return
            ;;
        *)
            # FIXME: see to_remove below
            epm_install_names $names || return
            ;;
    esac

    [ -z "$files" ] && debug "Skip empty install files list" && return 0

    if [ -n "$download_only" ] ; then
        # save files to the current dir before install and repack
        echo
        cp -v $files "$EPMCURDIR"
        return
    fi

    if [ -n "$repack" ] ; then
        # repack binary files if asked
        __epm_repack $files || return
        files="$repacked_pkgs"
    fi

    epm_install_files $files
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

# File bin/epm-install-alt:

epm_install_files_alt()
{
    local files="$*"
    [ -z "$files" ] && return

    # TODO: check read permissions
    # sudo test -r FILE
    # do not fallback to install_names if we have no permissions

    __epm_print_warning_for_nonalt_packages $files

    # do repack if needed
    if __epm_repack_if_needed $files ; then
        [ -n "$repacked_pkgs" ] || fatal "Can't convert $files"
        files="$repacked_pkgs"
    fi

    if [ -n "$save_only" ] ; then
        echo
        cp -v $files "$EPMCURDIR"
        return
    fi

    if [ -n "$put_to_repo" ] ; then
        epm_put_to_repo $files
        return
    fi

    __epm_check_if_src_rpm $files

    if [ -z "$repacked_pkgs" ] ; then
        __epm_check_vendor $files
        __epm_check_if_needed_repack $files
    fi

    # --replacepkgs: Install the Package Even If Already Installed
    local replacepkgs="$(__epm_get_replacepkgs $files)"
    sudocmd rpm -Uvh $replacepkgs $(subst_option dryrun --test) $force $noscripts $nodeps $files && save_installed_packages $files && return
    local RES=$?
    # TODO: check rpm result code and convert it to compatible format if possible
    __epm_check_if_rpm_already_installed $force $replacepkgs $noscripts $nodeps $files && return

    # if run with --nodeps, do not fallback on hi level
    [ -n "$nodeps" ] && return $RES

    # separate second output
    info

    # try install via apt if we could't install package file via rpm (we guess we need install requirements firsly)

    if [ -z "$noscripts" ] ; then
        epm_install_names $files
        return
    fi

    # TODO: use it always (apt can install version from repo instead of a file package)
    info "Workaround for install packages via apt with --noscripts (see https://bugzilla.altlinux.org/44670)"
    info "Firstly install package requrements …"
    # names of packages to be installed
    local fl="$(epm print name for package $files)"
    local req="$(docmd epm req --short $files)" || return
    # exclude package names from requires (req - fl)
    req="$(estrlist exclude "$fl" "$req")"
    # TODO: can we install only requires via apt?
    docmd epm install --skip-installed $req || return

    # retry with rpm
    # --replacepkgs: Install the Package Even If Already Installed
    local replacepkgs="$(__epm_get_replacepkgs $files)"
    sudocmd rpm -Uvh $replacepkgs $(subst_option dryrun --test) $force $noscripts $nodeps $files && save_installed_packages $files
}

get_current_kernel_flavour()
{
    rrel=$(uname -r)
    rflv=${rrel#*-}
    rflv=${rflv%-*}
    echo "$rflv"
}

make_kernel_release()
{
    echo "$2" | sed -e "s|-|-$1-|"
}

get_latest_kernel_rel()
{
    local kernel_flavour="$1"
    # current
    rrel=$(uname -r)

    # latest
    # copied and modified from update-kernel
    # get the maximum available kernel package version
    kmaxver=
    while read version
    do
        comparever="$(rpmevrcmp "$kmaxver" "$version")"
        [ "$comparever" -lt 0 ] && kmaxver="$version" ||:
    done <<<"$(epm print version-release for package kernel-image-$kernel_flavour)"
    [ -z "$kmaxver" ] && echo "$rrel" && return

    make_kernel_release "$kernel_flavour" "$kmaxver"
}

epm_install_alt_kernel_module()
{
    [ -n "$1" ] || return 0

    local kflist=''
    local kmplist=''
    local kmf km kf

    # fill kernel flavour list
    for kmf in $*; do
        km="$(echo "$kmf" | cut -d- -f1)"
        kf="$(echo "$kmf" | cut -d- -f2,3)"
        # use current flavour as default
        [ "$km" = "$kf" ] && kf="$(get_current_kernel_flavour)"
        kflist="$kflist $kf"
    done

    # firstly, update all needed kernels (by flavour)
    for kf in $(estrlist uniq $kflist) ; do
        info
        docmd epm update-kernel -t $kf || exit
    done

    # skip install modules if there are no installed kernels (may be, a container)
    epm installed "kernel-image-$kf" || return 0

    # make list for install kernel modules
    for kmf in $*; do
        km="$(echo "$kmf" | cut -d- -f1)"
        kf="$(echo "$kmf" | cut -d- -f2,3)"
        # use current flavour as default
        [ "$km" = "$kf" ] && kf="$(get_current_kernel_flavour)"
        kvf="$(get_latest_kernel_rel $kf)"
        #kmplist="$kmplist kernel-modules-$km-$kf"
        # install kernel module for latest installed kernel
        kmplist="$kmplist kernel-modules-$km-$kvf"
    done

    # secondly, install module(s)
    epm_install_names $kmplist
}


epm_install_alt_names()
{
    local kmlist=''
    local installnames=''

    while [ -n "$1" ] ; do
        local pkgname
        pkgname="$1"
        if echo "$pkgname" | grep -v "#" | grep -q "^kernel-modules*-" ; then
            # virtualbox[-std-def]
            local kmn="$(echo $pkgname | sed -e 's|kernel-modules*-||')"
            local kf1="$(echo "$kmn" | cut -d- -f2)"
            local kf2="$(echo "$kmn" | cut -d- -f4)"
            # pass install with full pkgnames
            if [ "$kf1" != "$kf2" ] && [ -n "$kf2" ] || echo "$kf1" | grep -q "^[0-9]" ; then
                installnames="$installnames $pkgname"
            else
                kmlist="$kmlist $kmn"
            fi
        else
            installnames="$installnames $pkgname"
        fi
        shift
    done

    epm_install_names $installnames || return
    epm_install_alt_kernel_module $kmlist || return
}


apt_repo_prepare()
{
    assure_exists apt-repo
    [ -n "$non_interactive" ] || return

    set_sudo
    trap "$SUDO rm /etc/apt/apt.conf.d/eepm-apt-noninteractive.conf 2>/dev/null" EXIT
    echo 'APT::Get::Assume-Yes "true";' | $SUDO tee /etc/apt/apt.conf.d/eepm-apt-noninteractive.conf >/dev/null
}

apt_repo_after()
{
    [ -n "$non_interactive" ] || return

    $SUDO rm /etc/apt/apt.conf.d/eepm-apt-noninteractive.conf 2>/dev/null
}


epm_install_alt_tasks()
{
    local res
    # TODO: don't use apt-repo
    apt_repo_prepare

    sudocmd_foreach "apt-repo test" $(tasknumber "$@")
    res=$?

    apt_repo_after
    return $res
}

# File bin/epm-install-apt-dpkg:

epm_install_files_apt_dpkg()
{
    local files="$*"
    [ -z "$files" ] && return

    # the new version of the conf. file is installed with a .dpkg-dist suffix
    if [ -n "$non_interactive" ] ; then
        DPKGOPTIONS="--force-confdef --force-confold"
    fi

    if __epm_repack_if_needed $files ; then
        [ -n "$repacked_pkgs" ] || fatal "Can't convert $files"
        files="$repacked_pkgs"
    fi

    if [ -n "$save_only" ] ; then
        echo
        cp -v $files "$EPMCURDIR"
        return
    fi

    if [ -n "$put_to_repo" ] ; then
        epm_put_to_repo $files
        return
    fi


    # TODO: if dpkg can't install due missed deps, trying with apt (as for now, --refuse-depends, --refuse-breaks don't help me)

    if [ -n "$nodeps" ] ; then
        sudocmd dpkg $DPKGOPTIONS -i $files
        return
    fi

    # for too old apt-get
    # TODO: check apt-get version?
    apt_can_install_files='1'
    if [ "$DISTRNAME" = "Ubuntu" ] ; then
        [ "$DISTRVERSION" = "14.04" ] && apt_can_install_files=''
        [ "$DISTRVERSION" = "12.04" ] && apt_can_install_files=''
    fi

    if [ -n "$apt_can_install_files" ] ; then
        # TODO: don't resolve fuzzy dependencies ()
        # are there apt that don't support dpkg files to install?
        epm_install_names $(make_filepath $files)
        return
    fi

    # old way:

    sudocmd dpkg $DPKGOPTIONS -i $files
    local RES=$?

    # return OK if all is OK
    [ "$RES" = "0" ] && return $RES

    # TODO: workaround with epm-check needed only for very old apt

    # run apt -f install if there are were some errors during install
    epm_check

    # repeat install for get correct status
    sudocmd dpkg $DPKGOPTIONS -i $files
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
    #    else
    #        TARBALLS="$TARBALLS $i"
        fi
    done
}

# File bin/epm-install-print-command:


epm_print_install_files_command()
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
        eopkg)
            echo "eopkg install $*"
            ;;
        android)
            echo "pm install $*"
            ;;
        termux-pkg)
            echo "pkg install $*"
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
        apt-rpm)
            echo "apt-get -y --force-yes -o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true $APTOPTIONS install $*"
            return ;;
        apt-dpkg)
            # this command  not for complex use. ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive
            echo "apt-get -y --force-yes -o APT::Install::VirtualVersion=true -o APT::Install::Virtual=true $APTOPTIONS install $*"
            return ;;
        aptitude-dpkg)
            echo "aptitude -y install $*"
            return ;;
        yum-rpm)
            echo "yum -y $YUMOPTIONS install $*"
            return ;;
        dnf-rpm)
            echo "dnf -y $YUMOPTIONS --allowerasing install $*"
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
        choco)
            echo "choco install $*"
            return ;;
        nix)
            echo "nix-env --install $*"
            return ;;
        eopkg)
            echo "eopkg install $*"
            return ;;
        termux-pkg)
            echo "pkg install $*"
            return ;;
        appget|winget)
            echo "$PMTYPE install $*"
            return ;;
        *)
            fatal "Have no suitable appropriate install command for $PMTYPE"
            ;;
    esac
}


# File bin/epm-install-rpm:

epm_install_files_rpm()
{
    local files="$*"
    [ -z "$files" ] && return

    if __epm_repack_if_needed $files ; then
        [ -n "$repacked_pkgs" ] || fatal "Can't convert $files"
        files="$repacked_pkgs"
    fi

    if [ -n "$save_only" ] ; then
        echo
        cp -v $files "$EPMCURDIR"
        return
    fi

    if [ -n "$put_to_repo" ] ; then
        epm_put_to_repo $files
        return
    fi


    __epm_check_if_src_rpm $files

    # --replacepkgs: Install the Package Even If Already Installed
    local replacepkgs="$(__epm_get_replacepkgs $files)"
    sudocmd rpm -Uvh $replacepkgs $(subst_option dryrun --test) $force $noscripts $nodeps $files && return
    local RES=$?

    __epm_check_if_rpm_already_installed $force $replacepkgs $noscripts $nodeps $files && return

    # if run with --nodeps, do not fallback on hi level
    [ -n "$nodeps" ] && return $RES

    # fallback to install names

    # separate second output
    info

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

    epm_install_names $files
    return

}

# File bin/epm-kernel_update:


epm_kernel_update()
{
    warmup_bases

    update_repo_if_needed

    info "Updating system kernel to the latest version..."

    case $BASEDISTRNAME in
    "alt")
        if ! __epm_query_package kernel-image >/dev/null ; then
            info "No installed kernel packages, skipping update"
            return
        fi
        assure_exists update-kernel update-kernel 0.9.9
        sudocmd update-kernel $dryrun $(subst_option non_interactive -y) $force $interactive $reinstall $verbose "$@" || return
        #docmd epm remove-old-kernels "$@" || fatal
        return ;;
    esac

    case $PMTYPE in
    dnf-rpm)
        docmd epm install kernel
        ;;
    apt-*)
        echo "Skipping: kernel package will update during dist-upgrade"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
    esac
}

# File bin/epm-list:

epm_list_help()
{
    cat <<EOF
epm list - list packages
Usage: epm list [options] [package]

Options:
  --available           list only available packages
  --installed           list only installed packages
  --upgradable          list only upgradable packages
EOF
}

epm_list()
{
    local option="$1"

    if [ -z "$1" ] ; then
        # locally installed packages by default
        epm_packages "$@"
        return
    fi

    shift

    case "$option" in
        -h|--help)
            epm_list_help
            return
            ;;
        #--all)
        #    # TODO: exclude locally installed?
        #    epm_list_available
        #    return
        #    ;;
        --available)
            # TODO: exclude locally installed?
            epm_list_available "$@"
            return
            ;;
        --installed)
            epm_packages "$@"
            return
            ;;
        --upgradable)
            # TODO: exclude locally installed?
            epm_list_upgradable "$@"
            return
            ;;
        *)
            fatal "Unknown option $option, use epm list --help to get info"
            ;;
    esac

    epm_list_help >&2
    fatal "Run with appropriate option"
}

# File bin/epm-list_available:


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

epm_list_available()
{

    if [ -n "$1" ] ; then
        # list --available with args is the same as search
        epm_search "$@"
        return
    fi

case $PMTYPE in
    apt-*)
        warmup_dpkgbase
        # TODO: use apt list
        if [ -n "$short" ] ; then
            docmd apt-cache search . | sed -e "s| .*||g"
        else
            docmd apt-cache search .
        fi
        ;;
    dnf-*)
        warmup_rpmbase
        if [ -n "$short" ] ; then
            docmd dnf list --available | sed -e "s| .*||g"
        else
            docmd dnf list --available
        fi
        ;;
    yum-*)
        warmup_rpmbase
        if [ -n "$short" ] ; then
            docmd yum list available | sed -e "s| .*||g"
        else
            docmd yum list available
        fi
        ;;
    packagekit)
        # see for filter list: pkcon get-filters
        # TODO: implement --short
        docmd pkcon get-packages -p | sed -e "s| (.*||g" -e "s|.* ||"
        ;;
    snappy)
        docmd snappy find .
        ;;
    snap)
        docmd snap find .
        ;;
    appget)
        docmd appget search .
        ;;
    winget)
        docmd winget search .
        ;;
    emerge)
        docmd eix --world
        ;;
    termux-pkg)
        docmd pkg list-all
        ;;
    npackd)
        CMD="npackdcl list"
        ;;
    eopkg)
        CMD="eopkg list-available"
        ;;
    choco)
        CMD="choco search ."
        ;;
    slackpkg)
        CMD="slackpkg search ."
        ;;
    homebrew)
        docmd brew search .
        ;;
    opkg)
        CMD="opkg list-available"
        ;;
    apk)
        CMD="apk list --available"
        ;;
    nix)
        CMD="nix-env -qaP"
        ;;
    xbps)
        CMD="xbps-query -l -R"
        showcmd $CMD
        if [ -n "$short" ] ; then
            $CMD | sed -e "s|^ii ||g" -e "s| .*||g" -e "s|\(.*\)-.*|\1|g" | __fo_pfn
        else
            $CMD | sed -e "s|^ii ||g" -e "s| .*||g" | __fo_pfn
        fi
        return 0
        ;;
    *)
        fatal "Have no suitable query command for $PMTYPE"
        ;;
esac

if [ -n "$CMD" ] ; then
    docmd $CMD | __fo_pfn
fi

}

# File bin/epm-list_upgradable:


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

epm_list_upgradable()
{

case $PMTYPE in
    apt-rpm)
        warmup_dpkgbase
        if [ -n "$short" ] ; then
            docmd epm upgrade --dry-run | grep "^Inst " | sed -e "s|^Inst ||" -e "s| .*||g"
        else
            docmd epm upgrade --dry-run | grep "^Inst " | sed -e "s|^Inst ||"
        fi
        ;;
    apt-dpkg)
        warmup_dpkgbase
        if [ -n "$short" ] ; then
            docmd apt list --upgradable | sed -e "s|/.*||g"
        else
            docmd apt list --upgradable
        fi
        ;;
    dnf-*|yum-*)
        warmup_rpmbase
        if [ -n "$short" ] ; then
            docmd dnf check-update | sed -e "s| .*||g"
        else
            docmd dnf check-update
        fi
        ;;
    zypper)
        docmd zypper list-updates --all
        ;;
    snap)
        docmd snap refresh --list
        ;;
    winget)
        docmd winget upgrade
        ;;
    *)
        fatal "Have no suitable query command for $PMTYPE"
        ;;
esac

if [ -n "$CMD" ] ; then
    docmd $CMD | __fo_pfn
fi

}

# File bin/epm-mark:

__is_wildcard()
{
    echo "$1" | grep -q "[*?]"
}

__alt_mark_hold_package()
{
        local pkg="$1"
        showcmd "echo \"RPM::Hold {\"^$pkg\";};\" > /etc/apt/apt.conf.d/hold-$pkg.conf"
        echo "RPM::Hold {\"^$pkg\";};" | sudorun tee "/etc/apt/apt.conf.d/hold-$pkg.conf" >/dev/null
}

__alt_test_glob()
{
    echo "$*" | grep -q "\.[*?]" && warning "Only glob symbols * and ? are supported. Don't use regexp here!"
}

__alt_mark_hold()
{
    # TODO: do more long checking via apt
    local pkg
    local i
    __alt_test_glob "$*"
    for i in "$@" ; do
        if __is_wildcard "$i" ; then
            local pkglist
            pkglist="$(epm qp --short "^$i")" || continue
            for pkg in $pkglist ; do
                __alt_mark_hold_package $pkg
            done
            return
        else
            pkg="$(epm query --short "$i")" || continue
        fi
        __alt_mark_hold_package $pkg
    done
}

__alt_mark_unhold()
{
    # TODO: do more long checking via apt
    local pkg
    local i
    __alt_test_glob "$*"
    for i in "$@" ; do
        pkg="$(epm query --short "$i")" || pkg="$i"
        sudocmd rm -fv /etc/apt/apt.conf.d/hold-$pkg.conf
    done
}

__alt_mark_showhold()
{
    grep -h "RPM::Hold" /etc/apt/apt.conf.d/hold-*.conf 2>/dev/null | sed -e 's|RPM::Hold {"^\(.*\)";};|\1|'
}

__dnf_assure_versionlock()
{
    epm assure /etc/dnf/plugins/versionlock.conf 'dnf-command(versionlock)'
}

__dnf_is_supported_versionlock()
{
    [ -f /etc/dnf/plugins/versionlock.conf ]
}

epm_mark_hold()
{

case $BASEDISTRNAME in
    "alt")
        __alt_mark_hold "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        sudocmd apt-mark hold "$@"
        ;;
    dnf-rpm)
        __dnf_assure_versionlock
        sudocmd dnf versionlock add "$@"
        ;;
    zypper-rpm)
        sudocmd zypper al "$@"
        ;;
    emerge)
        info "Check /etc/portage/package.mask"
        ;;
    pacman)
        info "Manually: edit /etc/pacman.conf modifying IgnorePkg array"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_mark_unhold()
{

case $BASEDISTRNAME in
    "alt")
        __alt_mark_unhold "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        sudocmd apt-mark unhold "$@"
        ;;
    dnf-rpm)
        __dnf_assure_versionlock
        sudocmd dnf versionlock delete "$@"
        ;;
    zypper-rpm)
        sudocmd zypper rl "$@"
        ;;
    emerge)
        info "Check /etc/portage/package.mask (package.unmask)"
        ;;
    pacman)
        info "Manually: edit /etc/pacman.conf removing package from IgnorePkg line"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_mark_showhold()
{

case $BASEDISTRNAME in
    "alt")
        __alt_mark_showhold "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        docmd apt-mark showhold "$@"
        ;;
    dnf-rpm)
        # there is no hold entries without versionlock
        __dnf_is_supported_versionlock || return 0
        __dnf_assure_versionlock
        if [ -n "$short" ] ; then
            docmd dnf versionlock list "$@" | sed -e 's|\.\*$||' | grep -v " " | filter_pkgnames_to_short
        else
            docmd dnf versionlock list "$@"
        fi
        ;;
    zypper-rpm)
        docmd zypper ll "$@"
        ;;
    emerge)
        cat /etc/portage/package.mask
        ;;
    pacman)
        cat /etc/pacman.conf
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

epm_mark_checkhold()
{
case $PMTYPE in
    dnf-rpm)
        # there is no hold entries without versionlock
        __dnf_is_supported_versionlock || return 1
        __dnf_assure_versionlock
        docmd dnf versionlock list | grep "^$1" | sed -e 's|\.\*$||' | grep -v " " | filter_pkgnames_to_short | grep -q "^$1$"
        return
        ;;
esac

epm_mark_showhold | grep -q "^$1$"

}


epm_mark_auto()
{

case $BASEDISTRNAME in
    "alt")
        sudocmd apt-mark auto "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        sudocmd apt-mark auto "$@"
        ;;
    dnf-rpm)
        sudocmd dnf mark remove "$@"
        ;;
    pacman)
            sudocmd pacman -D --asdeps "$@"
        ;;
    emerge)
            sudocmd emerge --oneshot "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_mark_manual()
{

case $BASEDISTRNAME in
    "alt")
        sudocmd apt-mark manual "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        sudocmd apt-mark manual "$@"
        ;;
    dnf-rpm)
        sudocmd dnf mark install "$@"
        ;;
    pacman)
            sudocmd pacman -D --asexplicit "$@"
        ;;
    emerge)
            sudocmd emerge --select "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_mark_showauto()
{

case $BASEDISTRNAME in
    "alt")
        sudocmd apt-mark showauto "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        sudocmd apt-mark showauto "$@"
        ;;
    dnf-rpm)
        sudocmd dnf repoquery --unneeded
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

epm_mark_showmanual()
{

case $BASEDISTRNAME in
    "alt")
        sudocmd apt-mark showmanual "$@"
        exit
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        sudocmd apt-mark showmanual "$@"
        ;;
    dnf-rpm)
        sudocmd dnf repoquery --userinstalled
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

epm_mark_help()
{
    echo "mark is the interface for marking packages"
            get_help HELPCMD $SHAREDIR/epm-mark
    cat <<EOF
Examples:
  epm mark hold mc
  epm manual mc
EOF
}

epm_mark()
{
    local CMD="$1"
    [ -n "$CMD" ] && shift
    case "$CMD" in
    ""|"-h"|"--help"|help)               # HELPCMD: help
        epm_mark_help
        ;;
    hold)                             # HELPCMD: mark the given package(s) as held back
        epm_mark_hold "$@"
        ;;
    unhold)                           # HELPCMD: unset the given package(s) as held back
        epm_mark_unhold "$@"
        ;;
    showhold)                         # HELPCMD: print the list of packages on hold
        epm_mark_showhold "$@"
        ;;
    checkhold)                        # HELPCMD: return true if the package is on hold
        epm_mark_checkhold "$@"
        ;;
    auto|remove)                      # HELPCMD: mark the given package(s) as automatically installed
        epm_mark_auto "$@"
        ;;
    manual|install)                   # HELPCMD: mark the given package(s) as manually installed
        epm_mark_manual "$@"
        ;;
    showauto)                         # HELPCMD: print the list of automatically installed packages
        epm_mark_showauto "$@"
        ;;
    showmanual)                       # HELPCMD: print the list of manually installed packages
        epm_mark_showmanual "$@"
        ;;
    *)
        fatal "Unknown command $ epm repo '$CMD'"
        ;;
esac

}

# File bin/epm-moo:

epm_moo()
{

    local figlet cowsay docmd
    epm assure figlet && figlet="figlet"
    epm assure cowsay cowsay-soft && cowsay="cowsay"

    [ -n "$verbose" ] && docmd="docmd"
    [ -n "$figlet" ] && $docmd $figlet "EPM"
    [ -n "$cowsay" ] && $docmd $cowsay "EPM from Etersoft"
    [ -n "$figlet" ] && $docmd $figlet "Etersoft"

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

# File bin/epm-pack:


[ -n "$EPM_PACK_SCRIPTS_DIR" ] || EPM_PACK_SCRIPTS_DIR="$CONFIGDIR/pack.d"

__epm_pack_run_handler()
{
    local packname="$1"
    local tarname="$2"
    local packversion="$3"
    local url="$4"
    returntarname=''

    local repackcode="$EPM_PACK_SCRIPTS_DIR/$packname.sh"
    [ -s "$repackcode" ] || return
    [ -f "$repackcode.rpmnew" ] && warning "There is .rpmnew file(s) in $EPM_PACK_SCRIPTS_DIR dir. The pack script can be outdated."

    # a file to keep filename of generated tarball
    filefortarname="$(pwd)/filefortarname"

    [ "$PROGDIR" = "/usr/bin" ] && SCPATH="$PATH" || SCPATH="$PROGDIR:$PATH"
    local bashopt=''
    [ -n "$debug" ] && bashopt='-x'
    #info "Running $($script --description 2>/dev/null) ..."
    # TODO: add url info here
    ( unset EPMCURDIR ; export PATH=$SCPATH ; export HOME=$(pwd) ; docmd $CMDSHELL $bashopt $repackcode "$tarname" "$filefortarname" "$packversion" "$url") || fatal
    returntarname="$(cat "$filefortarname")" || fatal "pack script $repackcode didn't set tarname"

    local i
    for i in $returntarname ; do
        [ -s "$i" ] || fatal "pack script for $packname returned a non-existent file $i"
    done

    return 0
}

__epm_pack()
{
    local packname="$1"
    local URL="$4"

    # fills returntarname with packed tar
    __epm_pack_run_handler "$@" || fatal "Can't find pack script for packname $packname"

    if [ -n "$download_only" ] ; then
        mv $returntarname $EPMCURDIR
        return
    fi

    # TODO: merge eepm.yaml here (common with $returntarname.eepm.yaml)
    # add upstream_url: $URL too

    # note: this repack related code here for follow reasons:
    #  * repack by default if we have repack rule
    #  * get repacked files
    #  * install (repacked) files
    # the most replacement is epm repack [--install] or epm install [--repack]

    # FIXME: check for every package would be more reliable
    # by default
    dorepack='--repack'
    # don't repack by default there is our pkg format
    __epm_split_by_pkg_type $PKGFORMAT $returntarname && dorepack=''
    # repack if we have a repack rule for it
    [ -z "$norepack" ] && __epm_check_repack_rule $returntarname && dorepack='--repack'
    # repack if forced
    [ -n "$repack" ] && dorepack='--repack'

    local pkgnames
    if [ -n "$dorepack" ]  ; then
        __epm_repack $returntarname
        [ -n "$repacked_pkgs" ] || fatal "Can't repack $returntarname"
        # remove packed file if we have repacked one
        rm -f $returntarname
        pkgnames="$repacked_pkgs"
    else
        pkgnames="$returntarname"
    fi

    if [ -n "$install" ] ; then
        docmd epm install $pkgnames
        return
    fi

    # we need put result in the cur dir
    mv -v $pkgnames $EPMCURDIR || fatal

    local i
    for i in "$returntarname" ; do
        [ -r "$i.eepm.yaml" ] && mv -v "$i.eepm.yaml" $EPMCURDIR
    done

    return 0
}

epm_pack_help()
{
    cat <<EOF
epm pack - create rpm package from files
Usage: epm pack [options] <packname> <tar|url|dir> [version]
Options:
    <packname>            - receipt
    <dir>                 - create tarball from the dir before
    <url>                 - download tar from url
    [version]             - force version for unversioned sources
    --install             - install after pack result
    --repack              - force repack ever if returned package can be installed without repack
    --download-only       - save pack result and exit
    --save-only           - save repacked packages and exit (this is default behaviour)
EOF
}


epm_pack()
{

    if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
        epm_pack_help
        exit
    fi

    local tmpdir
    tmpdir="$(mktemp -d --tmpdir=$BIGTMPDIR)" || fatal
    remove_on_exit "$tmpdir"

    local packname="$1"
    local tarname="$2"
    local packversion="$3"
    local url=''

    [ -n "$packname" ] || fatal "run with packname, see --help"

    if is_url "$tarname"; then
        url="$tarname"
        pkg_urls="$tarname"
        cd $tmpdir || fatal

        __download_pkg_urls
        pkg_urls=

        [ -n "$pkg_files" ] || fatal "Can't download $tarname"
        tarname="$(realpath "$pkg_files")"
    elif [ -d "$tarname" ] ; then
        tarname="$(realpath "$tarname")"
    elif [ -s "$tarname" ] ; then
        # get full path for real name
        tarname="$(realpath "$tarname")"
    else
        # just pass name
        true
    fi

    cd $tmpdir || fatal
    __epm_pack "$packname" "$tarname" "$packversion" "$url"

}

# File bin/epm-packages:


__epm_packages_sort()
{
case $PMTYPE in
    *-rpm)
        # FIXME: space with quotes problems, use point instead
        warmup_rpmbase
        docmd rpm -qa --queryformat "%{size}@%{name}-%{version}-%{release}\n" "$@" | sed -e "s|@| |g" | sort -n -k1
        ;;
    *-dpkg)
        warmup_dpkgbase
        docmd dpkg-query -W --showformat="\${Installed-Size}@\${Package}-\${Version}:\${Architecture}\n" "$@" | sed -e "s|@| |g" | sort -n -k1
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
    grep -v "^$" | grep -- "$*"
}

epm_packages()
{
    local CMD
    [ -n "$sort" ] && __epm_packages_sort "$@" && return

case $PMTYPE in
    *-dpkg)
        warmup_dpkgbase
        # FIXME: strong equal
        #CMD="dpkg -l $pkg_filenames"
        CMD="dpkg-query -W --showformat=\${db:Status-Abbrev}\${Package}-\${Version}:\${Architecture}\n"
        # TODO: ${Architecture}
        [ -n "$short" ] && CMD="dpkg-query -W --showformat=\${db:Status-Abbrev}\${Package}\n"
        showcmd $CMD "$@"
        $CMD "$@" | grep "^i" | sed -e "s|.* ||g" | __fo_pfn "$@"
        return ;;
    *-rpm)
        warmup_rpmbase
        # FIXME: strong equal
        CMD="rpm -qa"
        [ -n "$short" ] && CMD="rpm -qa --queryformat %{name}\n"
        docmd $CMD "$@" | __fo_pfn "$@"
        return ;;
    packagekit)
        docmd pkcon get-packages --filter installed
        ;;
    snappy)
        CMD="snappy info"
        ;;
    snap)
        CMD="snap list"
        ;;
    flatpak)
        CMD="flatpak list --app"
        ;;
    emerge)
        CMD="qlist -I -C"
        # print with colors for console output
        isatty && CMD="qlist -I"
        ;;
    pkgsrc)
        CMD="pkg_info"
        showcmd $CMD
        $CMD | sed -e "s| .*||g" | __fo_pfn "$@"
        return ;;
    pkgng)
        if [ -n "$@" ] ; then
            CMD="pkg info -E $@"
        else
            CMD="pkg info"
        fi
        showcmd $CMD
        if [ -n "$short" ] ; then
            $CMD | sed -e "s| .*||g" | sed -e "s|-[0-9].*||g" | __fo_pfn "$@"
        else
            $CMD | sed -e "s| .*||g" | __fo_pfn "$@"
        fi
        return ;;
    pacman)
        CMD="pacman -Qs $@"
        showcmd $CMD
        if [ -n "$short" ] ; then
            $CMD | sed -e "s| .*||g" -e "s|.*/||g" | __fo_pfn "$@"
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
    eopkg)
        CMD="eopkg list-installed"
        ;;
    choco)
        CMD="choco list"
        ;;
    slackpkg)
        CMD="ls -1 /var/log/packages/"
        if [ -n "$short" ] ; then
            # FIXME: does not work for libjpeg-v8a
            # TODO: remove last 3 elements (if arch is second from the last?)
            # FIXME this hack
            docmd ls -1 /var/log/packages/ | sed -e "s|-[0-9].*||g" | sed -e "s|libjpeg-v8a.*|libjpeg|g" | __fo_pfn "$@"
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
        CMD="apk list --installed"
        ;;
    nix)
        CMD="nix-env -q"
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
        CMD="winget list"
        ;;
    termux-pkg)
        docmd pkg list-installed
        ;;
    xbps)
        CMD="xbps-query -l"
        showcmd $CMD
        if [ -n "$short" ] ; then
            $CMD | sed -e "s|^ii ||g" -e "s| .*||g" -e "s|\(.*\)-.*|\1|g" | __fo_pfn "$@"
        else
            $CMD | sed -e "s|^ii ||g" -e "s| .*||g" | __fo_pfn "$@"
        fi
        return 0
        ;;
    android)
        CMD="pm list packages"
        showcmd $CMD
        $CMD | sed -e "s|^package:||g" | __fo_pfn "$@"
        return
        ;;
    aptcyg)
        CMD="apt-cyg list $@"
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

docmd $CMD | __fo_pfn "$@"

}

# File bin/epm-play:


__check_installed_app()
{
    [ -s $epm_vardir/installed-app ] || return 1
    grep -q -- "^$1\$" $epm_vardir/installed-app
}

__save_installed_app()
{
    [ -d "$epm_vardir" ] || return 0
    __check_installed_app "$1" && return 0
    echo "$1" | sudorun tee -a $epm_vardir/installed-app >/dev/null
}

__remove_installed_app()
{
    [ -s $epm_vardir/installed-app ] || return 0
    local i
    for i in $* ; do
        sudorun sed -i "/^$i$/d" $epm_vardir/installed-app
    done
    return 0
}


__is_app_installed()
{
    __run_script "$1" --installed "$2"
    return
}

__run_script()
{
    local script="$psdir/$1.sh"
    [ -s "$script" ] || return
    [ -f "$script.rpmnew" ] && warning "There is .rpmnew file(s) in $psdir dir. The play script can be outdated."

    shift
    [ "$PROGDIR" = "/usr/bin" ] && SCPATH="$PATH" || SCPATH="$PROGDIR:$PATH"
    ( unset EPMCURDIR ; export PATH=$SCPATH ; $script "$@" )
    return
}

__get_app_package()
{
    __run_script "$1" --package-name "$2" "$3" 2>/dev/null
}



__list_all_app()
{
    cd $psdir || fatal
    for i in *.sh ; do
       local name=${i/.sh/}
       [ -n "$IGNOREi586" ] && startwith "$name" "i586-" && continue
       startwith "$name" "common" && continue
       echo "$name"
    done
    cd - >/dev/null
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
        local pkg="$(__get_app_package $name)"
        [ -n "$pkg" ] || continue
        echo "$pkg $name"
    done
}

__filter_by_installed_packages()
{
    local i
    local tapt="$1"

    local pkglist
    pkglist="$(mktemp)" || fatal
    remove_on_exit $pkglist

    # get intersect between full package list and available packages table
    epm --short packages | LC_ALL=C sort -u >$pkglist
    LC_ALL=C join -11 -21 $tapt $pkglist | uniq
    rm -f $pkglist

    # rpm on Fedora/CentOS no more print missed packages to stderr
    # get supported packages list and print lines with it
    #for i in $(epm query --short $(cat $tapt | cut -f1 -d" ") 2>/dev/null) ; do
    #    grep "^$i " $tapt
    #done
}

__get_installed_table()
{
    local i
    local tapt
    tapt="$(mktemp)" || fatal
    remove_on_exit $tapt
    __list_app_packages_table | LC_ALL=C sort -u >$tapt
    __filter_by_installed_packages $tapt
    rm -f $tapt
}

__list_installed_app()
{
    # get all installed packages and convert it to a apps list
    __get_installed_table | cut -f2 -d" "
}

__list_installed_packages()
{
    # get all installed packages
    __get_installed_table | cut -f1 -d" "
}


__get_app_description()
{
    __run_script "$1" --description "$2" 2>/dev/null
}

__check_play_script()
{
    local script="$psdir/$1.sh"
    shift

    [ -s "$script" ]
}


__epm_play_run_script()
{
    local script="$1"
    shift

    local addopt
    addopt="$dryrun $non_interactive"

    local bashopt=''
    [ -n "$debug" ] && bashopt='-x'
    #info "Running $($script --description 2>/dev/null) ..."
    [ "$PROGDIR" = "/usr/bin" ] && SCPATH="$PATH" || SCPATH="$PROGDIR:$PATH"
    ( export EPM_OPTIONS="$EPM_OPTIONS $addopt" export PATH=$SCPATH ; docmd $CMDSHELL $bashopt $script "$@" )
}

__epm_play_run()
{
    local script="$psdir/$1.sh"
    shift
    __epm_play_run_script "$script" "$@"
}

__epm_play_list_installed()
{
    local i
    if [ -n "$short" ] ; then
        for i in $(__list_installed_app) ; do
            # skip hidden apps
            local desc="$(__get_app_description $i)"
            [ -n "$desc" ] || continue
            echo "$i"
        done
        exit
    fi
    [ -n "$quiet" ] || echo "Installed applications:"
    for i in $(__list_installed_app) ; do
        # skip hidden apps
        local desc="$(__get_app_description $i)"
        [ -n "$desc" ] || continue
        [ -n "$quiet" ] || echo -n "  "
        printf "%-20s - %s\n" "$i" "$desc"
    done
}


__epm_play_list()
{
    local psdir="$1"
    local extra="$2"
    local i
    local IGNOREi586
    local arch="$SYSTEMARCH"
    [ "$arch" = "x86_64" ] && IGNOREi586='' || IGNOREi586=1

    if [ -n "$short" ] ; then
        for i in $(__list_all_app) ; do
            local desc="$(__get_app_description $i $arch)"
            [ -n "$desc" ] || continue
            echo "$i"
            if [ -n "$extra" ] ; then
                for j in $(__run_script "$i" "--product-alternatives") ; do
                    echo "  $i=$j"
                done
            fi
        done
        exit
    fi

    for i in $(__list_all_app) ; do
        local desc="$(__get_app_description $i $arch)"
        [ -n "$desc" ] || continue
        [ -n "$quiet" ] || echo -n "  "
        printf "%-20s - %s\n" "$i" "$desc"
        if [ -n "$extra" ] ; then
            for j in $(__run_script "$i" "--product-alternatives") ; do
                printf "  %-20s - %s\n" "$i=$j" "$desc"
            done
        fi
    done
}


epm_play_help()
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
    --short (with --list) - list names only
    --installed <app>     - check if the app is installed
    --product-alternatives- list alternatives (use like epm play app=beta)

Examples:
    epm play --remove opera
    epm play yandex-browser = beta
    epm play telegram = beta
    epm play telegram = 4.7.1
    epm play --update all
EOF
}

__epm_is_shell_script()
{
    local script="$1"
    [ -x "$script" ] && rhas "$script" "\.sh$" && head -n1 "$script" | grep -q "^#!/bin/sh"
}

__epm_play_remove()
{
    local prescription
    for prescription in $* ; do
        if __epm_is_shell_script "$prescription"  ; then
            __epm_play_run_script $prescription --remove
            continue
        fi
        if __check_play_script "$prescription" ; then
            __epm_play_run $prescription --remove
            __remove_installed_app "$prescription"
        else
            psdir=$prsdir
            __check_play_script "$prescription" || fatal "We have no idea how to remove $prescription (checked in $psdir and $prsdir)"
            __epm_play_run "$prescription" --remove || fatal "There was some error during run the script."
        fi
    done
}


__epm_play_update()
{
    local i RES
    local CMDUPDATE="$1"
    shift
    RES=0
    for i in $* ; do
        echo
        echo "$i"
            if ! __is_app_installed "$i" ; then
                warning "$i is not installed"
                continue
            fi
        prescription="$i"
        if ! __check_play_script $prescription ; then
            warning "Can't find executable play script for $prescription. Try epm play --remove $prescription if you don't need it anymore."
            RES=1
            continue
        fi
        __epm_play_run $prescription $CMDUPDATE || RES=$?
    done
    return $RES
}


__epm_play_install_one()
{
    local prescription="$1"
    shift

    if __epm_is_shell_script "$prescription"  ; then
        # direct run play script
        __epm_play_run_script "$prescription" --run "$@" || fatal "There was some error during install the application."
        return
    fi

    if __check_play_script "$prescription" ; then
        #__is_app_installed "$prescription" && info "$$prescription is already installed (use --remove to remove)" && exit 1
        __epm_play_run "$prescription" --run "$@" && __save_installed_app "$prescription" || fatal "There was some error during install the application."
    else
        opsdir=$psdir
        psdir=$prsdir
        __check_play_script "$prescription" || fatal "We have no idea how to play $prescription (checked in $opsdir and $prsdir)"
        __epm_play_run "$prescription" --run "$@" || fatal "There was some error during run $prescription script."
    fi
}


__epm_play_install()
{
   local i RES
   RES=0


   update_repo_if_needed

   # get all options
   options=''
   for i in  $* ; do
       case "$i" in
           --*)
               options="$options $i"
               ;;
       esac
   done

   while [ -n "$1" ] ; do
       case "$1" in
           --*)
               shift
               continue
               ;;
       esac
       local p="$1"
       local v=''
       # drop spaces
       n="$(echo $2)"
       if [ "$n" = "=" ] ; then
           v="$3"
           shift 3
       else
           shift
       fi
       __epm_play_install_one "$p" "$v" $options || RES=1
   done

   return $RES
}

__epm_play_download_epm_file()
{
    local target="$1"
    local file="$2"
    # use short version (3.4.5)
    local epmver="$(epm --short --version)"
    local URL
    for URL in "https://eepm.ru/releases/$epmver/app-versions" "https://eepm.ru/app-versions" ; do
        info "Updating local IPFS DB in $eget_ipfs_db file from $URL/eget-ipfs-db.txt"
        docmd eget -q -O "$target" "$URL/$file" && return
    done
}


__epm_play_initialize_ipfs()
{
    if [ ! -d "$(dirname "$eget_ipfs_db")" ] ; then
        warning "ipfs db dir $eget_ipfs_db does not exist, skipping IPFS mode"
        return 1
    fi

    if [ ! -r "$eget_ipfs_db" ] ; then
        sudorun touch "$eget_ipfs_db" >&2
        sudorun chmod -v a+rw "$eget_ipfs_db" >&2
    fi

    # download and merge with local db
    local t
    t=$(mktemp) || fatal
    remove_on_exit $t
    __epm_play_download_epm_file "$t" "eget-ipfs-db.txt" || warning "Can't update IPFS DB"
    if [ -s "$t" ] && [ -z "$EPM_IPFS_DB_UPDATE_SKIPPING" ] ; then
        echo >>$t
        cat $eget_ipfs_db >>$t
        sort -u < $t | grep -v "^$" > $eget_ipfs_db
    fi

    # the only one thing is needed to enable IPFS in eget
    export EGET_IPFS_DB="$eget_ipfs_db"
}

epm_play()
{
[ "$EPMMODE" = "package" -o "$EPMMODE" = "git" ] || fatal "epm play is not supported in single file mode"
local psdir="$(realpath $CONFIGDIR/play.d)"
local prsdir="$(realpath $CONFIGDIR/prescription.d)"

if [ -z "$1" ] ; then
    [ -n "$short" ] || [ -n "$quiet" ] || echo "Available applications (for current arch $DISTRARCH):"
    __epm_play_list $psdir
    exit
fi


while [ -n "$1" ] ; do
case "$1" in
    -h|--help)
        epm_play_help
        exit
        ;;

    --ipfs)
        shift
        __epm_play_initialize_ipfs
        ;;

    --remove)
        shift
        if [ -z "$1" ] ; then
            fatal "run --remove with 'all' or a project name"
        fi

        local list
        if [ "$1" = "all" ] ; then
            shift
            info "Retrieving list of installed apps ..."
            list="$(__list_installed_app)"
        else
            list="$*"
        fi

        __epm_play_remove $list
        exit
        ;;

    --update)
        shift
        local CMDUPDATE="--update"
        # check --force on common.sh side
        #[ -n "$force" ] && CMDUPDATE="--run"

        if [ -z "$1" ] ; then
            fatal "run --update with 'all' or a project name"
        fi

        local list
        if [ "$1" = "all" ] ; then
            shift
            info "Retrieving list of installed apps ..."
            list="$(__list_installed_app)"
        else
            list="$*"
        fi

        __epm_play_update $CMDUPDATE $list
        exit
        ;;

    --installed)
        shift
        __is_app_installed "$1" "$2"
        #[ -n "$quiet" ] && exit
        exit
        ;;

    # internal options
    --installed-version|--package-name|--product-alternatives|--info)
        __run_script "$2" "$1" "$3"
        exit
        ;;
    --list-installed-packages)
        __list_installed_packages
        exit
        ;;
    --list|--list-installed)
        __epm_play_list_installed
        exit
        ;;

    --full-list-all)
        [ -n "$short" ] || [ -n "$quiet" ] || echo "Available applications (for current arch $DISTRARCH):"
        __epm_play_list $psdir extra
        exit
        ;;

    --list-all)
        [ -n "$short" ] || [ -n "$quiet" ] || echo "Available applications (for current arch $DISTRARCH):"
        __epm_play_list $psdir
        [ -n "$quiet" ] || [ -n "$*" ] && exit
        echo
        #echo "Run epm play --help for help"
        epm_play_help
        exit
        ;;

    --list-scripts)
        [ -n "$short" ] || [ -n "$quiet" ] || echo "Run with a name of a play script to run:"
        __epm_play_list $prsdir
        exit
        ;;
    -*)
        fatal "Unknown option $1"
        ;;
     *)
        break
        ;;
esac

done

__epm_play_install $(echo "$*" | sed -e 's|=| = |g')
}

# File bin/epm-policy:


epm_policy()
{

[ -n "$pkg_names" ] || fatal "Info: package name is missed"

warmup_bases

pkg_names=$(__epm_get_hilevel_name $pkg_names)

case $PMTYPE in
    apt-*)
        # FIXME: returns TRUE ever on missed package
        docmd apt-cache policy $pkg_names
        ;;
    dnf-*|yum-*)
        docmd dnf info $pkg_names
        ;;
    packagekit)
        docmd pkcon resolve $pkg_names
        ;;
    apk)
        docmd apk policy $pkg_names
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

if [ "$1" = "--list-all" ] || [ -z "$*" ] ; then
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

is_pkgfile()
{
     [ -f "$1" ] || return
     echo "$1" | grep -q "\.rpm$" && return
     echo "$1" | grep -q "\.deb$" && return
     return 1
}

rpm_query_package_format_field()
{
    local FORMAT="$1\n"
    shift
    local INSTALLED=""
    # if a file, add -p for get from rpm base
    if is_pkgfile "$1" ; then
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
        if is_pkgfile "$1" ; then
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


print_pkg_arch()
{
    case $PMTYPE in
        *-dpkg)
            dpkg_query_package_field "Arch" "$@" | sed -e "s|-.*||" -e "s|.*:||"
            ;;
        *-rpm)
            rpm_query_package_field "arch" "$@"
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
            rpm_query_package_format_field "%{version}-%{release}" "$@"
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



PKGNAMEMASK4="6\(.*\)[_-]\([^_-]*\)[_-]\(.*[0-9].*\):\(.*\)$"
PKGNAMEMASK3="^\(.*\)[_-]\([^_-]*\)[_-]\(.*[0-9].*\)$"

PKGNAMEMASK="\(.*\)-\([0-9].*\)-\(.*[0-9].*\)\.\(.*\)\.\(.*\)"

print_name()
{
    # FIXME:
    # don't change name (false cases)
    #echo "$@" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK4|\1-\2-\3|" -e "s|$PKGNAMEMASK3|\1|"
    echo "$@" | xargs -n1 echo
}

print_shortname()
{
    #if [ "$
    #echo "$@" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK4|\1-\2-\3|" -e "s|$PKGNAMEMASK3|\1|"
    echo "$@" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK3|\1|"
}

print_version()
{
    echo "$1" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK4|\1-\2-\3|" -e "s|$PKGNAMEMASK3|\2|"
}

print_release()
{
    echo "$1" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK4|\1-\2-\3|" -e "s|$PKGNAMEMASK3|\3|"
}

print_version_release()
{
    echo "$1" | xargs -n1 echo | sed -e "s|$PKGNAMEMASK4|\1-\2-\3|" -e "s|$PKGNAMEMASK3|\2-\3|"
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
    case $PMTYPE in
        *-rpm)
            # rpmevrcmp exists in ALT Linux only
            if is_command rpmevrcmp ; then
                a= rpmevrcmp "$@"
            else
                a= rpm --eval "%{lua:print(rpm.vercmp('$1', '$2'))}"
            fi
            ;;
        *-dpkg)
            a= dpkg --compare-versions "$1" lt "$2" && echo "-1" && return
            a= dpkg --compare-versions "$1" eq "$2" && echo "0" && return
            echo "1"
            ;;
        *)
            fatal "Not implemented for $PMTYPE"
            ;;
    esac
}

construct_name()
{
    local name="$1"
    local version="$2"
    local arch="$3"
    local pkgtype="$4"
    local ds="$5"
    local pds="$6"

    [ -n "$arch" ] || arch="$DISTRARCH"
    [ -n "$pkgtype" ] || pkgtype="$PKGFORMAT"
    [ -n "$ds" ] || ds=$(get_pkg_name_delimiter $pkgtype)
    [ -z "$pds" ] && pds="$ds" && [ "$pds" = "-" ] && pds="."
    [ -n "$version" ] && version="$ds$version"
    echo "${name}${version}${pds}$arch.$pkgtype"
}

epm_print_help()
{
cat <<EOF
  Examples:
    epm print info [args]                    print system and distro info (via distro_info command)
    epm print name [from filename|for package] NN        print only name of package name or package file
    epm print shortname [for package] NN        print only short name of package name
    epm print version [from filename|for package] NN     print only version of package name or package file
    epm print release [from filename|for package] NN     print only release of package name or package file
    epm print version-release [from filename|for package] NN     print only release-release of package name or package file
    epm print arch [from filename|for package] NN     print arch  of package name or package file
    epm print field FF for package NN        print field of the package
    epm print pkgname from filename NN       print package name for the package file
    epm print srcname from filename NN       print source name for the package file
    epm print srcpkgname from [filename|package] NN    print source package name for the binary package file
    epm print specname from filename NN      print spec filename for the source package file
    epm print binpkgfilelist in DIR for NN   list binary package(s) filename(s) from DIR for the source package file
    epm print compare [package] version N1 N2          compare (package) versions and print -1 (N1 < N2), 0 (N1 == N2), 1 (N1 > N2)
    epm print constructname <name> <version> [arch] [pkgtype] [delimiter1] [delimiter2]  print distro dependend package filename from args name version arch pkgtype
EOF
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
            fatal "Use epm print --help to get help."
            ;;
        "-h"|"--help"|"help")
            epm_print_help
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
        "arch")
            [ -n "$1" ] || fatal "Arg is missed"
            if [ -n "$FNFLAG" ] ; then
                print_pkg_arch "$@"
            elif [ -n "$PKFLAG" ] ; then
                print_pkg_arch "$@"
            else
                print_pkg_arch "$@"
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
        "shortname")
            [ -n "$1" ] || exit 0 #fatal "Arg is missed"
            print_shortname "$@"
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
            export EPMVERSION
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

    if [ -n "$short" ] ; then
        cd $DESKTOPDIR || fatal
        showcmd ls -1 *.desktop
        ls -1 *.desktop
        exit
    fi

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
            if [ -n "$short" ] ; then
                docmd rpm -q --provides -p $pkg_files | sed -e 's| .*||'
            else
                docmd rpm -q --provides -p $pkg_files
            fi
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
            if [ -n "$short" ] ; then
                docmd apt-cache show $pkg_names | grep "Provides:" | sed -e 's|, |\n|g' -e 's|Provides: ||' -e 's| .*||'
            else
                docmd apt-cache show $pkg_names | grep "Provides:" | sed -e 's|, |\n|g' -e 's|Provides: ||'
            fi
            return
        fi
        ;;
    urpm-rpm)
        if is_installed $pkg_names ; then
            CMD="rpm -q --provides"
        else
            CMD="urpmq --provides"
        fi
        ;;
    zypper-rpm)
        if is_installed $pkg_names ; then
            CMD="rpm -q --provides"
        else
            fatal "FIXME: use hi level commands or download firstly"
        fi
        ;;
    yum-rpm)
        if is_installed $pkg_names ; then
            CMD="rpm -q --provides"
        else
            fatal "FIXME: use hi level commands or download firstly"
        fi
        ;;
    dnf-rpm)
        if is_installed $pkg_names ; then
            CMD="rpm -q --provides"
        else
            CMD="dnf repoquery --provides"
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

if [ -n "$direct" ] && [ "$CMD" = "rpm -q --provides" ] ; then
    # do universal provides
    docmd $CMD $pkg_names | sed -e 's| .*||' | grep -F "()"
    a= $CMD $pkg_names | sed -e 's| .*||' | grep -v -E "^(lib|ld-linux)"
elif [ -n "$short" ] ; then
    docmd $CMD $pkg_names | sed -e 's| .*||'
else
    docmd $CMD $pkg_names
fi

}

epm_provides()
{
    # if possible, it will put pkg_urls into pkg_files or pkg_names
    if [ -n "$pkg_urls" ] ; then
        __handle_pkg_urls_to_checking
    fi

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

    [ "$DISTRARCH" = "x86_64" ] || { cat ; return ; }
    [ "$DISTRNAME" = "ROSA" ] &&  { cat ; return ; }

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
    (short=1 epm_packages $firstpkg | grep -- "$grepexp") && res=0 || res=1

    local pkg
    for pkg in "$@" ; do
        grepexp=$(_get_grep_exp $pkg)
        (short=1 epm_packages $pkg 2>/dev/null) | grep -- "$grepexp" || res=1
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
    (short=1 epm_packages $firstpkg) | grep -q -- "$grepexp" && (quiet=1 epm_packages $firstpkg) && res=0 || res=1

    local pkg
    for pkg in "$@" ; do
        grepexp=$(_get_grep_exp $pkg)
        (short=1 epm_packages $pkg 2>/dev/null) | grep -q -- "$grepexp" && (quiet=1 epm_packages $pkg) || res=1
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
            #pkg=$(rpm -q --queryformat "%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" -- $1)
            #echo $pkg | grep -q "(none)" && pkg=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" -- $1)
            pkg=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" -- $1)
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
            docmd npackdcl path --package=$1
            return
            ;;
        conary)
            CMD="conary query"
            ;;
        eopkg)
            showcmd eopkg blame $1
            local str
            str="$(a= eopkg blame $1 | grep "^Name")"
            [ -n "$str" ] || return 1
            echo "$str" | sed -e "s|Name[[:space:]]*: \(.*\), version: \(.*\), release: \(.*\)|\1-\2-\3|"
            return
            ;;
        #homebrew)
        #    showcmd "brew info $1"
        #    local HBRESULT
        #    HBRESULT="$(brew info "$1" 2>/dev/null)" || return
        #    echo "$HBRESULT" | grep -q "Not installed" && return 1
        #    echo "$1"
        #    return 0
        #    ;;
        pacman)
            docmd pacman -Q $@
            return
            ;;
        # TODO: need to print name if exists
        #pkgng)
        #    CMD="pkg info -e"
        #    ;;
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
            showcmd rpm -q --queryformat '%{name}\n' -- $@
            a='' rpm -q --queryformat '%{name}\n' -- $@
            return
            ;;
        *-dpkg)
            #CMD="dpkg-query -W --showformat=\${Package}\n"
            docmd dpkg-query -W "--showformat=\${Package}\n" -- $@ || return
            __epm_query_dpkg_check $@ || return
            return
            ;;
        npackd)
            docmd npackdcl path --package=$1
            return
            ;;
        conary)
            CMD="conary query"
            ;;
        eopkg)
            showcmd eopkg blame $1
            local str
            str="$(a= eopkg blame $1 | grep "^Name")"
            [ -n "$str" ] || return 1
            echo "$str" | sed -e "s|Name[[:space:]]*: \(.*\), version: \(.*\), release: \(.*\)|\1|"
            return
            ;;
        homebrew)
            docmd brew info "$1" >/dev/null 2>/dev/null && echo "$1" && return
            return 1
            ;;
        # TODO: check status
        #pacman)
        #    docmd pacman -Q $@ | sed -e "s| .*||g"
        #    return
        #    ;;

        # TODO: need to print name if exists
        #pkgng)
        #    CMD="pkg info -e"
        #    ;;
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

filter_pkgnames_to_short()
{
    local names="$(cat)"
    __epm_query_shortname $names
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
        TOFILE=$(print_command_path "$1" || echo "$1")
        if [ "$TOFILE" != "$1" ] ; then
            info " > $1 is placed as $TOFILE"
        fi
    fi

    [ -n "$TOFILE" ] || return

    local RES
    if [ -n "$short" ] ; then
        __do_short_query "$TOFILE"
        RES=$?
    else
        __do_query "$TOFILE"
        RES=$?
    fi

    # get value of symbolic link
    if [ -L "$TOFILE" ] ; then
        local LINKTO
        LINKTO=$(readlink -- "$TOFILE")
        info " > $TOFILE is link to $LINKTO"
        LINKTO=$(readlink -f -- "$TOFILE")
        __do_query_real_file "$LINKTO"
        return
    else
        return $RES
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
        eopkg)
            CMD="eopkg search-file"
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
        apt-dpkg)
            docmd dpkg -S "$1" | sed -e "s|:.*||"
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
    eval "epm_packages $MGS"
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
        termux-pkg)
            sudocmd pkg reinstall $@
            return ;;
        opkg)
            sudocmd opkg --force-reinstall install $@
            return ;;
        eopkg)
            sudocmd eopkg --reinstall install $@
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
    "c9f1")
        echo "c8" ;;
    "c9f2")
        echo "c9f1" ;;
    "10")
        echo "9" ;;
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

    case $BASEDISTRNAME in
    "alt")
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
        info "Try manually:"
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
        info "Try do manually:"
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
    if ! is_active_systemd ; then
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
    if [ "$1" = "--force" ] ; then
        FORCE="$1"
        shift
    fi

    local TO="$1"

    if [ "$TO" = "Sisyphus" ] ; then
        TO="sisyphus"
        echo "apt-conf-$TO"
        # apt-conf-sisyphus and apt-conf-branch conflicts
        epm installed apt-conf-branch && echo "apt-conf-branch-"
        #for i in apt apt-rsync libapt libpackagekit-glib librpm7 packagekit rpm synaptic realmd libldap2 ; do
        #    epm installed $i && echo "$i"
        #done

    else
        epm installed apt-conf-branch && echo "apt-conf-branch" && epm installed apt-conf-sisyphus && echo "apt-conf-sisyphus-"
    fi

    if [ "$FORCE" = "--force" ] ; then
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
    #    echo "$AR-"
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
            #echo $AR-
            # remove conflicts package right here to workaround against asking 'Yes, do as I say!' later
            epm remove --nodeps $AR >/dev/null
        fi
    fi
}

__check_system()
{
    local TO="$1"
    shift

    # sure we have systemd if systemd is running
    if is_active_systemd ; then
        docmd epm --skip-installed install systemd || fatal
    fi

    if [ "$TO" != "Sisyphus" ] ; then
        # note: we get --base-version directy to get new version
        if [ "$(DISTRVENDOR --base-version)" != "$TO" ] || epm installed altlinux-release-sisyphus >/dev/null ; then
            warning "Current distro still is not $TO, or altlinux-release-sisyphus package is installed."
            warning "Trying to fix with altlinux-release-$TO"
            docmd epm install altlinux-release-$TO
        fi
    fi

    # switch from prefdm: https://bugzilla.altlinux.org/show_bug.cgi?id=26405#c47
    if is_active_systemd ; then
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
    "c8.1")
        echo "c8.2" ;;
    "c8")
        echo "c9f2" ;;
    "c9f1")
        echo "c9f2" ;;
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
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            __switch_repo_to $TO
            docmd epm install rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            end_change_alt_repo
            __do_upgrade
            docmd epm update-kernel
            info "Run epm release-upgrade again for update to p8"
            ;;
        "p7"|"p7 p8"|"t7 p8"|"c7 c8")
            confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            __switch_repo_to $TO
            docmd epm install rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            end_change_alt_repo
            __do_upgrade
            __check_system "$TO"
            docmd epm update-kernel || fatal
            info "Run epm release-upgrade again for update to p9"
            ;;
        "c8"|"c8.1"|"c8.2"|"c8 c8.1"|"c8.1 c8.2"|"c8 c8.2")
            confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            __switch_repo_to $TO
            docmd epm install rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            end_change_alt_repo
            __do_upgrade
            __check_system "$TO"
            docmd epm update-kernel || fatal
            ;;
        "p8 c8"|"p8 c8.1"|"p8 c8.2")
            confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            __switch_repo_to $TO
            docmd epm install rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            if epm installed libcrypt ; then
                # glibc-core coflicts libcrypt
                docmd epm downgrade apt pam pam0_passwdqc glibc-core libcrypt- || fatal
            fi
            docmd epm $non_interactive $force_yes downgrade || fatal
            end_change_alt_repo
            __do_upgrade
            __check_system "$TO"
            docmd epm update-kernel || fatal
            ;;
        "p8"|"p8 p9"|"t8 p9"|"c8 c9"|"c8 p9"|"c8.1 p9"|"c8.2 p9"|"p9 p9"|"p9 c9f2")
            confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            info "Workaround for https://bugzilla.altlinux.org/show_bug.cgi?id=35492 ..."
            if epm installed gdb >/dev/null ; then
                docmd epm remove gdb || fatal
            fi
            __switch_repo_to $TO
            end_change_alt_repo
            __do_upgrade
            docmd epm install rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            __check_system "$TO"
            docmd epm update-kernel || fatal
            info "Run epm release-upgrade again for update to p10"
            ;;
        "p9"|"p9 p10"|"p10 p10")
            info "Upgrade all packages to current $FROM repository"
            __do_upgrade
            confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            __switch_repo_to $TO
            end_change_alt_repo
            __do_upgrade
            docmd epm install rpm apt $(get_fix_release_pkg "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            __check_system "$TO"
            docmd epm update-kernel -t std-def || fatal
            ;;
        "p9 p8"|"c8.1 c8"|"c8.1 p8"|"p8 p8")
            confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install $(get_fix_release_pkg "$FROM")
            __switch_repo_to $TO
            docmd epm downgrade rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
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
            docmd epm install $(get_fix_release_pkg "$FROM")
            __switch_repo_to $TO
            docmd epm downgrade rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            #if epm installed libcrypt >/dev/null ; then
            #    # glibc-core coflicts libcrypt
            #    docmd epm downgrade apt rpm pam pam0_passwdqc glibc-core libcrypt- || fatal
            #fi
            docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
            end_change_alt_repo
            __check_system "$TO"
            docmd epm upgrade || fatal
            ;;
        "p10 p9")
            confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install $(get_fix_release_pkg "$FROM")
            __switch_repo_to $TO
            docmd epm downgrade rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
            end_change_alt_repo
            __check_system "$TO"
            docmd epm upgrade || fatal
            ;;
        "Sisyphus p8"|"Sisyphus p9"|"Sisyphus p10"|"Sisyphus c8"|"Sisyphus c8.1"|"Sisyphus c9f2")
            confirm_info "Downgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install $(get_fix_release_pkg "$FROM")
            __switch_repo_to $TO
            docmd epm install rpm apt $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
            end_change_alt_repo
            __check_system "$TO"
            docmd epm upgrade || fatal
            ;;
        "p8 Sisyphus"|"p9 Sisyphus"|"p10 Sisyphus"|"10 Sisyphus"|"Sisyphus Sisyphus")
            confirm_info "Upgrade $DISTRNAME from $FROM to $TO ..."
            docmd epm install rpm apt $(get_fix_release_pkg "$FROM") || fatal
            docmd epm upgrade || fatal
            # TODO: epm_reposwitch??
            __replace_alt_version_in_repo "$FROM/branch/" "$TO/"
            __alt_repofix "alt"
            [ -s /etc/rpm/macros.d/p10 ] && rm -fv /etc/rpm/macros.d/p10
            __epm_ru_update || fatal
            docmd epm fix || fatal
            docmd epm install $(get_fix_release_pkg --force "$TO") || fatal "Check the errors and run '# epm release-upgrade' again"
            #local ADDPKG
            #ADDPKG=$(epm -q --short make-initrd sssd-ad 2>/dev/null)
            #docmd epm install librpm7 librpm rpm apt $ADDPKG $(get_fix_release_pkg --force "$TO") ConsoleKit2- || fatal "Check an error and run again"
            end_change_alt_repo
            docmd epm $force_yes $non_interactive upgrade || fatal "Check the error and run '# epm release-upgrade' again or just '# epm upgrade'"
            docmd epm $force_yes $non_interactive downgrade || fatal "Check the error and run '# epm downgrade'"
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

    case $BASEDISTRNAME in
    "alt")
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

        [ "$TARGET" = "Sisyphus" ] && info "Check also https://www.altlinux.org/Update/Sisyphus"

        [ -n "$TARGET" ] || TARGET="$(get_next_release $DISTRVERSION)"

        __alt_repofix

        __switch_alt_to_distro $DISTRVERSION $TARGET && info "Done. The system has been successfully upgraded to the next release '$TO'."

        return 0
        ;;
    *)
        ;;
    esac

    case $DISTRNAME in
    "Mageia")
        epm repo remove all
        sudocmd urpmi.addmedia --distrib --mirrorlist 'http://mirrors.mageia.org/api/mageia.8.$DISTRARCH.list'
        sudocmd urpmi --auto-update $non_interactive $force
        return
        ;;
     "OpenMandrivaLx")
        sudocmd dnf clean all
        sudocmd dnf --allowerasing distro-sync
        return
        ;;
    "ROSA")
        # TODO: move to distro related upgrade
        #epm repo remove all
        # FIXME: don't work:
        #epm repo add "http://mirror.rosalinux.ru/rosa/rosa2021.1/repository/$DISTRARCH"
        #showcmd urpmi.addmedia --distrib http://mirror.yandex.ru/mandriva/devel/2010.2/i586/
        #sudocmd urpmi --auto-update --replacefiles
        return
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
        info "Try do manually:"
        showcmd rpm -Uvh http://mirror.yandex.ru/fedora/linux/releases/16/Fedora/x86_64/os/Packages/fedora-release-16-1.noarch.rpm
        showcmd epm Upgrade
        ;;
    dnf-rpm)
        if [ "$DISTRNAME/$DISTRVERSION" = "CentOS/8" ] ; then
            if [ "$1" = "RockyLinux" ] ; then
                info "https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky/"
                confirm_info "Switch to Rocky Linux 8.x"
                cd /tmp
                docmd epm install git
                sudocmd git clone https://github.com/rocky-linux/rocky-tools.git || fatal
                sudocmd bash rocky-tools/migrate2rocky/migrate2rocky.sh -r
                exit
            fi

            if [ "$1" = "OracleLinux" ] ; then
                info "Check https://t.me/srv_admin/1630"
                confirm_info "Switch to Oracle Linux 8.x"
                cd /tmp
                docmd epm install git
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

        if [ "$DISTRNAME" = "RockyLinux" ] ; then
            sudocmd dnf --refresh upgrade || fatal
            sudocmd dnf clean all
            info "Check https://www.centlinux.com/2022/07/upgrade-your-servers-from-rocky-linux-8-to-9.html"
            info "For upgrading your yum repositories from Rocky Linux 8 to 9 ..."
            epm install "https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/Packages/r/rocky-gpg-keys*.rpm" || fatal
            epm install "https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/Packages/r/rocky-repos*.rpm" "https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/Packages/r/rocky-release*.rpm" || fatal

            # hack (TODO)
            DV=$(echo "$DISTRVERSION" | sed -e "s|\..*||")
            local RELEASEVER="$1"
            [ -n "$RELEASEVER" ] || RELEASEVER=$(($DV + 1))
            confirm_info "Upgrade to $DISTRNAME/$RELEASEVER"

            sudocmd dnf -y --releasever=$RELEASEVER --allowerasing --setopt=deltarpm=false distro-sync
            sudocmd rpm --rebuilddb
            epm upgrade
            info "You can run '# epm autoorphans' to remove orphaned packages"
            info "Use # dnf module reset <module> to resolve 'nothing provides module' error"
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
    zypper-rpm)
        docmd epm repolist
        # TODO: move to distro related upgrade
        # sudocmd zypper rr <номер_репозитория>
        showcmd rr N
        showcmd epm ar http://mirror.yandex.ru/opensuse/distribution/11.1/repo/oss 11.1oss
        showcmd zypper ref
        docmd epm update
        docmd epm install rpm zypper
        docmd epm upgrade
        ;;
    pacman)
        docmd epm Upgrade
        ;;
    conary)
        docmd epm Upgrade
        ;;
    emerge)
        docmd epm Upgrade
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
        eopkg)
            sudocmd eopkg $(subst_option nodeps --ignore-dependency) remove $@
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

    local APTOPTIONS="$(subst_option non_interactive -y)"

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
        eopkg)
            sudocmd eopkg $(subst_option nodeps --ignore-dependency) remove $@
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
        termux-pkg)
            sudocmd pkg uninstall $@
            return ;;
        choco)
            sudocmd choco uninstall $@
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
        eopkg)
            sudocmd eopkg $(subst_option nodeps --ignore-dependency) --yes-all remove $@
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
        eopkg)
            echo "eopkg remove $*"
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

    # TODO: add support for --no-scripts to all cases

    if [ "$BASEDISTRNAME" = "alt" ] ; then
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
                fatal "don't yet support --simulate for $PMTYPE"
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

    # TODO: FIX
    # нужно удалить все пакеты, которые зависят от удаляемого
    if [ -n "$noscripts" ] ; then
        #warning "It is not recommended to remove a few packages with disabled scripts simultaneously."
        fatal "We can't allow packages removing on hi level when --noscripts is used."
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

    case $BASEDISTRNAME in
    "alt")
        if ! __epm_query_package kernel-image >/dev/null ; then
            info "No installed kernel packages, skipping cleaning"
            return
        fi
        assure_exists update-kernel update-kernel 0.9.9
        sudocmd remove-old-kernels $dryrun $(subst_option non_interactive -y) "$@"

        [ -n "$dryrun" ] && return

        # remove unused nvidia drivers
        if is_command nvidia-clean-driver ; then
            if [ -n "$non_interactive" ] ; then
                yes | sudocmd nvidia-clean-driver
            else
                sudocmd nvidia-clean-driver
            fi
        fi

        return ;;
    esac

    case $DISTRNAME in
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
        rl="$( epm --quiet repolist 2>/dev/null | grep -F "$1")"
        [ -z "$rl" ] && warning "Can't find '$1' in the repos (see '# epm repolist' output)" && return 1
    fi
    echo "$rl" | while read rp ; do
        # TODO: print removed lines
        if [ -n "$dryrun" ] ; then
            docmd apt-repo $dryrun rm "$rp"
            continue
        fi
        if [ -z "$quiet" ] ; then
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

    local branch="$(echo "$DISTRVERSION" | tr "[:upper:]" "[:lower:]")"

    case "$1" in
        autoimports)
            info "remove autoimports repo"
            [ -n "$DISTRVERSION" ] || fatal "Empty DISTRVERSION"
            repo="autoimports.$branch"
            sudocmd apt-repo $dryrun rm "$repo"
            ;;
        archive)
            info "remove archive repos"
            __epm_removerepo_alt_grepremove "archive/"
            ;;
        korinf)
            info "remove korinf repo"
            __epm_removerepo_alt_grepremove "Korinf/"
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

case $BASEDISTRNAME in
    "alt")
        __epm_removerepo_alt "$@"
        return
        ;;
    "astra")
        echo "Use workaround for AstraLinux"
        [ -n "$*" ] || fatal "empty repo name"
        # aptsources.distro.NoDistroTemplateException: Error: could not find a distribution template for AstraLinuxCE/orel
        sudocmd sed -i -e "s|.*$*.*||" /etc/apt/sources.list
        if [ -d /etc/apt/sources.list.d ] && ls /etc/apt/sources.list.d/*.list >/dev/null 2>/dev/null ; then
            sudocmd sed -i -e "s|.*$*.*||" /etc/apt/sources.list.d/*.list
        fi
        return
        ;;
esac;

case $PMTYPE in
    apt-dpkg)
        assure_exists apt-add-repository software-properties-common
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
        if [ "$1" = "all" ] ; then
            sudocmd urpmi.removemedia -av
            return
        fi
        sudocmd urpmi.removemedia "$@"
        ;;
    zypper-rpm)
        sudocmd zypper removerepo "$@"
        ;;
    emerge)
        sudocmd layman "-d$1"
        ;;
    pacman)
        info "You need remove repo from /etc/pacman.conf"
        ;;
    npackd)
        sudocmd npackdcl remove-repo --url="$*"
        ;;
    winget)
        sudocmd winget source remove "$@"
        ;;
    eopkg)
        sudocmd eopkg remove-repo "$@"
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


[ -n "$EPM_REPACK_SCRIPTS_DIR" ] || EPM_REPACK_SCRIPTS_DIR="$CONFIGDIR/repack.d"

__epm_have_repack_rule()
{
    # FIXME: use real way (for any archive)
    local pkgname="$(epm print name for package "$1" 2>/dev/null)"
    local repackcode="$EPM_REPACK_SCRIPTS_DIR/$pkgname.sh"
    [ -s "$repackcode" ]
}

__epm_check_repack_rule()
{
    # skip repacking on non ALT systems
    [ "$BASEDISTRNAME" = "alt" ] || return 1

    local i
    for i in $* ; do
        # skip for packages built with repack
        epm_status_repacked "$i" && return 1

        __epm_have_repack_rule "$i" || return 1
    done
    return 0
}

__epm_check_if_needed_repack()
{
    __epm_check_repack_rule "$@" || return
    local pkgname="$(epm print name for package "$1")"
    warning "There is repack rule for '$pkgname' package. It is better install this package via 'epm install --repack' or 'epm play'."
}

__epm_split_by_pkg_type()
{
    local type="$1"
    shift

    split_replaced_pkgs=''

    for pkg in "$@" ; do
        [ "$(get_package_type "$pkg")" = "$type" ] || return 1
        [ -e "$pkg" ] || fatal "Can't read $pkg"
        split_replaced_pkgs="$split_replaced_pkgs $pkg"
    done

    [ -n "$split_replaced_pkgs" ]
}


__check_stoplist()
{
    local pkg="$1"
    local alf="$CONFIGDIR/repackstoplist.list"
    [ -s "$alf" ] || return 1
    [ -n "$pkg" ] || return 1
    grep -E -q "^$1$" $alf
}


__prepare_source_package()
{
    local pkg="$1"

    alpkg=$(basename $pkg)

    # TODO: use func for get name from deb pkg
    # TODO: epm print name from deb package
    local pkgname="$(echo $alpkg | sed -e "s|_.*||")"

    # TODO: use stoplist only for deb?
    [ -z "$force" ] && __check_stoplist $pkgname && fatal "Please use official package instead of $alpkg repacking (It is not recommended to use --force to skip this checking."

    SUBGENERIC=''

    if rhas "$alpkg" "\.(rpm|deb)$" ; then
        # skip packing for supported directly: rpm and deb
        return
    fi

    # convert tarballs to tar (for alien)

    # they will fill $returntarname
    if rihas "$alpkg" "\.AppImage$" ; then
        # big hack with $pkg_urls_downloaded (it can be a list, not a single url)
        __epm_pack_run_handler generic-appimage "$pkg" "" "$pkg_urls_downloaded"
        SUBGENERIC='appimage'
    elif rhas "$alpkg" "\.snap$" ; then
        __epm_pack_run_handler generic-snap "$pkg"
        SUBGENERIC='snap'
    else
        __epm_pack_run_handler generic-tar "$pkg"
        SUBGENERIC='tar'
    fi

    # it is possible there are a few files, we don't support it
    [ -s "$returntarname" ] || fatal "Can't read result from pack: '$returntarname' is not a readable file."

    alpkg=$(basename $returntarname)
    # FIXME: looks like a hack with current dir
    if [ "$(pwd)" != "$(dirname "$returntarname")" ] ; then
        cp $verbose $returntarname $alpkg
        [ -r "$returntarname.eepm.yaml" ] && cp $verbose $returntarname.eepm.yaml $alpkg.eepm.yaml
    fi
}



__epm_repack_single()
{
    local pkg="$1"
    case $PKGFORMAT in
        rpm)
            __epm_repack_to_rpm "$pkg" || return
            ;;
        deb)
            if __epm_have_repack_rule "$pkg" ; then
                # we have repack rules only for rpm, so use rpm step in any case
                __epm_repack_to_rpm "$pkg" || return
                [ -n "$repacked_pkg" ] || return
                __epm_repack_to_deb $repacked_pkg || return
            else
                __epm_repack_to_deb "$pkg" || return
            fi
            ;;
        *)
            fatal "$PKGFORMAT is not supported for repack yet"
            ;;
    esac

    return 0
}

__epm_repack()
{
    local pkg
    repacked_pkgs=''
    for pkg in $* ; do
        __epm_repack_single "$pkg" || fatal "Error with $pkg repacking."
        [ -n "$repacked_pkgs" ] && repacked_pkgs="$repacked_pkgs $repacked_pkg" || repacked_pkgs="$repacked_pkg"
    done
}


__epm_repack_if_needed()
{
    # return 1 if there is a package in host package format
    __epm_split_by_pkg_type $PKGFORMAT "$@" && return 1

    __epm_repack "$@"
    return 0
}

epm_repack()
{
    # if possible, it will put pkg_urls into pkg_files and reconstruct pkg_filenames
    if [ -n "$pkg_urls" ] ; then
        __download_pkg_urls
        pkg_urls=
    fi

    [ -n "$pkg_names" ] && warning "Can't find $pkg_names files"
    [ -z "$pkg_files" ] && info "Skip empty repack list" && return 22

    if __epm_repack $pkg_files && [ -n "$repacked_pkgs" ] ; then
        if [ -n "$install" ] ; then
            epm install $repacked_pkgs
            return
        fi

        cp $repacked_pkgs "$EPMCURDIR"
        if [ -z "$quiet" ] ; then
            echo
            echo "Adapted packages:"
            for i in $repacked_pkgs ; do
                echo "    $EPMCURDIR/$(basename "$i")"
            done
        fi
    fi

}

# File bin/epm-repack-deb:


__epm_repack_to_deb()
{
    local pkg="$1"

    assure_exists alien
    assure_exists fakeroot
    assure_exists rpm

    repacked_pkg=''

    local TDIR
    TDIR="$(mktemp -d --tmpdir=$BIGTMPDIR)" || fatal
    remove_on_exit $TDIR

    umask 022

    if echo "$pkg" | grep -q "\.deb" ; then
        warning "Repack deb to deb is not supported yet."
    fi

        abspkg="$(realpath "$pkg")"
        info "Repacking $abspkg to local deb format (inside $TDIR) ..."

        alpkg=$(basename $pkg)
        # don't use abs package path: copy package to temp dir and use there
        cp $verbose $pkg $TDIR/$alpkg

        cd $TDIR || fatal
        __prepare_source_package "$pkg"

        showcmd_store_output fakeroot alien -d -k $verbose $scripts "$alpkg"
        local DEBCONVERTED=$(grep "deb generated" $RC_STDOUT | sed -e "s| generated||g")
        if [ -n "$DEBCONVERTED" ] ; then
            repacked_pkg="$repacked_pkg $(realpath $DEBCONVERTED)"
            remove_on_exit "$(realpath $DEBCONVERTED)"
        else
            warning "Can't find converted deb for source binary package '$pkg'"
        fi
        clean_store_output
        cd - >/dev/null

    return 0
}


# File bin/epm-repack-rpm:

__get_icons_hicolor_list()
{
    local i j
    for i in apps scalable symbolic 8x8 14x14 16x16 20x20 22x22 24x24 28x28 32x32 36x36 42x42 45x45 48x48 64 64x64 72x72 96x96 128x128 144x144 160x160 192x192 256x256 256x256@2x 480x480 512 512x512 1024x1024 ; do
        echo "/usr/share/icons/hicolor/$i"
        for j in actions animations apps categories devices emblems emotes filesystems intl mimetypes places status stock ; do
            echo "/usr/share/icons/hicolor/$i/$j"
        done
    done
}

__fix_spec()
{
    local pkgname="$1"
    local buildroot="$2"
    local spec="$3"
    local i

    # drop forbidded paths
    # https://bugzilla.altlinux.org/show_bug.cgi?id=38842
    for i in / /etc /etc/init.d /etc/systemd /bin /opt /usr /usr/bin /usr/lib /usr/lib64 /usr/share /usr/share/doc /var /var/log /var/run \
            /etc/cron.daily /usr/share/icons/usr/share/pixmaps /usr/share/man /usr/share/man/man1 /usr/share/appdata /usr/share/applications /usr/share/menu \
            /usr/share/icons/hicolor $(__get_icons_hicolor_list) ; do
        sed -i \
            -e "s|/\./|/|" \
            -e "s|^%dir[[:space:]]\"$i/*\"$||" \
            -e "s|^%dir[[:space:]]$i/*$||" \
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
            subst "s|^\(\"$i\"\)$|%dir \1|" $spec
        #else
        #    subst 's|^\("'$i'"\)$|\1|' $spec
        fi
    done

}

has_repack_script()
{
    local repackcode="$EPM_REPACK_SCRIPTS_DIR/$1.sh"
    [ -s "$repackcode" ]
}

__apply_fix_code()
{
    local repackcode="$EPM_REPACK_SCRIPTS_DIR/$1.sh"
    [ -s "$repackcode" ] || return
    [ -f "$repackcode.rpmnew" ] && warning "There is .rpmnew file(s) in $EPM_REPACK_SCRIPTS_DIR dir. The pack script can be outdated."

    shift
    [ "$PROGDIR" = "/usr/bin" ] && SCPATH="$PATH" || SCPATH="$PROGDIR:$PATH"
    local bashopt=''
    [ -n "$debug" ] && bashopt='-x'
    ( unset EPMCURDIR ; export PATH=$SCPATH ; docmd $CMDSHELL $bashopt $repackcode "$1" "$2" "$3" "$4" "$5" ) || fatal "There is an error from $repackcode script"
}

__create_rpmmacros()
{
    cat <<EOF >$HOME/.rpmmacros
%_topdir    $HOME/RPM
%_tmppath    $TMPDIR

%packager    EPM <support@eepm.ru>
%_vendor    EEPM
%_gpg_name    support@etersoft.ru
%_allow_root_build    1
EOF
    remove_on_exit "$HOME/.rpmmacros"
}

__try_install_eepm_rpmbuild()
{
    RPMBUILD=/usr/bin/rpmbuild
    [ -x "$RPMBUILD" ] && return

    RPMBUILD=/usr/bin/eepm-rpmbuild
    if [ ! -x $RPMBUILD ] ; then
        epm install eepm-rpm-build
    fi

    if [ -x $RPMBUILD ] ; then
        warning "will use eepm-rpmbuild for rpm packing"
        export EPM_RPMBUILD=$RPMBUILD
        return
    fi

    RPMBUILD=/usr/bin/rpmbuild
}

__epm_repack_to_rpm()
{
    local pkg="$1"

    # Note: install epm-repack for static (package based) dependencies
    assure_exists alien || fatal
    assure_exists fakeroot

    # will set RPMBUILD
    __try_install_eepm_rpmbuild

    if [ ! -x $RPMBUILD ] ; then
        RPMBUILD=/usr/bin/rpmbuild
        # TODO: check for all systems
        case $PKGFORMAT in
            rpm)
                assure_exists $RPMBUILD rpm-build || fatal
                ;;
            deb)
                assure_exists $RPMBUILD rpm || fatal
                ;;
        esac
    fi

    umask 022

    # TODO: improve
    if echo "$pkg" | grep -q "\.deb" ; then
        assure_exists dpkg || fatal
        # TODO: Для установки требует: /usr/share/debconf/confmodule но пакет не может быть установлен
        # assure_exists debconf
    fi

    local alpkg
    local abspkg
    local tmpbuilddir

    repacked_pkg=''

        # TODO: keep home?
        HOME="$(mktemp -d --tmpdir=$BIGTMPDIR)" || fatal
        remove_on_exit $HOME
        export HOME
        __create_rpmmacros

        tmpbuilddir=$HOME/$(basename $pkg).tmpdir
        mkdir $tmpbuilddir
        abspkg="$(realpath $pkg)"
        info ""
        info "Repacking $abspkg to local rpm format (inside $tmpbuilddir) ..."

        alpkg=$(basename $pkg)
        # don't use abs package path: copy package to temp dir and use there
        cp -l $verbose $pkg $tmpbuilddir/../$alpkg 2>/dev/null || cp $verbose $pkg $tmpbuilddir/../$alpkg || fatal

        cd $tmpbuilddir/../ || fatal
        # fill alpkg and SUBGENERIC
        __prepare_source_package "$(realpath $alpkg)"
        cd $tmpbuilddir/ || fatal

        local fakeroot
        fakeroot=''
        ! is_root && is_command fakeroot && fakeroot='fakeroot'

        if [ -n "$verbose" ] ; then
            docmd $fakeroot alien --generate --to-rpm $verbose $scripts "../$alpkg" || fatal
        else
            showcmd $fakeroot alien --generate --to-rpm $scripts "../$alpkg"
            a='' $fakeroot alien --generate --to-rpm $scripts "../$alpkg" >/dev/null || fatal
        fi

        # remove all empty dirs (hack against broken dpkg with LF in the end of line) (hack for linux_pantum.deb)
        rmdir * 2>/dev/null

        local subdir="$(echo *)"
        [ -d "$subdir" ] || fatal "can't find subdir in $(pwd)"

        local buildroot="$tmpbuilddir/$subdir"

        # for tarballs fix permissions (ideally fix in pack.d/generic-tar.sh, but there is tar repacking only)
        [ "$SUBGENERIC" = "tar" ] && chmod $verbose -R a+rX $buildroot/*

        # detect spec and move to prev dir
        local spec="$(echo $buildroot/*.spec)"
        [ -s "$spec" ] || fatal "Can't find spec $spec"
        mv $spec $tmpbuilddir || fatal
        spec="$tmpbuilddir/$(basename "$spec")"

        local pkgname="$(grep "^Name: " $spec | sed -e "s|Name: ||g" | head -n1)"

        # run generic scripts and repack script for the pkg
        cd $buildroot || fatal

        __fix_spec $pkgname $buildroot $spec
        __apply_fix_code "generic"             $buildroot $spec $pkgname $abspkg $SUBGENERIC
        __apply_fix_code "generic-$SUBGENERIC" $buildroot $spec $pkgname $abspkg
        __apply_fix_code $pkgname              $buildroot $spec $pkgname $abspkg
        if ! has_repack_script $pkgname ; then
            __apply_fix_code "generic-default" $buildroot $spec $pkgname $abspkg
        fi
        __fix_spec $pkgname $buildroot $spec
        cd - >/dev/null

        # reassign package name (could be renamed in fix scripts)
        pkgname="$(grep "^Name: " $spec | sed -e "s|Name: ||g" | head -n1)"

        if [ -n "$EEPM_INTERNAL_PKGNAME" ] ; then
            if ! estrlist contains "$pkgname" "$EEPM_INTERNAL_PKGNAME" ; then
                fatal "Some bug: the name of the repacking package ($pkgname) differs with the package name ($EEPM_INTERNAL_PKGNAME) from play.d script."
            fi
        fi

        TARGETARCH=$(epm print info -a | sed -e 's|^x86$|i586|')

        showcmd $RPMBUILD --buildroot $buildroot --target $TARGETARCH -bb $spec
        if [ -n "$verbose" ] ; then
            a='' $RPMBUILD --buildroot $buildroot --target $TARGETARCH -bb $spec || fatal
        else
            a='' $RPMBUILD --buildroot $buildroot --target $TARGETARCH -bb $spec >/dev/null || fatal
        fi

        # remove copy of source binary package (don't mix with generated)
        rm -f $tmpbuilddir/../$alpkg
        local repacked_rpm="$(realpath $tmpbuilddir/../*.rpm)"
        if [ -s "$repacked_rpm" ] ; then
            remove_on_exit "$repacked_rpm"
            repacked_pkg="$repacked_rpm"
        else
            warning "Can't find converted rpm for source binary package '$pkg' (got $repacked_rpm)"
        fi
        cd $EPMCURDIR >/dev/null

    true
}


# File bin/epm-repo:


epm_repo_help()
{
    get_help HELPCMD $SHAREDIR/epm-repo
    cat <<EOF

Examples:
  epm repo set p9
  epm repo switch p10
  epm repo add autoimports
  epm repo list
  epm repo change yandex
EOF
}


epm_repo()
{
    local CMD="$1"
    [ -n "$CMD" ] && shift
    case $CMD in
    "-h"|"--help"|help)               # HELPCMD: help
        epm_repo_help
        ;;
    ""|list)                          # HELPCMD: list enabled repositories (-a|--all for list disabled repositorires too)
        epm_repolist "$@"
        ;;
    change)                           # HELPCMD: <mirror>: switch sources to the mirror (supports etersoft/yandex/basealt/altlinux.org/eterfund.org): rewrite URLs to the specified server
        epm_repofix "$@"
        ;;
    set)                              # HELPCMD: <mirror>: remove all existing sources and add mirror for the branch
        epm repo rm all
        epm addrepo "$@"
        ;;
    switch)                           # HELPCMD: switch repo to <repo>: rewrite URLs to the repo (but use epm release-upgrade [Sisyphus|p10] for upgrade to a next branch)
        epm_reposwitch "$@"
        ;;
    enable)                           # HELPCMD: enable <repo>
        epm_repoenable "$@"
        ;;
    disable)                          # HELPCMD: disable <repo>
        epm_repodisable "$@"
        ;;
    addkey)                           # HELPCMD: add repository gpg key (by URL or file) (run with --help to detail)
        epm_addkey "$@"
        ;;
    clean)                            # HELPCMD: remove temp. repos (tasks and CD-ROMs)
        [ "$BASEDISTRNAME" = "alt" ] || fatal "TODO: only ALT now is supported"
        # TODO: check for ALT
        sudocmd apt-repo $dryrun clean
        ;;
    save)                             # HELPCMD: save sources lists to a temp place
        epm_reposave "$@"
        ;;
    restore)                          # HELPCMD: restore sources lists from a temp place
        epm_reporestore "$@"
        ;;
    reset)                            # HELPCMD: reset repo lists to the distro default
        epm_reporeset "$@"
        ;;
    status)                           # HELPCMD: print repo status
        epm_repostatus "$@"
        ;;
    add)                              # HELPCMD: add package repo (etersoft, autoimports, archive 2017/01/31); run with param to get list
        epm_addrepo "$@"
        ;;
    Add)                              # HELPCMD: like add, but do update after add
        epm_addrepo "$@"
        epm update
        ;;
    rm|del|remove)                     # HELPCMD: remove repository from the sources lists (epm repo remove all for all)
        epm_removerepo "$@"
        ;;
    fix)                              # HELPCMD: fix paths in sources lists (ALT Linux only)
        epm_repofix "$@"
        ;;

    create)                            # HELPCMD: create (initialize) repo: [path] [name]
        epm_repocreate "$@"
        ;;
    index)                            # HELPCMD: index repo (update indexes): [--init] [path] [name]
        epm_repoindex "$@"
        ;;
    pkgadd)                           # HELPCMD: add to <dir> applied <package-filename1> [<package-filename2>...]
        epm_repo_pkgadd "$@"
        ;;
    pkgupdate)                        # HELPCMD: replace in <dir> with new <package-filename1> [<package-filename2>...]
        epm_repo_pkgupdate "$@"
        ;;
    pkgdel)                           # HELPCMD: del from <dir> <package1> [<package2>...]
        epm_repo_pkgdel "$@"
        ;;
    *)
        fatal "Unknown command $ epm repo '$CMD'"
        ;;
esac

}

# File bin/epm-repo-addkey:



__epm_get_file_from_url()
{
    local url="$1"
    local tmpfile
    tmpfile=$(mktemp) || fatal
    remove_on_exit $tmpfile
    eget -O "$tmpfile" "$url" >/dev/null
    echo "$tmpfile"
}

__epm_addkey_altlinux()
{
    local name
    local url="$1"
    shift
    if is_url "$url" ; then
        name="$(basename "$url" .gpg)"
    else
        name="$url"
        url="$1"
        shift
    fi

    local fingerprint
    if is_url "$url" ; then
        fingerprint="$1"
        shift
    else
        fingerprint="$url"
        url=""
    fi

    local comment="$1"
    # compat
    [ -n "$2" ] && name="$2"

    [ -s /etc/apt/vendors.list.d/$name.list ] && return

    cat << EOF | sudorun tee /etc/apt/vendors.list.d/$name.list
simple-key "$name" {
        FingerPrint "$fingerprint";
        Name "$comment";
}
EOF
    if [ -n "$url" ] ; then
        local tmpfile=$(__epm_get_file_from_url $url) || fatal
        sudocmd gpg --no-default-keyring --keyring /usr/lib/alt-gpgkeys/pubring.gpg --import $tmpfile
    fi
}


__epm_addkey_alpine()
{
    local name
    local url="$1"
    shift
    if is_url "$url" ; then
        name="$(basename "$url" .rsa)"
    else
        name="$url"
        url="$1"
        shift
    fi

    local target="/etc/apk/keys/$name.rsa"

    [ -s $target ] && return

    local tmpfile=$(__epm_get_file_from_url $url) || fatal
    sudocmd cp $tmpfile $target
}


__epm_addkey_dnf()
{
    local name
    local url="$1"
    shift
    if is_url "$url" ; then
        name="$(basename "$url" .gpg)"
    else
        name="$url"
        url="$1"
        shift
    fi
    local gpgkeyurl="$1"
    local nametext="$2"
    # compat
    [ -n "$3" ] && name="$3"

    # TODO: missed name, nametext, gpgkeyurl (disable gpgcheck=1)

    local target="/etc/yum.repos.d/$name.repo"
    [ -s $target ] && return

    local tmpfile
    tmpfile=$(mktemp) || fatal
    remove_on_exit $tmpfile
    cat >$tmpfile <<EOF
[$name]
name=$nametext
baseurl=$url
gpgcheck=1
enabled=1
gpgkey=$gpgkeyurl
EOF
    chmod 644 $tmpfile
    sudocmd cp $tmpfile $target
}


__epm_addkey_deb()
{
    local name
    local url="$1"
    shift
    if is_url "$url" ; then
        name="$(basename "$url" .gpg)"
    else
        name="$url"
        url="$1"
        shift
    fi
    local fingerprint="$1"
    local comment="$2"
    # compat
    [ -n "$3" ] && name="$3"

    # FIXME: check by GPG PUBKEY
    [ -s /etc/apt/trusted.gpg.d/$name.gpg ] && return

    if [ -z "$fingerprint" ] ; then
        local tmpfile=$(__epm_get_file_from_url $url) || fatal
        if cat $tmpfile | head -n3 | grep -- "-----BEGIN PGP PUBLIC KEY BLOCK-----" ; then
            # This is a GnuPG extension to OpenPGP
            cat $tmpfile | a= gpg --dearmor >$tmpfile
        fi
        sudocmd apt-key add $tmpfile

        return
    fi
    sudocmd apt-key adv --keyserver "$url" --recv "$fingerprint"
}


epm_addkey()
{

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ] ; then
    echo "Usage: $ epm repo addkey [name] [url] [fingerprint/gpgkey] [comment/name]"
    return
fi

remove_on_exit

case $BASEDISTRNAME in
    "alt")
        __epm_addkey_altlinux "$@"
        return
        ;;
    "alpine")
        __epm_addkey_alpine "$@"
        return
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        __epm_addkey_deb "$@"
        ;;
    dnf-*|yum-*)
        __epm_addkey_dnf "$@"
        ;;
esac

}


# File bin/epm-repodisable:


alt_LISTS='/etc/apt/sources.list /etc/apt/sources.list.d/*.list'


__epm_repodisable_alt()
{
    local rl
    # ^rpm means full string
    if rhas "$1" "\^rpm" ; then
        rl="$(echo "$1" | sed -e 's|\^||')"
    else
        rl="$( (epm --quiet repolist) 2>/dev/null | grep -F "$1" | head -n1 )"
        [ -z "$rl" ] && warning "Can't find '$1' entries in the repos (see '# epm repolist' output)" && return 1
    fi
    echo "$rl" | while read rp ; do
        [ -n "$dryrun" ] && echo "will comment $rp" && continue
        sed -i -e "s|^\($(sed_escape "$rl")\)|#\1|" $alt_LISTS
    done
}


epm_repodisable()
{

case $PMTYPE in
    apt-rpm)
        assure_root
        __epm_repodisable_alt "$@"
        ;;
    apt-dpkg|aptitude-dpkg)
        print_apt_sources_list
        ;;
    yum-rpm)
        docmd yum repolist $verbose
        [ -n "$verbose" ] || info "Use --verbose if you need detail information."
        ;;
    dnf-rpm)
        sudocmd dnf config-manager --enable $verbose "$@"
        ;;
    eoget)
        docmd eoget disable-repo "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

# File bin/epm-repoenable:


alt_LISTS='/etc/apt/sources.list /etc/apt/sources.list.d/*.list'


__epm_repoenable_alt()
{
    local rl
    # ^rpm means full string
    if rhas "$1" "\^rpm" ; then
        rl="$(echo "$1" | sed -e 's|\^||')"
    else
        rl="$( epm --quiet --all repolist 2>/dev/null | grep -F "$1" | head -n1 | sed -e 's|[[:space:]]*#[[:space:]]*||' )"
        [ -z "$rl" ] && warning "Can't find commented '$1' in the repos (see '# epm repolist' output)" && return 1
    fi
    echo "$rl" | while read rp ; do
        [ -n "$dryrun" ] && echo "will uncomment $rp" && continue
        sed -i -e "s|^[[:space:]]*#[[:space:]]*\($(sed_escape "$rl")\)|\1|" $alt_LISTS
    done
}


epm_repoenable()
{

case $PMTYPE in
    apt-rpm)
        assure_root
        __epm_repoenable_alt "$@"
        ;;
    apt-dpkg|aptitude-dpkg)
        print_apt_sources_list
        ;;
    yum-rpm)
        docmd yum repolist $verbose
        [ -n "$verbose" ] || info "Use --verbose if you need detail information."
        ;;
    dnf-rpm)
        sudocmd dnf config-manager --disable $verbose "$@"
        ;;
    eoget)
        docmd eoget enable-repo "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
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
        c8*)
            br="cert8"
            ;;
        c9*)
            br="cert9"
            ;;
        Sisyphus)
            br="alt"
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
    [ "$TO" = "sisyphus" ] && TO="Sisyphus"
    if [ "$TO" = "Sisyphus" ] ; then
        __replace_alt_version_in_repo "[tpc][5-9]\.?[0-9]?/branch/" "$TO/"
        __replace_alt_version_in_repo "p10\.?[0-9]?/branch/" "$TO/"
    else
        __replace_alt_version_in_repo "Sisyphus/" "$TO/branch/"
        __replace_alt_version_in_repo "[tpc][5-9]\.?[0-9]?/branch/" "$TO/branch/"
        if [ "$TO" != "p10" ] ; then
            __replace_alt_version_in_repo "p10\.?[0-9]?/branch/" "$TO/branch/"
        fi
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
    # FIXME: masked grep: предупреждение: stray \ before /
    if grep -q -e "^[^#].*$path" $list 2>/dev/null ; then
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


__subst_with_repo_url()
{
    local NURL="$2"
    echo "$1" | sed \
        -e "s|h\?f\?t\?tp://mirror.yandex.ru/* altlinux|$NURL|" \
        -e "s|h\?f\?t\?tp://ftp.altlinux.org/pub/distributions/* ALTLinux|$NURL|" \
        -e "s|h\?f\?t\?tp://ftp.basealt.ru/pub/distributions/* ALTLinux|$NURL|" \
        -e "s|h\?f\?t\?tp://ftp.etersoft.ru/pub/* ALTLinux|$NURL|" \
        -e "s|h\?f\?t\?tp://download.etersoft.ru/pub/* ALTLinux|$NURL|" \
        -e "s|h\?f\?t\?tp://mirror.eterfund.org/download.etersoft.ru/pub/* ALTLinux|$NURL|"
}

__change_repo()
{
    local SHORT="$1"
    local REPLTO="$2"
    local NN
    a="" apt-repo list | grep -v $SHORT | grep -v "file:/" | while read nn ; do
        NN="$(__subst_with_repo_url "$nn" "$REPLTO")"
        [ "$NN" = "$nn" ] && continue
        epm addrepo "$NN" && epm removerepo "$nn" || return 1
    done
}


epm_repofix()
{

case $BASEDISTRNAME in
    "alt")
        assure_exists apt-repo
        [ -n "$quiet" ] || docmd apt-repo list
        assure_root
        __fix_alt_sources_list /etc/apt/sources.list
        __fix_alt_sources_list /etc/apt/sources.list.d/*.list
        # TODO: move to repo change
        case "$1" in
        "etersoft")
            __change_repo etersoft "http://download.etersoft.ru/pub ALTLinux"
            ;;
        "eterfund.org")
            __change_repo eterfund.org "https://mirror.eterfund.org/download.etersoft.ru/pub ALTLinux"
            ;;
        "yandex")
            __change_repo mirror.yandex "http://mirror.yandex.ru altlinux"
            ;;
        "basealt")
            __change_repo ftp.basealt "http://ftp.basealt.ru/pub/distributions ALTLinux"
            ;;
        "altlinux.org")
            __change_repo ftp.altlinux "http://ftp.altlinux.org/pub/distributions ALTLinux"
            ;;
        *)
            fatal "Unsupported change key $1"
        esac
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

# File bin/epm-repoindex:


get_archlist()
{
    echo "noarch"
    echo "$DISTRARCH"
    case $DISTRARCH in
        x86_64)
            echo "i586"
            ;;
    esac
}

__epm_repoindex_alt()
{
    local archlist="i586 x86_64 x86_64-i586 aarch64 noarch"

    local init=''
    if [ "$1" = "--init" ] ; then
        init='--init'
        shift
    fi

    epm assure genbasedir apt-repo-tools || fatal
    REPO_DIR="$1"
    # TODO: check if we inside arch dir or RPMS.*
    [ -n "$REPO_DIR" ] || REPO_DIR="$(pwd)"
    if [ -z "$init" ] ; then
        [ -d "$REPO_DIR" ] || fatal "Repo dir $REPO_DIR does not exist"
    fi

    REPO_NAME="$2"
    if [ -z "$REPO_NAME" ] ; then
        # default name
        REPO_NAME="addon"
        # detect name if already exists
        for arch in $archlist ; do
            local rd="$(echo $REPO_DIR/$arch/RPMS.*)"
            [ -d "$rd" ] && REPO_NAME="$(echo "$rd" | sed -e 's|.*\.||')" && break
        done
    fi

    if [ -n "$init" ] ; then
        for arch in $(get_archlist); do
            mkdir -pv "$REPO_DIR/$arch/base/"
            mkdir -pv "$REPO_DIR/$arch/RPMS.$REPO_NAME/"
        done
        return
    fi

    for arch in $archlist; do
        [ -d "$REPO_DIR/$arch/RPMS.$REPO_NAME" ] || continue
        mkdir -pv "$REPO_DIR/$arch/base/"
        docmd genbasedir --bloat --progress --topdir=$REPO_DIR $arch $REPO_NAME
    done
}

__epm_repoindex_deb()
{
    local init=''
    if [ "$1" = "--init" ] ; then
        init='--init'
        shift
    fi

    local dir="$1"
    docmd mkdir -pv "$dir" || fatal
    assure_exists gzip
    docmd dpkg-scanpackages -t deb "$dir" | gzip | cat > "$dir/Packages.gz"
}


epm_repoindex()
{

case $PMTYPE in
    apt-rpm)
        __epm_repoindex_alt "$@"
        ;;
    apt-dpkg|aptitude-dpkg)
        __epm_repoindex_deb "$@"
        ;;
    yum-rpm)
        epm install --skip-installed yum-utils createrepo || fatal
        docmd mkdir -pv "$@"
        docmd createrepo -v -s md5 "$@"
        docmd verifytree
        ;;
    dnf-rpm)
        epm install --skip-installed yum-utils createrepo || fatal
        docmd mkdir -pv "$@"
        docmd createrepo -v -s md5 "$@"
        docmd verifytree
        ;;
    eoget)
        docmd eoget index "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_repocreate()
{
    epm_repoindex --init "$@"
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

__print_apt_sources_list_full()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        grep -- "^[[:space:]]*#*[[:space:]]*rpm" $i
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

__print_apt_sources_list_verbose_full()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        grep -- "^[[:space:]]*#*[[:space:]]*rpm" $i | grep -v -- "^ *\$" | grep -q . && echo && __info_cyan "$i:" || continue
        grep -- "^[[:space:]]*#*[[:space:]]*rpm" $i | grep -v -- "^ *\$" | sed -e 's|^|    |' -e "s|\(.*#.*\)|$(set_color $WHITE)\1$(restore_color)|"
    done
}

print_apt_sources_list()
{
    local LISTS='/etc/apt/sources.list /etc/apt/sources.list.d/*.list'

    if [ "$1" = "-a" ] || [ "$1" = "--all" ] ; then
        if [ -n "$quiet" ] ; then
            __print_apt_sources_list_full $LISTS
        else
            __print_apt_sources_list_verbose_full $LISTS
        fi
        return
    fi

    if [ -n "$quiet" ] ; then
        __print_apt_sources_list $LISTS
    else
        __print_apt_sources_list_verbose $LISTS
    fi
}


epm_repolist()
{

[ -z "$*" ] || [ "$PMTYPE" = "apt-rpm" ] || [ "$PMTYPE" = "apt-dpkg" ]  || fatal "No arguments are allowed here"

case $PMTYPE in
    apt-rpm)
        #assure_exists apt-repo
        if tasknumber "$1" >/dev/null ; then
            get_task_packages "$@"
        else
            print_apt_sources_list "$@"
            #docmd apt-repo list
        fi
        ;;
    deepsolver-rpm)
        docmd ds-conf
        ;;
    apt-dpkg|aptitude-dpkg)
        print_apt_sources_list "$@"
        ;;
    yum-rpm)
        docmd yum repolist $verbose
        [ -n "$verbose" ] || info "Use --verbose if you need detail information."
        ;;
    dnf-rpm)
        docmd dnf repolist $verbose
        [ -n "$verbose" ] || info "Use --verbose if you need detail information."
        ;;
    urpm-rpm)
        docmd urpmq --list-media active --list-url
        ;;
    apk)
        cat /etc/apk/repositories
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
    eoget)
        docmd eoget list-repo
        ;;
    pacman)
        if [ -f /etc/pacman.d/mirrorlist ] ; then
            docmd grep -v -- "^#\|^$" /etc/pacman.d/mirrorlist | grep "^Server =" | sed -e 's|^Server = ||'
        else
            docmd grep -v -- "^#\|^$" /etc/pacman.conf
        fi
        ;;
    slackpkg)
        docmd grep -v -- "^#\|^$" /etc/slackpkg/mirrors
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

# File bin/epm-repopkg:


__epm_repo_pkgadd_alt()
{
    local archlist="i586 x86_64 aarch64 noarch"

    local REPO_DIR="$1"
    shift
    [ -d "$REPO_DIR" ] || fatal "Can't find repo dir $REPO_DIR."

    # default name
    REPO_NAME="addon"
    # detect if already exists
    for arch in $archlist ; do
        local rd="$(echo $REPO_DIR/$arch/RPMS.*)"
        [ -d "$rd" ] && REPO_NAME="$(echo "$rd" | sed -e 's|.*\.||')" && break
    done

    [ -n "$1" ] || fatal "Missed package name"

    while [ -s "$1" ] ; do
        arch="$(epm print arch from filename "$1")" || fatal
        # arch hack (it is better to repack firstly)
        [ "$arch" = "i686" ] && arch="i586"
        [ "$arch" = "i386" ] && arch="i586"
        [ -d $REPO_DIR/$arch/RPMS.$REPO_NAME ] || fatal
        epm checkpkg "$1" || fatal
        cp -v "$1" $REPO_DIR/$arch/RPMS.$REPO_NAME || fatal
        shift
    done

}


__epm_repo_pkgdel_alt()
{
    local archlist="i586 x86_64 aarch64 noarch"

    local REPO_DIR="$1"
    shift
    [ -d "$REPO_DIR" ] || fatal "Can't find repo dir $REPO_DIR."

    [ -n "$1" ] || fatal "Missed package name"

    # default name
    REPO_NAME="addon"
    # detect if already exists
    for arch in $archlist ; do
        local rd="$(echo $REPO_DIR/$arch/RPMS.*)"
        [ -d "$rd" ] && REPO_NAME="$(echo "$rd" | sed -e 's|.*\.||')" && break
    done

    while [ -s "$1" ] ; do
        for arch in $archlist ; do
            local rd="$REPO_DIR/$arch/RPMS.$REPO_NAME"
            [ -d $REPO_DIR/$arch/RPMS.$REPO_NAME ] || continue
            for i in $rd/$1* ; do
                [ "$1" = "$(epm print name for package $i)" || continue
                rm -v $rd/$1*
            done
        done
        shift
    done

}


__epm_repo_pkgupdate_alt()
{
    local dir="$1"
    shift
    for i in "$@" ; do
        pkg="$(epm print name for package $i)" || fatal
        __epm_repo_pkgdel_alt "$dir" $pkg
    done
    __epm_repo_pkgadd_alt "$dir" "$@"
}



epm_repo_pkgadd()
{

case $PMTYPE in
    apt-rpm)
        __epm_repo_pkgadd_alt "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_repo_pkgupdate()
{

case $PMTYPE in
    apt-rpm)
        __epm_repo_pkgupdate_alt "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_repo_pkgdel()
{

case $PMTYPE in
    apt-rpm)
        __epm_repo_pkgdel_alt "$@"
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}

epm_put_to_repo()
{
    epm_repo_pkgupdate "$put_to_repo" "$@"
}

# File bin/epm-reposave:



SAVELISTDIR=$epm_vardir/eepm-etc-save
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
case $BASEDISTRNAME in
    alt)
        sudoepm repo set $DISTRVERSION
        return
        ;;
esac

case $PMTYPE in
    winget)
        sudocmd winget source reset
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac

}


epm_repostatus()
{
case $PMTYPE in
    apt-*)
        if [ -n "$short" ] ; then
            local days
            days="$(__epm_check_apt_db_days)" && return 0
            echo "$days"
            return 1
        else
            local days
            days="$(__epm_check_apt_db_days)" && info "APT database is actual." && return 0
            info "APT database is $days."
            return 1
        fi
        ;;
    *)
        fatal "Have no suitable command for $PMTYPE"
        ;;
esac
}

# File bin/epm-requires:


__epm_filter_out_base_alt_reqs()
{
    grep -E -v "(^rpmlib\(|^/bin/sh|^/bin/bash|^rtld\(GNU_HASH\)|ld-linux)"
}

__epm_alt_rpm_requires()
{
    if [ -n "$short" ] ; then
        # TODO see also rpmreqs from etersoft-build-utils
        docmd rpm -q --requires "$@" | __epm_filter_out_base_alt_reqs | sed -e "s| .*||"
    else
        docmd rpm -q --requires "$@" | __epm_filter_out_base_alt_reqs
    fi
}

get_linked_shared_libs()
{
    assure_exists readelf binutils
    #is_command readelf || fatal "Can't get required shared library: readelf is missed. Try install binutils package."
    #ldd "$exe" | sed -e 's|[[:space:]]*||' | grep "^lib.*[[:space:]]=>[[:space:]]\(/usr/lib\|/lib\)" | sed -e 's|[[:space:]].*||'
    LC_ALL=C readelf -d "$1" | grep "(NEEDED)" | grep "Shared library:" | sed -e 's|.*Shared library: \[||' -e 's|\]$||' | grep "^lib"
}

__epm_elf32_requires()
{
    get_linked_shared_libs "$1"
}

__epm_elf64_requires()
{
    get_linked_shared_libs "$1" | sed -e 's|$|()(64bit)|'
}

__epm_elf_requires()
{
    local i
    if [ -n "$direct" ] ; then
        for i in $* ; do
            get_linked_shared_libs $i
        done
        return
    fi

    for i in $* ; do
        if file -L "$i" | grep -q " ELF 32-bit " ; then
            __epm_elf32_requires "$i"
        elif file -L "$i" | grep -q " ELF 64-bit " ; then
            __epm_elf64_requires "$i"
        else
            warning "Unknown ELF binary"
        fi
    done
}

epm_requires_files()
{
    local pkg_files="$*"
    [ -n "$pkg_files" ] || return

    local fl
    for fl in $pkg_files ; do
        local PKGTYPE="$(get_package_type $fl)"

        case "$PKGTYPE" in
            rpm)
                assure_exists rpm >/dev/null
                __epm_alt_rpm_requires -p $fl
                ;;
            deb)
                assure_exists dpkg >/dev/null
                a='' docmd dpkg -I $fl | grep "^ *Depends:" | sed "s|^ *Depends:||g"
                ;;
            eopkg)
                showcmd eopkg info $fl
                LC_ALL=C eopkg info $fl | grep "^Dependencies" | head -n1 | sed -e "s|Dependencies[[:space:]]*: ||"
                ;;
            ELF)
                __epm_elf_requires $fl
                ;;
            *)
                warning "Have no suitable command for handle file $fl with .$PKGTYPE"
                ;;
        esac
    done
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
            assure_exists rpm >/dev/null
            __epm_alt_rpm_requires $pkg_names
            return
        else
            if [ -n "$verbose" ] ; then
                CMD="apt-cache depends"
            else
                if [ -n "$short" ] ; then
                    LC_ALL=C docmd apt-cache depends $pkg_names | grep "Depends:" | sed -e 's|, |\n|g' -e "s|.*Depends: ||" -e "s|<\(.*\)>|\1|" | __epm_filter_out_base_alt_reqs | sed -e "s| .*||"
                else
                    LC_ALL=C docmd apt-cache depends $pkg_names | grep "Depends:" | sed -e 's|, |\n|g' -e "s|.*Depends: ||" -e "s|<\(.*\)>|\1|" | __epm_filter_out_base_alt_reqs
                fi
                return
            fi
        fi
        ;;
    packagekit)
        CMD="pkcon required-by"
        ;;
    #zypper-rpm)
    #    # FIXME: use hi level commands
    #    CMD="rpm -q --requires"
    #    ;;
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
    eopkg)
        showcmd eopkg info $pkg_names
        LC_ALL=C eopkg info $pkg_names | grep "^Dependencies" | sed -e "s|Dependencies[[:space:]]*: ||"
        return
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
    # if possible, it will put pkg_urls into pkg_files or pkg_names
    if [ -n "$pkg_urls" ] ; then
        __handle_pkg_urls_to_checking
    fi

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

__epm_restore_print_toml()
{
    local lt
    lt=$(mktemp) || fatal
    remove_on_exit $lt
cat <<EOF >$lt

import sys
import toml

if len(sys.argv) < 2:
	raise Exception('Run me with a file')

pyproject = sys.argv[1]

c = toml.load(pyproject)
n = c["tool"]["poetry"]["dependencies"]
for key, value in n.items():
	if isinstance(value, dict):
		print('\n' + key + ' ' , value["version"])
	else:
		print('\n' + key + ' ' + value)
EOF
    a= python3 $lt "$1"
}

__epm_restore_print_pyproject()
{
    local req_file="$1"
    __epm_restore_print_toml "$req_file" | __epm_restore_convert_to_rpm_notation | sed -e 's|\*||' -e 's|\^|>= |'
}

__epm_restore_pyproject()
{
    local req_file="$1"
    local reqmacro
    local ilist

    if [ -n "$dryrun" ] ; then
        reqmacro="%py3_use"
        echo
        __epm_restore_print_comment "$req_file"
        __epm_restore_print_pyproject "$req_file" | sed -e "s|^|$reqmacro |"
        return
    else
        info "Install requirements from $req_file ..."
        ilist="$(__epm_restore_print_pyproject "$req_file" | cut -d' ' -f 1 | sed -e "s|^|python3-module-|")"
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

__epm_print_meson_list()
{
    local reqmacro="$1"
    local req_file="$2"
    local l
    while read name sign ver other ; do
        # gtk4-wayland
        # gtk4 >= 4.6
        [ -n "$other" ] && continue
        if [ -n "$dryrun" ] ; then
            local pi=''
            pi="$reqmacro pkgconfig($name)"
            [ -n "$sign" ] && pi="$pi $sign $ver"
            echo "$pi"
            continue
        else
            local pi="pkgconfig($name)"
        fi
        [ -n "$name" ] || continue
        ilist="$ilist $pi"
    done < $req_file

    [ -n "$dryrun" ] || echo "$ilist"
}

__epm_restore_meson()
{
    local req_file="$1"
    if [ -n "$dryrun" ] ; then
        local lt
        lt=$(mktemp) || fatal
        remove_on_exit $lt
        echo
        __epm_restore_print_comment "$req_file" " dependency"
        grep "dependency(" $req_file | sed -e 's|.*dependency(||' -e 's|).*||' -e 's|, required.*||' -e 's|, version:||' -e "s|'||g" >$lt
        __epm_print_meson_list "BuildRequires:" $lt
        rm -f $lt
        return
    fi

    info "Install requirements from $req_file ..."
    local lt
    lt=$(mktemp) || fatal
    remove_on_exit $lt
    grep "dependency(" $req_file | sed -e 's|.*dependency(||' -e 's|).*||' -e 's|, required.*||' -e 's|, version:||' -e "s|'||g" >$lt
    ilist="$ilist $(__epm_print_meson_list "" $lt)"

    rm -f $lt
    docmd epm install $ilist

}


__epm_restore_npm()
{
    local req_file="$1"

    assure_exists jq || fatal

    if [ -n "$dryrun" ] ; then
        local lt
        lt=$(mktemp) || fatal
        remove_on_exit $lt
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
    local lt
    lt=$(mktemp) || fatal
    remove_on_exit $lt
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
        local lt
        lt=$(mktemp) || fatal
        remove_on_exit $lt
        a= /usr/bin/perl $req_file PRINT_PREREQ=1 >$lt
        # all requirements will autodetected during packing, put it to the buildreq
        echo
        __epm_restore_print_comment "$req_file"
        __epm_print_perl_list "BuildRequires:" $lt
        rm -f $lt
        return
    fi

    info "Install requirements from $req_file ..."
    local lt
    lt=$(mktemp) || exit
    remove_on_exit $lt
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
        local lt
        lt=$(mktemp) || fatal
        remove_on_exit $lt
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
    local lt
    lt=$(mktemp) || fatal
    remove_on_exit $lt
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
    [ -n "$verbose" ] && info "Checking for $req_file ..."
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
        pyproject.toml)
            [ -s "$req_file" ] && __epm_restore_pyproject "$req_file"
            ;;
        package.json)
            [ -s "$req_file" ] && __epm_restore_npm "$req_file"
            ;;
        meson.build)
            [ -s "$req_file" ] && __epm_restore_meson "$req_file"
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
             Gemfile requires.txt package.json setup.py python_dependencies.py Makefile.PL meson.build pyproject.toml \
             *.sln *.csproj ; do
        __epm_restore_by $i
    done

}

# File bin/epm-search:


__epm_search_output()
{
local CMD
local string="$*"
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
    eopkg)
        CMD="eopkg search --"
        ;;
    yum-rpm)
        CMD="yum search"
        ;;
    dnf-rpm)
        CMD="dnf search"
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
    choco)
        CMD="choco list"
        ;;
    slackpkg)
        # FIXME
        echo "Note: case sensitive search"
        if [ -n "$verbose" ] ; then
            CMD="/usr/sbin/slackpkg search"
        else
            LC_ALL=C docmd /usr/sbin/slackpkg search $string | grep " - " | sed -e 's|.* - ||g'
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
    termux-pkg)
        CMD="pkg search"
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

LC_ALL=C docmd $CMD $string
epm play $short --list-all | sed -e 's|^ *||g' -e 's|[[:space:]]\+| |g' -e "s|\$| (use \'epm play\' to install it)|"
}

__convert_glob__to_regexp()
{
    # translate glob to regexp
    echo "$1" | sed -e "s|\*|.*|g" -e "s|?|.|g"
}

_clean_from_regexp()
{
    sed -e "s/[?\^.*]/ /g"
}

__clean_from_glob()
{
    sed -e "s/[?*].*//" -e "s/[?\^.*]/ /g"
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

    # TODO: only apt supports regexps?
    case $PMTYPE in
        apt-*)
            ;;
        *)
                list=$(echo "$list" | sed -e "s/[?\^.]/ /g")
                listN=$(echo "$listN" | sed -e "s/[?\^.]/ /g")
            ;;
    esac

    list=$(__convert_glob__to_regexp "$list")
    listN=$(__convert_glob__to_regexp "$listN")

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
    [ -n "$1" ] || fatal "Search: search argument(s) is missed"

    # it is useful for first time running
    update_repo_if_needed soft

    warmup_bases

    __epm_search_output $(get_firstarg $@) | grep "$*"
}


epm_search()
{
    [ -n "$1" ] || fatal "Search: search argument(s) is missed"

    # it is useful for first time running
    update_repo_if_needed soft

    warmup_bases

    echo "$*" | grep -q "\.[*?]" && warning "Only glob symbols * and ? are supported. Don't use regexp here!"

    # FIXME: do it better
    local MGS
    MGS=$(eval __epm_search_make_grep $quoted_args)
    EXTRA_SHOWDOCMD="$MGS"
    # TODO: use search args for more optimal output
    eval "__epm_search_output \"$(eval get_firstarg $quoted_args | __clean_from_glob)\" $MGS"
}

# File bin/epm-search_file:


__alt_search_file_output()
{
    # grep only on left part (filename), then revert order and grep with color
    ercat $quiet $1 | grep -h -- ".*$2.*[[:space:]]" | sed -e "s|\(.*\)\t\(.*\)|\2: \1|g" $3
}

__alt_local_content_search()
{

    check_alt_contents_index || init_alt_contents_index
    update_repo_if_needed

    if [ ! -s "$ALT_CONTENTS_INDEX_LIST" ] ; then
        fatal "There was some error in contents index retrieving. Try run 'epm update' again."
    fi

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

case $BASEDISTRNAME in
    "alt")
        __alt_local_content_search $pkg_filenames
        return ;;
esac

case $PMTYPE in
    apt-dpkg|aptitude-dpkg)
        if ! is_command apt-file ; then
            assure_exists apt-file
            sudocmd apt-file update
        else
            update_repo_if_needed
        fi
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
    eopkg)
        CMD="eopkg search-file"
        ;;
    xbps)
        CMD="xbps-query -Ro"
        ;;
    aptcyg)
        docmd apt-cyg searchall $(echo " $pkg_filenames" | sed -e "s| /| |g")
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

    info "TODO: please, improve apt-repo to support arepo (i586-) packages for apt-repo list task"
    showcmd "eget -q -O- http://git.altlinux.org/tasks/$tn/plan/arepo-add-x86_64-i586 | cut -f1"
    # TODO: retrieve one time
    res="$(eget -q -O- http://git.altlinux.org/tasks/$tn/plan/arepo-add-x86_64-i586 2>/dev/null)" || return #{ warning "There is a download error for x86_64-i586 arepo." ; return ; }
    echo "$res" | cut -f1
}

get_task_packages()
{
    local tn
    for tn in $(tasknumber "$@") ; do
        showcmd apt-repo list task "$tn"
        a='' apt-repo list task "$tn" >/dev/null || continue
        a='' apt-repo list task "$tn"
        [ "$DISTRARCH" = "x86_64" ] && get_task_arepo_packages "$tn"
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
    echo "$epm_cachedir/contents_index/$(get_alt_repo_path "$1")"
}

ALT_CONTENTS_INDEX_LIST=$epm_cachedir/contents_index/contents_index_list

__rsync_check()
{
    a= rsync -n "$1" >/dev/null 2>/dev/null
}

rsync_alt_contents_index()
{
    local URL="$1"
    local TD="$2"
    local res
    assure_exists rsync || return

    if ! __rsync_check "$URL" ; then
        warning "$URL is not accessible via rsync, skipping contents index update..."
        return
    fi

    mkdir -p "$(dirname "$TD")"

    [ -n "$USER" ] && sudorun chown -R $USER "$TD"

    if [ -z "$quiet" ] ; then
        docmd rsync --partial --inplace $3 -a "$URL" "$TD"
    else
        a= rsync --partial --inplace $3 -a "$URL" "$TD"
    fi
    res=$?
    [ -f "$TD" ] && sudorun chmod a+rw "$TD"
    return $res
}

get_url_to_etersoft_mirror()
{
    local REPOPATH
    local ETERSOFT_MIRROR="rsync://download.etersoft.ru/pub"
    local ALTREPO=$(get_alt_repo_path "$1")
    echo "$ALTREPO" | grep -q "^ALTLinux" || return
    echo "$ETERSOFT_MIRROR/$(get_alt_repo_path "$1" | sed -e "s|^ALTLinux/|ALTLinux/contents_index/|")"
}

__add_to_contents_index_list()
{
    [ -n "$verbose" ] && echo " $1 -> $2"
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


check_alt_contents_index()
{
    [ -f "$ALT_CONTENTS_INDEX_LIST" ]
}

init_alt_contents_index()
{
    sudocmd mkdir -p "$(dirname $ALT_CONTENTS_INDEX_LIST)"
    sudocmd chmod a+rw "$(dirname $ALT_CONTENTS_INDEX_LIST)"
    sudocmd truncate -s0 $ALT_CONTENTS_INDEX_LIST
    sudocmd chmod a+rw $ALT_CONTENTS_INDEX_LIST
    update_alt_contents_index
}

update_alt_contents_index()
{
    check_alt_contents_index || return

    truncate -s0 "$ALT_CONTENTS_INDEX_LIST"
    # TODO: fix for Etersoft/LINUX@Etersoft
    # TODO: fix for rsync
    info "Retrieving contents_index ..."
    (quiet=1 epm_repolist) | grep -v " task$" | grep -E "rpm.*(ftp://|http://|https://|rsync://|file:/)" | sed -e "s@^rpm.*\(ftp://\|http://\|https://\)@rsync://@g" | sed -e "s@^rpm.*\(file:\)@@g" | while read -r URL1 URL2 component ; do
        [ "$component" = "debuginfo" ] && continue
        URL="$URL1/$URL2"
        if is_abs_path "$URL" ; then
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
            # we don't know if remote server has rsync
            # fix rsync URL firstly
            #local RSYNCURL="$(echo "$URL" | sed -e "s|rsync://\(ftp.basealt.ru\|basealt.org\|altlinux.ru\)/pub/distributions/ALTLinux|rsync://\1/ALTLinux|")" #"
            #rsync_alt_contents_index $RSYNCURL/base/contents_index $LOCALPATH/contents_index -z && __add_to_contents_index_list "$RSYNCURL" "$LOCALPATH/contents_index" && continue
            #mkdir -p "$LOCALPATH"
            #eget -O $LOCALPATH/contents_index $URL/base/contents_index && __add_to_contents_index_list "$RSYNCURL" "$LOCALPATH/contents_index" && continue

            #__add_better_to_contents_index_list "(cached)" "$LOCALPATH/contents_index.gz" "$LOCALPATH/contents_index"
        fi
    done
}


# File bin/epm-sh-install:


__fast_hack_for_filter_out_installed_rpm()
{
    LC_ALL=C xargs -n1 rpm -q 2>&1 | grep 'is not installed' |
        sed -e 's|^.*package \(.*\) is not installed.*|\1|g'
}

filter_out_installed_packages()
{
    [ -z "$skip_installed" ] && cat && return

    case $PMTYPE in
        yum-rpm|dnf-rpm)
            if [ "$DISTRARCH" = "x86_64" ] && [ "$DISTRNAME" != "ROSA" ] ; then
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
        #    LANG=C LC_ALL=C xargs -n1 dpkg -l 2>&1 | grep -i 'no packages found matching' |
        #        sed -e 's|\.\+$||g' -e 's|^.*[Nn]o packages found matching \(.*\)|\1|g'
        #    ;;
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


__epm_print_warning_for_nonalt_packages()
{
    [ -n "$dryrun" ] && return 0
    # only ALT
    [ "$BASEDISTRNAME" = "alt" ] || return 0

    # download only
    [ -n "$save_only$download_only" ] && return 0


    local i
    for i in $* ; do
        if epm_status_repacked "$i" ; then
            warning "%%% You are trying install package $i repacked from third-party software source. Use it at your own risk. %%%"
            continue
        fi

        if epm_status_thirdparty "$i" ; then
            warning "%%% You are trying install package $i from third-party software source. Use it at your own risk. %%%"
            continue
        fi

        if ! epm_status_original "$i" ; then
            warning "%%% You are trying install package $i not from official $DISTRNAME/$DISTRVERSION repository. Use it at your own risk. %%%"
            continue
        fi
    done
}

__epm_check_vendor()
{
    # don't check vendor if there are forced script options
    [ -n "$scripts$noscripts" ] && return
    [ -n "$dryrun" ] && return 0

    # only ALT
    [ "$BASEDISTRNAME" = "alt" ] || return 0


    local i
    for i in $* ; do
        bi="$(basename $i)"
        if ! epm_status_validate "$i" ; then
            # it is missed package probably (package remove case)
            if is_installed "$i" ; then
                warning "Can't get any info for $i package. Scripts are DISABLED for package $bi. Use --scripts if you need run scripts from such packages."
            fi
            noscripts="--noscripts"
            continue
        fi

        local vendor
        vendor="$(epm print field Vendor for "$i")"

        if [ -z "$vendor" ] ; then
            warning "Can't get info about vendor for $i package. Scripts are DISABLED for package $bi. Use --scripts if you need run scripts from such packages."
            noscripts="--noscripts"
            continue
        fi

        epm_status_original "$i" && continue
        epm_status_repacked "$i" && continue

        if __epm_vendor_ok_scripts "$vendor" ; then
            warning "Scripts are ENABLED for package $bi from outside vendor '$vendor' (this vendor is listed in $CONFIGDIR/vendorallowscripts.list).  Use --noscripts if you need disable scripts in such packages."
            continue
        fi

        if __epm_package_ok_scripts "$i" ; then
            warning "Scripts are ENABLED for package $bi from outside vendor '$vendor' (the package is listed in $CONFIGDIR/pkgallowscripts.list).  Use --noscripts if you need disable scripts in such packages."
            continue
        fi
        warning "Scripts are DISABLED for package $bi from outside vendor '$vendor'. Use --scripts if you need run scripts from such packages."
        noscripts="--noscripts"
    done
}


# File bin/epm-sh-warmup:

is_warmup_allowed()
{
    # disable warming up until set warmup in /etc/eepm/eepm.conf
    [ -n "$warmup" ] || return 1

    # disable warm if have no enough memory
    [ "$DISTRMEMORY" -ge 1024 ] && return 0
    warning "Skipping warmup bases due low memory size"
    return 1
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
    is_warmup_allowed || return 0
    __warmup_files "rpm" "/var/lib/rpm/*"
}

warmup_dpkgbase()
{
    is_warmup_allowed || return 0
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
        eopkg)
            CMD="eopkg --dry-run install"
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
                __epm_search_internal "$pkg" | grep -q "^$pkg-[0-9]" && continue
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
    if is_command "$CMD" ; then
        docmd $CMD "$@"
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

# File bin/epm-stats:

epm_stats()
{
    case $PMTYPE in
        apk)
            CMD="apk stats"
            ;;
        *)
            fatal "Have no suitable command for $PMTYPE"
            ;;
        esac

    docmd $CMD "$@"
}

# File bin/epm-status:



__convert_pkgallowscripts_to_regexp()
{
    local tmpalf
    tmpalf="$(mktemp)" || fatal
    # copied from eget's filter_glob
    # check man glob
    # remove commentы and translate glob to regexp
    grep -v "^[[:space:]]*#" "$1" | grep -v "^[[:space:]]*$" | sed -e "s|\*|.*|g" -e "s|?|.|g" -e "s|^|^|" -e "s|$|\$|" >$tmpalf
    echo "$tmpalf"
}

__epm_package_name_ok_scripts()
{
    local name="$1"
    local alf="$CONFIGDIR/pkgallowscripts.list"
    [ -s "$alf" ] || return 1
    [ -n "$name" ] || return 1
    local tmpalf=$(__convert_pkgallowscripts_to_regexp "$alf")
    remove_on_exit $tmpalf
    echo "$name" | grep -q -f $tmpalf
    local res=$?
    rm $tmpalf
    return $res
}

__epm_package_ok_scripts()
{
    local pkg="$1"
    local name
    # TODO: improve epm print name and use it here
    name="$(epm print field Name for "$pkg" 2>/dev/null)"
    [ -n "$name" ] || return 1
    __epm_package_name_ok_scripts "$name"
}

__epm_vendor_ok_scripts()
{
    local vendor="$1"
    local alf="$CONFIGDIR/vendorallowscripts.list"
    [ -s "$alf" ] || return 1
    [ -n "$vendor" ] || return 1
    local tmpalf=$(__convert_pkgallowscripts_to_regexp "$alf")
    remove_on_exit $tmpalf
    echo "$vendor" | grep -q -f $tmpalf
    local res=$?
    rm $tmpalf
    return $res
}


epm_status_installable()
{
    local pkg="$1"
    #LANG=C epm policy "$pkg" | grep Candidate >/dev/null 2>/dev/null
    if [ -n "$verbose" ] ; then
        docmd epm install --simulate "$pkg"
    else
        epm install --simulate "$pkg" 2>/dev/null >/dev/null
    fi
}

epm_status_certified()
{
    local pkg="$1"
    __epm_package_ok_scripts "$pkg" && return

    local vendor
    vendor="$(epm print field Vendor for "$pkg" 2>/dev/null)"
    [ -n "$vendor" ] || return
    __epm_vendor_ok_scripts "$vendor" && return
}


epm_status_validate()
{
    local pkg="$1"
    local rpmversion="$(epm print field Version for "$pkg" 2>/dev/null)"
    [ -n "$rpmversion" ]
}

epm_status_original()
{
    local pkg="$1"

    #is_installed $pkg || fatal "FIXME: implemented for installed packages as for now"

    case $DISTRNAME in
        ALTLinux)
            epm_status_validate $pkg || return 1
            epm_status_repacked $pkg && return 1

            # not for all packages
            #[ "$(epm print field Vendor for package $pkg)" = "ALT Linux Team" ] || return

            local distribution
            distribution="$(epm print field Distribution for "$pkg" 2>/dev/null )"
            echo "$distribution" | grep -q "^ALT" || return 1

            # mc in Sisyphus has not a signature
            #local sig
            #sig="$(epm print field sigpgp for "$pkg" 2>/dev/null )"
            #[ "$sig" = "(none)" ] && return 1

            # FIXME: how to check if the package is from ALT repo (verified)?
            local release="$(epm print release from package "$pkg" 2>/dev/null )"
            echo "$release" | grep -q "^alt" || return 1
            return 0
            ;;
        *)
            fatal "Unsupported $DISTRNAME"
            ;;
    esac
    return 1
}

epm_status_repacked()
{
    local pkg="$1"

    #is_installed $pkg || fatal "FIXME: implemented for installed packages as for now"

    case $BASEDISTRNAME in
        alt)
            epm_status_validate $pkg || return
            local packager="$(epm print field Packager for "$1" 2>/dev/null)"
            [ "$packager" = "EPM <support@etersoft.ru>" ] && return 0
            [ "$packager" = "EPM <support@eepm.ru>" ] && return 0
            ;;
        *)
            fatal "Unsupported $BASEDISTRNAME"
            ;;
    esac
    return 1
}


epm_status_thirdparty()
{
    local pkg="$1"

    #is_installed $pkg || fatal "FIXME: implemented for installed packages as for now"

    case $BASEDISTRNAME in
        alt)
            ## FIXME: some repo packages have wrong Packager
            #local packager="$(epm print field Packager for "$1" 2>/dev/null)"
            #echo "$packager" && grep -q "altlinux" && return 0
            #echo "$packager" && grep -q "basealt" && return 0
            epm_status_validate $pkg || return 1

            local distribution
            distribution="$(epm print field Distribution for "$pkg" 2>/dev/null )"
            echo "$distribution" | grep -q "^ALT" && return 1
            echo "$distribution" | grep -q "^EEPM" && return 1
            return 0
            ;;
        *)
            fatal "Unsupported $BASEDISTRNAME"
            ;;
    esac
    return 1
}


epm_status_help()
{
    cat <<EOF

epm status - check status of the package and return result via exit code
Usage: epm status [options] <package>

Options:
  --installed           check if <package> is installed
  --installable         check if <package> can be installed from the repo
  --original            check if <package> is from distro repo
  --certified           check if <package> is certified that it can be installed without repacking
  --thirdparty          check if <package> from a third-party source (didn't packed for this distro)
  --repacked            check if <package> was repacked with epm repack
  --validate            check if <package> is accessible (we can get a fields from it)

EOF
}

epm_status()
{
    local option="$1"

    if [ -z "$1" ] ; then
        epm_status_help >&2
        exit 1
    fi

    shift

    # TODO: allow both option
    case "$option" in
        -h|--help)
            epm_status_help
            return
            ;;
        --installed)
            is_installed "$@"
            return
            ;;
        --original)
            epm_status_original "$@"
            return
            ;;
        --certified|--allowed-scripts)
            epm_status_certified "$@"
            return
            ;;
         --third-party|--thirdparty|--thirdpart)
            epm_status_thirdparty "$@"
            return
            ;;
        --repacked)
            epm_status_repacked "$@"
            return
            ;;
        --validate)
            epm_status_validate "$@"
            return
            ;;
        --installable)
            epm_status_installable "$@"
            return
            ;;
        -*)
            fatal "Unknown option $option, use epm status --help to get info"
            ;;
        *)
            fatal "No option before $option, use epm status --help to get info"
            ;;
    esac

    epm_status_help >&2
    fatal "Run with appropriate option"
}

# File bin/epm-tool:

epm_tool_help()
{
    echo "Tools embedded in epm:"
    get_help HELPCMD $SHAREDIR/epm-tool

    cat <<EOF
  Examples:
    epm tool eget -U http://ya.ru
    epm tool estrlist union a b a c
    epm tool erc archive.zip
EOF
}

epm_tool()
{
    local WHAT="$1"
    shift

    case "$WHAT" in
        "")
            fatal "Use epm tool --help to get help."
            ;;
        "-h"|"--help"|"help")
            epm_tool_help
            ;;
        "eget")                      # HELPCMD: downloading tool (simular to wget or curl)
            showcmd eget "$@"
            eget "$@"
            ;;
        "erc")                       # HELPCMD: universal archive manager
            showcmd erc "$@"
            erc "$@"
            ;;
        "ercat")                     # HELPCMD: universal file uncompressor
            showcmd ercat "$@"
            ercat "$@"
            ;;
        "estrlist")                  # HELPCMD: string operations
            showcmd estrlist "$@"
            estrlist "$@"
            ;;
        "json")                      # HELPCMD: json operations
            showcmd json "$@"
            $CMDSHELL internal_tools_json "$@"
            ;;
        "yaml")                      # HELPCMD: parse yaml operations
            showcmd yaml "$@"
            $CMDSHELL $SHAREDIR/tools_yaml "$@"
            ;;
        "which")
            print_command_path "$@"  # HELPCMD: which like command (no output to stderr, can works without which package)
            ;;
        *)
            fatal "Unknown command $ epm tool $WHAT. Use epm print help for get help."
            ;;
    esac
}

# File bin/epm-update:



get_latest_version()
{
    URL="https://eepm.ru/app-versions"
    #update_url_if_need_mirrored
    local var
    var="$(epm tool eget -q -O- "$URL/$1")" || return
    echo "$var" | head -n1 | cut -d" " -f1
}

__check_for_epm_version()
{
    # skip update checking for eepm from repo (ALT bug #44314)
    [ "$BASEDISTRNAME" = "alt" ] &&  [ "$DISTRVERSION" != "Sisyphus" ] && epm status --original eepm && return

    local latest="$(get_latest_version eepm)"
    #[ -z "$latest" ] && return
    local res="$(epm print compare "$EPMVERSION" "$latest")"
    [ "$res" = "-1" ] && info "Latest EPM version in Korinf repository is $latest. You have version $EPMVERSION running." && info "You can update eepm with \$ epm ei command."
}

__save_available_packages()
{
    [ -d "$epm_vardir" ] || return 0

    # TODO: ignore in docker
    # update list only if the system supports bash completion
    [ -d /etc/bash_completion.d ] || return 0

    # HACK: too much time (5 minutes) on deb systems in a docker
    [ $PMTYPE = "apt-dpkg" ] && return 0

    info "Retrieving list of all available packages (for autocompletion) ..."
    short=--short epm_list_available | sort | sudorun tee $epm_vardir/available-packages >/dev/null
}

__epm_update_content_index()
{
case $BASEDISTRNAME in
    "alt")
        update_alt_contents_index
        return
        ;;
esac

case $PMTYPE in
    apt-dpkg)
        is_command apt-file || return 0
        assure_exists apt-file || return 0
        sudocmd apt-file update
        ;;
esac

}

__epm_update()
{

    info "Running update the package index files from remote package repository database ..."

local ret=0
warmup_hibase

case $BASEDISTRNAME in
    "alt")
        # TODO: hack against cd to cwd in apt-get on ALT
        cd /
        sudocmd apt-get update
        ret="$?"
        cd - >/dev/null
        return $ret
        ;;
esac


case $PMTYPE in
    apt-rpm)
        # TODO: hack against cd to cwd in apt-get on ALT
        cd /
        sudocmd apt-get update
        ret="$?"
        cd - >/dev/null
        return $ret
        ;;
    apt-dpkg)
        sudocmd apt-get update || return
        # apt-get update retrieve Contents file too
        #sudocmd apt-file update
        ;;
    packagekit)
        docmd pkcon refresh
        ;;
    #snappy)
    #    sudocmd snappy
    #    ;;
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
        sudocmd zypper $(subst_option non_interactive --non-interactive) refresh
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
    eopkg)
        sudocmd eopkg update-repo
        ;;
    apk)
        sudocmd apk update
        ;;
    nix)
        sudocmd nix-channel --update
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


epm_update()
{
    if [ "$1" = "--content-index" ] ; then
        __epm_update_content_index
        return
    fi

    # update with args is the alias for upgrade
    if [ -n "$*" ] ; then
        epm upgrade "$@"
        return
    fi

    __epm_update "$@" || return

    __epm_touch_pkg

    __save_available_packages

    __epm_update_content_index

    return 0
}

# File bin/epm-upgrade:


epm_upgrade()
{
    local CMD

    # it is useful for first time running
    update_repo_if_needed

    warmup_bases

    if [ "$BASEDISTRNAME" = "alt" ] ; then
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
            __epm_update
            (pkg_names="$installlist" epm_install) || fatal "Can't update repo"
            epm_removerepo "$@"
            end_change_alt_repo

            return
        fi
    fi

    # Solus supports upgrade for a package (with all dependencies)
    if [ -n "$1" ] && [ "$DISTRNAME" = "Solus" ] ; then
        sudocmd eopkg upgrade "$@"
        return
    fi

    # if possible, it will put pkg_urls into pkg_files and reconstruct pkg_filenames
    if [ -n "$pkg_urls" ] ; then
        info "Downloading packages assigned to upgrade ..."
        __handle_pkg_urls_to_install
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
        local APTOPTIONS="$dryrun $(subst_option non_interactive -y) $(subst_option verbose "-V -o Debug::pkgMarkInstall=1 -o Debug::pkgProblemResolver=1")"
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
        CMD="zypper $(subst_option non_interactive --non-interactive) dist-upgrade"
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
    apk)
        CMD="apk upgrade"
        ;;
    choco)
        CMD="choco update all"
        ;;
    homebrew)
        #CMD="brew upgrade"
        sudocmd brew upgrade $(brew outdated)
        return
        ;;
    opkg)
        CMD="opkg upgrade"
        ;;
    eopkg)
        CMD="eopkg upgrade"
        ;;
    slackpkg)
        CMD="/usr/sbin/slackpkg upgrade-all"
        ;;
    guix)
        CMD="guix package -u"
        ;;
    appget)
        CMD="$PMTYPE update-all"
        ;;
    winget)
        if [ -z "$1" ] ; then
            sudocmd winget upgrade --all
            return
        fi
        CMD="winget upgrade"
        ;;
    aptcyg)
        # shellcheck disable=SC2046
        docmd_foreach "epm install" $(short=1 epm packages)
        return
        ;;
    xbps)
        CMD="xbps-install -Su"
        ;;
    nix)
        CMD="nix-env -u $dryrun"
        ;;
    termux-pkg)
        CMD="pkg upgrade"
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
    eopkg)
        showcmd eopkg info $pkg
        # eopkg info prints it only from repo info
        LC_ALL=C eopkg info $pkg | grep "^Reverse Dependencies" | sed -e "s|Reverse Dependencies[[:space:]]*: ||" | grep -v "^$"
        return
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
        LC_ALL=C docmd apt-get install --print-uris $pkg | grep "^Selecting" | cut -f2 -d" "
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
# 2007-2023 (c) Vitaly Lipatov <lav@etersoft.ru>
# 2007-2023 (c) Etersoft
# 2007-2023 Public domain

# You can set ROOTDIR to root system dir
#ROOTDIR=

PROGVERSION="20230406"

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

# copied from epm-sh-functions
# print a path to the command if exists in $PATH
if a='' which which 2>/dev/null >/dev/null ; then
    # the best case if we have which command (other ways needs checking)
    # TODO: don't use which at all, it is binary, not builtin shell command
print_command_path()
{
    a='' which -- "$1" 2>/dev/null
}
elif a='' type -a type 2>/dev/null >/dev/null ; then
print_command_path()
{
    a='' type -fpP -- "$1" 2>/dev/null
}
else
print_command_path()
{
    a='' type "$1" 2>/dev/null | sed -e 's|.* /|/|'
}
fi

# check if <arg> is a real command
is_command()
{
    print_command_path "$1" >/dev/null
}
##########################3


firstupper()
{
    # FIXME: works with GNU sed only
    echo "$*" | sed 's/.*/\u&/'
}

tolower()
{
    # tr is broken in busybox (checked with OpenWrt)
    #echo "$*" | tr "[:upper:]" "[:lower:]"
    echo "$*" | awk '{print tolower($0)}'
}

print_bug_report_url()
{
    echo "$BUG_REPORT_URL"
}

# allows x86_64/Distro/Version
override_distrib()
{
    [ -n "$DISTRNAMEOVERRIDE" ] || DISTRNAMEOVERRIDE="$1"
    [ -n "$DISTRNAMEOVERRIDE" ] || return

    local name="$(echo "$DISTRNAMEOVERRIDE" | sed -e 's|x86_64/||')"
    [ "$name" = "$DISTRNAMEOVERRIDE" ] && DIST_ARCH="x86" || DIST_ARCH="x86_64"
    DISTRIB_ID="$(echo "$name" | sed -e 's|/.*||')"
    DISTRIB_RELEASE="$(echo "$name" | sed -e 's|.*/||')"
    [ "$DISTRIB_ID" = "$DISTRIB_RELEASE" ] && DISTRIB_RELEASE=''

    VENDOR_ID=''
    PRETTY_NAME="$DISTRIB_ID"
    DISTRO_NAME="$DISTRIB_ID"
    DISTRIB_CODENAME="$DISTRIB_RELEASE"
    DISTRIB_FULL_RELEASE="$DISTRIB_RELEASE"

}

# Translate DISTRIB_ID to vendor name (like %_vendor does or package release name uses), uses VENDOR_ID by default
pkgvendor()
{
    [ "$DISTRIB_ID" = "ALTLinux" ] && echo "alt" && return
    [ "$DISTRIB_ID" = "ALTServer" ] && echo "alt" && return
    [ "$DISTRIB_ID" = "MOC" ] && echo "alt" && return
    [ "$DISTRIB_ID" = "MESh" ] && echo "alt" && return
    [ "$DISTRIB_ID" = "AstraLinuxSE" ] && echo "astra" && return
    [ "$DISTRIB_ID" = "AstraLinuxCE" ] && echo "astra" && return
    [ "$DISTRIB_ID" = "LinuxXP" ] && echo "lxp" && return
    [ "$DISTRIB_ID" = "TinyCoreLinux" ] && echo "tcl" && return
    [ "$DISTRIB_ID" = "VoidLinux" ] && echo "void" && return
    [ "$DISTRIB_ID" = "ManjaroLinux" ] && echo "manjaro" && return
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

# Print package manager (need DISTRIB_ID, DISTRIB_RELEASE vars)
pkgmanager()
{
local CMD

case $VENDOR_ID in
    alt)
        echo "apt-rpm" && return
        ;;
    arch|manjaro)
        echo "pacman" && return
        ;;
    debian)
        echo "apt-dpkg" && return
        ;;
esac

# FIXME: some problems with multibased distros (Server Edition on CentOS and Desktop Edition on Ubuntu)
case $DISTRIB_ID in
    PCLinux)
        CMD="apt-rpm"
        ;;
    Ubuntu|Debian|Mint|OSNovaLinux|AstraLinux*|Elbrus)
        CMD="apt-dpkg"
        #which aptitude 2>/dev/null >/dev/null && CMD=aptitude-dpkg
        #is_command snappy && CMD=snappy
        ;;
    Solus)
        CMD="eopkg"
        ;;
    Mandriva)
        CMD="urpm-rpm"
        ;;
    ROSA|NAME="OpenMandrivaLx")
        CMD="urpm-rpm"
        is_command yum && CMD="yum-rpm"
        is_command dnf && CMD="dnf-rpm"
        # use dnf since 2020
        #[ "$DISTRIB_ID/$DISTRIB_RELEASE" = "ROSA/2020" ] && CMD="urpm-rpm"
        ;;
    FreeBSD|NetBSD|OpenBSD|Solaris)
        CMD="pkgsrc"
        is_command pkg && CMD=pkgng
        ;;
    Gentoo)
        CMD="emerge"
        ;;
    ArchLinux|ManjaroLinux)
        CMD="pacman"
        ;;
    Fedora|CentOS|OracleLinux|RockyLinux|AlmaLinux|RHEL|RELS|Scientific|GosLinux|Amzn|RedOS)
        CMD="dnf-rpm"
        is_command dnf || CMD="yum-rpm"
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
        is_command winget && echo "winget" && return
        is_command appget && CMD="appget"
        is_command choco && CMD="choco"
        is_command npackdcl && CMD="npackd"
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
    NixOS)
        CMD="nix"
        ;;
    Android)
        CMD="android"
        # TODO: CMD="termux-pkg"
        ;;
    Cygwin)
        CMD="aptcyg"
        ;;
    AlpineLinux)
        CMD="apk"
        ;;
    TinyCoreLinux)
        CMD="tce"
        ;;
    VoidLinux)
        CMD="xbps"
        ;;
    *)
        if is_command "rpm" && [ -s /var/lib/rpm/Name ] || [ -s /var/lib/rpm/rpmdb.sqlite ] ; then
            is_command "apt-get" && [ -d /var/lib/apt ] && echo "apt-rpm" && return
            is_command "zypper" && echo "zypper-rpm" && return
            is_command "dnf" && echo "dnf-rpm" && return
            is_command "yum" && echo "yum-rpm" && return
            is_command "urpmi" && echo "urpm-rpm" && return
        fi

        if is_command "dpkg" && [ -s /var/lib/dpkg/status ] ; then
            is_command "apt" && echo "apt-dpkg" && return
            is_command "apt-get" && echo "apt-dpkg" && return
        fi

        echo "pkgmanager(): We don't support yet DISTRIB_ID $DISTRIB_ID (VENDOR_ID $VENDOR_ID)" >&2
        ;;
esac
echo "$CMD"
}

# Print pkgtype (need DISTRIB_ID var)
pkgtype()
{

    case $VENDOR_ID in
        arch|manjaro)
            echo "pkg.tar.xz" && return
            ;;
    esac

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
        solus) echo "eopkg" ;;
        *)
            case $(pkgmanager) in
                *-dpkg)
                    echo "deb" ;;
                *-rpm)
                    echo "rpm" ;;
                *)
                    echo "" ;;
            esac
    esac
}

print_codename()
{
    echo "$DISTRIB_CODENAME"
}

print_repo_name()
{
    echo "$DISTRIB_CODENAME"
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
        "Debian GNU/Linux")
            echo "Debian"
            ;;
        "Liya GNU/Linux")
            echo "LiyaLinux"
            ;;
        "CentOS Linux")
            echo "CentOS"
            ;;
        "Fedora Linux")
            echo "Fedora"
            ;;
        "Red Hat Enterprise Linux Server")
            echo "RHEL"
            ;;
        "ROSA Fresh"*|"ROSA Desktop Fresh"*)
            echo "ROSA"
            ;;
        "ROSA Chrome Desktop")
            echo "ROSA"
            ;;
        "MOS Desktop"|"MOS Panel")
            echo "ROSA"
            ;;
        "ROSA Enterprise Linux Desktop")
            echo "RELS"
            ;;
        "ROSA Enterprise Linux Server")
            echo "RELS"
            ;;
        *)
            #echo "${1// /}"
            #firstupper "$1" | sed -e "s/ //g" -e 's|(.*||'
            echo "$1" | sed -e "s/ //g" -e 's|(.*||'
            ;;
    esac
}

# 1.2.3.4.5 -> 1
normalize_version1()
{
    echo "$1" | sed -e "s|\..*||"
}

# 1.2.3.4.5 -> 1.2
normalize_version2()
{
    echo "$1" | sed -e "s|^\([^.][^.]*\.[^.][^.]*\)\..*|\1|"
}

# 1.2.3.4.5 -> 1.2.3
normalize_version3()
{
    echo "$1" | sed -e "s|^\([^.][^.]*\.[^.][^.]*\.[^.][^.]*\)\..*|\1|"
}


fill_distr_info()
{
# Default values
PRETTY_NAME=""
DISTRIB_ID=""
DISTRIB_RELEASE=""
DISTRIB_FULL_RELEASE=""
DISTRIB_RELEASE_ORIG=""
DISTRIB_CODENAME=""
BUG_REPORT_URL=""
BUILD_ID=""

# Default detection by /etc/os-release
# https://www.freedesktop.org/software/systemd/man/os-release.html
if distro os-release ; then
    # shellcheck disable=SC1090
    . $DISTROFILE
    DISTRO_NAME="$NAME"
    DISTRIB_ID="$(normalize_name "$NAME")"
    DISTRIB_RELEASE_ORIG="$VERSION_ID"
    DISTRIB_RELEASE="$VERSION_ID"
    [ -n "$DISTRIB_RELEASE" ] || DISTRIB_RELEASE="CUR"
    [ "$BUILD_ID" = "rolling" ] && DISTRIB_RELEASE="rolling"
    [ -n "$BUG_REPORT_URL" ] || BUG_REPORT_URL="$HOME_URL"
    # set by os-release:
    #PRETTY_NAME
    VENDOR_ID="$ID"
    case "$VENDOR_ID" in
        ubuntu|reld|rhel|astra|manjaro)
            ;;
        *)
            # ID_LIKE can be 'rhel centos fedora', use latest word
            [ -n "$ID_LIKE" ] && VENDOR_ID="$(echo "$ID_LIKE" | xargs -n1 | tail -n1)"
            ;;
    esac
    DISTRIB_FULL_RELEASE="$DISTRIB_RELEASE"
    DISTRIB_CODENAME="$VERSION_CODENAME"

elif distro lsb-release ; then
    DISTRIB_ID=$(cat $DISTROFILE | get_var DISTRIB_ID)
    DISTRO_NAME=$(cat $DISTROFILE | get_var DISTRIB_ID)
    DISTRIB_RELEASE="$(cat $DISTROFILE | get_var DISTRIB_RELEASE)"
    DISTRIB_RELEASE_ORIG="$DISTRIB_RELEASE"
    DISTRIB_FULL_RELEASE="$DISTRIB_RELEASE"
    DISTRIB_CODENAME=$(cat $DISTROFILE | get_var DISTRIB_CODENAME)
    PRETTY_NAME=$(cat $DISTROFILE | get_var DISTRIB_DESCRIPTION)
fi

DISTRIB_RELEASE=$(normalize_version2 "$DISTRIB_RELEASE")
[ -n "$DISTRIB_CODENAME" ] || DISTRIB_CODENAME=$DISTRIB_RELEASE

case "$VENDOR_ID" in
    "alt"|"altlinux")
        # 2.4.5.99 -> 2
        DISTRIB_RELEASE=$(normalize_version1 "$DISTRIB_RELEASE_ORIG")
        case "$DISTRIB_ID" in
            "ALTServer"|"ALTSPWorkstation"|"Sisyphus")
                ;;
            *)
                DISTRIB_ID="ALTLinux"
                ;;
        esac
        ;;
    "astra")
        DISTRIB_RELEASE=$(normalize_version2 "$DISTRIB_RELEASE_ORIG" | sed -e 's|_.*||')
        DISTRIB_FULL_RELEASE=$(normalize_version3 "$DISTRIB_RELEASE_ORIG" | sed -e 's|_.*||')
        if [ "$VARIANT" = "orel" ] || [ "$VARIANT" = "Orel" ] ; then
            DISTRIB_ID="AstraLinuxCE"
        else
            DISTRIB_ID="AstraLinuxSE"
        fi
        if [ "$DISTRIB_ID" = "AstraLinuxSE" ] ; then
            local fr="$(cat /etc/astra_version 2>/dev/null)"
            [ -n "$fr" ] && echo "$fr" | grep -q "$DISTRIB_RELEASE" && DISTRIB_FULL_RELEASE="$fr"
        fi
        ;;
    "fedora")
            DISTRIB_ID="Fedora"
        ;;
esac

case "$DISTRIB_ID" in
    "ALTLinux")
        echo "$VERSION" | grep -q "c9.* branch" && DISTRIB_RELEASE="c9"
        echo "$VERSION" | grep -q "c9f1 branch" && DISTRIB_RELEASE="c9f1"
        echo "$VERSION" | grep -q "c9f2 branch" && DISTRIB_RELEASE="c9f2"
        echo "$VERSION" | grep -q "c9f3 branch" && DISTRIB_RELEASE="c9f3"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
        # FIXME: fast hack for fallback: 10.1 -> p10 for /etc/os-release
        if echo "$DISTRIB_RELEASE" | grep -q "^0" ; then
            DISTRIB_RELEASE="Sisyphus"
            DISTRIB_CODENAME="$DISTRIB_RELEASE"
        elif echo "$DISTRIB_RELEASE" | grep -q "^[0-9]" && echo "$DISTRIB_RELEASE" | grep -q -v "[0-9][0-9][0-9]"  ; then
            DISTRIB_CODENAME="$(echo p$DISTRIB_RELEASE | sed -e 's|\..*||')"
            # TODO: change p10 to 10
            DISTRIB_RELEASE="$DISTRIB_CODENAME"
        fi
        ;;
    "ALTServer")
        DISTRIB_ID="ALTLinux"
        DISTRIB_CODENAME="$(echo p$DISTRIB_RELEASE | sed -e 's|\..*||')"
        # TODO: change p10 to 10
        DISTRIB_RELEASE="$DISTRIB_CODENAME"
        ;;
    "ALTSPWorkstation")
        DISTRIB_ID="ALTLinux"
        case "$DISTRIB_RELEASE_ORIG" in
            8.0|8.1)
                ;;
            8.2|8.3)
                DISTRIB_RELEASE="c9f1"
            ;;
            8.4)
                DISTRIB_RELEASE="c9f2"
            ;;
            8.*)
                DISTRIB_RELEASE="c9f3"
            ;;
        esac
        [ -n "$ALT_BRANCH_ID" ] && DISTRIB_RELEASE="$ALT_BRANCH_ID"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
#        DISTRIB_RELEASE=$(echo $DISTRIB_RELEASE | sed -e "s/\..*//g")
        ;;
    "Sisyphus")
        DISTRIB_ID="ALTLinux"
        DISTRIB_RELEASE="Sisyphus"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
        ;;
    "ROSA"|"MOSDesktop"|"MOSPanel")
        DISTRIB_FULL_RELEASE="$DISTRIB_CODENAME"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
        ;;
    "OpenMandrivaLx")
        echo "$PRETTY_NAME" | grep -q "Cooker" && DISTRIB_RELEASE="Cooker"
        echo "$PRETTY_NAME" | grep -q "Rolling" && DISTRIB_RELEASE="Rolling"
        ;;
esac


[ -n "$DISTRIB_ID" ] && [ -n "$DISTRIB_RELEASE" ] && return


# check via obsoleted ways

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
    DISTRIB_CODENAME="$DISTRIB_RELEASE"
    DISTRO_NAME="$DISTRIB_ID"
    DISTRIB_FULL_RELEASE="$DISTRIB_RELEASE"

elif distro gentoo-release ; then
    DISTRIB_ID="Gentoo"
    MAKEPROFILE=$(readlink $ROOTDIR/etc/portage/make.profile 2>/dev/null) || MAKEPROFILE=$(readlink $ROOTDIR/etc/make.profile)
    DISTRIB_RELEASE=$(basename $MAKEPROFILE)
    echo $DISTRIB_RELEASE | grep -q "[0-9]" || DISTRIB_RELEASE=$(basename "$(dirname $MAKEPROFILE)") #"

elif distro slackware-version ; then
    DISTRIB_ID="Slackware"
    DISTRIB_RELEASE="$(grep -Eo '[0-9]+\.[0-9]+' $DISTROFILE)"

elif distro os-release && is_command tce-ab ; then
    # shellcheck disable=SC1090
    . $ROOTDIR/etc/os-release
    DISTRIB_ID="TinyCoreLinux"
    DISTRIB_RELEASE="$VERSION_ID"

elif distro os-release && is_command xbps-query ; then
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

# Debian based
elif distro debian_version ; then
    DISTRIB_ID="Debian"
    DISTRIB_RELEASE=$(cat $DISTROFILE | sed -e "s/\..*//g")


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
elif [ "$(uname)" = "Linux" ] && is_command guix ; then
    DISTRIB_ID="GNU/Linux/Guix"
    DISTRIB_RELEASE=$(uname -r)

# fixme: move to up
elif [ "$(uname)" = "Linux" ] && [ -x $ROOTDIR/system/bin/getprop ] ; then
    DISTRIB_ID="Android"
    DISTRIB_RELEASE=$(getprop | awk -F": " '/system.build.version.release\]/ { print $2 }' | tr -d '[]' | head -n1)
    [ -n "$DISTRIB_RELEASE" ] || DISTRIB_RELEASE=$(getprop | awk -F": " '/build.version.release/ { print $2 }' | tr -d '[]' | head -n1)

elif [ "$(uname -o 2>/dev/null)" = "Cygwin" ] ; then
        DISTRIB_ID="Cygwin"
        DISTRIB_RELEASE="all"
fi

}

get_uname()
{
    tolower "$(uname $1)" | tr -d " \t\r\n"
}

get_glibc_version()
{
    for i in /lib/x86_64-linux-gnu /lib64 /lib/i386-linux-gnu /lib ; do
        [ -x "$ROOTDIR$i/libc.so.6" ] && $ROOTDIR$i/libc.so.6 | head -n1 | grep "version" | sed -e 's|.*version ||' -e 's|\.$||' && return
    done
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
[ -n "$DIST_ARCH" ] && return 0
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
        if is_command readelf && [ -z "$(readelf -A /proc/self/exe | grep Tag_ABI_VFP_args)" ] ; then
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
            detected=$(prtconf | grep Memory | sed -e "s|Memory size: \([0-9][0-9]*\) Megabyte.*|\1|") #"
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
            detected=$(a= sysctl hw.ncpu | awk '{print $2}')
            ;;
        linux)
            detected=$(grep -c "^processor" /proc/cpuinfo)
            ;;
        solaris)
            detected=$(a= prtconf | grep -c 'cpu[^s]')
            ;;
        aix)
            detected=$(a= lsdev -Cc processor -S A | wc -l)
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
    if is_command systemd-detect-virt ; then
        VIRT="$(systemd-detect-virt)"
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

    # use util-linux
    if LC_ALL=C a= lscpu 2>/dev/null | grep "Hypervisor vendor:" | grep -q "KVM" ; then
        echo "kvm" && return
    fi

    echo "(unknown)"
    # TODO: check for openvz
}

get_init_process_name()
{
    [ ! -f /proc/1/comm ] && echo "(unknown)" && return 1
    cat /proc/1/comm | head -n1
    #ps --no-headers -o comm 1
}

# https://unix.stackexchange.com/questions/196166/how-to-find-out-if-a-system-uses-sysv-upstart-or-systemd-initsystem
get_service_manager()
{
    [ -d /run/systemd/system ] && echo "systemd" && return
    # TODO
    #[ -d /usr/share/upstart ] && echo "upstart" && return
    is_command systemctl && [ "$(get_init_process_name)" = 'systemd' ] && echo "systemd" && return
    [ -d /etc/init.d ] && echo "sysvinit" && return
    get_init_process_name
}

filter_duplicated_words()
{
    echo "$*" | xargs -n1 echo | uniq | xargs -n100 echo
}

print_pretty_name()
{
    if [ -z "$PRETTY_NAME" ] ; then
        PRETTY_NAME="$DISTRIB_ID $DISTRIB_RELEASE"
    fi

    if ! echo "$PRETTY_NAME" | grep -q "$DISTRIB_FULL_RELEASE" ; then
        PRETTY_NAME="$PRETTY_NAME ($DISTRIB_FULL_RELEASE)"
    fi

    if ! echo "$PRETTY_NAME" | grep -q "$DISTRIB_RELEASE" ; then
        PRETTY_NAME="$PRETTY_NAME ($DISTRIB_RELEASE)"
    fi

    echo "$(filter_duplicated_words "$PRETTY_NAME")"
}

print_total_info()
{
local orig=''
[ -n "$BUILD_ID" ] && [ "$DISTRIB_FULL_RELEASE" != "$BUILD_ID" ] && orig=" (orig. $BUILD_ID)"
local EV=''
[ -n "$EPMVERSION" ] && EV="(EPM version $EPMVERSION) "
cat <<EOF
distro_info v$PROGVERSION $EV: Copyright © 2007-2024 Etersoft

                       Pretty name (--pretty): $(print_pretty_name)
           (--distro-name / --distro-version): $DISTRO_NAME / $DISTRIB_FULL_RELEASE$orig
         Base distro name (-d) / version (-v): $(print_name_version)
     Vendor distro name (-s) / Repo name (-r): $(pkgvendor) / $(print_repo_name)
                 Package manager/type (-g/-p): $(pkgmanager) / $(pkgtype)
            Base OS name (-o) / CPU arch (-a): $(get_base_os_name) $(get_arch)
                 CPU norm register size  (-b): $(get_bit_size) bit
                          Virtualization (-i): $(get_virt)
                        CPU Cores/MHz (-c/-z): $(get_core_count) / $(get_core_mhz) MHz
                      System memory size (-m): $(get_memory_size) MiB
                 Running service manager (-y): $(get_service_manager)
            Bug report URL (--bug-report-url): $(print_bug_report_url)

(run with -h to get help)
EOF
}

print_help()
{
    echo "distro_info v$PROGVERSION - distro information retriever"
    echo "Usage: distro_info [options] [SystemName/Version]"
    echo "Options:"
    echo " -h | --help            - this help"
    echo " -a                     - print hardware architecture (use --distro-arch for distro depended arch name)"
    echo " -b                     - print size of arch bit (32/64)"
    echo " -c                     - print number of CPU cores"
    echo " -i                     - print virtualization type"
    echo " -m                     - print system memory size (in MB)"
    echo " -y|--service-manager   - print running service manager"
    echo " -z                     - print current CPU MHz"
    echo " --glibc-version        - print system glibc version"
    echo
    echo " -d|--base-distro-name  - print distro id (short distro name)"
    echo " -e                     - print full name of distro with version"
    echo " -o | --os-name         - print base OS name"
    echo " -p | --package-type    - print type of the packaging system (f.i., apt-dpkg)"
    echo " -g                     - print name of the packaging system (f.i., deb)"
    echo " -s|-n|--vendor-name    - print name of the distro family (vendor name) (ubuntu for all Ubuntu family, alt for all ALT family) (see _vendor macros in rpm)"
    echo " --pretty|--pretty-name - print pretty distro name"
    echo " -v | --base-version    - print version of the distro"
    echo " --distro-name          - print distro name"
    echo " --distro-version       - print full version of the distro"
    echo " --full-version         - print full version of the distro"
    echo " --codename (obsoleted) - print distro codename (focal for Ubuntu 20.04)"
    echo " -r|--repo-name         - print repository name (focal for Ubuntu 20.04)"
    echo " --build-id             - print a string uniquely identifying the system image originally used as the installation base"
    echo " -V                     - print the utility version"
    echo "Run without args to print all information."
}

# print code for eval with names for eepm
print_eepm_env()
{
cat <<EOF
# -d | --base-distro-name
DISTRNAME="$(echo $DISTRIB_ID)"
# -v | --base-version
DISTRVERSION="$(echo "$DISTRIB_RELEASE")"
# distro dependent arch
DISTRARCH="$(get_distro_arch)"
# -s | --vendor-name
BASEDISTRNAME=$(pkgvendor)
# --repo-name
DISTRREPONAME=$(print_repo_name)

# -a
SYSTEMARCH="$(get_arch)"
# -y | --service-manager
DISTRCONTROL="$(get_service_manager)"
# -g
PMTYPE="$(pkgmanager)"
# -p | --package-type
PKGFORMAT=$(pkgtype)
# -m
DISTRMEMORY="$(get_memory_size)"

# TODO: remove?
PKGVENDOR=$(pkgvendor)
RPMVENDOR=$(pkgvendor)

EOF

}

override_distrib "$DISTRNAMEOVERRIDE"

if [ -n "$*" ] ; then
    eval lastarg=\${$#}
    case "$lastarg" in
        -*)
            ;;
        *)
            override_distrib "$lastarg"
            # drop last arg
            set -- "${@:1:$(($#-1))}"
            ;;
    esac
fi

# if without override
if [ -z "$DISTRIB_ID" ] ; then
    fill_distr_info
    [ -n "$DISTRIB_ID" ] || DISTRIB_ID="Generic"
fi

if [ -z "$1" ] ; then
    print_total_info
    return
fi

while [ -n "$1" ] ; do
case "$1" in
    -h|--help)
        print_help
        exit 0
        ;;
    -p|--package-type)
        pkgtype
        ;;
    -g)
        pkgmanager
        ;;
    --pretty|--pretty-name)
        print_pretty_name
        ;;
    --distro-arch)
        get_distro_arch
        ;;
    --debian-arch)
        get_debian_arch
        ;;
    --glibc-version)
        get_glibc_version
        ;;
    -d|--base-distro-name)
        echo $DISTRIB_ID
        ;;
    --distro-name)
        echo $DISTRO_NAME
        ;;
    --codename)
        print_codename
        ;;
    -a)
        if [ -n "$DIST_ARCH" ] ; then
            echo "$DIST_ARCH"
        else
            get_arch
        fi
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
    -o|--os-name)
        get_base_os_name
        ;;
    -r|--repo-name)
        print_repo_name
        ;;
    --build-id)
        echo "$BUILD_ID"
        ;;
    -v|--base-version)
        echo "$DISTRIB_RELEASE"
        ;;
    --full-version|--distro-version)
        echo "$DISTRIB_FULL_RELEASE"
        ;;
    --bug-report-url)
        print_bug_report_url
        ;;
    -s|-n|--vendor-name)
        pkgvendor
        ;;
    -y|--service-manager)
        get_service_manager
        ;;
    -V)
        echo "$PROGVERSION"
        ;;
    -e)
        print_name_version
        ;;
    --print-eepm-env)
        print_eepm_env
        exit 0
        ;;
    -*)
        echo "Unsupported option $1" >&2
        # print empty line in any case
        echo
        exit 1
        ;;
esac
shift
done
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

init_eget()
{
PROGDIR=$(dirname "$0")
PROGNAME=$(basename "$0")
CMDSHELL="/bin/sh"
[ "$PROGDIR" = "." ] && PROGDIR="$(pwd)"
if [ "$0" = "/dev/stdin" ] || [ "$0" = "sh" ] ; then
    PROGDIR=""
    PROGNAME=""
fi
}



fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    [ -n "$quiet" ] && return
    echo "$*" >&2
}

eget()
{
	if [ -n "$EPMMODE" ] ; then
		# if embedded in epm
		(unset EGET_IPFS_GATEWAY; unset EGET_IPFS_API ; unset EGET_IPFS_DB ; EGET_BACKEND=$ORIG_EGET_BACKEND internal_tools_eget "$@" )
		return
	fi

	[ -n "$PROGNAME" ] || fatal "pipe mode is not supported"

	local bashopt=''
	#[ -n "$verbose" ] && bashopt='-x'

	(unset EGET_IPFS_GATEWAY; unset EGET_IPFS_API ; unset EGET_IPFS_DB ; EGET_BACKEND=$ORIG_EGET_BACKEND $CMDSHELL $bashopt $PROGDIR/$PROGNAME "$@" )
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
	is_command tput >/dev/null 2>/dev/null || return
	# FreeBSD does not support tput -S
	echo | a= tput -S >/dev/null 2>/dev/null || return
	export USETTY="tput -S"
}

: ${BLACK:=0} ${RED:=1} ${GREEN:=2} ${YELLOW:=3} ${BLUE:=4} ${MAGENTA:=5} ${CYAN:=6} ${WHITE:=7}

set_boldcolor()
{
	[ -n "$USETTY" ] || return
	{
		echo bold
		echo setaf $1
	} | $USETTY
}

set_color()
{
	[ -n "$USETTY" ] || return
	{
		echo setaf $1
	} | $USETTY
}

restore_color()
{
	[ -n "$USETTY" ] || return
	{
		echo op; # set Original color Pair.
		echo sgr0; # turn off all special graphics mode (bold in our case).
	} | $USETTY
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

verdocmd()
{
	[ -n "$verbose" ] && showcmd "$@"
	"$@"
}


# copied from epm
# print a path to the command if exists in $PATH
if a= which which 2>/dev/null >/dev/null ; then
    # the best case if we have which command (other ways needs checking)
    # TODO: don't use which at all, it is binary, not builtin shell command
print_command_path()
{
    a= which -- "$1" 2>/dev/null
}
elif a= type -a type 2>/dev/null >/dev/null ; then
print_command_path()
{
    a= type -fpP -- "$1" 2>/dev/null
}
else
print_command_path()
{
    a= type "$1" 2>/dev/null | sed -e 's|.* /|/|'
}
fi

# check if <arg> is a real command
is_command()
{
    print_command_path "$1" >/dev/null
}

# add realpath if missed
if ! is_command realpath ; then
realpath()
{
    [ -n "$*" ] || return
    readlink -f "$@"
}
fi


# check man glob
filter_glob()
{
	[ -z "$1" ] && cat && return
	# translate glob to regexp
	grep "$(echo "$1" | sed -e 's|\.|\\.|g' -e 's|\*|.*|g' -e 's|\?|.|g' )$"
}

filter_order()
{
    if [ -n "$SECONDLATEST" ] ; then
        sort -V | tail -n2 | head -n1
        return
    fi
    [ -z "$LATEST" ] && cat && return
    sort -V | tail -n1
}

have_end_slash()
{
    echo "$1" | grep -q '/$'
}

is_abs_path()
{
    echo "$1" | grep -q '^/'
}

is_fileurl()
{
    is_abs_path "$1" && return
    echo "$1" | grep -q "^file:/"
}

path_from_url()
{
    echo "$1" | sed -e 's|^file://*|/|'
}

is_url()
{
    echo "$1" | grep -q "^[filehtps]*:/"
}

is_strange_url()
{
    local URL="$1"
    is_url "$URL" || return
    echo "$URL" | grep -q "[?&]"
}

is_ipfs_hash()
{
    # If a CID is 46 characters starting with "Qm", it's a CIDv0
    echo "$1" | grep -q -E "^Qm[[:alnum:]]{44}$" && return
    # TODO: CIDv1 support, see https://github.com/multiformats/cid
    return 1
}

is_ipfsurl()
{
    is_ipfs_hash "$1" && return
    echo "$1" | grep -q "^ipfs://"
}

is_httpurl()
{
    # TODO: improve
    echo "$1" | grep -q "^https://" & return
    echo "$1" | grep -q "^http://" & return
}

cid_from_url()
{
    echo "$1" | sed -e 's|^ipfs://*||' -e 's|\?.*||'
}


# args: cmd <URL> <options>
# will run cmd <options> <URL>
download_with_mirroring()
{
    local CMD="$1"
    shift
    local URL="$1"
    shift

    local res
    $CMD "$@" "$URL" && return
    res=$?
    [ -n "$CHECKMIRRORS" ] || return $res

    MIRROR="https://mirror.eterfund.ru"
    SECONDURL="$(echo "$URL" | sed -e "s|^.*://|$MIRROR/|")"
    $CMD "$@" "$SECONDURL" && URL="$SECONDURL" && return

    MIRROR="https://mirror.eterfund.org"
    SECONDURL="$(echo "$URL" | sed -e "s|^.*://|$MIRROR/|")"
    $CMD "$@" "$SECONDURL" && URL="$SECONDURL" && return
}



check_tty

quiet=''
verbose=''
WGETNOSSLCHECK=''
CURLNOSSLCHECK=''
AXELNOSSLCHECK=''
WGETUSERAGENT=''
CURLUSERAGENT=''
AXELUSERAGENT=''
WGETHEADER=''
CURLHEADER=''
AXELHEADER=''
WGETCOMPRESSED=''
CURLCOMPRESSED=''
AXELCOMPRESSED=''
WGETQ='' #-q
CURLQ='' #-s
AXELQ='' #-q
# TODO: aria2c
# TODO: wget --trust-server-names
# TODO: 
WGETNAMEOPTIONS='--content-disposition'
CURLNAMEOPTIONS='--remote-name --remote-time --remote-header-name'
AXELNAMEOPTIONS=''


LISTONLY=''
CHECKURL=''
CHECKSITE=''
GETRESPONSE=''
GETFILENAME=''
GETREALURL=''
GETIPFSCID=''
LATEST=''
SECONDLATEST=''
CHECKMIRRORS=''
TARGETFILE=''
FORCEIPV=''


set_quiet()
{
    WGETQ='-q'
    CURLQ='-s'
    AXELQ='-q'
    quiet=1
}


eget_help()
{
cat <<EOF

eget - wget like downloader wrapper with wildcard support in filename part of URL
Usage: eget [options] http://somesite.ru/dir/na*.log

Options:
    -q|--quiet                - quiet mode
    --verbose                 - verbose mode
    -k|--no-check-certificate - skip SSL certificate chain support
    -H|--header               - use <header> (X-Cache:1 for example)
    -U|-A|--user-agent        - send browser like UserAgent
    --compressed              - request a compressed response and automatically decompress the content
    -4|--ipv4|--inet4-only    - use only IPV4
    -6|--ipv6|--inet6-only    - use only IPV6
    -O-|-O -                  - output downloaded file to stdout
    -O file                   - download to this file
    --latest                  - print only latest version of a file
    --second-latest           - print only second to latest version of a file
    --allow-mirrors           - check mirrors if url is not accessible

    --list|--list-only        - print only URLs
    --check-url URL           - check if the URL exists (returns HTTP 200 OK)
    --check-site URL          - check if the site is accessible (returns HTTP 200 OK or 404 Not found)
    --get-response URL        - get response with all headers (ever if HEAD is not acceptable)
    --get-filename URL        - print filename for the URL (via Content-Disposition if applicable)
    --get-real-url URL        - print URL after all redirects
    --get-ipfs-cid URL        - print CID for URL (after all redirects)

Supported URLs:
  ftp:// http:// https:// file:/ ipfs://

Supported backends (set like EGET_BACKEND=curl)
  wget curl (todo: aria2c)

Examples:
  $ eget http://ftp.somesite.ru/package-*.x64.tar
  $ eget http://ftp.somesite.ru/package *.tar
  $ eget https://github.com/owner/project package*.ext
  $ eget -O myname ipfs://QmVRUjnsnxHWkjq91KreCpUk4D9oZEbMwNQ3rzdjwND5dR
  $ eget --list http://ftp.somesite.ru/package-*.tar
  $ eget --check-url http://ftp.somesite.ru/test
  $ eget --list http://download.somesite.ru 'package-*.tar.xz'
  $ eget --list --latest https://github.com/telegramdesktop/tdesktop/releases 'tsetup.*.tar.xz'

EOF
}


if [ -z "$1" ] ; then
    echo "eget - wget like downloader wrapper with wildcard support, uses wget or curl as backend" >&2
    echo "Run $0 --help to get help" >&2
    exit 1
fi


while [ -n "$1" ] ; do

    case "$1" in
        -h|--help)
            eget_help
            return
            ;;
        -q|--quiet)
            set_quiet
            ;;
        --verbose)
            verbose="$1"
            ;;
        -k|--no-check-certificate)
            WGETNOSSLCHECK='--no-check-certificate'
            CURLNOSSLCHECK='-k'
            AXELNOSSLCHECK='--insecure'
            ;;
        -H|--header)
            shift
            WGETHEADER="--header=$1"
            CURLHEADER="--header $1"
            AXELHEADER="--header=$1"
            ;;
        -U|-A|--user-agent)
            user_agent="Mozilla/5.0 (X11; Linux $arch) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
            WGETUSERAGENT="-U '$user_agent'"
            CURLUSERAGENT="-A '$user_agent'"
            AXELUSERAGENT="--user-agent='$user_agent'"
            ;;
        --compressed)
            CURLCOMPRESSED='--compressed'
            WGETCOMPRESSED='--compression=auto'
            ;;
        -4|--ipv4|--inet4-only)
            FORCEIPV="-4"
            ;;
        -6|--ipv6|--inet6-only)
            FORCEIPV="-6"
            ;;
        --list|--list-only)
            LISTONLY="$1"
            set_quiet
            ;;
        --check-url)
            CHECKURL="$1"
            #set_quiet
            ;;
        --check-site|--check)
            CHECKSITE="$1"
            #set_quiet
            ;;
        --get-filename)
            GETFILENAME="$1"
            ;;
        --get-response)
            GETRESPONSE="$1"
            ;;
        --get-real-url)
            GETREALURL="$1"
            ;;
        --get-ipfs-cid)
            GETIPFSCID="$1"
            ;;
        --latest)
            LATEST="$1"
            ;;
        --second-latest)
            SECONDLATEST="$1"
            ;;
        --check-mirrors)
            CHECKMIRRORS="$1"
            ;;
        -O)
            shift
            TARGETFILE="$1"
            ;;
        -O-)
            TARGETFILE="-"
            ;;
        -*)
            fatal "Unknown option '$1', check eget --help."
            ;;
        *)
            break
            ;;
    esac
    shift
done


#############################3
# defaults

# https://github.com/ipfs/kubo/issues/5541
ipfs_diag_timeout='--timeout 60s'

ipfs_api_local="/ip4/127.0.0.1/tcp/5001"
[ -n "$EGET_IPFS_API" ] && ipfs_api_local="$EGET_IPFS_API"

ipfs_api_brave="/ip4/127.0.0.1/tcp/45005"

# Public IPFS http gateways
ipfs_gateways="https://cloudflare-ipfs.com/ipfs https://dweb.link/ipfs https://dhash.ru/ipfs"

# Test data: https://etersoft.ru/templates/etersoft/images/logo.png
ipfs_checkQm="QmYwf2GAMvHxfFiUFL2Mr6KUG6QrDiupqGc8ms785ktaYw"

get_ipfs_brave()
{
    local ipfs_brave="$(ls ~/.config/BraveSoftware/Brave-Browser/*/*/go-ipfs_* 2>/dev/null | sort | tail -n1)"
    [ -n "$ipfs_brave" ] && [ -x "$ipfs_brave" ] || return
    echo "$ipfs_brave"
}

ipfs_api_access()
{
    [ -n "$IPFS_CMD" ] || fatal "IPFS is disabled"
    if [ -n "$verbose" ] ; then
         verdocmd $IPFS_CMD --api $IPFS_API $ipfs_diag_timeout diag sys >/dev/null
    else
         verdocmd $IPFS_CMD --api $IPFS_API $ipfs_diag_timeout diag sys >/dev/null 2>/dev/null
    fi
}

ipfs_check()
{
    [ -n "$IPFS_CMD" ] || fatal "IPFS is disabled"
    verdocmd $IPFS_CMD --api $IPFS_API $ipfs_diag_timeout cat "$1" >/dev/null
}

check_ipfs_gateway()
{
    local ipfs_gateway="$1"
    # TODO: check checksum
    if docmd eget --check-url "$ipfs_gateway/$ipfs_checkQm" ; then
        ipfs_mode="gateway"
        return
    fi

    if docmd eget --check-site "$(dirname $ipfs_gateway)" ; then
       info "IPFS gateway $ipfs_gateway is accessible, but can't return shared $ipfs_checkQm"
    else
       info "IPFS gateway $(dirname $ipfs_gateway) is not accessible"
    fi

    return 1
}

select_ipfs_gateway()
{
    # check public http gateways
    for ipfs_gateway in $ipfs_gateways ; do
        check_ipfs_gateway $ipfs_gateway || continue
        IPFS_GATEWAY="$ipfs_gateway"
        return
    done

    ipfs_mode="disabled"
    return 1
}


select_ipfs_mode()
{
    IPFS_CMD="$(print_command_path ipfs)"
    if [ -n "$IPFS_CMD" ] ; then
        IPFS_API="$ipfs_api_local"
        if ipfs_api_access ; then
            ipfs_mode="local" && return
            #if ipfs_check "$ipfs_checkQm" ; then
            #    ipfs_mode="local" && return
            #else
            #    info "Skipped local: it is accessible via $IPFS_CMD --api $IPFS_API, but can't return shared $ipfs_checkQm"
            #fi
        fi
    fi

    IPFS_CMD="$(get_ipfs_brave)"
    # if no EGET_IPFS_API, check brave
    if [ -z "$EGET_IPFS_API" ] && [ -n "$IPFS_CMD" ] ; then
        IPFS_API="$ipfs_api_brave"
        if ipfs_api_access ; then
            ipfs_mode="brave" && return
            #if ipfs_check "$ipfs_checkQm" ; then
            #    ipfs_mode="brave" && return
            #else
            #    info "Skipped Brave: it is accessible via $IPFS_CMD --api $IPFS_API, but can't return shared $ipfs_checkQm"
            #fi
        fi
    fi

    IPFS_GATEWAY=''

    # if set some http gateway, use only it
    if [ -n "$EGET_IPFS_GATEWAY" ] ; then
        check_ipfs_gateway "$EGET_IPFS_GATEWAY" && IPFS_GATEWAY="$EGET_IPFS_GATEWAY" || ipfs_mode="disabled"
        return
    fi

    select_ipfs_gateway
}


# Functions for work with eget ipfs db
get_cid_by_url()
{
    local URL="$1"
    [ -r "$EGET_IPFS_DB" ] || return
    is_fileurl "$URL" && return 1
    grep -F "$URL Qm" "$EGET_IPFS_DB" | cut -f2 -d" " | grep -E "Qm[[:alnum:]]{44}" | head -n1
}

put_cid_and_url()
{
    local URL="$1"
    local CID="$2"
    local FN="$3"
    [ -w "$EGET_IPFS_DB" ] || return

    is_fileurl "$URL" && return

    echo "$URL $CID $FN" >> "$EGET_IPFS_DB"
    info "Placed in $EGET_IPFS_DB: $URL $CID $FN"
}

get_filename_by_cid()
{
    local CID="$1"
    [ -z "$EGET_IPFS_DB" ] && basename "$CID" && return
    grep -F " $CID " "$EGET_IPFS_DB" | head -n1 | cut -f3 -d" "
}

get_url_by_cid()
{
    local CID="$1"
    [ -z "$EGET_IPFS_DB" ] && echo "$CID" && return
    grep -F " $CID " "$EGET_IPFS_DB" | head -n1 | cut -f1 -d" "
}

###################


ipfs_mode="$EGET_IPFS"

# enable auto mode when set $EGET_IPFS_DB
[ -z "$ipfs_mode" ] && [ -n "$EGET_IPFS_DB" ] && ipfs_mode="auto"

if [ -n "$LISTONLY$CHECKURL$CHECKSITE" ] ; then
    ipfs_mode=""
    EGET_IPFS_DB=''
fi


if [ -n "$ipfs_mode" ] && [ -n "$EGET_IPFS_DB" ] ; then
    ddb="$(dirname "$EGET_IPFS_DB")"
    if [ -d "$ddb" ] ; then
        info "Using eget IPFS db $EGET_IPFS_DB"
        [ -r "$EGET_IPFS_DB" ] || touch "$EGET_IPFS_DB"
    else
        EGET_IPFS_DB=''
    fi
fi


# detect if we run with ipfs:// or with auto
if is_ipfsurl "$1" && [ -z "$ipfs_mode" ] || [ "$ipfs_mode" = "auto" ] ; then
    info "Autodetecting available IPFS relay..."
    select_ipfs_mode
    info "Auto selected IPFS mode: $ipfs_mode"
    [ "$ipfs_mode" = "gateway" ] && info "Since the ipfs command is missed, the http gateway will be used."
else
    [ "$ipfs_mode" = "gateway" ] && select_ipfs_gateway
    [ -n "$ipfs_mode" ] && info "IPFS mode: $ipfs_mode"
fi

IPFS_CMD=''

if [ "$ipfs_mode" = "disabled" ] ; then

ipfs_get()
{
    fatal "IPFS is disabled"
}

ipfs_put()
{
    fatal "IPFS is disabled"
}

ipfs_cat()
{
    fatal "IPFS is disabled"
}


elif [ "$ipfs_mode" = "brave" ] ; then
    IPFS_CMD="$(get_ipfs_brave)" || fatal "Can't find ipfs command in Brave"
    IPFS_PRETTY_CMD="~Brave-Browser/$(basename $IPFS_CMD)"
    IPFS_API="$ipfs_api_brave"
    ipfs_api_access || fatal "Can't access to Brave IPFS API (Brave browser is not running and IPFS is not activated?)"
    info "Will use $IPFS_PRETTY_CMD --api $IPFS_API"

elif [ "$ipfs_mode" = "local" ] ; then
    IPFS_CMD="$(print_command_path ipfs)" || fatal "Can't find ipfs command"
    IPFS_PRETTY_CMD="$IPFS_CMD"
    IPFS_API="$ipfs_api_local"
    ipfs_api_access || fatal "Can't access to IPFS API (ipfs daemon is not running?)"
    info "Will use $IPFS_PRETTY_CMD --api $IPFS_API"

elif [ "$ipfs_mode" = "gateway" ] ; then
    info "Will use eget $IPFS_GATEWAY/HASH"

ipfs_get_real_url()
{
    [ -n "$IPFS_GATEWAY" ] || fatal "ipfs http gateway is not set"
    echo "$IPFS_GATEWAY/$1"
}

ipfs_get()
{
    if [ -n "$2" ] ; then
        docmd eget -O "$2" "$(ipfs_get_real_url "$1")"
    else
        docmd eget "$(ipfs_get_real_url "$1")"
    fi
}

ipfs_cat()
{
    # FIXME:
    ipfs_get "$1" "-"
}

ipfs_put()
{
    info "IPFS put skipped when a gateway is used"
    return 1
}
elif [ -z "$ipfs_mode" ] ; then
    :
else
    fatal "Unsupported eget ipfs mode $ipfs_mode"
fi

if [ -n "$IPFS_CMD" ] ; then

ipfs_get_real_url()
{
    return 1
}

ipfs_get()
{
    [ -n "$IPFS_CMD" ] || fatal "ipfs api is not usable"
    if [ -n "$2" ] ; then
        showcmd $IPFS_PRETTY_CMD --api $IPFS_API get -o "$2" "$1"
        $IPFS_CMD --api $IPFS_API get -o "$2" "$1"
    else
        showcmd $IPFS_PRETTY_CMD --api $IPFS_API get "$1"
        $IPFS_CMD --api $IPFS_API get "$1"
    fi
}

ipfs_put()
{
    [ -n "$IPFS_CMD" ] || fatal "ipfs api is not usable"

    # detect if -q is used (will output Qm instead of addded Qm)
    local qu="$1"
    [ "$qu" = "-q" ] || qu=''

    showcmd $IPFS_PRETTY_CMD --api $IPFS_API add "$@"

    local res
    res="$($IPFS_CMD --api $IPFS_API add "$@")" || return

    if [ -z "$qu" ] ; then
        res="$(echo "$res" | grep "^added Qm")" || return
        res="$(echo "$res" | cut -f2 -d" ")"
    fi

    is_ipfs_hash "$res" && echo "$res" && return
    fatal "Can't recognize $res IPFS hash"
}

ipfs_cat()
{
    [ -n "$IPFS_CMD" ] || fatal "ipfs api is not usable"
    showcmd $IPFS_PRETTY_CMD --api $IPFS_API cat "$1"
    $IPFS_CMD --api $IPFS_API cat "$1"
}

fi
###############################



WGET="$(print_command_path wget)"
CURL="$(print_command_path curl)"

ORIG_EGET_BACKEND="$EGET_BACKEND"
# override backend
if is_fileurl "$1" ; then
    EGET_BACKEND="file"
elif is_ipfsurl "$1" ; then
    EGET_BACKEND="ipfs"
fi


case "$EGET_BACKEND" in
    file|ipfs)
        ;;
    wget)
        [ -n "$WGET" ] || fatal "There are no wget in the system but you forced using it via EGET_BACKEND. Install it with $ epm install wget"
        ;;
    curl)
        [ -n "$CURL" ] || fatal "There are no curl in the system but you forced using it via EGET_BACKEND. Install it with $ epm install curl"
        ;;
    '')
        [ -n "$WGET" ] && EGET_BACKEND="wget"
        [ -z "$EGET_BACKEND" ] && [ -n "$CURL" ] && EGET_BACKEND="curl"
        [ -n "$EGET_BACKEND" ] || fatal "There are no wget nor curl in the system. Install something with $ epm install wget"
        ;;
    *)
        fatal "Uknown EGET_BACKEND $EGET_BACKEND"
        ;;
esac



if [ "$EGET_BACKEND" = "file" ] ; then

# put remote content to stdout
url_scat()
{
    local URL="$1"
    cat "$(path_from_url "$URL")"
}
# download to default name of to $2
url_sget()
{
    local URL="$1"
    if [ "$2" = "/dev/stdout" ] || [ "$2" = "-" ] ; then
       scat "$URL"
       return
    elif [ -n "$2" ] ; then
       cp -av "$(path_from_url "$URL")" "$2"
       return
    fi
    cp -av "$(path_from_url "$URL")" .
}

url_check_accessible()
{
    local URL="$1"
    test -f "$(path_from_url "$URL")"
}

url_check_available()
{
    local URL="$1"
    test -f "$(path_from_url "$URL")"
}

url_get_filename()
{
    basename "$1"
}

url_get_real_url()
{
    echo "$1"
}

elif [ "$EGET_BACKEND" = "ipfs" ] ; then

# put remote content to stdout
url_scat()
{
    local URL="$1"
    ipfs_cat "$(cid_from_url "$URL")"
}
# download to default name of to $2
url_sget()
{
    local URL="$1"
    if [ "$2" = "/dev/stdout" ] || [ "$2" = "-" ] ; then
       scat "$URL"
       return
    elif [ -n "$2" ] ; then
       ipfs_get "$(cid_from_url "$URL")" "$2"
       return
    fi

    local fn="$(url_print_filename_from_url "$URL")"
    if [ -n "$fn" ] ; then
       ipfs_get "$(cid_from_url "$URL")" "$fn"
       return
    fi

    ipfs_get "$(cid_from_url "$URL")"
}

url_check_accessible()
{
    local URL="$1"
    # TODO: improve me
    scat "$URL" >/dev/null
}

url_check_available()
{
    local URL="$1"
    # TODO: improve me
    scat "$URL" >/dev/null
}

url_print_filename_from_url()
{
    local URL="$1"
    local fn="$(echo "$URL" | sed -e 's|ipfs://.*\?filename=||')"
    [ "$URL" != "$fn" ] && echo "$fn" && return
}

url_get_filename()
{
    local URL="$1"
    url_print_filename_from_url "$URL" && return
    local CID="$(cid_from_url "$URL")"
    get_filename_by_cid "$CID"
}

url_get_real_url()
{
    local URL="$1"
    local CID="$(cid_from_url "$URL")"
    # if we use gateway, return URL with gateway
    ipfs_get_real_url "$URL" && return
    get_url_by_cid "$CID"
}


elif [ "$EGET_BACKEND" = "wget" ] ; then
__wget()
{
    if [ -n "$WGETUSERAGENT" ] ; then
        docmd $WGET $FORCEIPV $WGETQ $WGETCOMPRESSED $WGETHEADER $WGETNOSSLCHECK "$WGETUSERAGENT" "$@"
    else
        docmd $WGET $FORCEIPV $WGETQ $WGETCOMPRESSED $WGETHEADER $WGETNOSSLCHECK "$@"
    fi
}

# put remote content to stdout
url_scat()
{
    local URL="$1"
    download_with_mirroring __wget "$URL" -O-
}
# download to default name of to $2
url_sget()
{
    local URL="$1"
    if [ "$2" = "/dev/stdout" ] || [ "$2" = "-" ] ; then
       scat "$URL"
       return
    elif [ -n "$2" ] ; then
       download_with_mirroring __wget "$URL" -O "$2"
       return
    fi
# TODO: поддержка rsync для известных хостов?
# Не качать, если одинаковый размер и дата
# -nc
# TODO: overwrite always
    download_with_mirroring __wget "$URL" $WGETNAMEOPTIONS
}

url_get_response()
{
    local URL="$1"
    local answer
    answer="$(quiet=1 __wget --spider -S "$URL" 2>&1)"
    # HTTP/1.1 405 Method Not Allowed
    if echo "$answer" | grep -q "^ *HTTP/[12.]* 405" ; then
        (quiet=1 __wget --start-pos=5000G -S "$URL" 2>&1)
        return
    fi
    echo "$answer"
}


elif [ "$EGET_BACKEND" = "curl" ] ; then

__curl()
{
    if [ -n "$CURLUSERAGENT" ] ; then
        docmd $CURL $FORCEIPV --fail -L $CURLQ $CURLCOMPRESSED $CURLHEADER "$CURLUSERAGENT" $CURLNOSSLCHECK "$@"
    else
        docmd $CURL $FORCEIPV --fail -L $CURLQ $CURLCOMPRESSED $CURLHEADER $CURLNOSSLCHECK "$@"
    fi
}
# put remote content to stdout
url_scat()
{
    local URL="$1"
    download_with_mirroring __curl "$URL" --output -
}
# download to default name of to $2
url_sget()
{
    local URL="$1"
    local res
    if [ "$2" = "/dev/stdout" ] || [ "$2" = "-" ] ; then
       scat "$1"
       return
    elif [ -n "$2" ] ; then
       download_with_mirroring __curl "$URL" --output "$2"
       return
    fi

    download_with_mirroring __curl "$URL" $CURLNAMEOPTIONS
}

url_get_response()
{
    local URL="$1"
    local answer
    answer="$(quiet=1 __curl -LI "$URL" 2>&1)"
    # HTTP/1.1 405 Method Not Allowed
    if echo "$answer" | grep -q "^ *HTTP/[12.]* 405" ; then
        (quiet=1 __curl -L -i -r0-0 "$URL" 2>&1)
        return
    fi
    echo "$answer"
}

else
    fatal "Unknown EGET_BACKEND '$EGET_BACKEND', logical error."
fi


# Common code for both wget and curl (http related)
if [ "$EGET_BACKEND" = "wget" ] || [ "$EGET_BACKEND" = "curl" ] ; then

url_get_headers()
{
    local URL="$1"
    url_get_response "$URL" | grep -i "^ *[[:alpha:]].*: " | sed -e 's|^ *||' -e 's|\r$||'
}

url_check_accessible()
{
    local URL="$1"
    url_get_response "$URL" | grep "HTTP/" | tail -n1 | grep -q -w "200\|404"
}

url_check_available()
{
    local URL="$1"
    url_get_response "$URL" | grep "HTTP/" | tail -n1 | grep -q -w "200"
}

url_get_header()
{
    local URL="$1"
    local HEADER="$2"
    url_get_headers "$URL" | grep -i "^ *$HEADER: " | sed -e "s|^ *$HEADER: ||i"
}

url_get_real_url()
{
    local URL="$1"

    ! is_httpurl "$URL" && echo "$URL" && return

    # don't check location if we have made form of the URL
    [ -n "$MADEURL" ] && [ "$MADEURL" = "$URL" ] && echo "$URL" && return

    local loc
    for loc in $(url_get_header "$URL" "Location" | tac | sed -e 's| .*||') ; do
        # hack for construct full url from related Location
        if is_abs_path "$loc" ; then
            loc="$(concatenate_url_and_filename "$(get_host_only "$URL")" "$loc")" #"
        fi
        if ! is_strange_url "$loc" ; then
            echo "$loc"
            return
        fi
    done

    echo "$URL"
}

url_get_filename()
{
    local URL="$1"

    ! is_httpurl "$URL" && basename "$URL" && return

    # See https://www.cpcwood.com/blog/5-aws-s3-utf-8-content-disposition
    # https://www.rfc-editor.org/rfc/rfc6266
    local cd="$(url_get_header "$URL" "Content-Disposition")"
    if echo "$cd" | grep -qi "filename\*= *UTF-8" ; then
        #Content-Disposition: attachment; filename="unityhub-amd64-3.3.0.deb"; filename*=UTF-8''"unityhub-amd64-3.3.0.deb"
        echo "$cd" | sed -e "s|.*filename\*= *UTF-8''||i" -e 's|^"||' -e 's|";$||' -e 's|"$||'
        return
    fi
    if echo "$cd" | grep -qi "filename=" ; then
        #Content-Disposition: attachment; filename=postman-linux-x64.tar.gz
        #content-disposition: attachment; filename="code-1.77.1-1680651749.el7.x86_64.rpm"
        echo "$cd" | sed -e 's|.*filename= *||i' -e 's|^"||' -e 's|";.*||' -e 's|"$||'
        return
    fi

    basename "$(url_get_real_url "$URL")"
}

fi


if [ -n "$ipfs_mode" ] && [ -n "$EGET_IPFS_DB" ] &&  ! is_ipfsurl "$1"  ; then

download_to_ipfs()
{
    local URL="$1"
    local res
    #res="$(url_scat "$URL" | ipfs_put )" || return
    #res="$(echo "$res" | grep "^added Qm")" || return 1
    #CID="$(echo "$res" | cut -f2 -d" ")"
    # with -q to disable progress (mixed with download progress)
    res="$(url_scat "$URL" | ipfs_put -q)" || return
    is_ipfs_hash "$res" || return 1
    echo "$res"
}

# put remote content to stdout
scat()
{
    local URL="$1"
    url_scat "$URL"

    # It is list only function. Don't save to IPFS
    return

    ###################

    local CID="$(get_cid_by_url "$URL")"
    if [ -n "$CID" ] ; then
        info "$URL -> $CID"
        ipfs_cat "$CID"
        return
    fi

    CID="$(download_to_ipfs "$URL")" || return

    ipfs_cat "$CID" || return

    local FN="$(url_get_filename "$URL")" || return

    put_cid_and_url "$URL" "$CID" "$FN"
}

# download to default name of to $2
sget()
{
    local URL="$1"
    local TARGET="$2"

    if [ -n "$GETFILENAME" ] ; then
        get_filename "$URL"
        return
    fi

    local REALURL="$(get_real_url "$URL")" || return

    if [ -n "$GETREALURL" ] ; then
        echo "$REALURL"
        return
    fi

    # skip ipfs for cat
    if [ "$TARGET" = "/dev/stdout" ] || [ "$TARGET" = "-" ] ; then
       url_scat "$URL"
       return
    fi


    #if is_strange_url "$REALURL" ; then
    #    info "Just download strange URL $REALURL, skipping IPFS"
    #    url_sget "$REALURL" "$TARGET"
    #    return
    #fi

    local CID="$(get_cid_by_url "$REALURL")"
    if [ -n "$CID" ] ; then

        if [ -n "$GETIPFSCID" ] ; then
            echo "$CID"
            return
        fi

        if [ -n "$GETFILENAME" ] ; then
            get_filename_by_cid "$CID"
            return
        fi

        if [ -n "$GETREALURL" ] ; then
            get_url_by_cid "$CID"
            return
        fi

        if [ -z "$TARGET" ] ; then
            # TODO: in some cases we can get name from URL...
            TARGET="$(get_filename_by_cid "$CID")"
            if [ -z "$TARGET" ] ; then
                TARGET="$CID"
            fi
        fi
        [ "$URL" = "$REALURL" ] && info "$URL -> $CID -> $TARGET" || info "$URL -> $REALURL -> $CID -> $TARGET"
        ipfs_get "$CID" "$TARGET" && return

        # fail get from IPFS, fallback
        url_sget "$REALURL" "$TARGET"
        return
    fi


    # download and put to IPFS
    local FN="$(url_get_filename "$REALURL")" || return
    if [ -z "$TARGET" ] ; then
        TARGET="$FN"
    fi

    if [ -n "$GETIPFSCID" ] ; then
         # add to IPFS and print out CID
         CID="$(ipfs_put --progress "$REALURL")" || return
         echo "$CID"
         return
    fi

    # download file and add to IPFS
    url_sget "$REALURL" "$TARGET" || return

    # don't do ipfs put when gateway is using
    [ "$ipfs_mode" = "gateway" ] && return

    CID="$(ipfs_put --progress "$TARGET")" || return

    put_cid_and_url "$REALURL" "$CID" "$FN"
}

check_url_is_available()
{
    local URL="$1"
    local REALURL="$(get_real_url "$URL")" || return
    local CID="$(get_cid_by_url "$REALURL")"
    if [ -n "$CID" ] ; then
        [ "$URL" = "$REALURL" ] && info "$URL -> $CID" || info "$URL -> $REALURL -> $CID"
        ipfs_check "$CID"
        return
    fi

    CID="$(download_to_ipfs "$REALURL")" || return

    local FN="$(url_get_filename "$REALURL")" || return
    ipfs_cat "$CID" >/dev/null || return
    put_cid_and_url "$REALURL" "$CID" "$FN"
}

check_url_is_accessible()
{
    check_url_is_available "$@"
}

get_filename()
{
    url_get_filename "$1"
}

get_real_url()
{
    url_get_real_url "$1"
}

else
scat()
{
    url_scat "$@"
}

sget()
{
    if [ -n "$GETFILENAME" ] ; then
        get_filename "$1"
        return
    fi

    if [ -n "$GETREALURL" ] ; then
        get_real_url "$1"
        return
    fi

    url_sget "$@"
}

check_url_is_accessible()
{
    url_check_accessible "$@"
}

check_url_is_available()
{
    url_check_available "$@"
}

get_filename()
{
    url_get_filename "$1"
}

get_real_url()
{
    url_get_real_url "$1"
}

fi


get_github_urls()
{
    # https://github.com/OWNER/PROJECT
    local owner="$(echo "$1" | sed -e "s|^https://github.com/||" -e "s|/.*||")" #"
    local project="$(echo "$1" | sed -e "s|^https://github.com/$owner/||" -e "s|/.*||")" #"
    [ -n "$owner" ] || fatal "Can't get owner from $1"
    [ -n "$project" ] || fatal "Can't get project from $1"
    local URL="https://api.github.com/repos/$owner/$project/releases"
    # api sometime returns unformatted json
    scat $URL | sed -e 's|,\(["{]\)|,\n\1|g' | \
        grep -i -o -E '"browser_download_url": *"https://.*"' | cut -d'"' -f4
}

# drop file path from URL
get_host_only()
{
    echo "$1/" | grep -Eo '(.*://[^/]+)'
}

concatenate_url_and_filename()
{
    local url="$(echo "$1" | sed -e 's|/*$||' )"
    local fn="$(echo "$2" | sed -e 's|^/*||' )"
    echo "$url/$fn"
}

# MADEURL filled with latest made URL as flag it is end form of URL
MADEURL=''

# Args: URL filename
make_fileurl()
{
    local url="$1"
    local fn="$2"

    fn="$(echo "$fn" | sed -e 's|^./||' -e 's|^/+||')"

    if is_fileurl "$url" ; then
        # if it is url
        :
    elif is_abs_path "$fn" ; then
        # if there is file path from the root of the site
        url="$(get_host_only "$url")"
    elif ! have_end_slash "$url" ; then
        url="$(dirname "$url")"
    fi

    MADEURL="$(concatenate_url_and_filename "$url" "$fn")"
    echo "$MADEURL"
}

get_urls()
{
    if is_fileurl "$URL" ; then
        ls -1 "$(path_from_url "$URL")"
        return
    fi

    # cat html, divide to lines by tags and cut off hrefs only
    scat $URL | sed -e 's|<|<\n|g' -e 's|data-file=|href=|g' -e "s|href=http|href=\"http|g" -e "s|>|\">|g" -e "s|'|\"|g" | \
         grep -i -o -E 'href="(.+)"' | sed -e 's|&amp;|\&|' | cut -d'"' -f2
}


if [ -n "$CHECKURL" ] ; then
    #set_quiet
    URL="$1"
    check_url_is_available "$URL"
    res=$?
    if [ -n "$verbose" ] ; then
        [ "$res" = "0" ] && echo "$URL is accessible via network and file exists" || echo "$URL is NOT accessible via network or file does not exist"
    fi
     return $res
fi

if [ -n "$CHECKSITE" ] ; then
    #set_quiet
    URL="$1"
    check_url_is_accessible "$URL"
    res=$?
    if [ -n "$verbose" ] ; then
        [ "$res" = "0" ] && echo "$URL is accessible via network" || echo "$URL is NOT accessible via network"
    fi
     return $res
fi

if [ -n "$GETRESPONSE" ] ; then
    url_get_response "$1"
    return
fi


# separate part for github downloads
if echo "$1" | grep -q "^https://github.com/" && \
   echo "$1" | grep -q -v "/download/" && [ -n "$2" ] ; then
    MASK="$2"

    if [ -n "$LISTONLY" ] ; then
        get_github_urls "$1" | filter_glob "$MASK" | filter_order
        return
    fi

    ERROR=0
    for fn in $(get_github_urls "$1" | filter_glob "$MASK" | filter_order) ; do
        MADEURL="$fn" # mark it is the end form of the URL
        sget "$fn" "$TARGETFILE" || ERROR=1
        [ -n "$TARGETFILE" ] && [ "$ERROR" = "0" ] && break
    done
    return
fi

if is_ipfsurl "$1" ; then
    [ -n "$2" ] && fatal "too many args when ipfs://Qm... used: extra '$2' arg"
    sget "$1" "$TARGETFILE"
    return
fi

# if mask is the second arg
if [ -n "$2" ] ; then
    URL="$1"
    MASK="$2"
else
    if have_end_slash "$1" ; then
        URL="$1"
        MASK=""
    else
        # drop mask part
        URL="$(dirname "$1")/"
        # wildcards allowed only in the last part of path
        MASK=$(basename "$1")
    fi

fi

# https://www.freeoffice.com/download.php?filename=freeoffice-2021-1062.x86_64.rpm
if echo "$URL" | grep -q "[*\[\]]" ; then
    fatal "Error: there are globbing symbol (*[]) in $URL. It is allowed only for mask part"
fi

is_url "$MASK" && fatal "eget supports only one URL as argument"
[ -n "$3" ] && fatal "too many args: extra '$3'. May be you need use quotes for arg with wildcards."

# TODO: curl?
# If ftp protocol, just download
if echo "$URL" | grep -q "^ftp://" ; then
    [ -n "$LISTONLY" ] && fatal "TODO: list files for ftp:// is not supported yet"
    sget "$1" "$TARGETFILE"
    return
fi


if [ -n "$LISTONLY" ] ; then
    for fn in $(get_urls | filter_glob "$MASK" | filter_order) ; do
        is_url "$fn" && echo "$fn" && continue
        make_fileurl "$URL" "$fn"
    done
    return
fi

is_wildcard()
{
    echo "$1" | grep -q "[*?]" && return
    echo "$1" | grep -q "\]" && return
    echo "$1" | grep -q "\[" && return
}

# If there is no wildcard symbol like asterisk, just download
if ! is_wildcard "$MASK" || echo "$MASK" | grep -q "[?].*="; then
    sget "$1" "$TARGETFILE"
    return
fi

ERROR=0
for fn in $(get_urls | filter_glob "$MASK" | filter_order) ; do
    is_url "$fn" || fn="$(make_fileurl "$URL" "$fn" )" #"
    sget "$fn" "$TARGETFILE" || ERROR=1
    [ -n "$TARGETFILE" ] && [ "$ERROR" = "0" ] && break
done
 return $ERROR

}
################# end of incorporated bin/tools_eget #################


################# incorporate bin/tools_erc #################
internal_tools_erc()
{
#!/bin/bash
#
# Copyright (C) 2013-2015, 2017, 2020, 2023  Etersoft
# Copyright (C) 2013-2015, 2017, 2020, 2023  Vitaly Lipatov <lav@etersoft.ru>
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

# will replaced to /usr/share/erc during install
SHAREDIR=$(dirname $0)

load_helper()
{
    local CMD="$SHAREDIR/$1"
    [ -r "$CMD" ] || fatal "Have no $CMD helper file"
    . $CMD
}

load_helper erc-sh-functions
load_helper erc-sh-archive

check_tty

# 1.zip tar:  -> 1.tar
build_target_name()
{
	is_target_format $2 && echo $(get_archive_name "$1").${2/:/} && return
	echo "$1"
        return 1
}


# TODO: list of $HAVE_7Z supported (see list_formats)

# target file1 [file2...]
create_archive()
{
	local arc="$1"
	shift
	if have_patool ; then
		docmd patool $verbose create "$arc" "$@"
		return
	fi

	# FIXME: get type by ext only
	local type="$(get_archive_type "$arc")"
	case "$type" in
		tar)
			#docmd $HAVE_7Z a -l $arc "$@"
			docmd tar cvf "$arc" "$@"
			;;
		*)
			# TODO: fix symlinks support
			docmd $HAVE_7Z a -l "$arc" "$@"
			#fatal "Not yet supported creating of $type archives"
			;;
	esac
}

extract_archive()
{
	local arc="$1"
	shift

	if have_patool ; then
        docmd patool $verbose extract "$arc" "$@"
		return
	fi

	local type="$(get_archive_type "$arc")"

	arc="$(realpath -s "$arc")"
	tdir=$(mktemp -d $(pwd)/UXXXXXXXX) && cd "$tdir" || fatal

	local TSUBDIR="$(basename "$arc" .$type)"

	case "$type" in
		tar.*|tgz)
			# TODO: check if there is only one file?
			# use subdir if there is no subdir in archive
			TSUBDIR="$(basename "$arc" .$(echo $type | sed -e 's|^tar\.||') )"
			docmd $HAVE_7Z x -so "$arc" | docmd $HAVE_7Z x -y -si -ttar
			;;
		*)
			docmd $HAVE_7Z x -y "$arc" "$@"
			#fatal "Not yet supported extracting of $type archives"
			;;
	esac

	cd - >/dev/null
	# if only one dir in the subdir
	if [ -e "$(echo $tdir/*)" ] ; then
		mv $tdir/* .
		rmdir $tdir
	else
		mv $tdir "$TSUBDIR"
	fi
}

list_archive()
{
	local arc="$1"
	shift

	# TODO: move to patool
	if [ "$(get_archive_type "$arc" 2>/dev/null)" = "exe" ] ; then
		docmd $HAVE_7Z l "$arc" || fatal
		return
	fi

	if have_patool ; then
		docmd patool $verbose list "$arc" "$@"
		return
	fi

	local type="$(get_archive_type "$arc")"
	case "$type" in
		*)
			docmd $HAVE_7Z l "$arc" "$@"
			#fatal "Not yet supported listing of $type archives"
			;;
	esac

}

test_archive()
{
	local arc="$1"
	shift

	# TODO: move to patool
	if [ "$(get_archive_type "$arc" 2>/dev/null)" = "exe" ] ; then
		docmd $HAVE_7Z t "$arc" || fatal
		return
	fi

	if have_patool ; then
		docmd patool $verbose test "$arc" "$@"
		return
	fi

	local type="$(get_archive_type "$arc")"
	case "$type" in
		*)
			docmd $HAVE_7Z t "$arc" "$@"
			#fatal "Not yet supported test of $type archives"
			;;
	esac

}

repack_archive()
{
	if have_patool ; then
		docmd patool $verbose repack "$1" "$2"
		return
	fi

	# TODO: if both have tar, try unpack | pack

	local ftype="$(get_archive_type "$1")"
	local ttype="$(get_archive_type "$2")"
	case "$ftype-$ttype" in
		tar.*-tar|tgz-tar)
			docmd $HAVE_7Z x -so "$1" > "$2"
			;;
		tar-tar.*)
			docmd $HAVE_7Z a -si "$2" < "$1"
			;;
		tar.*-tar.*)
			docmd $HAVE_7Z x -so "$1" | $HAVE_7Z a -si "$2"
			;;
		*)
			fatal "Not yet supported repack of $ftype-$ttype archives in 7z mode (try install patool)"
			;;
	esac

}


phelp()
{
	echo "$Descr
$Usage
 Commands:
$(get_help HELPCMD)

 Options:
$(get_help HELPOPT)

 Examples:
    # erc dir - pack dir to dirname.zip
    # erc a archive.zip file(s)... - pack files to archive.zip
    # erc [x] archive.zip - unpack
    # unerc archive.zip - unpack
    # erc [repack] archive1.zip... archive2.rar $HAVE_7Z: - repack all to $HAVE_7Z
    # erc -f [repack] archive.zip archive.$HAVE_7Z - force repack zip to $HAVE_7Z (override target in anyway)
    # erc file/dir zip: - pack file to zip
"
}

print_version()
{
        echo "Etersoft archive manager version @VERSION@"
        echo "Copyright (c) Etersoft 2013-2023"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}

progname="${0##*/}"

Usage="Usage: $progname [options] [<command>] [params]..."
Descr="erc - universal archive manager"

progname="${0##*/}"


force=
target=
verbose=--verbose
use_7z=
use_patool=

if [ -z "$" ] ; then
    echo "Etersoft archive manager version @VERSION@" >&2
    echo "Run $0 --help to get help" >&2
    exit 1
fi

while [ -n "$1" ] ; do
case "$1" in
    -h|--help|help)       # HELPOPT: this help
        phelp
        return
        ;;
    -V|--version)         # HELPOPT: print version
        print_version
        return
        ;;
    -q|--quiet)           # HELPOPT: be silent
        verbose=
        ;;
    -f|--force)           # HELPOPT: override target
        force=-f
        ;;
    --use-patool)         # HELPOPT: force use patool as backend
        use_patool=1
        ;;
    --use-7z)             # HELPOPT: force use 7z as backend
        use_7z=1
        ;;
    -*)
        fatal "Unknown option '$1'"
        ;;
    *)
        break
        ;;
esac
shift
done

set_backend

cmd="$1"

eval lastarg=\${$#}

# Just printout help if run without args
if [ -z "$cmd" ] ; then
    print_version
    echo
    fatal "Run $ $progname --help for get help"
fi



# if the first arg is some archive, suggest extract
if get_archive_type "$cmd" 2>/dev/null >/dev/null ; then
    if is_target_format $lastarg ; then
        cmd=repack
    else
        cmd=extract
    fi
# erc dir (pack to zip by default)
elif [ -d "$cmd" ] && [ -z "$2" ] ; then
    cmd=pack
    target=$(basename "$1").zip
# erc dir zip:
elif test -r "$1" && is_target_format "$2" ; then
    cmd=pack
elif [ "$progname" = "unerc" ] ; then
    cmd=extract
else
    shift
fi


# TODO: Если программа-архиватор не установлена, предлагать установку с помощью epm

case $cmd in
    a|-a|create|pack|add)        # HELPCMD: create archive / add file(s) to archive
        # TODO: realize archive addition if already exist (and separate adding?)
        if [ -z "$target" ] && is_target_format $lastarg ; then
            [ $# = 2 ] || fatal "Need two args"
            target="$(build_target_name "$1" "$2")"
            # clear last arg
            set -- "${@:1:$(($#-1))}"
        fi
        [ -z "$target" ] && target="$1" && shift

        [ -e "$target" ] && [ -n "$force" ] && docmd rm -f "$target"
        create_archive "$target" "$@"
        ;;
    e|x|-e|-x|u|-u|extract|unpack)          # HELPCMD: extract files from archive
        # TODO: move to patool
        if [ "$(get_archive_type "$1" 2>/dev/null)" = "exe" ] ; then
            docmd $HAVE_7Z x "$1"
            return
        fi
        extract_archive "$@"
        ;;
# TODO: implement deletion
#    d|delete)             # HELPCMD: delete file(s) from archive
#        docmd patool delete "$@"
#        ;;
    l|-l|list)               # HELPCMD: list archive contents
        list_archive "$@"
        ;;
    t|-t|test|check)         # HELPCMD: test for archive integrity
        test_archive "$@"
        ;;
    type)                 # HELPCMD: print type of archive
        get_archive_type "$1" || fatal "Can't recognize $1 as archive"
        ;;
    diff)                 # HELPCMD: compare two archive
        # check 2 arg
        docmd patool $verbose diff "$@"
        ;;
    b|-b|bench|benchmark)    # HELPCMD: do CPU benchmark
        #assure_cmd $HAVE_7Z
        # TODO: can be $HAVE_7Za?
        docmd $HAVE_7Z b
        ;;
    search|grep)               # HELPCMD: search in files from archive
        docmd patool $verbose search "$@"
        ;;
    repack|conv)          # HELPCMD: convert source archive to target
        # TODO: need repack remove source file?
        # TODO: check for 2 arg
        if ! is_target_format $lastarg ; then
            [ $# = 2 ] || fatal "Need two args"
            [ "$(realpath "$1")" = "$(realpath "$2")" ] && warning "Output file is the same as input" && return
            [ -e "$2" ] && [ -n "$force" ] && docmd rm -f "$2"
            repack_archive "$1" "$2"
            return
        fi

        # add support for target zip:
        for i in "$@" ; do
            [ "$i" = "$lastarg" ] && continue
            target="$(build_target_name "$i" "$lastarg")"
            [ "$(realpath "$1")" = "$(realpath "$target")" ] && warning "Output file is the same as input" && return
            [ -e "$target" ] && [ -n "$force" ] && docmd rm -f "$target"
            repack_archive "$i" "$target" || return
        done

        ;;
    formats)              # HELPCMD: lists supported archive formats
        # TODO: print allowed with current programs separately
        if [ -n "$verbose" ] && have_patool ; then
            docmd patool formats "$@"
            echo "Also we supports:"
            ( list_subformats ; list_extraformats ) | sed -e "s|^|  |"
        else
            list_formats
        fi
        ;;
    *)
        # TODO: If we have archive in parameter, just unpack it
        fatal "Unknown command $1"
        ;;
esac

}
################# end of incorporated bin/tools_erc #################


################# incorporate bin/tools_ercat #################
internal_tools_ercat()
{
#!/bin/bash
#
# Copyright (C) 2013, 2020  Etersoft
# Copyright (C) 2013, 2020  Vitaly Lipatov <lav@etersoft.ru>
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

# will replaced to /usr/share/erc during install
SHAREDIR=$(dirname $0)

load_helper()
{
    local CMD="$SHAREDIR/$1"
    [ -r "$CMD" ] || fatal "Have no $CMD helper file"
    . $CMD
}

load_helper erc-sh-functions
load_helper erc-sh-archive

check_tty

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
        echo "Etersoft uncompressor version @VERSION@"
        echo "Copyright (c) Etersoft 2013, 2020, 2023"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}

regular_unpack()
{
    local file="$1"
    local prg="$2"
    local pkg="$3"
    local opt="$4"

    # instead of epm assure
    if ! is_command "$prg" ; then
        epm assure $prg $pkg || fatal "Try install $pkg package for $prg unpack command."
    fi

    docmd $prg $opt $file || fatal
}


progname="${0##*/}"

Usage="Usage: $progname [options] file(s)..."
Descr="ercat - universal file uncompressor"

quiet=
cmd=$1

# Just printout help if run without args
if [ -z "$cmd" ] ; then
    print_version
    echo
    fatal "Run $ $progname --help for get help"
fi

case $cmd in
    -h|--help|help)       # HELPOPT: this help
        phelp
        return
        ;;
    -q|--quiet)           # HELPOPT: be silent
        quiet=--quiet
        shift
        cmd=$1
        ;;
    -v|--version)         # HELPOPT: print version
        print_version
        return
        ;;
esac

# TODO: check ext
# TODO: check file existence
# TODO: check by content
for f in $@ ; do
    TYPE=$(get_archive_ext $f) || TYPE=$(is_plain_text $f) || { warning "Skipping unrecognized $f" ; continue ; }
    case $TYPE in
        gz)
            regular_unpack "$f" gunzip gzip -c
            ;;
        bz2)
            regular_unpack "$f" bzcat bzip2
            ;;
        xz)
            regular_unpack "$f" xzcat xz
            ;;
        Z|compress)
            regular_unpack "$f" zcat gzip
            ;;
        lzma)
            regular_unpack "$f" lzcat xz
            ;;
        zst|zstd)
            regular_unpack "$f" zstdcat zstd
            ;;
        lz4)
            regular_unpack "$f" lz4cat lz4
            ;;
        plain)
            docmd cat "$f" || fatal
            ;;
        *)
            fatal "Unsupported compression format $TYPE"
            ;;
    esac
done
}
################# end of incorporated bin/tools_ercat #################


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

contains()
{
    #estrlist has "$1" "$2"
    local res="$(reg_wordexclude "$1" "$2")"
    [ "$res" != "$2" ]
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
        echo "  contains <word> [word list]       - check if word list contains the word"
        echo
        echo "Examples:"
#        example reg_remove "1." "11 12 21 22"
#        example reg_wordremove "1." "11 12 21 22"
        example exclude "1 3" "1 2 3 4"
        example reg_exclude "22 1." "11 12 21 22"
        example reg_wordexclude "wo.* er" "work were more else"
        example union "1 2 2 3 3"
        example_res contains "wo" "wo wor"
        example_res contains "word" "wo wor"
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
        echo "Run with --help for get command description." >&2
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

  if echo "test string" | grep -E -ao --color=never "test" >/dev/null 2>&1
  then
    GREP='grep -E -ao --color=never'
  else
    GREP='grep -E -ao'
  fi

  if echo "test string" | grep -E -o "test" >/dev/null 2>&1
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
  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | grep -E -v "^$SPACE$"
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

# fast call for tool
if [ "$1" = "tool" ] ; then
        shift
        epm_tool "$@"
        exit
fi

if [ "$1" = "--inscript" ] && [ "$2" = "tool" ] ; then
        shift 2
        epm_tool "$@"
        exit
fi


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
        echo "EPM package manager version $EPMVERSION  Telegram: https://t.me/useepm  https://wiki.etersoft.ru/Epm"
        echo "Running on $DISTRNAME/$DISTRVERSION ('$PMTYPE' package manager uses '$PKGFORMAT' package format)"
        echo "Copyright (c) Etersoft 2012-2024"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}


Usage="Usage: epm [options] <command> [package name(s), package files]..."
Descr="epm - EPM package manager"

debug=
verbose=$EPM_VERBOSE
quiet=
nodeps=
noremove=
dryrun=
force=
repack=
norepack=
install=
inscript=
scripts=
noscripts=
short=
direct=
sort=
non_interactive=$EPM_AUTO
download=
download_only=
print_url=
interactive=
force_yes=
skip_installed=
skip_missed=
show_command_only=
epm_cmd=
warmup=
pkg_files=
pkg_dirs=
pkg_names=
pkg_urls=
pkg_options=
quoted_args=
direct_args=

eget_backend=$EGET_BACKEND
epm_vardir=/var/lib/eepm
epm_cachedir=/var/cache/eepm
eget_ipfs_db=$epm_vardir/eget-ipfs-db.txt

# load system wide config
[ -f $CONFIGDIR/eepm.conf ] && . $CONFIGDIR/eepm.conf


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
    epmp)                      # HELPSHORT: alias for epm play
        epm_cmd=play
        direct_args=1
        ;;
    epms)                      # HELPSHORT: alias for epm search
        epm_cmd=search
        direct_args=1
        ;;
    epmsf)                     # HELPSHORT: alias for epm search-file (epm sf)
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
    -i|install|add|i|it)         # HELPCMD: install package(s) from remote repositories or from local file
        epm_cmd=install
        ;;
    -e|-P|rm|del|remove|delete|uninstall|erase|purge|e)  # HELPCMD: remove (delete) package(s) from the database and the system
        epm_cmd=remove
        ;;
    -s|search|s|find|sr)                # HELPCMD: search in remote package repositories
        epm_cmd=search
        direct_args=1
        ;;
    -qp|qp|grep|query_package)     # HELPCMD: search in the list of installed packages
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
    status)                   # HELPCMD: get status of package(s) (see epm status --help)
        epm_cmd=status
        direct_args=1
        ;;
    -sf|sf|filesearch|search-file)        # HELPCMD: search in which package a file is included
        epm_cmd=search_file
        ;;
    -ql|ql|filelist|get-files)          # HELPCMD: print package file list
        epm_cmd=filelist
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
    -qa|qa|ls|packages|list-installed|li)  # HELPCMD: print list of all installed packages
        epm_cmd=packages
        direct_args=1
        ;;
    list)                     # HELPCMD: print list of packages (see epm list --help)
        epm_cmd=list
        direct_args=1
        ;;
    # it is too hard operation, so just list name is very short for it
    list-available)           # HELPCMD: print list of all available packages
        epm_cmd=list_available
        direct_args=1
        ;;
    programs)                 # HELPCMD: print list of installed packages with GUI program(s) (they have .desktop files)
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
    update|update-repo|ur)    # HELPCMD: update remote package repository databases (with args, run upgrade)
        epm_cmd=update
        #direct_args=1
        ;;
    addrepo|ar|--add-repo)    # HELPCMD: add package repo (etersoft, autoimports, archive 2017/01/31); run with param to get list
        epm_cmd=addrepo
        direct_args=1
        ;;
    repolist|sl|rl|listrepo|repo-list|list-repo|lr)  # HELPCMD: print repo list
        epm_cmd=repolist
        direct_args=1
        ;;
    repofix)                  # HELPCMD: <mirror>: fix paths in sources lists (ALT Linux only). use repofix etersoft/yandex/basealt for rewrite URL to the specified server
        epm_cmd=repofix
        direct_args=1
        ;;
    removerepo|remove-repo|rr)            # HELPCMD: remove package repo (shortcut for epm repo remove)
        epm_cmd=removerepo
        direct_args=1
        ;;
    repo)                     # HELPCMD: manipulate with repository list (see epm repo --help)
        epm_cmd=repo
        direct_args=1
        ;;
    check|fix|verify)         # HELPCMD: check local package base integrity and fix it
        epm_cmd=check
        direct_args=1
        ;;
    dedup)                    # HELPCMD: remove unallowed duplicated pkgs (after upgrade crash)
        epm_cmd=dedup
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
    stats)                                      # HELPCMD: show statistics about repositories and installations
        epm_cmd=stats
        direct_args=1
        ;;

# HELPCMD: PART: Other commands:
    clean|delete-cache|dc)                    # HELPCMD: clean local package cache
        epm_cmd=clean
        direct_args=1
        ;;
    restore)                  # HELPCMD: install (restore) packages need for the project (f.i. by requirements.txt)
        epm_cmd=restore
        direct_args=1
        ;;
    autoremove|package-cleanup)   # HELPCMD: auto remove unneeded package(s) Supports args for ALT: [--direct [libs|python|perl|libs-devel]]
        epm_cmd=autoremove
        direct_args=1
        ;;
    mark)                     # HELPCMD: mark package as manually or automatically installed or hold/unhold it (see epm mark --help)
        epm_cmd=mark
        direct_args=1
        ;;
    history)                  # HELPCMD: show a log of actions taken by the software management (see epm history --help)
        epm_cmd=history
        direct_args=1
        ;;
    autoorphans|--orphans|remove-orphans)    # HELPCMD: remove all packages not from the repository
        epm_cmd=autoorphans
        direct_args=1
        ;;
    upgrade|up|dist-upgrade)     # HELPCMD: performs upgrades of package software distributions
        epm_cmd=upgrade
        ;;
    Upgrade)                  # HELPCMD: force update package base, then run upgrade
        epm_cmd=Upgrade
        direct_args=1
        ;;
    Downgrade)                # HELPCMD: force update package base, then run downgrade [all] packages to the repo state
        epm_cmd=Downgrade
        ;;
    downgrade|distro-sync)    # HELPCMD: downgrade [all] packages to the repo state
        epm_cmd=downgrade
        ;;
    download|fetch|fc)        # HELPCMD: download package(s) file to the current dir
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
    tool)                     # HELPCMD: run embedded tool (see epm tool --help)
        epm_cmd=tool
        direct_args=1
        ;;
    repack)                   # HELPCMD: repack rpm to local compatibility
        epm_cmd=repack
        ;;
    pack)                     # HELPCMD: pack tarball or dir to a rpm package
        epm_cmd=pack
        direct_args=1
        ;;
    moo)
        epm_cmd=moo
        direct_args=1
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
    # optimization
    case $1 in
    -*)
        # pass
        ;;
    *)
        return 1
        ;;
    esac

    case $1 in
    -v|--version)         # HELPOPT: print version
        [ -n "$epm_cmd" ] && return 1
        [ -n "$short" ] && echo "$EPMVERSION" | sed -e 's|-.*||' && exit 0
        print_version
        exit 0
        ;;
    --verbose)            # HELPOPT: verbose mode
        verbose="--verbose"
        ;;
    --debug)              # HELPOPT: more debug output mode
        debug="--debug"
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
        quiet="--quiet"
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
    --norepack)              # HELPOPT: don't repack rpm package(s) if it is by default before install
        norepack="--norepack"
        ;;
    --install)             # HELPOPT: install packed rpm package(s)
        install="--install"
        ;;
    --scripts)             # HELPOPT: include scripts in repacked rpm package(s) (see --repack or repacking when foreign package is installed)
        scripts="--scripts"
        ;;
    --noscripts)           # HELPOPT: disable scripts in install packages
        noscripts="--noscripts"
        ;;
    --save-only)            # HELPOPT: save the package/tarball after all transformations (instead of install it)
        save_only="--save-only"
        ;;
    --put-to-repo=*)          # HELPOPT: put the package after all transformations to the repo (--put-to-repo=/path/to/repo)
        put_to_repo="$(echo "$1" | sed -e 's|--put-to-repo=||')"
        ;;
    --download-only)       # HELPOPT: download only the package/tarball (before any transformation)
        download_only="--download-only"
        ;;
    --url)                 # HELPOPT: print only URL instead of download package
        print_url="--url"
        ;;
    --sort)               # HELPOPT: sort output, f.i. --sort=size (supported only for packages command)
        # TODO: how to read arg?
        sort="$1"
        ;;
    -y|--auto|--assumeyes|--non-interactive|--disable-interactivity)  # HELPOPT: non interactive mode
        non_interactive="--auto"
        interactive=""
        ;;
    --interactive)  # HELPOPT: interactive mode (ask before any operation)
        interactive="--interactive"
        non_interactive=""
        ;;
    --force-yes)           # HELPOPT: force yes in a danger cases (f.i., during release upgrade)
        force_yes="--force-yes"
        ;;
    --no-check-certificate)
        fatal "--no-check-certificate is a wget option. It is recommended never use it at all. Check the date or upgrade your system."
        ;;
    -*)
        [ -n "$direct_args" ] && return 1
        [ -n "$pkg_options" ] && pkg_options="$pkg_options $1" || pkg_options="$1"
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
            has_space "$opt" && warning "There are space(s) in filename '$opt', it is not supported. Skipped" && continue
            [ -n "$pkg_files" ] && pkg_files="$pkg_files $opt" || pkg_files="$opt"
        elif [ -d "$opt" ] ; then
            has_space "$opt" && warning "There are space(s) in directory path '$opt', it is not supported. Skipped" && continue
            [ -n "$pkg_dirs" ] && pkg_dirs="$pkg_dirs $opt" || pkg_dirs="$opt"
        elif is_url "$opt" ; then
            has_space "$opt" && warning "There are space(s) in URL '$opt', it is not supported. Skipped" && continue
            [ -n "$pkg_urls" ] && pkg_urls="$pkg_urls $opt" || pkg_urls="$opt"
        elif echo "$opt" | grep -q "[/]" ; then
            has_space "$opt" && warning "There are space(s) in filename '$opt', it is not supported. Skipped" && continue
            [ -n "$pkg_files" ] && pkg_files="$pkg_files $opt" || pkg_files="$opt"
        else
            has_space "$opt" && warning "There are space(s) in package name '$opt', it is not supported. Skipped." && continue
            echo "$opt" | grep -q "[*]" && warning "There are forbidden symbols in package name '$opt'. Skipped." && continue
            [ -n "$pkg_names" ] && pkg_names="$pkg_names $opt" || pkg_names="$opt"
        fi
        [ -n "$quoted_args" ] && quoted_args="$quoted_args \"$opt\"" || quoted_args="\"$opt\""
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
        [ -n "$quoted_args" ] && quoted_args="$quoted_args \"$opt\"" || quoted_args="\"$opt\""
    else
        # Note: will parse all params separately (no package names with spaces!)
        check_filenames "$opt"
    fi
done

if [ -n "$quiet" ] ; then
    verbose=''
    EPM_VERBOSE=''
fi

# fill
export EPM_OPTIONS="$nodeps $force $verbose $debug $quiet $interactive $non_interactive $save_only $download_only"

# if input is not console and run script from file, get pkgs from stdin too
if [ ! -n "$inscript" ] && [ -p /dev/stdin ] && [ "$EPMMODE" != "pipe" ] ; then
    for opt in $(withtimeout 10 cat) ; do
        # FIXME: do not work
        # workaround against # yes | epme
        [ "$opt" = "y" ] && break;
        [ "$opt" = "yes" ] && break;
        check_filenames $opt
    done
fi

# in common case dirs equals to names only suddenly
pkg_names=$(strip_spaces "$pkg_names $pkg_dirs")

pkg_filenames=$(strip_spaces "$pkg_files $pkg_names")

# Just debug
#echover "command: $epm_cmd"
#echover "pkg_files=$pkg_files"
#echover "pkg_names=$pkg_names"

print_short_help()
{
cat <<EOF

Popular commands:
 epm search <name>          - search package by name
 epm install <package>      - install package
 epm full-upgrade           - do full upgrade (packages, kernel) of the system
 epm Upgrade                - upgrade all installed packages (Upgrade = update + upgrade)
 epm play [application]     - install the application (run without params to get list of available apps)
 epm qf (<command>|<path>)  - print what package contains this command (file)
 epm sf <name>              - search for the name in all files of all packages
 epm cl <package name>      - print changelog for the package
EOF
}

# Just printout help if run without args
if [ -z "$epm_cmd" ] ; then
    print_version >&2
    echo >&2
    fatstr="Unrecognized command in '$*' arg(s)"
    if [ -z "$*" ] ; then
        fatstr="That program needs be running with some command"
        print_short_help >&2
    fi
    echo "Run $(echocmd "$PROGNAME --help") to get help." >&2
    echo "Run $(echocmd "epm print info") to get some system and distro info." >&2
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
