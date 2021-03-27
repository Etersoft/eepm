#!/bin/sh

run_command()
{
    # use make_temp_file from etersoft-build-utils
    RC_STDOUT=$(mktemp)
    #RC_STDERR=$(mktemp)
    $1 2>&1 | tee $RC_STDOUT
}

return_big()
{
    return 2021
}

func()
{
    echo STDERR >&2
    echo STDOUT
}

run_command func
cat $RC_STDOUT
#cat $RC_STDERR
rm -f $RC_STDOUT $RC_STDERR

return_big
echo $?
