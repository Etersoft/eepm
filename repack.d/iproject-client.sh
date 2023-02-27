#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=iproject-client
PRODUCTDIR="/opt/iproject-client"

. $(dirname $0)/common.sh

mkdir -p $BUILDROOT/usr/bin/

cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
mono /opt/iproject-client/RSClient.exe
EOF
chmod 755 $BUILDROOT/usr/bin/$PRODUCT
pack_file /usr/bin/$PRODUCT

#	mono(Microsoft.Threading.Tasks) = 1.0.12.0 нужен для iproject-client-100:2.0.11.128-alt1.repacked.with.epm.2.x86_64
#	mono(Microsoft.Threading.Tasks.Extensions) = 1.0.12.0 нужен для iproject-client-100:2.0.11.128-alt1.repacked.with.epm.2.x86_64
#	mono(System.Runtime) = 2.6 нужен для iproject-client-100:2.0.11.128-alt1.repacked.with.epm.2.x86_64
#	mono(System.Threading.Tasks) = 2.6 нужен для iproject-client-100:2.0.11.128-alt1.repacked.with.epm.2.x86_64
filter_from_requires "mono(Microsoft.Threading.Tasks)"
filter_from_requires "mono(Microsoft.Threading.Tasks.Extensions)"
filter_from_requires "mono(System.Runtime)"
filter_from_requires "mono(System.Threading.Tasks)"
