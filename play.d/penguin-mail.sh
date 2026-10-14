#!/bin/sh

PKGNAME=penguin-mail
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Penguin Mail: mail, calendar and contacts client using GTK4 and libadwaita"
URL="https://penguin-mail.com/"

. $(dirname $0)/common.sh

is_glibc_enough 2.39 || fatal "Penguin Mail needs glibc 2.39 or newer."

case "$(epm print info -p)" in
    rpm) mask="penguin-mail-$VERSION-*.x86_64.rpm" ;;
    *) mask="penguin-mail_${VERSION}_amd64.deb" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url https://github.com/c9dev/penguin-mail "$mask")"
else
    case "$(epm print info -p)" in
        rpm)
            case "$RELEASE" in ''|'*') RELEASE=1 ;; esac
            file="penguin-mail-$VERSION-$RELEASE.x86_64.rpm"
            ;;
        *) file="penguin-mail_${VERSION}_amd64.deb" ;;
    esac
    PKGURL="https://github.com/c9dev/penguin-mail/releases/download/v$VERSION/$file"
fi

install_pkgurl
