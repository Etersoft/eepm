#!/bin/sh

# support for direct run a play script
if [ -x "../bin/epm" ] ; then
    export PATH="$(realpath ../bin):$PATH"
fi

print_command_path2()
{
    a= type -fpP -- "$1" 2>/dev/null
}


for i in $(seq 1 100) ; do
    #epm tool which which
    #which which
    print_command_path2 which
done

