#!/bin/sh

PKGNAME=spo-anketa
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="СПО «Анкета ГС (МС)» для заполнения анкеты госслужащего"
URL="https://gossluzhba.gov.ru/spo/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Download URL for Linux version from gossluzhba.gov.ru
# Version 1.0.2 from 25.02.2026
PKGURL="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/94f919b3-eccc-4bc1-a838-4913bb92b1cc"

# Checksum for version 1.0.2 (2026-02-25) - update when new version is released
PKGSUM="sha256:b2d4ff805429020a5640b8ee574e1dd6289704cded5729b942ddb1ee87ab97d2"

install_pack_pkgurl "" "$PKGSUM"
