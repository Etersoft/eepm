#!/bin/sh

PKGNAME=everty-desk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Everty Desk - remote access (RustDesk based) from the official site"
URL="https://desk.everty.ru/"

. $(dirname $0)/common.sh

# the deb package is named rustdesk, use our repack script
export EPM_REPACK_SCRIPT="$PKGNAME"

# the vendor publishes only the latest client
warn_version_is_not_supported

API_URL="https://desk.everty.ru/admin/public/published-clients"

# get "id version" of the published Linux deb client
client="$(fetch_url "$API_URL" | epm --inscript --quiet tool json -b | awk -F'\t' '
    $1 ~ /^\["data",[0-9]+,"(id|platform|version|file_name)"\]$/ {
        split($1, a, ",") ; n = a[2] ; f = a[3] ; gsub(/[]"]/, "", f) ; gsub(/"/, "", $2)
        v[n, f] = $2 ; idx[n] = 1
    }
    END {
        for (n in idx)
            if (v[n, "platform"] == "linux" && v[n, "file_name"] ~ /\.deb$/) {
                print v[n, "id"], v[n, "version"] ; exit
            }
    }')"

id="$(echo "$client" | cut -d' ' -f1)"
LATEST_VERSION="$(echo "$client" | cut -d' ' -f2)"
[ -n "$id" ] && [ -n "$LATEST_VERSION" ] || fatal "Can't get Linux client info from $API_URL"

[ "$VERSION" = "*" ] || [ "$VERSION" = "$LATEST_VERSION" ] || info "Version $VERSION is not available, using the latest $LATEST_VERSION"
VERSION="$LATEST_VERSION"

DOWNLOAD_URL="https://desk.everty.ru/admin/public/published-clients/download/$id"

if [ -n "$print_url" ] ; then
    echo "$DOWNLOAD_URL"
    exit 0
fi

cd_to_temp_dir

# the URL has no file extension, so save it with a proper name
PKGURL="$PKGNAME-$VERSION.deb"
eget -O "$PKGURL" "$DOWNLOAD_URL" || fatal

install_pkgurl || exit

cat <<EOF

Note: run
# serv rustdesk on
to enable needed Everty Desk system service (daemon)
EOF
