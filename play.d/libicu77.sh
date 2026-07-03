#!/bin/sh

PKGNAME=libicu77
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='ICU 77.1 runtime libraries (libicudata/libicui18n/libicuuc .so.77) for apps built against the GNOME 49 runtime'

. $(dirname $0)/common.sh

# ALT Sisyphus ships ICU up to 76. Applications built against the GNOME 49 Flatpak
# runtime (e.g. Orion) link libicu*.so.77, which ALT does not package. Arch skipped
# ICU 77 (76 -> 78) and Debian is still on 76.1/78.3, but Fedora 43 distributes ICU
# 77.1 as a native RPM. Repack only its runtime .so files; ALT auto-provides the
# libicu*.so.77 sonames, so packages can require libicudata.so.77 etc.
case "$(epm print info -a)" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="aarch64" ;;
    *) fatal "Unsupported architecture for $PKGNAME" ;;
esac

PKGURL="https://kojipkgs.fedoraproject.org/packages/icu/77.1/1.fc43/$arch/libicu-77.1-1.fc43.$arch.rpm"

install_pack_pkgurl
