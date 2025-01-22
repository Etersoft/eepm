#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ "$(basename $TAR)" = "teamspeak-client.tar.gz" ] || fatal "Unsupported $TAR"

erc $TAR || fatal
mkdir -p opt
mv teamspeak-client* opt/TeamSpeak

PKGNAME=$PRODUCT-$VERSION

erc a $PKGNAME.tar opt/TeamSpeak

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Video
license: Proprietary
url: http://www.teamspeak.com
summary: TeamSpeak is software for quality voice communication via the Internet
description: eamSpeak is software for quality voice communication via the Internet
EOF

return_tar $PKGNAME.tar
