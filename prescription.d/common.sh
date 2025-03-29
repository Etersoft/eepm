#!/bin/sh

# kind of hack: inheritance --force from main epm
echo "$EPM_OPTIONS" | grep -q -- "--force" && force="--force"
echo "$EPM_OPTIONS" | grep -q -- "--auto" && auto="--auto"
echo "$EPM_OPTIONS" | grep -q -- "--verbose" && verbose="--verbose"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*" >&2
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


# print a path to the command if exists in $PATH
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

# check if <arg> is a real command
is_command()
{
    print_command_path "$1" >/dev/null
}

# add to all epm calls
#EPM="$(epm tool which epm)" || fatal
EPM="$(print_command_path epm)" || fatal
epm()
{
    #if [ "$1" = "tool" ] ; then
    #    __showcmd_shifted 1 "$@"
    if [ "$1" != "print" ] && [ "$1" != "tool" ] && [ "$1" != "status" ] ; then
        showcmd "$(basename $EPM) $*"
    fi
    $EPM "$@"
}

. $(dirname $0)/common-outformat.sh

check_tty

if [ -n "$DESCRIPTION" ] ; then
    [ "$1" != "--run" ] && echo "$DESCRIPTION" && exit
fi
