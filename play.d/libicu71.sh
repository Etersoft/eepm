#!/bin/sh

PKGNAME=libicu71
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='ICU 71.1 runtime libraries (libicudata/libicui18n/libicuuc .so.71) for apps built against RED OS 8 / Fedora 37'

. $(dirname $0)/common.sh

# ALT ships ICU 74 and newer. Applications built for RED OS 8 (e.g. Space Client)
# link libicu*.so.71, which ALT does not package. Fedora 37 distributes ICU 71.1
# as a native RPM. Repack only its runtime .so files; the sonames are declared
# explicitly in pack.d/libicu71.sh.
case "$(epm print info -a)" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="aarch64" ;;
    *) fatal "Unsupported architecture for $PKGNAME" ;;
esac

PKGURL="https://kojipkgs.fedoraproject.org/packages/icu/71.1/2.fc37/$arch/libicu-71.1-2.fc37.$arch.rpm"

install_pack_pkgurl
