#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Set up Stapler (stplr) with the community aides repository"

. $(dirname $0)/common.sh

# install the Stapler universal build system (epm elevates by itself)
epm install stplr || fatal "Can't install stplr"

# Add the community 'aides' recipe repository, but only when stplr has no
# repositories configured yet. If the user already set up any repository we
# leave it untouched - this keeps the prescription safe to run repeatedly.
if epm repolist stplr: 2>/dev/null | grep -qE 'https?://' ; then
    info 'Stapler already has repositories configured, leaving them as is'
else
    # the prescription itself runs unprivileged (it is called from epm play),
    # so elevate the stplr commands that write to /etc/stplr ourselves
    SUDO=''
    is_root || SUDO=sudo
    docmd $SUDO stplr repo add aides https://altlinux.space/aides-community/aides.git
    docmd $SUDO stplr refresh
fi
