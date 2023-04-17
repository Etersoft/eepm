#!/bin/sh

# copied from /etc/init.d/outformat (ALT Linux)


# FIXME on Android: FIX ME! implement ttyname_r() bionic/libc/bionic/stubs.c:366
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

# echo string without EOL
echon()
{
    # default /bin/sh on MacOS does not recognize -n
    echo -n "$*" 2>/dev/null || a= /bin/echo -n "$*"
}

is_root()
{
    local EFFUID="$(id -u)"
    [ "$EFFUID" = "0" ]
}

# Print command line and run command line
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

# Print command
echocmd()
{
    set_boldcolor $GREEN
    local PROMTSIG="\$"
    is_root && PROMTSIG="#"
    echo -n "$PROMTSIG $*"
    restore_color
}

# Print command line and run command line
docmd()
{
    showcmd "$*$EXTRA_SHOWDOCMD"
    "$@"
}

