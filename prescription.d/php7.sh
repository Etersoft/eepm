#!/bin/sh

[ "$1" != "--run" ] && echo "Install php7 (or upgrade from php5)" && exit

if epmqp --quiet php5- ; then
    # Upgrade if was installed php5
    epmqp php5 --short | grep -E -v "(php5-mysql|suhosin|timezonedb|zend-optimizer|mongo|xdebug|openid)" | sed -e "s|php5|php7|" | epmi --auto

    # (потребовалось для обновления, добавил в зависимости)
    epmi php7-fileinfo

    epme php5-libs
else
    # Install all packages
    epmi php7 php7-mbstring php7-pdo php7-curl php7-fileinfo php7-dom php7-exif php7-pdo_mysql php7-mysqli php7-pcntl php7-openssl php7-mcrypt php7-gd2 php7-xmlreader php7-memcached php7-xsl php7-zip php7-redis php7-opcache
    echo "Think twice about php7-imagick. See https://bugzilla.altlinux.org/show_bug.cgi?id=39033"
fi
