#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# the release ships a versionless AppleColorEmoji.ttf; fall back to the file
# mtime (preserved by eget), then to a known release version
[ "$VERSION" = "*" ] && VERSION=""
[ -n "$VERSION" ] || VERSION="$(date -u -r "$TAR" +%Y.%m.%d 2>/dev/null)"
[ -n "$VERSION" ] || VERSION="18.4"

PKGNAME=$PRODUCT-$VERSION

# the download is a single raw TTF font, not an archive
install -D -m644 "$TAR" usr/share/fonts/ttf/apple-color-emoji/AppleColorEmoji.ttf || fatal

# fontconfig rules to make the emoji font available to applications
cat <<'EOF' | create_file usr/share/fontconfig/conf.avail/75-apple-color-emoji.conf
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="pattern">
        <test qual="any" name="family"><string>emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test name="family"><string>sans</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test name="family"><string>serif</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test name="family"><string>sans-serif</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test name="family"><string>monospace</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>Noto Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>
</fontconfig>
EOF

# enable the fontconfig rule
mkdir -p etc/fonts/conf.d || fatal
ln -sf /usr/share/fontconfig/conf.avail/75-apple-color-emoji.conf etc/fonts/conf.d/75-apple-color-emoji.conf || fatal

erc pack $PKGNAME.tar usr etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Fonts
license: custom
url: https://github.com/samuelngs/apple-emoji-linux
summary: Apple Color Emoji font for Linux
description: Apple Color Emoji font for Linux with fontconfig rules to use it as the system emoji font.
provides: emoji-font
requires: fontconfig
EOF

return_tar $PKGNAME.tar
