#!/bin/sh

PKGNAME=spo-anketa
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="СПО «Анкета ГС (МС)» для заполнения анкеты госслужащего"
URL="https://gossluzhba.gov.ru/spo/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# gossluzhba.gov.ru publishes only the current version. Choose the package label for
# our OS, and the last known link to fall back to if the site can't be read.
if [ "$(epm print info -p)" = "deb" ] ; then
    spolabel="Astra Linux"
    # SPO_AstraLinux_1_3_3.deb (version 1.3.3 from 17.06.2026)
    fallback_url="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/d72bbb41-137c-4705-a2c9-705bfd27cc7b"
else
    spolabel="RedOS/Alt Linux"
    # SPO_RedOS_AltLinux_1_3_3.rpm (version 1.3.3 from 17.06.2026)
    fallback_url="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/531b32f0-acb4-432a-869c-b1332b4319bd"
fi

# Read the current download URL from the site. It is an Angular SPA with no public
# file API, but the URLs are baked (labelled by OS) into webpack chunk 3468 of its
# build: /spo/ -> runtime.js gives the chunk hash -> the chunk lists the URLs.
sparoot="https://gossluzhba.gov.ru/web-lk-new"
runtime="$(fetch_url "https://gossluzhba.gov.ru/spo/" | grep -o 'runtime\.[a-f0-9]*\.js' | head -1)"
chunkhash="$(fetch_url "$sparoot/$runtime" | grep -o '3468:"[a-f0-9]*"' | grep -o '[a-f0-9]\{16\}')"
PKGURL="$(fetch_url "$sparoot/3468.$chunkhash.js" | tr '}' '\n' | grep "label:.$spolabel" \
    | grep -oE 'https://files\.gossluzhba\.gov\.ru/[a-f0-9-]+/download/[a-f0-9-]+' | head -1)"

if [ -z "$PKGURL" ] ; then
    warning "Could not read the current download URL from the site, using the last known one"
    PKGURL="$fallback_url"
fi

install_pkgurl
