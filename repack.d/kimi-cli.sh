#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# kimi-cli and kimi-code are two incarnations of the same Moonshot agent,
# both ship /usr/bin/kimi, so they can not be installed together
add_conflicts kimi-code
