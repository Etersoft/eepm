#!/bin/sh

PKGNAME=weasis
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Weasis DICOM medical viewer"
URL="https://github.com/nroduit/Weasis"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$(epm print info -p)-$arch" in
    rpm-x86_64)
        file="weasis-$VERSION-1.$arch.rpm"
        ;;
    *)
        arch="$(epm print info --debian-arch)"
        file="weasis_$VERSION-1_$arch.deb"
        ;;
esac

PKGURL=$(eget --list --latest https://github.com/nroduit/Weasis/releases "$file")

install_pkgurl
