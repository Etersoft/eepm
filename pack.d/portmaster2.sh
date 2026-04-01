#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

BINDIR=opt/portmaster2
DATADIR=var/lib/portmaster

# extract original installer deb (contains only portmaster-start bootstrap)
erc --here unpack $TAR || fatal

# fetch manifests
MANIFEST_URL="https://updates.safing.io/stable.v3.json"
eget -O manifest.json "$MANIFEST_URL" || fatal "Can't fetch manifest"

INTEL_URL="https://updates.safing.io/intel.v3.json"
eget -O intel.json "$INTEL_URL" || fatal "Can't fetch intel manifest"

# parse with python3
VERSION=$(python3 -c "import json; print(json.load(open('manifest.json'))['Version'])")
[ -n "$VERSION" ] || fatal "Can't get version from manifest"

get_url()
{
    python3 -c "
import json,sys
name, platform = sys.argv[1], sys.argv[2] if len(sys.argv)>2 else None
d = json.load(open(sys.argv[3]))
for a in d['Artifacts']:
    if a['Filename'] == name:
        if platform and a.get('Platform') != platform:
            continue
        print(a['URLs'][0])
        break
" "$1" "$2" "$3"
}

PKGNAME=$PRODUCT-$VERSION

# download core and app binaries
mkdir -p $BINDIR
for artifact in portmaster-core portmaster; do
    url=$(get_url "$artifact" "linux_amd64" manifest.json)
    [ -n "$url" ] || fatal "Can't find URL for $artifact"
    eget -O $BINDIR/$artifact "$url" || fatal "Can't download $artifact"
    chmod +x $BINDIR/$artifact
done

# download UI modules
for artifact in portmaster.zip assets.zip; do
    url=$(get_url "$artifact" "" manifest.json)
    [ -n "$url" ] || fatal "Can't find URL for $artifact"
    eget -O $BINDIR/$artifact "$url" || fatal "Can't download $artifact"
done

# download intel data
mkdir -p $DATADIR/intel
for artifact in index.dsd base.dsdl intermediate.dsdl urgent.dsdl main-intel.yaml notifications.yaml news.yaml; do
    url=$(get_url "$artifact" "" intel.json)
    [ -n "$url" ] && eget -O $DATADIR/intel/$artifact "$url"
done

for artifact in geoipv4.mmdb geoipv6.mmdb; do
    url=$(get_url "$artifact" "" intel.json)
    [ -n "$url" ] && eget -O $DATADIR/intel/$artifact.gz "$url" && gunzip -f $DATADIR/intel/$artifact.gz
done

# create dirs for runtime
mkdir -p $DATADIR/logs

# collect files to pack
erc pack $PKGNAME.tar $BINDIR $DATADIR

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
summary: Portmaster v2 - Privacy Suite and Application Firewall
url: https://safing.io/portmaster
license: GPL-3.0
EOF

return_tar $PKGNAME.tar
