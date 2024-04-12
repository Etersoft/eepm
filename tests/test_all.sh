#!/bin/bash

EPMPKGFILE=/github/home/RPM/RPMS/noarch/eepm-3.*.rpm
# just a package
TESTPKG1=fakeroot
TESTPKG2=erc

fatal()
{
    exit 1
}

restore_epm()
{
	# in the far future: epm upgrade /usr/src/RPM/RPMS/noarch/*.rpm
	epm --auto install $EPMPKGFILE
}

set -e -x
set -o pipefail

epm print info

epm update

epm --auto upgrade $EPMPKGFILE

epm --auto downgrade $EPMPKGFILE

for i in $TESTPKG1 $TESTPKG2 ; do
    epm --auto remove $i
    epm --auto install $i
    epm --auto remove $i
done

epm --auto autoremove

epm --auto autoremove --direct

epm --auto autoorphans

epm --auto upgrade

epmqf bash

epm ql eepm | head

epm cl erc | head

epm checkpkg eepm

epm --auto upgrade eepm
restore_epm || :

epm --auto downgrade eepm
restore_epm || :

# stop upgrade (it is broken now)
exit 0

# Sisyphus -> p10
epm --auto --force --force-yes downgrade-release p10
restore_epm

# p10 -> p9
epm --auto --force --force-yes downgrade-release
restore_epm

# p9 -> p10
epm --auto --force --force-yes upgrade-release
restore_epm

# try upgrade again p10
epm --auto --force --force-yes upgrade-release
restore_epm

# p10 -> Sisyphus
epm --auto --force --force-yes upgrade-release Sisyphus
restore_epm


epm clean
