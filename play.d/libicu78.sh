#!/bin/sh

PKGNAME=libicu78
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='ICU 78.3 runtime libraries (libicudata/libicui18n/libicuuc .so.78) for apps built against Fedora 45'

. $(dirname $0)/common.sh

# Use the distro package if there is one (ALT Sisyphus has libicu78):
# the repacked package with the same name and epoch 100 shadows it
# and has no set: versioned provides required by distro packages (tesseract etc.)
if epm status --installable libicu78 ; then
    epm install libicu78
    exit
fi

# ALT p11 ships ICU up to 74. Applications built against Fedora 45
# (e.g. Sunshine >= 2026) link libicu*.so.78, which ALT p11 does not package.
# Fedora 45 distributes ICU 78.3 as a native RPM. Repack only its runtime .so
# files; the sonames are declared explicitly in pack.d/libicu78.sh.
case "$(epm print info -a)" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="aarch64" ;;
    *) fatal "Unsupported architecture for $PKGNAME" ;;
esac

PKGURL="https://kojipkgs.fedoraproject.org/packages/icu/78.3/3.fc45/$arch/libicu-78.3-3.fc45.$arch.rpm"

install_pack_pkgurl
