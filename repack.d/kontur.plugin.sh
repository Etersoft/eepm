#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=kontur.plugin
PRODUCTDIR=/opt/kontur.plugin

. $(dirname $0)/common.sh

# Browser registration is already shipped in the package as native messaging manifests:
# /etc/chromium (also used by Yandex Browser and Chromium-Gost), /etc/opt/chrome, /etc/opt/edge,
# /usr/lib/mozilla, /usr/lib64/mozilla

# Replace the original %post script:
# mkdir -p /etc/opt/skbkontur/plugin, world writable /var/tmp/skbkontur/plugin/metrics
mkdir -p $BUILDROOT/etc/opt/skbkontur/plugin
pack_dir /etc/opt/skbkontur
pack_dir /etc/opt/skbkontur/plugin

cat <<EOF | create_file /usr/lib/tmpfiles.d/$PRODUCT.conf
#Type	Path					Mode	User	Group	Age	Argument
d	/var/tmp/skbkontur			0755	root	root	-	-
d	/var/tmp/skbkontur/plugin		0755	root	root	-	-
d	/var/tmp/skbkontur/plugin/metrics	0777	root	root	-	-
EOF

# kontur.plugin.assistant.timer (sends metrics and fetches remote config hourly)
# was enabled by %post, now it is up to the user:
#   systemctl enable --now kontur.plugin.assistant.timer

# pcscd is needed for smart card tokens (Rutoken, JaCarta PKCS#11 modules in pkcs11/)
add_requires /usr/sbin/pcscd
