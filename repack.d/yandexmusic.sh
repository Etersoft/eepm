#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

# Conflicts with an official client used before
add_conflicts yandex-music

move_to_opt "/opt/Яндекс Музыка"

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
# workaround for https://github.com/electron/electron/issues/46538
exec $PRODUCTDIR/$PRODUCT --gtk-version=3
EOF

# for compatibility
add_bin_link_command yandex-music $PRODUCT

subst "s|^Exec=.*|Exec=$PRODUCT %U|" usr/share/applications/yandexmusic.desktop

# the original .desktop has only Categories=Audio; which is not a main XDG menu category,
# so the entry does not appear in the menu. Add the AudioVideo main category.
subst "s|^Categories=.*|Categories=AudioVideo;Audio;|" usr/share/applications/yandexmusic.desktop



add_electron_deps

