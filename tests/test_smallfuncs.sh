#!/bin/sh

has_space()
{
    [ "$1" != "${1/ //}" ]
}

notok()
{
    echo "notok test for '$*'"
    has_space "$@" && echo "FAILED: space(s) detected"
}

ok()
{
    echo "ok test for '$*'"
    has_space "$@" || echo "FAILED: space(s) not detected"
}

notok "list"
ok "l i s t"
ok " l i s t "
ok " l "
ok "  "
ok " "
notok ""
