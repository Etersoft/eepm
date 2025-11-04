#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p  opt
mv  ramus* opt/$PRODUCT

VERSION=$(echo "$URL" | grep -oE '[0-9]+(\.[0-9]+){1,2}')
[ -n "$VERSION" ] || fatal "Can't get package version"

install_file opt/ramus/gui-framework-common/src/main/resources/com/ramussoft/gui/application.png /usr/share/pixmaps/ramus.png

cat <<EOF | create_file /usr/share/applications/ramus.desktop
[Desktop Entry]
Version=1.0
Name=Ramus
Comment=Java-based IDEF0 & DFD Modeler
Exec=ramus %u
Icon=ramus
Type=Application
Categories=Development;IDE
EOF

cat <<EOF | create_file /usr/bin/ramus
#!/bin/sh
# Run Ramus IDEF0, DFD Modeler - Visual editor

cd /opt/ramus
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=\$JAVA_HOME/bin:\$PATH
gradle runLocal --no-daemon
EOF

# Cannot create directory '/opt/ramus/.gradle/8.14.3/fileHashes'
cat <<EOF | create_file /opt/ramus/gradle.properties
gradle.user.home=\$HOME/.gradle
EOF

# Failed to create parent directory '/opt/ramus/*/build' when creating directory '/opt/ramus/*/build/classes/java/main'
find . -type f -name "build.gradle" -exec sed -i "/apply plugin: 'java'/a buildDir = \"\${System.env.HOME}/.ramus-build/\${project.name}\"" {} +

# Could not resolve all files for configuration ':gui-framework-core:compileClasspath'.
sed -i "s|^.*implementation 'org\.dockingframes:docking-frames-common:1\.1\.2-SNAPSHOT'|    implementation 'org.dockingframes:docking-frames-common:1.1.1'|" opt/ramus/gui-framework-core/build.gradle

chmod 755 usr/bin/ramus


PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
