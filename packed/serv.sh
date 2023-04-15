#!/bin/sh
#
# Copyright (C) 2012-2013, 2016, 2020, 2021  Etersoft
# Copyright (C) 2012-2013, 2016, 2020, 2021  Vitaly Lipatov <lav@etersoft.ru>
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
    echo "$*" >&2
}

echon()
{
    # default /bin/sh on MacOS does not recognize -n
    echo -n "$*" 2>/dev/null || a= /bin/echo -n "$*"
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
    RC_STDOUT="$(mktemp)"
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
    if [ "$EPMMODE" = "pipe" ] ; then
        epm_main --inscript "$@"
        return
    fi

    # run epm again to full initialization
    local bashopt=''
    [ -n "$verbose" ] && bashopt='-x'

    $CMDSHELL $bashopt $PROGDIR/$PROGNAME --inscript "$@"
}

sudoepm()
{
    [ "$EPMMODE" = "pipe" ] && fatal "Can't use sudo epm call from the piped script"

    local bashopt=''
    [ -n "$verbose" ] && bashopt='-x'

    sudorun $CMDSHELL $bashopt $PROGDIR/$PROGNAME --inscript "$@"
}

fatal()
{
    if [ -z "$TEXTDOMAIN" ] ; then
        echo "Error: $*  (you can discuss the problem in Telegram: https://t.me/useepm)" >&2
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

    if ! is_command $SUDO_CMD ; then
        [ "$nofail" = "nofail" ] || SUDO="fatal 'Can't find sudo. Please install and tune sudo ('# epm install sudo') or run epm under root.'"
        return "$SUDO_TESTED"
    fi

    # if input is a console
    if inputisatty && isatty && isatty2 ; then
        if ! $SUDO_CMD -l >/dev/null ; then
            [ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only passwordless sudo is supported in non interactive using). Please run epm under root.'"
            return "$SUDO_TESTED"
        fi
    else
        # use sudo if one is tuned and tuned without password
        if ! $SUDO_CMD -l -n >/dev/null 2>/dev/null ; then
            [ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only passwordless sudo is supported). Please run epm under root or check http://altlinux.org/sudo '"
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

assure_exists_erc()
{
    local package="erc"
    ( direct='' epm_assure "$package" ) || epm ei erc || fatal "erc is not available to install."
}

disabled_eget()
{
    local EGET
    # use internal eget only if exists
    if [ -s $SHAREDIR/tools_eget ] ; then
        ( EGET_BACKEND=$eget_backend $SHAREDIR/tools_eget "$@" )
        return
    fi
    fatal "Internal error: missed tools_eget"

    # FIXME: we need disable output here, eget can be used for get output
    assure_exists eget eget 3.3 >/dev/null
    # run external command, not the function
    EGET=$(print_command_path eget) || fatal "Missed command eget from installed package eget"
    $EGET "$@"
}

disabled_erc()
{
    local ERC
    # use internal eget only if exists
    if [ -s $SHAREDIR/tools_erc ] ; then
        $SHAREDIR/tools_erc "$@"
        return
    fi
    fatal "Internal error: missed tools_erc"

    # FIXME: we need disable output here, ercat can be used for get output
    assure_exists_erc >/dev/null
    # run external command, not the function
    ERC=$(print_command_path erc) || fatal "Missed command erc from installed package erc"
    $ERC "$@"
}

disabled_ercat()
{
    local ERCAT
    # use internal eget only if exists
    if [ -s $SHAREDIR/tools_ercat ] ; then
        $SHAREDIR/tools_ercat "$@"
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
    [ -n "$BASEDISTRNAME" ] || BASEDISTRNAME=$($DISTRVENDOR -s)

    # TODO: improve BIGTMPDIR conception
    # https://bugzilla.mozilla.org/show_bug.cgi?id=69938
    # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s15.html
    # https://geekpeach.net/ru/%D0%BA%D0%B0%D0%BA-systemd-tmpfiles-%D0%BE%D1%87%D0%B8%D1%89%D0%B0%D0%B5%D1%82-tmp-%D0%B8%D0%BB%D0%B8-var-tmp-%D0%B7%D0%B0%D0%BC%D0%B5%D0%BD%D0%B0-tmpwatch-%D0%B2-centos-rhel-7
    [ -n "$BIGTMPDIR" ] || [ -d "/var/tmp" ] && BIGTMPDIR="/var/tmp" || BIGTMPDIR="/tmp"
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
   [ -n "$pkgtype" ] || pkgtype="$PKGFORMAT"

   [ "$pkgtype" = "deb" ] && echo "_" && return
   echo "-"
}


__epm_remove_from_tmp_files()
{
   keep="$1"
   [ -r "$keep" ] || return 0
   [ -n "$to_remove_pkg_files" ] || return 0
   to_remove_pkg_files="$(echo "$to_remove_pkg_files" | sed -e "s|$keep||")"
}

__epm_remove_tmp_files()
{
    # TODO: move it to exit handler
    if [ -z "$DEBUG" ] ; then
        # TODO: reinvent
        [ -n "$to_remove_pkg_files" ] && rm -f $to_remove_pkg_files
        # hack??
        [ -n "$to_remove_pkg_files" ] && rmdir $(dirname $to_remove_pkg_files | head -n1) 2>/dev/null
        [ -n "$to_remove_pkg_dirs" ] && rmdir $to_remove_pkg_dirs 2>/dev/null
        [ -n "$to_clean_tmp_dirs" ] && rm -rf $to_clean_tmp_dirs 2>/dev/null
    fi
    return 0
}


has_space()
{
    estrlist -- has_space "$@"
}

is_url()
{
    echo "$1" | grep -q "^[filehtps]*:/"
}

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

is_command()
{
    print_command_path "$1" >/dev/null
}


if ! is_command realpath ; then
realpath()
{
    [ -n "$*" ] || return
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


# File bin/serv-cat:

serv_cat()
{
    local SERVICE="$1"
    shift

    case $SERVICETYPE in
        systemd)
            docmd systemctl cat "$SERVICE" "$@"
            ;;
        *)
            case $BASEDISTRNAME in
            "alt")
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


serv_enable()
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
            assure_exists $SERVICE
            [ -r "/etc/sv/$SERVICE" ] || fatal "Can't find /etc/sv/$SERVICE"
            sudocmd ln -s /etc/sv/$SERVICE /var/service/
            ;;
        *)
            fatal "Have no suitable command for $SERVICETYPE"
            ;;
    esac
}

# File bin/serv-exists:

serv_exists()
{
    local SERVICE="$1"
    shift

    case $SERVICETYPE in
        systemd)
            # too direct way: test -s /lib/systemd/system/dm.service
            docmd systemctl cat "$SERVICE" "$@" >/dev/null 2>/dev/null
            ;;
        *)
            case $BASEDISTRNAME in
            "alt")
                local INITFILE=/etc/init.d/$SERVICE
                [ -r "$INITFILE" ] || return
                return ;;
            *)
                fatal "Have no suitable for $DISTRNAME command for $SERVICETYPE"
                ;;
            esac
    esac
}

# File bin/serv-list:

serv_list()
{
    [ -n "$short" ] || info "Running services:"
    case $SERVICETYPE in
        service-upstart)
            sudocmd initctl list
            ;;
        service-update)
            sudocmd service --status-all
            ;;
        systemd)
            if [ -n "$short" ] ; then
                docmd systemctl list-units --type=service "$@" | grep '\.service' | sed -e 's|\.service.*||' -e 's|^ *||'
            else
                docmd systemctl list-units --type=service "$@"
            fi
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
            if [ -n "$short" ] ; then
                # service --status-all for Ubuntu/Fedora
                sudocmd chkconfig --list | cut -f1 | grep -v "^$" | grep -v "xinetd:$" | cut -f 1 -d" "
            else
                # service --status-all for Ubuntu/Fedora
                sudocmd chkconfig --list | cut -f1 | grep -v "^$" | grep -v "xinetd:$"
            fi
            if [ -n "$ANYSERVICE" ] ; then
                if [ -n "$short" ] ; then
                    sudocmd anyservice --quiet list | cut -f 1 -d" "
                else
                    sudocmd anyservice --quiet list
                fi
                return
            fi
            ;;
        service-initd|service-update)
            if [ -n "$short" ] ; then
                sudocmd ls $INITDIR/ | grep -v README | cut -f 1 -d" "
            else
                sudocmd ls $INITDIR/ | grep -v README
            fi
            ;;
        systemd)
            if [ -n "$short" ] ; then
                docmd systemctl list-unit-files --type=service "$@" | sed -e 's|\.service.*||' | grep -v 'unit files listed' | grep -v '^$'
            else
                docmd systemctl list-unit-files --type=service "$@"
            fi
            ;;
        openrc)
            if [ -n "$short" ] ; then
                sudocmd rc-service -l | cut -f 1 -d" "
            else
                sudocmd rc-service -l
            fi
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
            for i in $(short=1 serv_list_startup) ; do
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
            for i in $(short=1 serv_list_all) ; do
                is_service_autostart >/dev/null 2>/dev/null $i && echo $i
            done
            ;;
        *)
            for i in $(short=1 serv_list_all) ; do
                is_service_autostart >/dev/null 2>/dev/null $i && echo $i
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
            case $BASEDISTRNAME in
            "alt")
                FF="" ; [ "$1" = "-f" ] && FF="-f"
                __serv_log_altlinux "$SERVICE" $FF
                return ;;
            *)
                fatal "Have no suitable for $DISTRNAME command for $SERVICETYPE"
                ;;
            esac
    esac
}

# File bin/serv-off:


serv_off()
{
    local SERVICE="$1"

    is_service_running $1 && { serv_stop $1 || return ; }
    is_service_autostart $1 || { info "Service $1 already disabled for startup" && return ; }
    serv_disable $SERVICE
}

# File bin/serv-on:


serv_on()
{
    serv_enable "$1" || return
    # start if need
    is_service_running $1 && info "Service $1 is already running" && return
    serv_start $1
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
                OUTPUT="$(sudorun anyservice $1 status 2>/dev/null)" || return 1
                echo "$OUTPUT" | grep -q "is stopped" && return 1
                return 0
            fi
            OUTPUT="$(sudorun service $1 status 2>/dev/null)" || return 1
            echo "$OUTPUT" | grep -q "is stopped" && return 1
            return 0
            ;;
        service-initd|service-update)
            sudorun $INITDIR/$1 status >/dev/null 2>/dev/null
            ;;
        systemd)
            a='' systemctl status $1 >/dev/null 2>/dev/null
            ;;
        runit)
            sudorun sv status "$SERVICE" >/dev/null 2>/dev/null
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
            LANG=C sudorun chkconfig $1 --list | grep -q "[35]:on"
            ;;
        service-initd|service-update)
            test -L "$(echo /etc/rc5.d/S??$1)"
            ;;
        systemd)
            a='' systemctl is-enabled $1
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
            docmd systemctl -l status $SERVICE "$@"
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

# File bin/serv-test:

serv_test()
{
    local SERVICE="$1"
    shift

    case $SERVICE in
        cups|cupsd)
            docmd cupsd -t
            ;;
        nginx)
            docmd nginx -t
            ;;
        sshd)
            docmd sshd -t
            ;;
        httpd2|httpd|apache|apache2)
            if is_command httpd2 ; then
                docmd httpd2 -t
            elif is_command apache2 ; then
                docmd apache2 -t
            fi
            ;;
        postfix)
            docmd /etc/init.d/postfix check
            ;;
        *)
            fatal "$SERVICE is not supported yet. Please report if you know how to test"
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
            sudorun service $SERVICE 2>&1
            ;;
        service-initd|service-update)
            #sudocmd /etc/init.d/$SERVICE 2>&1
            sudorun service $SERVICE 2>&1
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

override_distrib()
{
    [ -n "$1" ] || return
    VENDOR_ID=''
    PRETTY_NAME=''
    local name="$(echo "$1" | sed -e 's|x86_64/||')"
    [ "$name" = "$1" ] && DIST_ARCH="x86" || DIST_ARCH="x86_64"
    DISTRIB_ID="$(echo "$name" | sed -e 's|/.*||')"
    DISTRO_NAME="$DISTRIB_ID"
    DISTRIB_RELEASE="$(echo "$name" | sed -e 's|.*/||')"
    [ "$DISTRIB_ID" = "$DISTRIB_RELEASE" ] && DISTRIB_RELEASE=''
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
    ROSA)
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
    ArchLinux)
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
        is_command chocolatey && CMD="chocolatey"
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
        # try detect firstly
        if grep -q "ID_LIKE=debian" /etc/os-release 2>/dev/null ; then
            echo "apt-dpkg" && return
        fi

        if is_command "rpm" && [ -s /var/lib/rpm/Name ] || [ -s /var/lib/rpm/rpmdb.sqlite ] ; then
            is_command "zypper" && echo "zypper-rpm" && return
            is_command "dnf" && echo "dnf-rpm" && return
            is_command "apt-get" && echo "apt-rpm" && return
            is_command "yum" && echo "yum-rpm" && return
            is_command "urpmi" && echo "urpm-rpm" && return
        fi

        if is_command "dpkg" && [ -s /var/lib/dpkg/status ] ; then
            is_command "apt" && echo "apt-dpkg" && return
            is_command "apt-get" && echo "apt-dpkg" && return
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
        solus) echo "eopkg" ;;
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
    # set by os-release:
    #PRETTY_NAME
    VENDOR_ID="$ID"
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
esac

case "$DISTRIB_ID" in
    "ALTLinux")
        echo "$VERSION" | grep -q "c9.* branch" && DISTRIB_RELEASE="c9"
        echo "$VERSION" | grep -q "c9f1 branch" && DISTRIB_RELEASE="c9f1"
        echo "$VERSION" | grep -q "c9f2 branch" && DISTRIB_RELEASE="c9f2"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
        # FIXME: fast hack for fallback: 10.1 -> p10 for /etc/os-release
        if echo "$DISTRIB_RELEASE" | grep -q "^[0-9]" && echo "$DISTRIB_RELEASE" | grep -q -v "[0-9][0-9][0-9]"  ; then
            DISTRIB_RELEASE="$(echo p$DISTRIB_RELEASE | sed -e 's|\..*||')"
            DISTRIB_CODENAME="$DISTRIB_RELEASE"
        fi
        ;;
    "ALTServer")
        DISTRIB_CODENAME="$(echo p$DISTRIB_RELEASE | sed -e 's|\..*||')"
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
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
#        DISTRIB_RELEASE=$(echo $DISTRIB_RELEASE | sed -e "s/\..*//g")
        ;;
    "Sisyphus")
        DISTRIB_ID="ALTLinux"
        DISTRIB_RELEASE="Sisyphus"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
        ;;
    "ROSA")
        DISTRIB_FULL_RELEASE="$DISTRIB_CODENAME"
        DISTRIB_CODENAME="$DISTRIB_RELEASE"
        ;;
esac


[ -n "$DISTRIB_ID" ] && return


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
    DISTRIB_RELEASE=$(getprop | awk -F": " '/build.version.release/ { print $2 }' | tr -d '[]')

elif [ "$(uname -o 2>/dev/null)" = "Cygwin" ] ; then
        DISTRIB_ID="Cygwin"
        DISTRIB_RELEASE="all"
fi

}

fill_distr_info
[ -n "$DISTRIB_ID" ] || DISTRIB_ID="Generic"

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
    if LANG=C a= lscpu | grep "Hypervisor vendor:" | grep -q "KVM" ; then
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
    is_command systemctl && echo "systemd" && return
    [ -d /etc/init.d ] && echo "sysvinit" && return
    echo "(unknown)"
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
[ -n "$BUILD_ID" ] && orig=" (orig. $BUILD_ID)"
cat <<EOF
distro_info v$PROGVERSION : Copyright © 2007-2023 Etersoft

                Pretty distro name (--pretty): $(print_pretty_name)
Distro name / version (--distro-name/version): $DISTRO_NAME / $DISTRIB_FULL_RELEASE$orig
         Base distro name (-d) / version (-v): $(print_name_version)
     Vendor distro name (-s) / Repo name (-r): $(pkgvendor) / $(print_repo_name)
                 Package manager/type (-g/-p): $(pkgmanager) / $(pkgtype)
            Base OS name (-o) / CPU arch (-a): $(get_base_os_name) $(get_arch)
            Bug report URL (--bug-report-url): $(print_bug_report_url)
                 CPU norm register size  (-b): $(get_bit_size)
                          Virtualization (-i): $(get_virt)
                        CPU Cores/MHz (-c/-z): $(get_core_count) / $(get_core_mhz) MHz
                 System memory size (MB) (-m): $(get_memory_size)
                 Running service manager (-y): $(get_service_manager)

(run with -h to get help)
EOF
}

case "$2" in
    -*)
        echo "Unsupported option $2" >&2
        exit 1
        ;;
esac

case "$1" in
    -h|--help)
        echo "distro_info v$PROGVERSION - distro information retriever"
        echo "Usage: distro_info [options] [SystemName/Version]"
        echo "Options:"
        echo " -h | --help            - this help"
        echo " -a                     - print hardware architecture (--distro-arch for distro depended name)"
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
        echo " -p | package-type      - print type of the packaging system"
        echo " -g                     - print name of the packaging system"
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
        exit 0
        ;;
    -p|--package-type)
        override_distrib "$2"
        pkgtype
        exit 0
        ;;
    -g)
        override_distrib "$2"
        pkgmanager
        exit 0
        ;;
    --pretty|--pretty-name)
        override_distrib "$2"
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
    --glibc-version)
        override_distrib "$2"
        get_glibc_version
        exit 0
        ;;
    -d|--base-distro-name)
        override_distrib "$2"
        echo $DISTRIB_ID
        ;;
    --distro-name)
        override_distrib "$2"
        echo $DISTRO_NAME
        ;;
    --codename)
        override_distrib "$2"
        print_codename
        ;;
    -a)
        override_distrib "$2"
        [ -n "$DIST_ARCH" ] && echo "$DIST_ARCH" && exit 0
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
    -o|--os-name)
        override_distrib "$2"
        get_base_os_name
        ;;
    -r|--repo-name)
        override_distrib "$2"
        print_repo_name
        ;;
    --build-id)
        echo "$BUILD_ID"
        ;;
    -v|--base-version)
        override_distrib "$2"
        echo "$DISTRIB_RELEASE"
        ;;
    --full-version|--distro-version)
        override_distrib "$2"
        echo "$DISTRIB_FULL_RELEASE"
        ;;
    --bug-report-url)
        print_bug_report_url
        return
        ;;
    -s|-n|--vendor-name)
        override_distrib "$2"
        pkgvendor
        exit 0
        ;;
    -y|--service-manager)
        override_distrib "$2"
        get_service_manager
        ;;
    -V)
        echo "$PROGVERSION"
        exit 0
        ;;
    -e)
        override_distrib "$2"
        print_name_version
        ;;
    -*)
        echo "Unsupported option $1" >&2
        exit 1
        ;;
    *)
        override_distrib "$1"
        print_total_info
        ;;
esac

}
################# end of incorporated bin/distr_info #################


serv_main()
{

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

    set_distro_info
    set_target_pkg_env

case "$DISTRCONTROL" in
    sysvinit)
        CMD="service-chkconfig"
        ;;
    systemd)
        CMD="systemd"
        ;;
esac

# override system control detection result
[ -n "$FORCESERVICE" ] && CMD="$FORCESERVICE"

SERVICETYPE="$CMD"

ANYSERVICE=$(print_command_path anyservice)

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
        echo "Service manager version 3.51.2  https://wiki.etersoft.ru/Epm"
        echo "Running on $($DISTRVENDOR -e) $on_text with $SERVICETYPE"
        echo "Copyright (c) Etersoft 2012-2021"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}

progname="${0##*/}"

Usage="Usage: $progname [options] [<service>] [<command>] [params]..."
Descr="serv - Service manager"

set_service_type

verbose=
quiet=
short=
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
    restart)                 # HELPCMD: restart service
        serv_cmd=restart
        ;;
    reload)                  # HELPCMD: reload service
        serv_cmd=reload
        ;;
    start)                    # HELPCMD: start service
        serv_cmd=start
        ;;
    stop)                     # HELPCMD: stop service
        serv_cmd=stop
        ;;
    on)                       # HELPCMD: add service to run on startup and start it now
        serv_cmd=on
        ;;
    off)                      # HELPCMD: remove service to run on startup and stop it now
        serv_cmd=off
        ;;
    enable)                   # HELPCMD: add service to run on startup (see 'on' also)
        serv_cmd=enable
        ;;
    disable)                 # HELPCMD: remove service to run on startup (see 'off' also)
        serv_cmd=disable
        ;;
    log|journal)              # HELPCMD: print log for the service (-f - follow,  -r - reverse order)
        serv_cmd=log
        ;;
    cat)                      # HELPCMD: print out service file for the service
        serv_cmd=cat
        ;;
    exists)                   # HELPCMD: check if the service is installed on the system
        serv_cmd=exists
        ;;
    edit)                     # HELPCMD: edit service file overload (use --full to edit full file)
        serv_cmd=edit
        ;;
    test|-t)                  # HELPCMD: test a config file of the service
        serv_cmd=test
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
    print)                    # HELPCMD: print some info
        serv_cmd=print
        withoutservicename=1
        ;;
    try-restart|condrestart)  # HELPCMD: Restart service if running
        serv_cmd=try_restart
        ;;
    usage)                    # HELPCMD: print out usage of the service
        serv_cmd=usage
        withoutservicename=1
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
    --short)              # HELPOPT: short mode
        short=1
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
}
serv_main "$@"
