#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

BASENAME=$(basename "$1" | sed -e 's|\.deb$||' -e 's|\.rpm$||')
VERSION=$(echo $BASENAME | sed -n 's|.*1c-enterprise-\([0-9.]*-[0-9]*\).*|\1|p' | sed 's/.$//')

__remove_libstdc() 
{
    rm opt/1cv8/common/libstdc++.so.6
    rm opt/1cv8/x86_64/$VERSION/libstdc++.so.6*
    rm opt/1cv8/x86_64/$VERSION/libgcc_s.so.1
}

# debug part - remove later
echo ""
echo $BASENAME
echo $FILENAME
echo $VERSION
echo ""
# remove later

case "$BASENAME" in

    1c-enterprise-*-common-nls-*)
        TARNAME=1c-enterprise-common-nls-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-common-*)
        TARNAME=1c-enterprise-common-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-crs-*)
        TARNAME=1c-enterprise-crs-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-server-nls-*)
        TARNAME=1c-enterprise-server-nls-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-server-*)
        TARNAME=1c-enterprise-server-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-ws-nls-*)
        TARNAME=1c-enterprise-ws-nls-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-ws-*)
        TARNAME=1c-enterprise-ws-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-thin-client-nls-*)
        TARNAME=1c-enterprise-thin-client-nls-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-thin-client-*)
        TARNAME=1c-enterprise-thin-client-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        cd 1c-enterprise*

        __remove_libstdc
        ;;
    1c-enterprise-*-client-nls-*)
        TARNAME=1c-enterprise-client-nls-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        ;;
    1c-enterprise-*-client-*)
        TARNAME=1c-enterprise-client-$VERSION.tar
        erc unpack "$FILENAME" || fatal
        cd 1c-enterprise*

        __remove_libstdc
        ;;
    *)
        fatal "Unsupported file format: $BASENAME" 
        ;;
esac


if [ -d usr ]; then
    erc pack "$TARNAME" opt usr || fatal
else
    erc pack "$TARNAME" opt || fatal
fi


return_tar $TARNAME
