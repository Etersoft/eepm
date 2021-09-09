#!/bin/sh -e

fatal()
{
    exit 1
}

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

epm --auto --force downgrade-release p10

epm --auto --force downgrade-release

epm --auto --force upgrade-release

epm --auto --force upgrade-release

epm --auto --force upgrade-release && fatal

epm --auto --force upgrade-release Sisyphus

epm checkpkg eepm

epm clean
