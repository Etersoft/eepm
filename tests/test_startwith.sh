#!/bin/sh

startwith()
{
    # rhas "$1" "^$2"
    #echo "${#2}"
    #echo "${1:0:${#2}}"
    [ "${1:0:${#2}}" = "$2" ]
    #[[ "$1" = ${2}* ]]
}


check_ok()
{
    startwith "$1" "$2" && echo "OK for '$1' with '$2'" || echo "FATAL with '$1': result FALSE do not match with '$2'"
}

check_notok()
{
    startwith "$1" "$2" && echo "FATAL with '$1': result TRUE do not match with '$2'" || echo "OK for '$1' with '$2'"
}

check_ok "/abs" "/"
check_notok "../abs" "/"
check_ok "../abs" ".."
check_ok "common-file.abs" "common"

startwith_inlist()
{
    local str="$1"
    local i
    for i in "$@" ; do
        startwith "$str" "$i" && return
    done
    return 1
}

startwith_inlist "file-1.2.3.rpm" "base" "name" "filer" "file" && echo OK
startwith_inlist "files-1.2.3.rpm" "base" "name" "filer" "file" || echo OK
