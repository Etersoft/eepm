#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

echo "$TAR" | grep -q "SMART_software_deb_archive.*\.tar\.gz" || fatal "Unknown file $TAR"

SMARTDIR="opt/SMART Technologies"
DRVDIR="$SMARTDIR/SMART Product Drivers"
LANGDIR="$SMARTDIR/Language Setup"

erc -C archive unpack "$TAR" || fatal

for i in smart-common smart-languagesetup smart-product-drivers fwupdatesmart ; do
    deb="$(ls archive/pool/non-free/*/$i/${i}_*_amd64.deb | tail -n1)"
    [ -f "$deb" ] || fatal "Can't find $i in $TAR"
    [ "$i" = "smart-product-drivers" ] && VERSION="$(basename "$deb" | sed -e "s|^${i}_||" -e 's|-[0-9]*_amd64\.deb$||')"
    erc -C "deb-$i" unpack "$deb" || fatal
    cp -a "deb-$i/." root/ || fatal
done
[ -n "$VERSION" ] || fatal "Can't get package version"

cd root || fatal

# done by smart-common postinst
for i in "$SMARTDIR/common/lib.common"/* ; do
    ln -sf "../lib.common/$(basename "$i")" "$SMARTDIR/common/lib/" || fatal
done

# Ubuntu 20.04 libraries missed in ALT: Qt5 needs ICU 66, the tools need boost 1.67 (boost_signals was removed in 1.69)
UBUNTU="http://archive.ubuntu.com/ubuntu/pool"
for i in main/i/icu/libicu66_66.1-2ubuntu2.1_amd64.deb \
         universe/b/boost1.67/libboost-regex1.67.0_1.67.0-17ubuntu8_amd64.deb \
         universe/b/boost1.67/libboost-signals1.67.0_1.67.0-17ubuntu8_amd64.deb \
         universe/b/boost1.67/libboost-system1.67.0_1.67.0-17ubuntu8_amd64.deb \
         universe/b/boost1.67/libboost-thread1.67.0_1.67.0-17ubuntu8_amd64.deb ; do
    deb="$(basename "$i")"
    epm tool eget -O "../$deb" "$UBUNTU/$i" || fatal "Can't download $UBUNTU/$i"
    erc -C "../ubuntu-$deb" unpack "../$deb" || fatal
    cp -a "../ubuntu-$deb/usr/lib/x86_64-linux-gnu/"*.so.* "$SMARTDIR/common/lib/" || fatal
done

STORE="$SMARTDIR/.store"

# udev rules (60-SMARTBoard32.rules): NAME= for event devices is not supported by udev for ages
mkdir -p etc/udev/rules.d etc/X11/xorg.conf.d etc/xdg/autostart "etc/xdg/SMART Technologies" usr/share/applications
grep -v 'NAME="SB%k"' "$STORE/smart-product-drivers/rules/60-SMARTBoard32.rules" > etc/udev/rules.d/60-SMARTBoard.rules || fatal
cp "$DRVDIR/xconfig/15-lightraise.conf" etc/X11/xorg.conf.d/ || fatal

for i in "$DRVDIR/bin/qt.conf" "$LANGDIR/bin/qt.conf" ; do
    cat <<EOF2 >"$i"
[Paths]
Plugins=/$SMARTDIR/common/plugins
Settings=/etc/xdg
EOF2
done

# done by smart-product-drivers and smart-languagesetup postinst
cat <<EOF2 >"etc/xdg/SMART Technologies.conf"
[Software]
SMART%20Technologies\\SMART%20Board%20Drivers\\Install%20Information\\Drivers%20Directory=/$DRVDIR
SMART%20Technologies\\SMART%20Board%20Drivers\\Install%20Information\\Drivers%20Version=$VERSION
SMART%20Technologies\\SMART%20Board%20Drivers\\Install%20Information\\Documentation=/$DRVDIR/documentation
SMART%20Technologies\\SMART%20Board%20Drivers\\Install%20Information\\CustomLayout=/$DRVDIR/Default Profiles and Layouts/CustomLayout.xml
SMART%20Technologies\\SMART%20Board%20Drivers\\Install%20Information\\CustomLayoutTranslation=/$DRVDIR/Default Profiles and Layouts/CustomLayoutTranslation.xml
SMART%20Technologies\\SMART%20Board%20Drivers\\Install%20Information\\DefaultLayout=/$DRVDIR/Default Profiles and Layouts/DefaultLayout.xml
SMART%20Technologies\\SMART%20Tools\\ToolsPath=/$DRVDIR
SMART%20Technologies\\SMART%20Board%20Drivers\\Board%20Tools\\FloatingToolsWasRunning=1
SMART%20Technologies\\Language%20Setup\\Path=/$LANGDIR
EOF2

cat <<EOF2 >"etc/xdg/SMART Technologies/Language Setup.conf"
[SMART Board]
DisplayName=SMART Board Drivers
IsHwConfigurable=0
IsLanguageConfigurable=1
LanguagesFolder=/$DRVDIR/Languages
EOF2

# the tools write their settings there
touch "etc/xdg/SMART Technologies Drivers.conf" "etc/xdg/SMART Technologies/SMART Notebook.conf"

# the board service and tools run in the user session
for i in SMARTBoardService SystemNotifications SystemTrayIcon ; do
    cat <<EOF2 >etc/xdg/autostart/smart-$i.desktop
[Desktop Entry]
Name=$i
Comment=SMART Board Software
Type=Application
Exec="/$DRVDIR/bin/$i"
Icon=system-run
X-GNOME-Autostart-enabled=true
EOF2
done

# menu entries (the vendor's Categories=SMART-Technologies needs their own menu files)
for i in "$STORE/smart-product-drivers/xdg/menu-desktop"/*.desktop "$STORE/smart-languagesetup/xdg/menu-desktop-update"/*.desktop ; do
    case "$i" in
        *smart-languagesetup*) bindir="/$LANGDIR/bin" ;;
        *) bindir="/$DRVDIR/bin" ;;
    esac
    sed -e "s|^Exec=\"*\([^\"]*\)\"*$|Exec=\"$bindir/\1\"|" \
        -e 's|^\(Icon=.*\)\.png$|\1|' \
        -e 's|^Categories=.*|Categories=Settings;HardwareSettings;|' "$i" > "usr/share/applications/$(basename "$i")" || fatal
done

rm -rf "$STORE" "$DRVDIR/xconfig" usr/share/pixmaps

PKGNAME=$PRODUCT-$VERSION

erc pack ../$PKGNAME.tar etc opt usr || fatal
cd .. || fatal

cat <<EOF2 >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: System/Configuration/Hardware
license: Proprietary
url: https://www.smarttech.com/
summary: SMART Product Drivers for SMART Board interactive whiteboards
description: SMART Product Drivers (board service, tools, calibration, firmware updater) for SMART Board interactive whiteboards, with SMART Language Setup and SMART common libraries.
EOF2

return_tar $PKGNAME.tar
