#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/WebDAVCloudMailRu

. $(dirname $0)/common.sh

cat <<EOF | create_exec_file /usr/bin/wdmrc
#!/bin/sh
exec dotnet --roll-forward Major $PRODUCTDIR/wdmrc.dll "\$@"
EOF

add_requires dotnet-8.0
