#!/bin/sh

[ "$1" != "--run" ] && echo "Uninstall etersoft build of glibc" && exit

[ "$($DISTRVENDOR -d)" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1

epm downgrade glibc glibc-core glibc-preinstall
exit 0

TR=$(mktemp)

epm repolist | grep etersoft >$TR
while read n ; do
    epm removerepo $n </dev/null
done <$TR

epm rl

while read n ; do
    epm addrepo $n </dev/null
done <$TR

epm rl
