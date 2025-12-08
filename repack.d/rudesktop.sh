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

#xdg-mime default rudesktop.desktop x-scheme-handler/rudesktop || true

move_to_opt /usr/share/rudesktop-client/files

install_file usr/lib64/libsciter-gtk.so $PRODUCTDIR/libsciter-gtk.so
remove_file /usr/lib64/libsciter-gtk.so

install_file usr/bin/rudesktop $PRODUCTDIR/rudesktop
chmod a+x $BUILDROOT/opt/rudesktop/rudesktop
remove_file /usr/bin/rudesktop

install_file $PRODUCTDIR/rudesktop.service /etc/systemd/system/rudesktop.service
remove_file $PRODUCTDIR/rudesktop.service
install_file $PRODUCTDIR/rudesktop.desktop /usr/share/applications/rudesktop.desktop
remove_file $PRODUCTDIR/rudesktop.desktop
install_file $PRODUCTDIR/rudesktop-user.service /usr/lib/systemd/user/rudesktop-user.service
remove_file $PRODUCTDIR/rudesktop-user.service

cat <<EOF | create_exec_file /usr/bin/rudesktop
#!/bin/sh
cd $PRODUCTDIR
if [ "\$LD_LIBRARY_PATH" ]; then
	export LD_LIBRARY_PATH=".:\$LD_LIBRARY_PATH"
else
	export LD_LIBRARY_PATH="."
fi
./rudesktop "\$@"
EOF

subst "s|^Summary:.*|Summary: A remote control software.|" $SPEC

add_libs_requires
