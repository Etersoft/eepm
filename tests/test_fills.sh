#!/bin/sh

fill_sign()
{
    local sign="$1"
    echo "$2" | grep -E -- "$sign[[:space:]]*[0-9.]+?" | sed -E "s|.*$sign[[:space:]]*([0-9.]+?).*|\1|"
}

l="soupsieve >1.2; python_version>='3.0'"

fill_sign ">" "soupsieve >1.2; python_version>='3.0'"
fill_sign ">" "soupsieve >1.2"
fill_sign ">" "soupsieve >1.2 "
fill_sign ">" "soupsieve >1.2 t"
fill_sign ">" "soupsieve >1.2t"
fill_sign ">=" "soupsieve >=1.2"
fill_sign ">" "soupsieve > 1.2"
fill_sign ">" "soupsieve >1.2; p>"
echo "---"
l="$(echo "$l" | sed -e "s| *;.*||")"
fill_sign ">" "$l"
echo

test()
{
l="$1"
local t="$(echo "$l" | sed -E -e "s|[[:space:]]*[<>=!]+.*||" -e "s|[[:space:]]*#.*||")"
#local t="$(echo "$l" | sed -E -e "s|[[:space:]]*==.*||" -e "s|[[:space:]]*#.*||")"
echo "$t"
}

test "$l"
test "testfixtures==6.14.0"
