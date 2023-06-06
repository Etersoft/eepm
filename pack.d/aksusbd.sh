#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz" ; then
    erc $TAR || fatal
    TAR="Sentinel_LDK_Linux_Run-time_Installer_script/aksusbd-*.tar.gz"
fi

if echo "$TAR" | grep -q "aksusbd" ; then
    erc $TAR || fatal
else
    fatal "How no idea how to handle $TAR"
fi

# select package by package type and target arch

pkgtype="$(epm print info -p)"

if [ "$pkgtype" = "rpm" ] ; then

    case "$(epm print info -a)" in
        x86_64)
            arch="x86_64"
            ;;
        x86)
            arch="i386"
            ;;
        aarch64)
            arch="aarch64"
            ;;
        armhf)
            arch="armv7hl"
            ;;
        *)
            fatal "Unsupported arch"
            ;;
    esac

    pkg="aksusbd-*.$arch.rpm"

else

    case "$(epm print info -a)" in
        x86_64)
            arch="amd64"
            ;;
        x86)
            arch="i386"
            ;;
        aarch64)
            arch="arm64"
            ;;
        armhf)
            arch="armhf"
            ;;
        *)
            fatal "Unsupported arch"
            ;;
    esac

    pkg="aksusbd_*_$arch.deb"
fi

mv -v $PRODUCT*/pkg/$pkg . || fatal

return_tar $pkg
