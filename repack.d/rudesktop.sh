#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGINPACKAGE="$4"

. $(dirname $0)/common.sh

# follow original requires
#reqs="$(epm requires "$ORIGINPACKAGE")"
#[ -n "$reqs" ] && add_requires $reqs

# ??
# echo "root ALL=(ALL) NOPASSWD:SETENV:/usr/bin/rudesktop" > /etc/sudoers.d/rudesktop

install_file usr/share/rudesktop-client/files/rudesktop.service /etc/systemd/system/rudesktop.service
install_file usr/share/rudesktop-client/files/rudesktop.desktop /usr/share/applications/rudesktop.desktop

#xdg-mime default rudesktop.desktop x-scheme-handler/rudesktop || true

install_file usr/lib64/libsciter-gtk.so /usr/share/rudesktop-client/files/libsciter-gtk.so
install_file usr/bin/rudesktop /usr/share/rudesktop-client/files/rudesktop

remove_file /usr/lib64/libsciter-gtk.so
remove_file /usr/bin/rudesktop

move_to_opt /usr/share/rudesktop-client/files

mkdir -p $BUILDROOT/usr/bin
cat <<EOF >$BUILDROOT/usr/bin/rudesktop
#!/bin/sh
cd /opt/rudesktop
if [ "\$LD_LIBRARY_PATH" ]; then
	export LD_LIBRARY_PATH=".:\$LD_LIBRARY_PATH"
else
	export LD_LIBRARY_PATH="."
fi
./rudesktop
EOF
chmod a+x $BUILDROOT/usr/bin/rudesktop
chmod a+x $BUILDROOT/opt/rudesktop/rudesktop
pack_file /usr/bin/rudesktop

subst "s|^Summary:.*|Summary: A remote control software.|" $SPEC

add_libs_requires
