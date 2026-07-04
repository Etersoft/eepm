#!/bin/sh

# Generic pack handler for a self-contained flatpak bundle (.flatpak).
# Analogous to generic-appimage: any Class A flatpak app (browsers, Electron —
# apps that run on system libs without the freedesktop runtime) is packed into a
# native package with no app-specific script.
#
# A .flatpak bundle is an ostree static delta; erc unpacks it via ostree alone
# (no flatpak needed) and yields <appid>/ with the /app payload (bin/, lib/,
# share/). The flatpak metadata file is NOT part of that payload, so the app id
# and the launch command are recovered from share/applications/<appid>.desktop.
#
# Apps needing the freedesktop Platform runtime (Class B) or special launch
# flags are out of scope — write an app-specific pack.d/<name>.sh for those.

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

rhas "$TAR" "\.flatpak$" || fatal "Not a .flatpak bundle: $TAR"

# erc unpacks flatpak via ostree; make sure the tool is available.
# (Safe wrt RPM shell.req: it sees `epm', not `ostree'. ostree itself is called
# inside erc, never directly here — see reference_hide_cmds_from_shell_req.)
epm assure ostree || fatal "Can't assure ostree (needed to unpack flatpak)"

# unpack -> a single <name>/ directory holding the /app payload
erc unpack "$TAR" || fatal "Can't unpack flatpak bundle $TAR"

# a flatpak payload is exactly one directory
set -- */
[ $# -eq 1 ] || fatal "Expected a single directory from $TAR, got $#"
APPDIR="${1%/}"
[ -d "$APPDIR" ] || fatal "Can't find unpacked app directory"

# recover the app id from the desktop file flatpak ships under share/applications
set -- "$APPDIR"/share/applications/*.desktop
DESKTOP="$1"
[ -r "$DESKTOP" ] || fatal "Can't find .desktop in $APPDIR/share/applications (not a Class A flatpak?)"

APP_ID="$(basename "$DESKTOP" .desktop)"
PRODUCT="${APP_ID##*.}"
[ -n "$PRODUCT" ] || PRODUCT="$APP_ID"

# the launch command: first token of Exec=, with any /app/bin/ prefix stripped
COMMAND="$(grep '^Exec=' "$DESKTOP" | head -n1 | sed -e 's|^Exec=||' -e 's| .*||' -e 's|.*/||')"
[ -n "$COMMAND" ] || fatal "Can't read Exec= from $DESKTOP"

# Class A self-contained app tree lives under lib/<command> (Firefox/Electron).
# Anything else needs an app-specific pack.d script.
APP_TREE=''
for c in "$APPDIR/lib/$COMMAND" "$APPDIR/lib/$PRODUCT" ; do
    [ -d "$c" ] && APP_TREE="$c" && break
done
# fallback: the single directory under lib/
if [ -z "$APP_TREE" ] ; then
    for d in "$APPDIR/lib/"*/ ; do APP_TREE="${d%/}" ; break ; done
fi
[ -n "$APP_TREE" ] && [ -d "$APP_TREE" ] || fatal "Can't locate self-contained app tree under $APPDIR/lib (Class A only; write pack.d/$PRODUCT.sh)"

# version: explicit, then Firefox-class application.ini, then give up
if [ -z "$VERSION" ] && [ -r "$APP_TREE/application.ini" ] ; then
    VERSION="$(grep '^Version=' "$APP_TREE/application.ini" | head -n1 | cut -d= -f2-)"
fi
[ -n "$VERSION" ] || fatal "Can't detect version of $APP_ID (pass VERSION or add detection in pack.d/$PRODUCT.sh)"

# the real executable inside the app tree
BIN="$APP_TREE/$COMMAND"
[ -x "$BIN" ] || fatal "Can't find executable '$COMMAND' in $APP_TREE (expected $APP_TREE/$COMMAND)"

mkdir -p opt/$PRODUCT usr/bin usr/share/applications usr/share/icons

# move the self-contained app tree to /opt/$PRODUCT.
# NB: the flatpak bin/ launchers (shell scripts calling flatpak/ostree) are left
# behind in $APPDIR and never packaged — they would leak Requires into the app
# package and are replaced by the native /usr/bin/$PRODUCT wrapper below.
mv "$APP_TREE" opt/$PRODUCT

cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
cd /opt/$PRODUCT || exit 1
exec ./$COMMAND "\$@"
EOF
chmod 755 usr/bin/$PRODUCT

cp "$DESKTOP" usr/share/applications/$PRODUCT.desktop
subst "s|^Exec=.*|Exec=$PRODUCT|" usr/share/applications/$PRODUCT.desktop
subst "s|^TryExec=.*||" usr/share/applications/$PRODUCT.desktop

[ -d "$APPDIR/share/icons" ] && cp -a "$APPDIR/share/icons/." usr/share/icons/

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $(basename "$TAR")
generic_repack: flatpak
EOF

return_tar $PKGNAME
