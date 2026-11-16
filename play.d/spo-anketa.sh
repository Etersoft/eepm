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
    # SPO_AstraLinux_1_3_7.deb (version 1.3.7 from 21.10.2026)
    fallback_url="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/4c36ed05-4152-4fd0-aaf4-d090dd2d46c7"
else
    spolabel="RedOS/Alt Linux"
    # SPO_RedOS_AltLinux_1_3_7.rpm (version 1.3.7 from 21.10.2026)
    fallback_url="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/63df09d0-3edc-4e48-9a97-6809cbd007fa"
fi

# Read the current download URL from the site. It is an Angular SPA with no public
# file API, but the URLs are baked (labelled by OS) into one of its lazy chunks
# (shown at /spo/knowledge-base). Chunk names are content hashes, so find the chunk
# of the "spo" route and walk its imports until the one with the labelled URLs.
sparoot="https://gossluzhba.gov.ru/web-lk-new"
spochunk=''
for chunk in $(fetch_url "https://gossluzhba.gov.ru/spo/" | grep -oE '(chunk|main)-[A-Z0-9]+\.js' | sort -u) ; do
    spochunk="$(fetch_url "$sparoot/$chunk" | grep -oE 'path:"spo",loadChildren:\(\)=>import\("\./chunk-[A-Z0-9]+\.js"\)' | grep -oE 'chunk-[A-Z0-9]+\.js')"
    [ -n "$spochunk" ] && break
done

PKGURL=''
queue="$spochunk"
seen=''
count=0
while [ -n "$queue" ] && [ "$count" -lt 40 ] ; do
    set -- $queue
    chunk="$1"
    shift
    queue="$*"
    case " $seen " in
        *" $chunk "*) continue ;;
    esac
    seen="$seen $chunk"
    count=$((count + 1))
    content="$(fetch_url "$sparoot/$chunk")"
    PKGURL="$(echo "$content" | tr '}' '\n' | grep "label:.$spolabel" \
        | grep -oE 'https://files\.gossluzhba\.gov\.ru/[a-f0-9-]+/download/[a-f0-9-]+' | head -1)"
    [ -n "$PKGURL" ] && break
    queue="$queue $(echo "$content" | grep -oE 'chunk-[A-Z0-9]+\.js' | sort -u)"
done

if [ -z "$PKGURL" ] ; then
    warning "Could not read the current download URL from the site, using the last known one"
    PKGURL="$fallback_url"
fi

install_pkgurl
