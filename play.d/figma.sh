#!/bin/sh

PKGNAME=figma-linux
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Figma-linux - an unofficial Electron-based Figma desktop app for Linux"
URL="https://github.com/Figma-Linux/figma-linux"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9].*"

pkgtype="$(epm print info -p)"

if [ "$pkgtype" == "rpm" ] ; then
    case "$(epm print info -a)" in
        x86_64)
            file="${PKGNAME}_${VERSION}_linux_x86_64.$pkgtype" ;;
        aarch64)
            file="${PKGNAME}_${VERSION}_linux_aarch64.$pkgtype" ;;
    esac
elif [ "$pkgtype" == "deb" ] ; then
    case "$(epm print info -a)" in
        x86_64)
            file="${PKGNAME}_${VERSION}_linux_amd64.$pkgtype" ;;
        aarch64)
            file="${PKGNAME}_${VERSION}_linux_arm64.$pkgtype" ;;
    esac
elif [ "$pkgtype" == "pacman" ] ; then
    case "$(epm print info -a)" in
        x86_64)
            file="${PKGNAME}_${VERSION}_linux_x64.$pkgtype" ;;
        aarch64)
            file="${PKGNAME}_${VERSION}_linux_aarch64.$pkgtype" ;;
    esac
fi

PKGURL=$(get_github_version "https://github.com/Figma-Linux/figma-linux/" "$file")

install_pkgurl

