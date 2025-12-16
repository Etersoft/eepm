#!/bin/sh

PKGNAME=ocenaudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Easy, fast and powerful audio editor"
URL="https://www.ocenaudio.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

case "$(epm print info -e)" in
    openSUSE/15*)
        distro="opensuse15"
        ;;
    Fedora/39)
        distro="fedora39"
        ;;
    Fedora/4*)
        distro="fedora40"
        ;;
    RockyLinux/9*)
        distro="rockylinux9.3"
        ;;
    Debian/11*)
        distro="debian11"
        ;;
    Debian/12*)
        distro="debian12"
        ;;
    Debian/13*)
        distro="debian13"
        ;;
    Ubuntu/20.*)
        distro="ubuntu20.04"
        ;;
    Ubuntu/22.*)
        distro="ubuntu22.04"
        ;;
    Ubuntu/24.*)
        distro="ubuntu24.04"
        ;;
    ALTLinux/Sisyphus)
        distro="fedora40"
        ;;
    ALTLinux/p11)
        distro="debian12"
        pkgtype="deb"
        ;;
    ALTLinux/p10)
        distro="debian11"
        pkgtype="deb"
        ;;
    *)
        distro="debian12" 
        pkgtype="deb"
esac

PKGURL="https://www.ocenaudio.com/downloads/index.php/ocenaudio_${distro}.${pkgtype}"

install_pkgurl
