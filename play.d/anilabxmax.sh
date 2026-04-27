#!/bin/sh

PKGNAME=anilabxmax
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AniLabX MAX - PC app for watching anime/dramas/cartoons and reading manga/comics/light novels"
URL="https://anilabx.xyz"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/AniLabX/AniLabXMAX/" "AniLabXMAX_v${VERSION}_linux64")

install_pack_pkgurl
