#!/bin/sh

PKGNAME=angie
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="ANGIE (a web server, that was forked from nginx) from the official site"
REPOURL="https://angie.software/"

. $(dirname $0)/common.sh

reponame=$(epm print info --repo-name)
vendor=$(epm print info -s)
version=$(epm print info --base-version)

# Strict supported list
case $(epm print info -e) in
    Alpine/3.14|Alpine/3.15|Alpine/3.16|Alpine/3.17)
        epm install --skip-installed curl ca-certificates
        epm repo addkey "https://angie.software/keys/angie-signing.rsa"
        epm repo add "https://download.angie.software/angie/alpine/v$version/main"
        ;;
    ALTLinux/p10|ALTServer/10|MOS/10|ALTLinux/Sisyphus)
        epm install --skip-installed curl apt-https
        epm repo addkey "https://angie.software/keys/angie-signing.gpg" "EB8EAF3D4EF1B1ECF34865A2617AB978CB849A76" "Angie (Signing Key) <devops@tech.wbsrv.ru>" angie
        epm repo add "rpm [angie] https://download.angie.software/angie/altlinux/10/ x86_64 main"
        ;;
    CentOS/8|CentOS/9)
        epm repo addkey 'https://download.angie.software/angie/centos/$releasever/' "https://angie.software/keys/angie-signing.gpg" "Angie repo" angie
        #epm repo add 'https://download.angie.software/angie/centos/$releasever/'
        ;;
    Debian/10|Debian/11)
        epm install --skip-installed ca-certificates curl lsb-release
        epm repo addkey "https://angie.software/keys/angie-signing.gpg"
        epm repo add "deb https://download.angie.software/angie/debian/ $reponame main"
        ;;
    Oracle/8|Oracle/9)
        epm repo addkey 'https://download.angie.software/angie/oracle/$releasever/' "https://angie.software/keys/angie-signing.gpg" "Angie repo" angie
        #epm repo add 'https://download.angie.software/angie/oracle/$releasever/'
        ;;
    RedOS/7.3)
        epm repo addkey "https://download.angie.software/angie/redos/73/" "https://angie.software/keys/angie-signing.gpg" "Angie repo" angie
        #epm repo add "https://download.angie.software/angie/redos/73/"
        ;;
    RockyLinux/8|RockyLinux/9)
        epm repo addkey 'https://download.angie.software/angie/rocky/$releasever/' "https://angie.software/keys/angie-signing.gpg" "Angie repo" angie
        #epm repo add 'https://download.angie.software/angie/rocky/$releasever/'
        ;;
    Ubuntu/20.04|Ubuntu/22.04)
        epm install --skip-installed ca-certificates curl lsb-release
        epm repo addkey "https://angie.software/keys/angie-signing.gpg"
        epm repo add "deb https://download.angie.software/angie/ubuntu/ $reponame main"
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac


epm update
epm install $PKGNAME || exit

cat <<EOF

Note:
You can use serv command for start Angie service:
    # serv angie start
To make sure Angie starts on server reboot, run:
    # serv angie on
Also you can install an addional modules:
    # epm install angie-module-<module>

Angie repository provides following dynamic module packages:
  angie-module-auth-spnego
  angie-module-brotli
  angie-module-dav-ext
  angie-module-geoip2
  angie-module-headers-more
  angie-module-image-filter
  angie-module-ndk
  angie-module-njs
  angie-module-perl
  angie-module-rtmp
  angie-module-set-misc
  angie-module-xslt
EOF
