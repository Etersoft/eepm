#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

VERSION=$(echo "$URL" | grep -oP 'softmaker-freeoffice-[0-9]+-\K[0-9]+')
YEAR=$(echo "$URL" | grep -oP 'softmaker-freeoffice-\K[0-9]{4}')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/softmaker-freeoffice
mkdir -p usr/bin
erc $TAR || fatal
erc $(basename $TAR .tgz)/freeoffice$YEAR.tar.lzma || fatal
mv freeoffice$YEAR/* opt/$PRODUCT

cat <<EOF > usr/bin/planmaker
#!/bin/sh
# A script to run PlanMaker.
/opt/softmaker-freeoffice/planmaker "\$@"
EOF

cat <<EOF > usr/bin/textmaker
#!/bin/sh
# A script to run TextMaker
/opt/softmaker-freeoffice/textmaker "\$@"
EOF

cat <<EOF > usr/bin/presentations
#!/bin/sh
# A script to run Presentations
/opt/softmaker-freeoffice/presentations "\$@"
EOF
chmod 755 usr/bin/planmaker
chmod 755 usr/bin/textmaker
chmod 755 usr/bin/presentations

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
