#!/bin/sh

PKGNAME="saby sabycenter nmh-transport"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Saby (SBIS) desktop application from the official site"
URL="https://saby.ru/help/plugin/sbis3plugin"

. $(dirname $0)/common.sh

warn_version_is_not_supported

DLBASE="https://update.saby.ru"

# saby/sabycenter/nmh-transport binaries require GLIBCXX_3.4.30 (= GCC 12).
# On systems with libstdc++ < 12 install vendor-provided sbis-libstdc++12 first.
pkgtype=$(epm print info -p)
case "$pkgtype" in
    rpm)
        if ! is_stdcpp_enough 12 ; then
            epm install "$DLBASE/SabyDesktop/master/linux/rpm_repo/sbis-libstdc++12-12.2.1-4.el7.x86_64.rpm" || warning 'Failed to install sbis-libstdc++12'
        fi
        epm install \
            "$DLBASE/SabyDesktop/master/linux/saby.rpm" \
            "$DLBASE/SabyCenter/master/linux/sabycenter.rpm" \
            "$DLBASE/NmhTransport/master/linux/nmh-transport.rpm"
        ;;
    deb)
        if ! is_stdcpp_enough 12 ; then
            epm install "$DLBASE/SabyDesktop/master/linux/deb_repo/sbis-libstdc++12.deb" || warning 'Failed to install sbis-libstdc++12'
        fi
        epm install \
            "$DLBASE/SabyDesktop/master/linux/deb_repo/saby.deb" \
            "$DLBASE/SabyCenter/master/linux/sabycenter.deb" \
            "$DLBASE/NmhTransport/master/linux/nmh-transport.deb"
        ;;
    *)
        fatal "Only rpm and deb package formats are supported"
        ;;
esac

# Replacement for postinstall actions (maintainer scripts dropped via repack):

# 1. Saby plugin connector path (used by browsers via sbis3plugin)
SABYDIR="/opt/Tensor/Saby"
SABYVER="$(ls -1d $SABYDIR/*/service/modules/SbisNNGConnector 2>/dev/null | head -1 | sed "s|$SABYDIR/||;s|/service/.*||")"
if [ -n "$SABYVER" ] ; then
    mkdir -p /usr/share/Tensor/Saby
    echo "$SABYDIR/$SABYVER/service/modules/SbisNNGConnector/libsbis-plugin-connector.so" > /usr/share/Tensor/Saby/sbis-plugin-connector-path
fi

# 2. Register Saby native messaging host and other components for browsers
NMHDIR="/opt/nmh-transport"
NMHVER="$(ls -1d $NMHDIR/*/service/components-registrator 2>/dev/null | head -1 | sed "s|$NMHDIR/||;s|/service/.*||")"
if [ -n "$NMHVER" ] && [ -x "$NMHDIR/$NMHVER/service/components-registrator" ] ; then
    "$NMHDIR/$NMHVER/service/components-registrator" installNmh || warning 'Failed to register native messaging host'
fi

# 3. Show post-install hints
echo
echo "Saby installed. Note:"
echo "  - Saby launcher: $SABYDIR/saby (also in menu and autostart)"
echo "  - SabyCenter service is NOT registered automatically (was done by maintainer script via sbis-daemon-setup.sh)."
echo "    To enable: run '/opt/Tensor/Saby Center/<version>/service/sbis-daemon-setup.sh' manually if needed,"
echo "    or just launch SabyCenter from menu."
