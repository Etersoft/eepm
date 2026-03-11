#!/bin/sh

PKGNAME=openvpn
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="OpenVPN - open source VPN daemon from the official repo"
URL="https://openvpn.net/"

. $(dirname $0)/common.sh

reponame=$(epm print info --repo-name)

GPGKEY="https://build.openvpn.net/debian/openvpn/stable/pubkey.gpg"

case $(epm print info -e) in
    Debian/*)
        epm install --skip-installed ca-certificates lsb-release
        epm repo addkey openvpn "$GPGKEY"
        epm repo add --disabled --name openvpn "deb https://build.openvpn.net/debian/openvpn/stable $reponame main"
        epm install openvpn/$PKGNAME || exit
        ;;
    Ubuntu/*)
        epm install --skip-installed ca-certificates lsb-release
        epm repo addkey openvpn "$GPGKEY"
        epm repo add --disabled --name openvpn "deb https://build.openvpn.net/debian/openvpn/stable $reponame main"
        epm install openvpn/$PKGNAME || exit
        ;;
    Fedora/*|CentOS/*|RHEL/*|RockyLinux/*|AlmaLinux/*)
        epm repo add copr/@OpenVPN/openvpn-release-2.6
        epm update
        epm install $PKGNAME || exit
        ;;
    *)
        # For ALT Linux and other distros, install from the standard repo
        epm install $PKGNAME || exit
        ;;
esac

cat <<EOF

Note:
You can use serv command for start OpenVPN service:
    # serv openvpn start
To make sure OpenVPN starts on server reboot, run:
    # serv openvpn on
EOF
