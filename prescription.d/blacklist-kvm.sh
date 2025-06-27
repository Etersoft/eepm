#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Blacklist KVM modules to ensure compatibility with VirtualBox"

. $(dirname $0)/common.sh

assure_root

cat > /etc/modprobe.d/epm-kvm-blacklist.conf <<'EOF'
blacklist kvm
blacklist kvm_intel
blacklist kvm_amd
EOF

a= make-initrd

echo "KVM modules have been blacklisted."
echo "Please reboot your system for the changes to take effect."
