#!/bin/sh

[ "$1" != "--run" ] && echo "Install php8.1 (or upgrade from a previous version)" && exit

distrbase="$($DISTRVENDOR -s)" ; [ "$distrbase" = "alt" ] || { echo "Only ALTLinux is supported as for now" ; exit 1 ; }

if epmqp --quiet php7- ; then
    # Upgrade all installed php7
    epmi $(epmqp php7 --short | grep -v "rpm-build-php"| grep -E -v "php7-(http|xmlrpc|krb5|raphf|propro|enchant|geioip)" | sed -e "s|php7-apcu_bc$||" -e "s|php7-pdo_sqlsrv$||" -e "s|php7-sqlsrv$||" -e "s|php7|php8.0|") #"
else
    # Install all packages
    epmi php8.0 php8.0-mbstring php8.0-pdo php8.0-curl php8.0-fileinfo php8.0-dom php8.0-exif php8.0-pdo_mysql php8.0-mysqli php8.0-pcntl php8.0-openssl php8.0-mcrypt php8.0-gd2 php8.0-xmlreader php8.0-memcached php8.0-xsl php8.0-zip php8.0-redis php8.0-opcache
    #echo "Think twice about php8.0-imagick. See https://bugzilla.altlinux.org/show_bug.cgi?id=39033"
fi
