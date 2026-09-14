#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"
PKGROOT="$PWD/1c83-client-root"
PK1CV8_CREATED=''

. $(dirname $0)/common.sh
. $(dirname $0)/../repack.d/common-1c-enterprise.sh

# unpack if something like server64_8_3_22_1851.tar.gz
if echo "$(basename "$FILENAME")" | grep -q "^server.._8_3.*tar\.gz$" ; then
    echo "Tarball detected, unpacking ..."
    erc --here "$FILENAME" || fatal
    # server64_8_3_22_1851.tar
    FILENAME="$(echo server*/setup-full-8.*.run)"
fi

# with run with setup-full.*.run or setup-training.*.run file
case "$(basename "$FILENAME")" in
    setup-full-8.*-*.run|setup-training-8.*-*.run) ;;
    *) fatal "run with file looks like setup-full-8.3.22.1851-x86_64.run or setup-training-8.5.1.1150-x86_64.run" ;;
esac


case "$(basename "$FILENAME")" in
    setup-training-*) INSTDIR="/opt/1cv8t" ;;
    *) INSTDIR="/opt/1cv8" ;;
esac
VERSION="$(echo $FILENAME | sed 's|.*-8|8|' | sed 's|-.*||')"
TARNAME="1c83-client-$VERSION.tar"
HOST_CONFDIR_WAS_PRESENT=''

run_root_command()
{
    if [ "$(id -u)" = 0 ] ; then
        "$@"
    else
        esu "$@"
    fi
}

chmod -v u+x $FILENAME
# По умолчанию устанавливается только "client_full,langs,en,ru,advanced". Все остальные компоненты по умолчанию отключены.
# Задана тихая установка.
rm -rf "$PKGROOT" || fatal
[ -e /usr/local/bin/pk1cv8 ] || PK1CV8_CREATED=1
[ -e "$INSTDIR/conf" ] && HOST_CONFDIR_WAS_PRESENT=1
run_root_command "$(realpath "$FILENAME")" --mode unattended --prefix "$PKGROOT" || {
    [ -d "$PKGROOT$INSTDIR" ] || fatal "Can't install"
}
[ -z "$PK1CV8_CREATED" ] || rm -f /usr/local/bin/pk1cv8
[ -n "$HOST_CONFDIR_WAS_PRESENT" ] || run_root_command rm -rf "$INSTDIR/conf"

if echo "$FILENAME" | grep -q "x86_64.run$" ; then
    arch="x86_64"
elif echo "$FILENAME" | grep -q "i586.run$"; then
    arch="i586"
else
    fatal "Unsupported arch"
fi

[ -d "$PKGROOT$INSTDIR/$arch/$VERSION" ] || fatal "Can't detect installed 1C files in $PKGROOT$INSTDIR/$arch/$VERSION"

__1c_enterprise_remove_bundled_runtime_libs_from_root "$PKGROOT"

rm -rf "$PKGROOT$INSTDIR/conf" "$PKGROOT$INSTDIR/$arch/$VERSION/conf" || fatal

command -v tar >/dev/null 2>&1 || epm install --skip-installed tar || fatal
( cd "$PKGROOT" && tar cf "../$TARNAME" opt usr ) || fatal

return_tar $TARNAME
