#!/bin/sh

[ "$1" != "--run" ] && echo "Install php8 (or upgrade from php7)" && exit

distro="$($DISTRVENDOR -d)" ; [ "$distro" = "ALTLinux" ] || [ "$distro" = "ALTServer" ] || { echo "Only ALTLinux is supported" ; exit 1 ; }

# TODO: check for apache2-mod_php7

if epmqp --quiet php7- ; then
    # Upgrade if was installed php5
    epmqp php7 --short | sed -e "s|php7-http||" -e "s|php7-raphf||" -e "s|php7-propro||" -e "s|php7-memcache||" -e "s|php7|php8.1|" | epmi --auto

    epme php7-libs
else
    # Install all packages
    epmi php8 php8-mbstring php8-pdo php8-curl php8-fileinfo php8-dom php8-exif php8-pdo_mysql php8-mysqli php8-pcntl php8-openssl php8-mcrypt php8-gd2 php8-xmlreader php8-memcached php8-xsl php8-zip php8-redis php8-opcache
    #echo "Think twice about php8-imagick. See https://bugzilla.altlinux.org/show_bug.cgi?id=39033"
fi
