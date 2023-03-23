#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=gitlab-runner

. $(dirname $0)/common.sh


# we need repack due broken upstream package:

# $ epm conflicts gitlab-runner_amd64.rpm 
#  $ rpm -q --conflicts -p gitlab-runner_amd64.rpm
# gitlab-ci-multi-runner

# $ epm provides gitlab-runner_amd64.rpm 
#  $ rpm -q --provides -p gitlab-runner_amd64.rpm
# gitlab-ci-multi-runner

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

add_requires curl git tar
