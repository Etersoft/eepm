#!/bin/sh

load_helper()
{
    . ../bin/$1
}

PMTYPE=apt-rpm

. ../bin/epm-sh-altlinux
. ../bin/epm-sh-functions
. ../bin/epm-restore


ok()
{
    __eresection "$1" "$2" && echo "$1   OK" || echo "$1   failed"
}

notok()
{
    __eresection "$1" "$2" && echo "$1   failed" || echo "$1   OK"
}

ok "install=[" "install"
ok "install=[''" "install"
ok "install=['']" "install"
ok "install=(" "install"
ok "install=(fd" "install"
ok "install=(fd)" "install"
notok "install=fd" "install"

echo
echo "rhas:"
ok()
{
# something is wrong
    rhas "$1" "[\])],*" && echo "$1   OK" || echo "$1   failed"
#    rhas "$1" "(\]|\)),*" && echo "$1   OK" || echo "$1   failed"
}

ok "),"
ok ")"
ok "]"
ok "],"

ok()
{
# something is wrong
#    rhas "$1" "[\])],*" && echo "$1   OK" || echo "$1   failed"
    rhas "$1" "(\]|\)),*" && echo "$1   OK" || echo "$1   failed"
}

ok "),"
ok ")"
ok "]"
ok "],"

ok()
{
    rhas "$1" "[\[(],*" && echo "$1   OK" || echo "$1   failed"
}

ok "=("
ok "("
ok "=["
ok "[,"

echo
echo "==="

f1()
{
    sed -E -e 's@(\]|\)).*@OK@'
}

echo ")," | f1
echo "]" | f1


f1()
{
    sed -e 's|[\])].*|OK|'
}

echo ")," | f1
echo "]" | f1

echo
echo "==="


f1()
{
    sed -e 's|[\[(].*|OK|'
}

echo "(," | f1
echo "[" | f1


f1()
{
    sed -e 's@\(\[|(\).*@OK@'
}

echo "(," | f1
echo "[" | f1


f1()
{
    sed -E -e 's@(\[|\().*@OK@'
}

echo "(," | f1
echo "[" | f1
