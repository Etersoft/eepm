#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rstudio
PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT /usr/lib/rstudio/bin/rstudio

# https://bugzilla.altlinux.org/43794
subst '1iAutoReq:yes,nopython,nopython3,nomono,nomonolib' $SPEC

remove_dir /usr/lib/.build-id

filter_from_requires libQt5 libicu "libpq.so.5(RHPG_9"

epm install --skip-installed libpq5 libsqlite sqlite R-base R-doc-html
