#!/bin/bash

fatal()
{
    exit 1
}

set -e -x
set -o pipefail

epm print info

epm update

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

# p10 -> p9
epm --auto --force --force-yes downgrade-release

# p9 -> p10
epm --auto --force --force-yes upgrade-release

# try upgrade p10
epm --auto --force --force-yes upgrade-release && fatal

# p10 -> Sisyphus
epm --auto --force --force-yes upgrade-release Sisyphus

epm checkpkg eepm

epm clean
