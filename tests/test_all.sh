#!/bin/bash

EPMPKGFILE=/usr/src/RPM/RPMS/noarch/eepm-3*.rpm

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

epm upgrade $EPMPKGFILE

epm downgrade $EPMPKGFILE

epm --auto remove erc

epm --auto install erc

epm --auto remove erc

epm --auto autoremove

epm --auto autoremove --direct

epm --auto autoorphans

epm --auto upgrade

epmqf bash

epm ql eepm | head

epm cl erc | head

# Sisyphus -> p10
epm --auto --force --force-yes downgrade-release p10
restore_epm

# p10 -> p9
epm --auto --force --force-yes downgrade-release
restore_epm

# p9 -> p10
epm --auto --force --force-yes upgrade-release
restore_epm

# try upgrade p10
epm --auto --force --force-yes upgrade-release && fatal
restore_epm

# p10 -> Sisyphus
epm --auto --force --force-yes upgrade-release Sisyphus
restore_epm

epm checkpkg eepm

epm upgrade eepm
restore_epm || :

epm downgrade eepm
restore_epm || :

epm clean
