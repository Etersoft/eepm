#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

for i in opt/pfusp/consumables/pfuspconsumables \
         opt/pfusp/pfuspgetinfo/pfuspgetscerror \
         opt/pfusp/pfuspgetinfo/pfuspgetscstatus ; do
   chmod 0755 $i
   add_bin_link_command $(basename $i) /$i
done

PFUSCANNER="pfusp"

cat <<EOF | create_file /opt/pfusp/etc/$PFUSCANNER.conf
#SP-1120
usb 0x04c5 0x1473
#SP-1125
usb 0x04c5 0x1475
#SP-1130
usb 0x04c5 0x1476
#SP-1425
usb 0x04c5 0x1524
#SP-1120N
usb 0x04c5 0x1625
#SP-1125N
usb 0x04c5 0x1626
#SP-1130N
usb 0x04c5 0x1627
EOF

cat <<EOF | create_file /opt/pfusp/etc/consumablessettings.xml
<Root>
<Version>2.2.1</Version>
<Copyright>2017-2023</Copyright>
</Root>
EOF

cat <<EOF | create_file /etc/sane.d/dll.d/$PFUSCANNER
# dll.conf snippet for $PFUSCANNER
#

$PFUSCANNER
EOF

cat <<EOF | create_file /opt/pfusp/etc/simple-scan.conf
PAPER_SIZE=0
EOF

add_libs_requires
