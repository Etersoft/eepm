#!/bin/sh

[ "$1" != "--run" ] && echo "Install php8.0 (or upgrade from php7)" && exit

distro="$($DISTRVENDOR -d)" ; [ "$distro" = "ALTLinux" ] || [ "$distro" = "ALTServer" ] || { echo "Only ALTLinux is supported" ; exit 1 ; }

# TODO: check for apache2-mod_php7

if epmqp --quiet php7- ; then
    # Upgrade if was installed php7
    epmqp php7 --short | grep -v "rpm-build-php" | sed  -e "s|php7-http||" -e "s|php7-xmlrpc||" -e "s|php7-krb5||" -e "s|php7-raphf||" -e "s|php7-propro||" -e "s|php7-memcache$||" -e "s|php7-apcu_bc$||" -e "s|php7-enchant||" -e "s|php7-pdo_sqlsrv$||" -e "s|php7-sqlsrv$||" -e "s|php7-geoip||" -e "s|php7|php8.0.1|" | epmi --auto

    epme php7-libs
else
    # Install all packages
    epmi php8.0 php8.0-mbstring php8.0-pdo php8.0-curl php8.0-fileinfo php8.0-dom php8.0-exif php8.0-pdo_mysql php8.0-mysqli php8.0-pcntl php8.0-openssl php8.0-mcrypt php8.0-gd2 php8.0-xmlreader php8.0-memcached php8.0-xsl php8.0-zip php8.0-redis php8.0-opcache
    #echo "Think twice about php8.0-imagick. See https://bugzilla.altlinux.org/show_bug.cgi?id=39033"
fi
