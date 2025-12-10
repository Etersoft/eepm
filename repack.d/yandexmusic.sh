#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

# Conflicts with an official client used before
add_conflicts yandex-music

move_to_opt "/opt/Яндекс Музыка"

# disable autoupdate
remove_file -v $PRODUCTDIR/resources/app-update.yml

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
# workaround for https://github.com/electron/electron/issues/46538
exec $PRODUCTDIR/$PRODUCT --gtk-version=3
EOF

# for compatibility
add_bin_link_command yandex-music $PRODUCT

subst "s|^Exec=.*|Exec=$PRODUCT %U|" usr/share/applications/yandexmusic.desktop

add_libs_requires

fix_chrome_sandbox

add_electron_deps

