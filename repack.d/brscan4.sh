#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# EEPM strips the vendor's %post/%preun maintainer scripts, so reproduce
# their effects as static files here.

# The SANE framework (dll loader, /etc/sane.d, /usr/lib64/sane backends dir).
add_requires libsane

# Auto-detect library deps of the bundled binaries
# (brscan_cnetconfig/brscan_gnetconfig need libavahi/libgtk, etc.).
add_libs_requires

# Vendor %post runs: setupSaneScan4 -i
# which appends the single word "brother4" to /etc/sane.d/dll.conf so the
# SANE dll meta-backend loads libsane-brother4.so.
# Static equivalent: a dll.d drop-in read by modern sane-backends.
echo brother4 | create_file /etc/sane.d/dll.d/brother4

# Vendor %post also runs udev_config.sh, which installs a generic udev rule
# matching all Brother USB devices (idVendor 04f9) so libsane picks them up.
# Reproduce it as a static rule (the lib backend ships in /usr/lib64/sane already).
create_file /etc/udev/rules.d/60-brother-brscan4-libsane-type1.rules <<'EOF'
#
#   udev rules
#

ACTION!="add", GOTO="brother_mfp_end"
SUBSYSTEM=="usb", GOTO="brother_mfp_udev_1"
SUBSYSTEM!="usb_device", GOTO="brother_mfp_end"
LABEL="brother_mfp_udev_1"
SYSFS{idVendor}=="04f9", GOTO="brother_mfp_udev_2"
ATTRS{idVendor}=="04f9", GOTO="brother_mfp_udev_2"
GOTO="brother_mfp_end"
LABEL="brother_mfp_udev_2"
ATTRS{bInterfaceClass}!="0ff", GOTO="brother_mfp_end"
ATTRS{bInterfaceSubClass}!="0ff", GOTO="brother_mfp_end"
ATTRS{bInterfaceProtocol}!="0ff", GOTO="brother_mfp_end"
ENV{libsane_matched}="yes"
LABEL="brother_mfp_end"
EOF

# Drop the now-inert vendor scripts (their effect is baked in above).
remove_file /opt/brother/scanner/brscan4/setupSaneScan4
remove_file /opt/brother/scanner/brscan4/udev_config.sh
