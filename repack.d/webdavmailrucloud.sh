#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/WebDAVCloudMailRu

. $(dirname $0)/common.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

subst "s|^License: unknown$|License: MIT|" $SPEC
subst "s|^Url:.*|Url: https://github.com/yar229/WebDavMailRuCloud|" $SPEC
subst "s|^Summary:.*|Summary: WebDAV emulator for Cloud.mail.ru / Yandex.Disk|" $SPEC

mkdir -p usr/bin
cat <<EOF >usr/bin/wdmrc
#!/bin/sh
dotnet $PRODUCTDIR/wdmrc.dll "\$@"
EOF
chmod a+x usr/bin/wdmrc
pack_file /usr/bin/wdmrc

add_requires dotnet-6.0
