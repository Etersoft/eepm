#!/bin/sh

PKGNAME=t1client-standalone
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DSSL Trassir Client"
URL="https://confluence.trassir.com/pages/viewpage.action?pageId=36865118"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# The upstream rpm advertises a large obsolete runtime stack as external
# dependencies on rpm-based systems. The deb bundle repacks more cleanly after
# trimming legacy helper trees in repack.d, so use it on every target.
PKGURL="https://ncloud.dssl.ru/public.php/dav/files/WQqtPwda5KNyHzK"

install_pkgurl
