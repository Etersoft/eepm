#!/bin/sh

PKGNAME=horizon-launcher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Horizon launcher for Minecraft: Java Edition rewritten in Rust"
URL="https://github.com/horizon-rust/horizon"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # App and launcher releases share this repository. Walk all release pages
    # until the newest launcher tag is found, rather than using releases/latest.
    get_launcher_url()
    {
        local page=1 info item tag
        while : ; do
            info=$(fetch_url "https://api.github.com/repos/horizon-rust/horizon/releases?per_page=100&page=$page") || return 1
            item=0
            while [ "$item" -lt 100 ] ; do
                tag=$(echo "$info" | parse_json_value "[$item,\"tag_name\"]") || return 1
                [ -n "$tag" ] || break
                case "$tag" in
                    launcher@*)
                        echo "$URL/releases/download/$tag/horizon-launcher-linux-x86_64.tar.gz"
                        return 0
                        ;;
                esac
                item=$((item + 1))
            done
            [ "$item" -eq 100 ] || return 1
            page=$((page + 1))
        done
    }
    PKGURL=$(get_launcher_url) || fatal "Cannot find the latest Horizon launcher release"
else
    PKGURL="$URL/releases/download/launcher@$VERSION/horizon-launcher-linux-x86_64.tar.gz"
fi

install_pack_pkgurl
