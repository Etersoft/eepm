#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/ts3client_runscript.sh
#add_bin_link_command $PRODUCT $PRODUCTDIR/ts3client_linux_amd64

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Encoding=UTF-8
Name=TeamSpeak 3
GenericName=TeamSpeak 3 - Voice communication
Comment=TeamSpeak is software for quality voice communication via the Internet
Exec=teamspeak3
Icon=teamspeak3
StartupNotify=true
Terminal=false
Type=Application
Categories=Network;Application
StartupWMClass=TeamSpeak 3
EOF
pack_file /usr/share/applications/$PRODUCT.desktop

install_file "https://aur.archlinux.org/cgit/aur.git/plain/teamspeak3.png?h=teamspeak3-wbundled" /usr/share/pixmaps/$PRODUCT.png

# hack, todo: update libevent in p10
get_libevent()
{
    local libdir
    for libdir in /usr/lib/x86_64-linux-gnu /usr/lib64 /lib64 ; do
        basename $(ls $libdir/libevent-2.1.so.[0-9] 2>/dev/null) 2>/dev/null
    done | head -n1
}

libevent="$(get_libevent)"
[ -n "$libevent" ] || fatal "libevent is missed, install it before"

if [ "$libevent" != "libevent-2.1.so.7" ] && epm assure patchelf ; then
    patchelf --replace-needed libevent-2.1.so.7 $libevent .$PRODUCTDIR/libQt5WebEngineCore.so.5
    # Fix libquazip1-qt5.so name
    #patchelf --replace-needed libquazip.so libquazip1-qt5.so.1.0.0 .$PRODUCTDIR/ts3client_linux_amd64
fi

epm install "libwebp.so.6()(64bit)" || epm install https://git.altlinux.org/tasks/177836/build/200/x86_64/rpms/libwebp6-0.5.2-alt2.x86_64.rpm || fatal "Can't install needed libwebp6"

# require missed libQt5WaylandClient.so.5
remove_file $PRODUCTDIR/platforms/libqwayland-generic.so
remove_file $PRODUCTDIR/platforms/libqwayland-egl.so
remove_file $PRODUCTDIR/platforms/libqwayland-xcomposite-glx.so
remove_file $PRODUCTDIR/platforms/libqwayland-xcomposite-egl.so

add_libs_requires
