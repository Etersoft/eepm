#!/bin/sh

PKGNAME=pro32connect
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Joint (PRO32 Connect, Getscreen) - remote access to computers from the official site'
URL="https://jointhub.ru/"

. $(dirname $0)/common.sh

# only the current version is available
warn_version_is_not_supported

case "$(epm print info -a)" in
    x86_64)
        PKGURL="https://my.jointhub.ru/download/joint.rpm"
        ;;
    aarch64)
        PKGURL="https://my.jointhub.ru/download/joint.arm.rpm"
        ;;
esac

install_pkgurl || exit

cat <<EOF

Note: run
# serv $PKGNAME on
to enable the $PKGNAME system service (unattended access agent).
To register the device in your account, run
$ $PKGNAME -register <email>
EOF
