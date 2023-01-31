#!/bin/sh

[ "$1" != "--run" ] && echo "Install php8.1 (or upgrade from a previous version)" && exit

distrbase="$($DISTRVENDOR -s)" ; [ "$distrbase" = "alt" ] || { echo "Only ALTLinux is supported as for now" ; exit 1 ; }

if epmqp --quiet php7- ; then
    # Upgrade all installed php7
    epmi $(epmqp php7 --short | grep -v "rpm-build-php"| grep -E -v "php7-(http|xmlrpc|krb5|raphf|propro|enchant|geioip)" | sed -e "s|php7-apcu_bc$||" -e "s|php7-pdo_sqlsrv$||" -e "s|php7-sqlsrv$||" -e "s|php7|php8.1|") #"
else
    # Install all packages
    epmi php8.1 php8.1-mbstring php8.1-pdo php8.1-curl php8.1-fileinfo php8.1-dom php8.1-exif php8.1-pdo_mysql php8.1-mysqli php8.1-pcntl php8.1-openssl php8.1-mcrypt php8.1-gd2 php8.1-xmlreader php8.1-memcached php8.1-xsl php8.1-zip php8.1-redis php8.1-opcache
    #echo "Think twice about php8.1-imagick. See https://bugzilla.altlinux.org/show_bug.cgi?id=39033"
fi
