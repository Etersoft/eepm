
__status_repacked()
{
    local repacked="$(epm print field Description for "$1" | grep -qi "alien" 2>/dev/null)"
    local packager="$(epm print field Packager for "$1" 2>/dev/null)"

    local rpmversion="$(epm print field Version for "$1" 2>/dev/null)"
    [ -n "$rpmversion" ] || return

    [ "$packager" = "EPM <support@etersoft.ru>" ] && return 0
    [ "$packager" = "EPM <support@eepm.ru>" ] && return 0

    return 1
}

LIST="hiddify mc"

#__status_repacked $LIST
#echo $?

FORMAT="%{Name} %{Version} %{Packager}\n"
a= rpmquery --queryformat "$FORMAT" -a | grep "EPM <support@e"
