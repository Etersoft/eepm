#!/bin/sh

PKGNAME=nanolm-nanosoft
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="nanoLM - Nanosoft license manager server (for nanoCAD) from the official site"
URL="https://nanodev.ru"

. $(dirname $0)/common.sh

# repository release follows nanoCAD releases (r25.0, r26.0, ...)
REPOREL="r26.0"

# packages are built for ALT, use ALT p11 build on other systems
distr="Alt_p11"
[ "$(epm print info -e)" = "ALTLinux/p10" ] && distr="Alt_p10"

# https://repo.nanodev.ru/r26.0/Alt_p11/x86_64/RPMS.nanodev/nanolm-nanosoft-1.3.1352-3086Alt_p11.x86_64.rpm
PKGURL="$(eget --list --latest "https://repo.nanodev.ru/$REPOREL/$distr/x86_64/RPMS.nanodev/" "nanolm-nanosoft-${VERSION}-*.x86_64.rpm")" || fatal "Can't get package URL"

install_pkgurl || exit

cat <<EOF

Note: run
# serv nanoLMsrv-Nanosoft on
to start nanoLM license server permanently.
Use 'Network License Wizard' (nanoLMctl-Nanosoft) to manage licenses.
EOF
