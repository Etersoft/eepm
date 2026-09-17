#!/bin/sh

BUILDROOT="$1"
SPEC="$2"

PRODUCT=cromite

. $(dirname $0)/common-chromium-browser.sh

remove_file $PRODUCTDIR/chrome-wrapper
remove_file $PRODUCTDIR/product_logo_48.png

# The upstream wrapper creates a user desktop file and mimeapps.list,
# and tries to add library symlinks in the browser directory. Replace it with a simpler launcher.
cat <<'EOF' | create_exec_file /usr/bin/cromite
#!/bin/bash

usage()
{
    echo "$0 [--gdb] [--help] [--man-page] [--] [chrome-options]"
    echo
    echo '        --gdb                   Start within gdb'
    echo '        --help                  This help screen'
    echo '        --man-page              Open the man page in the tree'
}

CHROME_WRAPPER="/usr/bin/cromite"
HERE="/opt/cromite"

export CHROME_WRAPPER
export CHROME_DESKTOP="cromite.desktop"
export CHROME_VERSION_EXTRA="custom"
export LD_LIBRARY_PATH="$HERE:$HERE/lib:$HERE/lib.target${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

CMD_PREFIX=
ARGS=()
while [ "$#" -gt 0 ]; do
    case "$1" in
    "--")
        shift
        break ;;
    "--gdb")
        CMD_PREFIX="gdb --args" ;;
    "--help")
        usage
        exit 0 ;;
    "--man-page")
        exec man "$HERE/../../chrome/app/resources/manpage.1.in" ;;
    *)
        ARGS=( "${ARGS[@]}" "$1" ) ;;
    esac
    shift
done
set -- "${ARGS[@]}" "$@"

exec $CMD_PREFIX "$HERE/chrome" "$@"
EOF

use_system_xdg

# Upstream ships a Chromium placeholder icon; replace it with the Cromite SVG.
cat <<'EOF' | create_file /usr/share/icons/hicolor/scalable/apps/cromite.svg
<?xml version="1.0" encoding="UTF-8"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg width="200mm" height="200mm" version="1.1" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
 <defs>
  <linearGradient id="linearGradient8220" x2="200" y1="100" y2="100" gradientUnits="userSpaceOnUse">
   <stop stop-color="#67b793" offset="0"/>
   <stop stop-color="#50956d" offset="1"/>
  </linearGradient>
 </defs>
 <g>
  <circle cx="100" cy="100" r="100" fill="url(#linearGradient8220)"/>
  <g fill="#d7f5ec">
   <circle cx="100" cy="100" r="60"/>
   <path d="m181.92 157.36a100 100 0 0 1-24.558 24.558l-57.358-81.915z"/>
   <path d="m157.36 18.085a100 100 0 0 1 24.558 24.558l-81.915 57.358z"/>
   <rect transform="rotate(45)" x="141.42" y="-17.365" width="98.481" height="34.73"/>
   <rect transform="rotate(-45)" x="-8.5459e-7" y="124.06" width="98.481" height="34.73"/>
  </g>
  <circle cx="100" cy="100" r="40" fill="#4a8f62"/>
 </g>
</svg>
EOF

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Cromite Web Browser
Name[ru]=Веб-браузер Cromite
Comment=Chromium fork with ad blocking and privacy enhancements
Icon=$PRODUCT
Exec=$PRODUCT %u
Categories=GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
Terminal=false
GenericName=Web Browser
GenericName[ru]=Веб-браузер
EOF

set_alt_alternatives 65

add_chromium_deps
