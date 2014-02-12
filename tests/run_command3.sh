#!/bin/sh

store_output()
{
    # use make_temp_file from etersoft-build-utils
    RC_STDOUT=$(mktemp)
    local CMDSTATUS=$RC_STDOUT.pipestatus
    echo 1 >$CMDSTATUS
    #RC_STDERR=$(mktemp)
    ( "$@" 2>&1 ; echo $? >$CMDSTATUS ) | tee $RC_STDOUT
    return $(cat $CMDSTATUS)
    # bashism
    # http://tldp.org/LDP/abs/html/bashver3.html#PIPEFAILREF
    #return $PIPESTATUS
}

clean_store_output()
{
    rm -f $RC_STDOUT $RC_STDOUT.pipestatus
}


store_output epmq mc
echo $?
cat $RC_STDOUT
ls -l $RC_STDOUT

store_output epmq mc1
echo $?
cat $RC_STDOUT
ls -l $RC_STDOUT
