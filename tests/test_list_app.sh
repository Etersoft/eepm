#!/bin/sh

psdir=../play.d

# bash specific
startwith()
{
    # rhas "$1" "^$2"
    [[ "$1" = ${2}* ]]
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

# args: script, host arch
__get_app_description()
{
    local arch="$2"
    #__run_script "$1" --description "$arch" 2>/dev/null
    #return
    if grep -q '^SUPPORTEDARCHES=.*\<'"$arch"'\>' "$psdir/$1.sh" || grep -q "^SUPPORTEDARCHES=[\"'][\"']$" "$psdir/$1.sh" || ! grep -q "^SUPPORTEDARCHES=" "$psdir/$1.sh" ; then
        grep -oP "^DESCRIPTION=[\"']*\K[^\"']+" "$psdir/$1.sh" | sed -e 's| *#*$||'
    fi
}


#for i in $(__list_all_app) ; do
#    n="$(__get_app_description $i x86_64)"
#    [ -z "$n" ] || echo $i
#done | wc -l

__get_fast_short_list_app()
{
    local arch="$1"
    [ -n "$arch" ] || fatal
    local IGNOREi586
    [ "$arch" = "x86_64" ] && IGNOREi586='NoNo' || IGNOREi586='i586-'
    grep -L -E "^DESCRIPTION=(''|\"\")" $psdir/*.sh | xargs grep -l -E "^SUPPORTEDARCHES=(''|\"\"|.*\<$arch\>)" | xargs basename -s .sh | grep -v -E "(^$IGNOREi586|^common)"
}

#__get_fast_short_list_app x86_64
#__get_fast_short_list_app x86

__get_fast_quiet_list_app()
{
    local arch="$1"
    [ -n "$arch" ] || fatal
    local IGNOREi586
    [ "$arch" = "x86_64" ] && IGNOREi586='NoNo' || IGNOREi586='i586-'
    grep -l -E "^SUPPORTEDARCHES=(''|\"\"|.*\<$arch\>)" $psdir/*.sh | xargs grep -oP "^DESCRIPTION=[\"']*\K[^\"']+"  | sed -e "s|.*/\(.*\).sh:|\1 - |" | grep -v -E "(^$IGNOREi586|^common|#.*$)"
}

__get_fast_list_app()
{
    local arch="$1"
    [ -n "$arch" ] || fatal
    local IGNOREi586
    [ "$arch" = "x86_64" ] && IGNOREi586='NoNo' || IGNOREi586='i586-'
    grep -l -E "^SUPPORTEDARCHES=(''|\"\"|.*\<$arch\>)" $psdir/*.sh | xargs grep -oP "^DESCRIPTION=[\"']*\K[^\"']+"  | sed -e "s|.*/\(.*\).sh:|    \1 - |" | grep -v -E "(^$IGNOREi586|^common|#.*$)"
}

#__get_fast_list_app x86_64

__get_fast_list_pkg()
{
    local arch="$1"
    [ -n "$arch" ] || fatal
    local IGNOREi586

    local tmplist
    tmplist="$(mktemp)" || fatal
    #remove_on_exit $tmplist

    local tmplist1
    tmplist1="$(mktemp)" || fatal
    #remove_on_exit $tmplist1

    [ "$arch" = "x86_64" ] && IGNOREi586='NoNo' || IGNOREi586='i586-'

    __get_fast_short_list_app $arch | LC_ALL=C sort >$tmplist
    grep -l -E "^SUPPORTEDARCHES=(''|\"\"|.*\<$arch\>)" $psdir/*.sh | xargs grep -oP "^PKGNAME=[\"']*\K[^\"']+"  | sed -e "s|.*/\(.*\).sh:|\1 |" | grep -v -E "(^$IGNOREi586|^common|#.*$)" | LC_ALL=C sort >$tmplist1
    LC_ALL=C join -j 1 -a 1 $tmplist $tmplist1
    # TODO: if right column is missed, run script
}

__get_fast_list_pkg x86_64
