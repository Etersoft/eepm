#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/eepm-wine/$PRODUCT/

cat <<EOF >opt/eepm-wine/$PRODUCT/run.sh
#!/bin/sh
INSTALLER="/opt/eepm-wine/yandex-telemost/TelemostSetup.exe"

# Yandex Telemost installs under %localappdata% (not %appdata%) into a
# per-version subdir; search both (Local first) for the installed exe so we
# don't relaunch the installer on every run
RUNFILE=
for var in %localappdata% %appdata% ; do
    base=\$(winepath -u "\$(wine cmd /c echo \$var | tr -d '\r')" 2>/dev/null) || continue
    RUNFILE=\$(find "\$base" -name YandexTelemost.exe 2>/dev/null | head -1)
    [ -n "\$RUNFILE" ] && break
done

if [ -z "\$RUNFILE" ] || [ ! -f "\$RUNFILE" ] ; then
    # not installed yet: run the installer with winemenubuilder disabled so it
    # does not create a duplicate menu shortcut (we ship our own .desktop)
    exec env WINEDLLOVERRIDES="winemenubuilder.exe=" wine "\$INSTALLER"
fi
exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 opt/eepm-wine/$PRODUCT/run.sh

cp $TAR opt/eepm-wine/$PRODUCT/
erc pack $PKGNAME opt/eepm-wine

return_tar $PKGNAME
