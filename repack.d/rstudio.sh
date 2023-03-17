#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rstudio
PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT

# fix bug in upstream
subst 's|/usr/lib/rstudio/bin/rstudio|$PRODUCTDIR/$PRODUCT|' $BUILDROOT$PRODUCTDIR/resources/app/bin/rstudio-backtrace.sh

# https://bugzilla.altlinux.org/43794
subst '1iAutoReq:yes,nopython,nopython3,nomono,nomonolib' $SPEC

remove_dir /usr/lib/.build-id

filter_from_requires libQt5 libicu "libpq.so.5(RHPG_9"

#if [ "$(epm print info -e)" = "ALTLinux/p10" ] ; then
# version `GLIBC_2.34' not found
# version `GLIBCXX_3.4.29' not found
#    rm -v $BUILDROOT/usr/lib/rstudio/resources/app/bin/{diagnostics,rpostback,rsession}
#fi

epm install --skip-installed libpq5 libsqlite sqlite R-base R-doc-html
