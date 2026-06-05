#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# allow .appimage extension
if rhas "$TAR" "\.appimage$" ; then
    newtarname="${TAR/.appimage/.AppImage}"
    mv "$TAR" "$newtarname"
    TAR="$newtarname"
fi

if ! rhas "$TAR" "\.AppImage$" ; then
    fatal "No idea how to handle $TAR"
fi

alpkg=$(basename $TAR)

PRODUCT="$(basename $alpkg .AppImage)"

# BASEDIR is the unpacked directory (full name without extension)
BASEDIR="$PRODUCT"

# unpack AppImage into BASEDIR
erc --here -C $BASEDIR unpack $TAR || fatal

# strip architecture, OS and build type suffix from PRODUCT name
PRODUCT="${PRODUCT/-x86_64/}"
PRODUCT="${PRODUCT/-x86-64/}"
PRODUCT="${PRODUCT/-aarch64/}"
PRODUCT="${PRODUCT/-arm64/}"
PRODUCT="${PRODUCT/-x64/}"
PRODUCT="${PRODUCT/-linux64/}"
PRODUCT="${PRODUCT/-Linux/}"
PRODUCT="${PRODUCT/-linux/}"
PRODUCT="${PRODUCT/-stable/}"
# same suffixes with underscore separator (e.g. ElegooSlicer_Linux_V1.5.0.7)
PRODUCT="${PRODUCT/_x86_64/}"
PRODUCT="${PRODUCT/_Linux/}"
PRODUCT="${PRODUCT/_linux/}"

# try separate VERSION from PRODUCT
if [ -z "$VERSION" ] ; then
    # match version with optional v/V prefix and pre-release suffix like -b1, -rc1, -beta
    vermatch="$(echo "$PRODUCT" | grep -o -P "[-_.][vV]?[0-9]+(?:\.[0-9]+)*(?:-(?:alpha|beta|rc|b|a|pre|dev|nightly)[0-9]*)?" | head -n1)"
    # strip the whole matched part (separator and v prefix included) from PRODUCT
    [ -n "$vermatch" ] && PRODUCT="$(echo "$PRODUCT" | sed -e "s|$vermatch.*||")"
    [ -n "$vermatch" ] && VERSION="$(echo "$vermatch" | sed -e 's|^[-_.]||' -e 's|^[vV]||')"
else
    # VERSION is already known, but PRODUCT may still contain it — strip version from PRODUCT
    vermatch="$(echo "$PRODUCT" | grep -o -P "[-_.][vV]?[0-9]+(?:\.[0-9]+)*" | head -n1)"
    [ -n "$vermatch" ] && PRODUCT="$(echo "$PRODUCT" | sed -e "s|$vermatch.*||")"
fi


DESKTOPFILE="$(echo $BASEDIR/*.desktop | head -n1)"

# try get version from X-AppImage-Version
if [ -z "$VERSION" ] ; then
    str="$(grep '^X-AppImage-Version=[0-9]' $DESKTOPFILE)"
    if [ -n "$str" ] ; then
        VERSION="$(echo $str | sed -e 's|.*X-AppImage-Version=||')"
    fi
fi

# try get version from URL
# https://github.com/neovide/neovide/releases/download/0.12.2/neovide.AppImage
if [ -z "$VERSION" ] && rhas "$URL" "github.com.*/releases/download" ; then
    VERSION="$(echo "$URL" | sed -e 's|.*/releases/download/||' -e "s|/$alpkg||")"
fi

[ -n "$VERSION" ] || fatal "Can't get version from $TAR. You can rename the file like name-version.AppImage. Please, inform upstream about https://docs.appimage.org/reference/desktop-integration.html (X-AppImage-Version field)"

PKGNAME=$PRODUCT-$VERSION.tar

# get first occurrence of XML tag value from file
get_xml_tag() {
    grep "<$1>" "$2" | head -1 | sed "s|.*<$1>||;s|</${1%% *}>.*||"
}

if [ -f "$DESKTOPFILE" ] ; then
    yaml_summary="$(grep '^Comment=' "$DESKTOPFILE" | head -1 | sed 's/^Comment=//')"
fi

APPDATAFILE="$(find $BASEDIR -maxdepth 5 \( -name '*.appdata.xml' -o -name '*.metainfo.xml' \) -type f 2>/dev/null | head -1)"
if [ -f "$APPDATAFILE" ] ; then
    [ -n "$yaml_summary" ] && yaml_summary="$(get_xml_tag 'summary' "$APPDATAFILE")"
    yaml_license="$(get_xml_tag 'project_license' "$APPDATAFILE")"
    yaml_url="$(get_xml_tag 'url type="homepage"' "$APPDATAFILE")"
fi

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $alpkg
generic_repack: appimage
EOF
[ -n "$yaml_summary" ] && echo "summary: $yaml_summary" >> $PKGNAME.eepm.yaml
[ -n "$yaml_license" ] && echo "license: $yaml_license" >> $PKGNAME.eepm.yaml
[ -n "$yaml_url" ] && echo "url: $yaml_url" >> $PKGNAME.eepm.yaml

chmod og-w -R $BASEDIR
chmod a+rX -R $BASEDIR

# fix ELF executables permissions (7z doesn't preserve permissions from squashfs)
find $BASEDIR -type f -perm 0644 -exec file -N {} + | grep 'ELF.*executable' | cut -d: -f1 | xargs -r chmod -v a+x

erc pack $PKGNAME $BASEDIR

return_tar $PKGNAME
