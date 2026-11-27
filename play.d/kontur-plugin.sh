#!/bin/sh

PKGNAME=kontur.plugin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kontur.Plugin (browser plugin for cryptographic operations in SKB Kontur services) from the official site"
URL="https://help.kontur.ru/plugin/"
TIPS="Kontur.Plugin needs the Kontur.Plugin browser extension (install it from https://install.kontur.ru/) and CryptoPro CSP (install it with 'ecryptomgr install cprocsp', https://github.com/Etersoft/ecryptomgr)."

. $(dirname $0)/common.sh

# file names contain an internal build number, only the latest build is published
warn_version_is_not_supported

case "$(epm print info -p)" in
    deb)
        key="KonturPluginDEB"
        ;;
    *)
        key="KonturPluginRPM"
        ;;
esac

# "KonturPluginRPM":{"fictionFile":"kontur.plugin_amd64.rpm","file":"kontur.plugin.admin.003255.rpm","min_version":"4.16.0.6195","version":"4.16.0.6195","size":14067110}
file="$(fetch_url "$URL" | tr '}' '\n' | grep "\"$key\":{" | head -n1 | sed -e 's|.*"file":"||' -e 's|".*||')"
[ -n "$file" ] || fatal "Can't get $key file name from $URL"

# https://help.kontur.ru/files/kontur.plugin.admin.003255.rpm
PKGURL="https://help.kontur.ru/files/$file"

install_pkgurl || exit

echo
info 'Install the Kontur.Plugin browser extension from https://install.kontur.ru/ and restart the browser.'
info 'Kontur services also need CryptoPro CSP (with token and smart card support). Install it with ecryptomgr install cprocsp'
