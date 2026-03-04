#!/bin/sh

PKGNAME=cloudflare-warp
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Cloudflare Warp Client"
URL="https://one.one.one.one/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

# Cloudflare RPM is built for Fedora with incompatible sonames
# (e.g. libpcap.so.1 instead of libpcap.so.0.8 on ALT)
[ "$(epm print info -s)" = "alt" ] && pkgtype=deb

case "$pkgtype" in
    rpm)
        arch="$(epm print info --distro-arch)"
        if [ "$VERSION" = "*" ] ; then
            primary_href="$(eget -O- "https://pkg.cloudflareclient.com/rpm/repodata/repomd.xml" \
            | grep -oP 'href="\K[^"]*primary\.xml\.gz')"
            VERSION="$(eget -O- "https://pkg.cloudflareclient.com/rpm/$primary_href" \
            | gzip -d | grep -oP '<version epoch="0" ver="\K[^"]+' | head -1)"
        fi
        PKGURL="https://pkg.cloudflareclient.com/rpm/$arch/cloudflare-warp-${VERSION}.$arch.rpm"
        ;;
    *)
        debarch="$(epm print info --debian-arch)"
        reponame="$(epm print info --repo-name)"

        # use native codename for Ubuntu/Debian, otherwise select by glibc
        case "$reponame" in
            noble|jammy|focal|bionic|xenial|bookworm|bullseye|buster|trixie)
                DEBDIST="$reponame"
                ;;
            *)
                if is_glibc_enough 2.39 ; then
                    DEBDIST=noble
                elif is_glibc_enough 2.34 ; then
                    DEBDIST=jammy
                elif is_glibc_enough 2.30 ; then
                    DEBDIST=focal
                elif is_glibc_enough 2.25 ; then
                    DEBDIST=bionic
                else
                    fatal 'glibc is too old, needed glibc 2.25 or above'
                fi
                ;;
        esac

        if [ "$VERSION" = "*" ] ; then
            VERSION="$(eget -O- "https://pkg.cloudflareclient.com/dists/$DEBDIST/main/binary-$debarch/Packages" \
            | grep -m1 "^Version: " | sed 's/Version: //')"
        fi

        PKGURL="https://pkg.cloudflareclient.com/pool/$DEBDIST/main/c/cloudflare-warp/cloudflare-warp_${VERSION}_${debarch}.deb"
        ;;
esac

install_pkgurl || fatal

cat <<EOF
Note: run
# serv warp-svc.service on
to start Cloudflare Warp permanently
and
$ systemctl --user start warp-taskbar.service
to start the system tray icon.
EOF
