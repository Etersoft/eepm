#!/bin/sh

PKGNAME=rutokenlogon
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Rutoken Logon (OS and domain logon with Rutoken) from the official site"
URL="https://www.rutoken.ru/products/all/rutoken-logon-linux/"

. $(dirname $0)/common.sh

base_url="https://download.rutoken.ru/Rutoken_Logon_for_Linux"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$base_url/" | grep -o 'href="[0-9][0-9.]*/"' | sed -e 's|href="\(.*\)/"|\1|' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get version."
fi

url="$base_url/$VERSION/packages"

arch="$(epm print info -a)"
case "$(epm print info -p)" in
    rpm)
        if [ "$(epm print info -s)" = "alt" ] ; then
            # https://download.rutoken.ru/Rutoken_Logon_for_Linux/1.1.0/packages/rutokenlogon-1.1.0-alt1.x86_64.rpm
            PKGURL="$url/rutokenlogon-$VERSION-alt1.$arch.rpm"
        else
            # https://download.rutoken.ru/Rutoken_Logon_for_Linux/1.1.0/packages/rutokenlogon-1.1.0-1.x86_64.rpm
            PKGURL="$url/rutokenlogon-$VERSION-1.$arch.rpm"
        fi
        ;;
    *)
        # https://download.rutoken.ru/Rutoken_Logon_for_Linux/1.1.0/packages/rutokenlogon_1.1.0-1_amd64.deb
        PKGURL="$url/rutokenlogon_$VERSION-1_$(epm print info --debian-arch).deb"
        ;;
esac

if [ -z "$print_url" ] ; then
    # Rutoken Logon license is checked by Guardant Control Center
    epm installed grdcontrol || epm play grdcontrol || fatal "Can't install Guardant Control Center (grdcontrol)."
fi

install_pkgurl || exit

cat <<EOF

Note: Rutoken Logon is installed, but the system logon is not configured.
1. Activate the Guardant DL license for rtlogon with Guardant License Wizard (license_wizard)
   on the license server: this PC (serv grdcontrol on) or another host available by port 3189.
2. The rtlogon greeter and lock screen need LightDM (epm install lightdm),
   otherwise use the system ones: rtlogon-cli configure ... --use-system-gui yes
   For domain 2FA join the PC to the domain first (sssd, Kerberos PKINIT; task-auth-ad-sssd for AD).
   For JaCarta tokens install libjcpkcs11 and copy libjcPKCS11-2.so to /opt/aktivco/rtlogon/pkcs/
3. Configure the logon as root, for example:
   # rtlogon-cli configure --local --license-server 127.0.0.1
   # rtlogon-cli configure --domain ad --license-server <host> --ca-cert <ca.pem>
   then back up /etc/rtlogon/rtlogon.conf (it is needed to unconfigure).
   The rtlogon_log service (logging) can be enabled with: serv rtlogon_log on
Before removing the package run as root
   # rtlogon-cli unconfigure
and reboot to restore the original PAM configuration.
Documentation: $base_url/$VERSION/documentation/
EOF
