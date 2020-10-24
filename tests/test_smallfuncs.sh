#!/bin/sh

#. ../bin/epm-sh-functions
has_space()
{
    ../bin/tools_estrlist has_space "$@"
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
ok "li st"
ok " l i s t "
ok " l "
ok "  "
ok " "
notok ""

notok "http://updates.etersoft.ru/pub/Korinf/x86_64/Ubuntu/20.04/eepm_*.deb"
