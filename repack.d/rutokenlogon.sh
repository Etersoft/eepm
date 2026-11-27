#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rutokenlogon
PRODUCTDIR=/opt/aktivco/rtlogon

. $(dirname $0)/common.sh

# The original maintainer scripts:
#  %post: create world writable /var/rtlogon, SELinux contexts (semanage), paxrat,
#         enable and start rtlogon_log.service, restart polkit and pcscd,
#         run 'rtlogon-cli reconfigure' on upgrade.
#  %preun: 'rtlogon-cli unconfigure' on erase (restores PAM and display manager configs).
# The logon (PAM and display manager) configuration is left to the user: rtlogon-cli configure
# rtlogon_log.service is not enabled automatically: serv rtlogon_log on

cat <<EOF | create_file /usr/lib/tmpfiles.d/$PRODUCT.conf
#Type	Path		Mode	User	Group	Age	Argument
d	/var/rtlogon	0777	root	root	-	-
EOF

# paxrat is not used
remove_dir /etc/paxrat

# duplicates /usr/share/bash-completion/completions/rtlogon-cli
remove_file /etc/bash_completion.d/rtlogon-cli

# the greeter is found via /usr/share/xgreeters/lightdm-rtlogon-greeter.desktop
move_file /usr/local/bin/lightdm-rtlogon-greeter /usr/bin/lightdm-rtlogon-greeter
remove_dir /usr/local

# librtpkcs11ecp.so in pkcs/ is a private copy used by rtlogon

# uses system Qt5, PAM, X11, GLib and LightDM greeter library (for the rtlogon greeter, recommended by the vendor)
add_unirequires libQt5Concurrent.so.5 libQt5Core.so.5 libQt5DBus.so.5 libQt5Gui.so.5 libQt5Svg.so.5 libQt5Widgets.so.5
add_unirequires libpam.so.0 libX11.so.6 libglib-2.0.so.0 libgobject-2.0.so.0 liblightdm-gobject-1.so.0

# pcscd and CCID reader driver are needed for Rutoken
add_requires /usr/sbin/pcscd
case "$(epm print info -p)" in
    deb)
        add_requires libccid
        ;;
    *)
        # provided by pcsc-lite-ccid in ALT and Fedora, ccid in ROSA
        add_requires ccid
        ;;
esac
