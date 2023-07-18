#!/bin/sh

[ "$1" != "--run" ] && echo "Install php8.2 (or upgrade from a previous version)" && exit

. $(dirname $0)/common.sh

distrbase="$(epm print info -s)" ; [ "$distrbase" = "alt" ] || { echo "Only ALTLinux is supported as for now" ; exit 1 ; }

# TODO: check for apache2-mod_php7

if epmqp --quiet php7- ; then
    # Upgrade all installed php7
    epmi $(epmqp php7 --short | grep -v "rpm-build-php"| grep -E -v "php7-(http|xmlrpc|krb5|raphf|propro|enchant|geioip)" | sed -e "s|php7-apcu_bc$||" -e "s|php7-pdo_sqlsrv$||" -e "s|php7-sqlsrv$||" -e "s|php7|php8.2|") #"
else
    # Install all packages
    epmi php8.2 php8.2-mbstring php8.2-pdo php8.2-curl php8.2-fileinfo php8.2-dom php8.2-exif php8.2-pdo_mysql php8.2-mysqli php8.2-pcntl php8.2-openssl php8.2-mcrypt php8.2-gd2 php8.2-xmlreader php8.2-memcached php8.2-xsl php8.2-zip php8.2-redis php8.2-opcache
    #echo "Think twice about php8.2-imagick. See https://bugzilla.altlinux.org/show_bug.cgi?id=39033"
fi
