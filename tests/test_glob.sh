#!/bin/sh

__convert_glob__to_regexp()
{
    # translate glob to regexp
    echo "$1" | sed -e "s|\*|.*|g" -e "s|?|.|g"
}


test()
{
    res="$(__convert_glob__to_regexp "$1")"
    if [ "$res" = "$2" ] ; then
        echo "test for '$1': result '$res' is OK"
    else
        echo "test for '$1': result '$res' not equal to expected '$2'"
    fi
}

test '[tcp][1-3]?[0-9][.f]?[0-9]?/branch/' '[tcp][1-3].[0-9][.f].[0-9]./branch/'
test '[tcp][1-3]*' '[tcp][1-3].*'
