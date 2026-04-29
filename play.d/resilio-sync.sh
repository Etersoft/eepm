#!/bin/sh

PKGNAME=resilio-sync
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="is a proprietary peer-to-peer file synchronisation tool."
URL="https://www.resilio.com/sync/download/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"
debarch="$(epm print info --debian-arch)"
rpmarch="$(epm print info -a)"


VERSION=$(eget -O- 'http://linux-packages.resilio.com/resilio-sync/deb/dists/resilio-sync/non-free/binary-amd64/Packages' \
    | awk '/^Package: resilio-sync$/{p=1;next} p&&/^Version:/{print $2; exit}' | sed 's/-.*//')


case "$pkgtype" in
    rpm)
        # https://download-cdn.resilio.com/3.1.2.1076/linux/x86_64/0/resilio-sync-x86_64.rpm
        file="resilio-sync-${rpmarch}.rpm"
        link_type="rpm"
        arch="$rpmarch"
        ;;
        
    *)
        # https://download-cdn.resilio.com/3.1.2.1076/linux/amd64/0/resilio-sync-amd64.deb
        file="resilio-sync-${debarch}.deb" 
        link_type="debian"
        arch="$debarch"
        ;;
esac
 
PKGURL="https://download-cdn.resilio.com/$VERSION/linux/$arch/0/$file"

install_pkgurl

cat <<EOF
Note: run
# serv resilio-sync on
to start Resilio Sync permanently
EOF

