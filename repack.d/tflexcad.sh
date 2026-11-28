#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=tflexcad
PRODUCTDIR=/opt/TFlexCAD

. $(dirname $0)/common.sh

# install helpers from upstream package scripts (we do their work here)
for i in 2origin.sh after_install.sh after_remove.sh before_remove.sh app-reg.sh app-unreg.sh \
         License/install_tflex_licensing.sh License/uninstall_tflex_licensing.sh ; do
    remove_file $PRODUCTDIR/$i
done

# after_install.sh: move T-FLEX fonts to the system fonts dir
move_dir $PRODUCTDIR/.fonts /usr/share/fonts/ttf/tflex

# app-reg.sh: desktop file, icon and mime type for *.grb files
add_bin_exec_command tflex-cad $PRODUCTDIR/tflex.cad

install_file $PRODUCTDIR/TFlex.png /usr/share/icons/hicolor/48x48/apps/tflex-cad.png
install_file $PRODUCTDIR/application-x-tflex.png /usr/share/icons/hicolor/48x48/mimetypes/application-x-tflex-cad.png

cat <<EOF | create_file /usr/share/mime/packages/tflex-cad.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="application/x-tflex-cad">
        <comment>T-FLEX CAD document</comment>
        <icon name="application-x-tflex-cad"/>
        <glob pattern="*.grb"/>
        <glob pattern="*.GRB"/>
    </mime-type>
</mime-info>
EOF

cat <<EOF | create_file /usr/share/applications/tflex-cad.desktop
[Desktop Entry]
Version=1.0
Name=T-FLEX CAD
Comment=T-FLEX CAD parametric 2D/3D CAD system
Exec=tflex-cad %U
MimeType=application/x-tflex-cad;
Icon=tflex-cad
Terminal=false
Type=Application
StartupWMClass=T-FLEX
Categories=Graphics;Engineering;
EOF

# install_tflex_licensing.sh: T-FLEX Licensing tool (keys activation)
LICDIR=$PRODUCTDIR/License/TFlex.Licensing
add_bin_exec_command tflex-licensing $LICDIR/TFlex.Licensing
install_file $LICDIR/Assets/Icons/App.png /usr/share/pixmaps/TFlex.Licensing.png

cat <<EOF | create_file /usr/share/applications/TFlex.Licensing.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=T-FLEX Licensing
Comment=T-FLEX license keys activation and update
Exec=tflex-licensing
Icon=TFlex.Licensing
Terminal=false
Categories=Utility;System;
EOF

# uses system Qt5 (upstream requires libqt5-webengine, libqt5-webenginewidgets)
add_unirequires libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5PrintSupport.so.5 libQt5WebChannel.so.5 \
                libQt5WebEngine.so.5 libQt5WebEngineCore.so.5 libQt5WebEngineWidgets.so.5 libQt5Widgets.so.5 libQt5Xml.so.5

# TFlexPythonApi.so is an optional Python API module built against python 3.12 only
ignore_lib_requires 'libpython3.*'
# bundled .NET: liblttng-ust.so.0 only for optional LTTng/EventPipe tracing
ignore_lib_requires liblttng-ust.so.0
