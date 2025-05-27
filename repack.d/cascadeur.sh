#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Cascadeur
Comment=Cascadeur - a physics-based 3D animation software
Icon=$PRODUCT
Exec=$PRODUCT %u
Categories=Games;
Terminal=false
EOF

# they use missed Qt5/Qt6 libs
remove_dir /opt/cascadeur/qml/QtQuick/Scene2D
remove_dir /opt/cascadeur/qml/QtQuick/Scene3D
remove_dir /opt/cascadeur/qml/QtQuick/Shapes
remove_dir /opt/cascadeur/qml/QtQuick/Effects
remove_dir /opt/cascadeur/qml/QtQml/RemoteObjects
remove_dir /opt/cascadeur/qml/QtQuick/LocalStorage
remove_dir /opt/cascadeur/qml/QtQuick/XmlListModel

ignore_lib_requires 'libbz2.so.1.0' 'libgdbm.so.6'

# used in some python lib-dyn modules
ignore_lib_requires 'libncursesw.so.*'
ignore_lib_requires 'libpanelw.so.*'
ignore_lib_requires 'libreadline.so.*'
ignore_lib_requires 'libtinfo.so.*'

ignore_library_path /opt/cascadeur/plugins/multimedia

add_libs_requires
