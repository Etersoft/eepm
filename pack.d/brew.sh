#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p usr/share/man/man1 etc/bash_completion.d usr/share/zsh/site-functions usr/share/fish/vendor_completions.d opt
mv brew* opt/$PRODUCT

VERSION=$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
[ -n "$VERSION" ] || fatal "Can't get package version"

mv opt/$PRODUCT/manpages/brew.1 usr/share/man/man1/brew.1

mv opt/$PRODUCT/completions/bash/brew etc/bash_completion.d/brew

mv opt/$PRODUCT/completions/zsh/_brew usr/share/zsh/site-functions/_brew

mv opt/$PRODUCT/completions/fish/brew.fish usr/share/fish/vendor_completions.d/brew.fish

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr etc || fatal

return_tar $PKGNAME.tar
