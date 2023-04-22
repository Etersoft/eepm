#!/bin/sh

PKGNAME=ClipGrab
SUPPORTEDARCHES="x86_64"
DESCRIPTION="ClibGrab - A friendly downloader for YouTube and other sites from the official site"
URL="https://clipgrab.org/"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest https://clipgrab.org/ "ClipGrab-*-x86_64.AppImage")"

epm install $PKGURL
