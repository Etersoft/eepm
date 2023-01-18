#!/bin/sh

check()
{
    [ "$2" != "$3" ] && echo "FATAL with '$1': result '$3' do not match with '$2'" || echo "OK for '$1' with '$2'"
}

# 1.2.3.4.5 -> 1
normalize_version1()
{
    echo "$1" | sed -e "s|\..*||"
}

# 1.2.3.4.5 -> 1.2
normalize_version2()
{
    echo "$1" | sed -e "s|^\([^.][^.]*\.[^.][^.]*\)\..*|\1|"
}

# 1.2.3.4.5 -> 1.2.3
normalize_version3()
{
    echo "$1" | sed -e "s|^\([^.][^.]*\.[^.][^.]*\.[^.][^.]*\)\..*|\1|"
}


test1()
{
    check "$1" "$2" "$(normalize_version1 "$1")"
}

test2()
{
    check "$1" "$2" "$(normalize_version2 "$1")"
}

test3()
{
    check "$1" "$2" "$(normalize_version3 "$1")"
}

echo
echo " 1"
test1 1              1
test1 10             10
test1 10.1           10
test1 10.01          10
test1 1.1            1
test1 1.1.1          1
test1 1.2.3.4        1
test1 1.2.3.4.5      1
test1 123            123

echo
echo " 2"
test2 2.1            2.1
test2 2              2
test2 10             10
test2 10.1           10.1
test2 10.01          10.01
test2 1.1            1.1
test2 1.1.1          1.1
test2 1.2.3.4        1.2
test2 1.2.3.4.5      1.2
test2 123            123

echo
echo " 3"
test3 2.1            2.1
test3 2              2
test3 10             10
test3 10.1           10.1
test3 10.01          10.01
test3 1.1            1.1
test3 1.1.1          1.1.1
test3 1.2.3.4        1.2.3
test3 1.2.3.4.5      1.2.3
test3 1.2.3.4.5.6    1.2.3
test3 123            123
