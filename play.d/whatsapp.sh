#!/bin/sh

PKGNAME=wasistlos
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WhatsApp desktop application (from the repository or via wasistlos)"
URL="https://github.com/xeco23/WasIstLos"

. $(dirname $0)/common.sh

# This path installs packages or configures repositories rather than resolving URLs.
[ -z "$print_url" ] || fatal "--print-url is not supported for whatsapp."

epm install $PKGNAME && exit 0

epm play wasistlos

