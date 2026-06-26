#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Set up Stapler (stplr) with the community aides repository"

. $(dirname $0)/common.sh

assure_root

# install the Stapler universal build system
epm install stplr || fatal "Can't install stplr"

# Add the community 'aides' recipe repository, but only when stplr has no
# repositories configured yet. If the user already set up any repository we
# leave it untouched - this keeps the prescription safe to run repeatedly.
if epm repolist stplr: 2>/dev/null | grep -qE 'https?://' ; then
    info 'Stapler already has repositories configured, leaving them as is'
else
    stplr repo add aides https://altlinux.space/aides-community/aides.git
    stplr refresh
fi
