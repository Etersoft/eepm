#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

PRODUCTDIR=/opt/eepm-wine/$PRODUCT
INSTALLER="$(basename "$TAR")"

mkdir -p .$PRODUCTDIR/

# c:/users/lav/AppData/Local/AnthropicClaude/claude.exe
cat <<EOF > .$PRODUCTDIR/run.sh
#!/bin/sh
# AppData\Roaming
# APPDATA=\$(wine cmd /c echo %appdata% | tr -d '\r')
# AppData\Local
LOCALAPPDATA="\$(wine cmd /c echo %localappdata% | tr -d '\r')"
RUNFILE="\$LOCALAPPDATA\\\\AnthropicClaude\\\\claude.exe"

URUNFILE="\$(winepath -u "\$RUNFILE")"
if [ ! -f "\$URUNFILE" ] ; then
    INSTALLER="$PRODUCTDIR/$INSTALLER"
    exec wine "\$INSTALLER"
fi
exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 .$PRODUCTDIR/run.sh

cp $TAR .$PRODUCTDIR
erc pack $PKGNAME opt/eepm-wine

return_tar $PKGNAME
