#!/bin/sh

[ "$1" != "--run" ] && echo "Fix missed 32 bit package modules on 64 bit system" && exit

vendor="$($DISTRVENDOR -s)" ; [ "$vendor" = "alt" ] || { echo "Only ALT distros is supported for now" ; exit 1 ; }

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

LIST=''

# copied from

echo
echo "Checking for installed modules... "
for i in glibc-nss glibc-gconv-modules \
         sssd-client \
         $(epmqp --short libnss | grep "^libnss-") \
         $(epmqp --short xorg-dri | grep "^xorg-dri-")
do
    epm --quiet installed $i && LIST="$LIST i586-$i"
done

echo
echo "Installing all appropiate i586-* packages ..."
epm install $LIST
