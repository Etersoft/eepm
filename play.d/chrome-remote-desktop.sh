#!/bin/sh

PKGNAME=chrome-remote-desktop
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Remote desktop support for google-chrome & chromium"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKGURL="https://dl.google.com/linux/direct/${PKGNAME}_current_$arch.$pkgtype"

install_pkgurl

echo '
run crd --setup
(Optional) Configure execution of your preferred window manager in ~/.chrome-remote-desktop-session
Go to http://remotedesktop.google.com/headless
Click "next" and "authorize" through each instruction
Copy/paste and run the provided "Debian" command, which should look like the following: DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="<UNIQUE_CODE>" --redirect-url="<https://remotedesktop.google.com/_/oauthredirect>" --name=
Set up a name and PIN
Wait for successful output containing "Host ready to receive connections."
Run crd --start
'
