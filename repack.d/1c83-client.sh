#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# source file: 1c83-client-8.3.22.1851.tar

PRODUCT=1c83-client

PREINSTALL_PACKAGES="glib2 libatk libcairo libcairo-gobject libcom_err libcups libenchant libgdk-pixbuf libgio libGL libgst-plugins1.0 libgstreamer1.0 libgtk+3 libharfbuzz-icu libkrb5 libpango libSM libsoup libunwind libX11 libXcomposite libXdamage libXrender libXt"

. $(dirname $0)/common.sh
. $(dirname $0)/common-1c-enterprise.sh

if [ -d "$BUILDROOT/opt/1cv8t" ] ; then
    PRODUCTDIR=/opt/1cv8t
    PRODUCTSUMMARY="1C Training Client"
    STARTER=1cestartt
    COMMANDS="1cv8t 1cv8ct 1cv8st"
else
    PRODUCTDIR=/opt/1cv8
    PRODUCTSUMMARY="1C Client"
    STARTER=1cestart
    COMMANDS="1cv8 1cv8c 1cv8s"
fi

# installing from tar, so we need fill some fields here
subst "s|^Group:.*|Group: Office|" $SPEC
subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^URL:.*|URL: https://1c.ru|" $SPEC
subst "s|^Summary:.*|Summary: $PRODUCTSUMMARY|" $SPEC

#remove_file /usr/local/bin/$PRODUCT
#add_bin_link_command

if [ -d "$BUILDROOT$PRODUCTDIR/x86_64" ] ; then
    arch="x86_64"
elif [ -d "$BUILDROOT$PRODUCTDIR/i586" ] ; then
    arch="i586"
else
    fatal "Unsupported arch"
fi

VERSION="$(basename "$(echo "$BUILDROOT$PRODUCTDIR"/$arch/8.*.*.* | sed -e 's| .*||')")"
[ -n "$VERSION" ] && [ -d "$BUILDROOT$PRODUCTDIR/$arch/$VERSION" ] || fatal "Can't detect 1C version"
VERSIONDIR="$PRODUCTDIR/$arch/$VERSION"

__1c_enterprise_add_requires
__1c_enterprise_remove_bundled_runtime_libs_from_root "$BUILDROOT"

remove_dir "$PRODUCTDIR/conf"
remove_dir "$VERSIONDIR/conf"

__1c_enterprise_remove_uninstall_desktop_files "$VERSIONDIR"

remove_dir /usr/share/polkit-1

if [ -x "$BUILDROOT$PRODUCTDIR/common/$STARTER" ] ; then
    cat <<EOF | create_exec_file "/usr/bin/$STARTER"
#!/bin/sh
export LD_LIBRARY_PATH="$VERSIONDIR:$PRODUCTDIR/common\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "$PRODUCTDIR/common/$STARTER" "\$@"
EOF
    __1c_enterprise_normalize_desktop_name "$STARTER" "$VERSIONDIR"
    fix_desktop_file "$PRODUCTDIR/common/$STARTER" "$STARTER"
fi

for command in $STARTER $COMMANDS ; do
    __1c_enterprise_normalize_icon_name "$command"
done

for command in $COMMANDS ; do
    [ -x "$BUILDROOT$VERSIONDIR/$command" ] || continue
    __1c_enterprise_normalize_desktop_name "$command" "$VERSIONDIR"
    add_bin_exec_command "$command" "$VERSIONDIR/$command"
    fix_desktop_file "$VERSIONDIR/$command" "$command"
done

remove_dir /usr/share/app-install

epm assure patchelf || exit

for i in $BUILDROOT$PRODUCTDIR/*/*/lib* ; do
    a= patchelf --set-rpath "\$ORIGIN:$PRODUCTDIR/common" $i
done

for i in $BUILDROOT$PRODUCTDIR/common/lib* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done
