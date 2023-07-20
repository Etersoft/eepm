#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=bitrix24
PRODUCTCUR=Bitrix24
PRODUCTDIR=/opt/$PRODUCTCUR

UNIREQUIRES='libnotify.so.4'

. $(dirname $0)/common.sh

remove_dir /etc/apt/sources.list.d
remove_dir /etc/yum.repos.d
remove_dir /etc/apt/trusted.gpg.d

add_bin_exec_command $PRODUCTCUR $PRODUCTDIR/$PRODUCTCUR
add_bin_exec_command $PRODUCTCUR-web $PRODUCTDIR/$PRODUCTCUR-web
add_bin_link_command $PRODUCT $PRODUCTCUR
add_bin_link_command $PRODUCT-web $PRODUCTCUR-web
