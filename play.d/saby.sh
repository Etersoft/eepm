#!/bin/sh

PKGNAME="saby sabycenter nmh-transport"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Saby (SBIS) desktop application from the official site"
URL="https://saby.ru/help/plugin/sbis3plugin"

. $(dirname $0)/common.sh

warn_version_is_not_supported

DLBASE="https://update.saby.ru"

pkgtype=$(epm print info -p)
case "$pkgtype" in
    rpm)
        # check if libstdc++ needs update
        if ! is_stdcpp_enough 12 ; then
            epm install --scripts "$DLBASE/SabyDesktop/master/linux/rpm_repo/sbis-libstdc++12-12.2.1-4.el7.x86_64.rpm" || warning 'Failed to install sbis-libstdc++12'
        fi
        epm install --scripts \
            "$DLBASE/SabyDesktop/master/linux/saby.rpm" \
            "$DLBASE/SabyCenter/master/linux/sabycenter.rpm" \
            "$DLBASE/NmhTransport/master/linux/nmh-transport.rpm"
        ;;
    deb)
        if ! is_stdcpp_enough 12 ; then
            epm install --scripts "$DLBASE/SabyDesktop/master/linux/deb_repo/sbis-libstdc++12.deb" || warning 'Failed to install sbis-libstdc++12'
        fi
        epm install --scripts \
            "$DLBASE/SabyDesktop/master/linux/deb_repo/saby.deb" \
            "$DLBASE/SabyCenter/master/linux/sabycenter.deb" \
            "$DLBASE/NmhTransport/master/linux/nmh-transport.deb"
        ;;
    *)
        fatal "Only rpm and deb package formats are supported"
        ;;
esac

# create connector-path (replaces components-registrator installActions)
SABYDIR="/opt/Tensor/Saby"
SABYVER="$(ls -1d $SABYDIR/*/service/modules/SbisNNGConnector 2>/dev/null | head -1 | sed "s|$SABYDIR/||;s|/service/.*||")"
if [ -n "$SABYVER" ] ; then
    mkdir -p /usr/share/Tensor/Saby
    echo "$SABYDIR/$SABYVER/service/modules/SbisNNGConnector/libsbis-plugin-connector.so" > /usr/share/Tensor/Saby/sbis-plugin-connector-path
fi
