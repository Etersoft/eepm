#!/bin/sh

# http://mywiki.wooledge.org/Bashism
# https://wiki.ubuntu.com/DashAsBinSh

EXCL=-eSC2086,SC2039,SC2034,SC2068,SC2155,SC3043

# TODO:
# SC2154: pkg_filenames is referenced but not assigned.
# SC2002: Useless cat.
EXCL="$EXCL,SC2154,SC2002"

if [ -n "$1" ] ; then
    shellcheck $EXCL "$1"
    checkbashisms -f "$1"
    exit
fi

checkbashisms -f bin/*
checkbashisms -f Makefile

shellcheck $EXCL \
	bin/epm bin/distr_info bin/epm-* bin/serv-* bin/tools_*
