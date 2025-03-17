#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/WebDAVCloudMailRu

. $(dirname $0)/common.sh

cat <<EOF | create_bin_exec_command /usr/bin/wdmrc
#!/bin/sh
dotnet $PRODUCTDIR/wdmrc.dll "\$@"
EOF

add_requires dotnet-6.0
