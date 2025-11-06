#!/bin/sh

PKGNAME=satvision-v.2.0
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VMS Software Satvision V.2.0"
URL="https://satvision-cctv.ru/"

. $(dirname $0)/common.sh


PKGURL=$(eget --list --latest https://satvision-cctv.ru/base/instructions/485/ VMS-Pro64_SATVISION_Satvision*.zip)

install_pack_pkgurl
