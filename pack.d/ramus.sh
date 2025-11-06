#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"
WORKDIR="$(pwd)"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p  opt
mv  $PRODUCT* opt/$PRODUCT

VERSION=$(echo "$URL" | grep -oE '[0-9]+(\.[0-9]+){1,2}')
[ -n "$VERSION" ] || fatal "Can't get package version"

epmi java-11-openjdk-devel gradle

# Could not resolve all files for configuration ':gui-framework-core:compileClasspath'.
sed -i "s|^.*implementation 'org\.dockingframes:docking-frames-common:1\.1\.2-SNAPSHOT'|    implementation 'org.dockingframes:docking-frames-common:1.1.1'|" opt/$PRODUCT/gui-framework-core/build.gradle

cd opt/$PRODUCT
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$JAVA_HOME/bin:$PATH
gradle build || fatal
gradle copyFiles || fatal
cd $WORKDIR
install -d "usr/share/doc/$PRODUCT/"{ru,en}
install -d "usr/share/java/$PRODUCT"
install -d "usr/share/pixmaps"

install -m644 "opt/$PRODUCT/dest/doc/ru/"* "usr/share/doc/$PRODUCT/ru/"
install -m644 "opt/$PRODUCT/dest/doc/en/"* "usr/share/doc/$PRODUCT/en/"
mv "opt/$PRODUCT/dest/full/lib/thirdparty/"{local-client-1.0-SNAPSHOT.jar,$PRODUCT-modeler.jar} || true
install -m644 "opt/$PRODUCT/dest/full/lib/$PRODUCT/"*.jar "usr/share/java/$PRODUCT/"
install -m644 "opt/$PRODUCT/dest/full/lib/thirdparty/"*.jar "usr/share/java/$PRODUCT/"
install -m644 "opt/$PRODUCT/dest/izpack/icon.png" "usr/share/pixmaps/$PRODUCT.png"


cat <<EOF | create_file /usr/bin/$PRODUCT
#!/bin/sh
# Run Ramus IDEF0, DFD Modeler - Visual editor

for name in /usr/share/java/ramus/*.jar ; do
  CP=\$CP:\$name
done


# Set the initial and maximum JVM heap size
JAVA_HEAP_MAX_SIZE=192

# Start jEdit
exec java -cp \$CP -Xmx\${JAVA_HEAP_MAX_SIZE}M -Dawt.useSystemAAFontSettings=lcd com.ramussoft.local.Main "\$@"
EOF


cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=Ramus
Comment=Java-based IDEF0 & DFD Modeler
Exec=$PRODUCT %u
Icon=$PRODUCT
Type=Application
Categories=Development;IDE
EOF

chmod 755 usr/bin/$PRODUCT

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
