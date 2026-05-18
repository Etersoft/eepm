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
# --repack forces repack.d/{saby,sabycenter}.sh to run even for native rpm/deb —
# they replace the vendor maintainer scripts (drop chmod 777, killall, ABRT changes;
# move temp_*/ contents into PRODUCTDIR/ so /opt/Tensor/Saby/saby launcher exists).
pkgtype=$(epm print info -p)
case "$pkgtype" in
    rpm)
        # saby.rpm requires /usr/bin/certutil — provided by nss-utils
        epm install nss-utils || warning 'Failed to install nss-utils (provides /usr/bin/certutil required by saby.rpm)'
        if ! is_stdcpp_enough 12 ; then
            epm install --repack "$DLBASE/SabyDesktop/master/linux/rpm_repo/sbis-libstdc++12-12.2.1-4.el7.x86_64.rpm" || warning 'Failed to install sbis-libstdc++12'
        fi
        epm install --repack \
            "$DLBASE/SabyDesktop/master/linux/saby.rpm" \
            "$DLBASE/SabyCenter/master/linux/sabycenter.rpm" \
            "$DLBASE/NmhTransport/master/linux/nmh-transport.rpm"
        ;;
    deb)
        # saby.deb requires certutil — provided by libnss3-tools on Debian/Ubuntu
        epm install libnss3-tools || warning 'Failed to install libnss3-tools (provides certutil required by saby.deb)'
        if ! is_stdcpp_enough 12 ; then
            epm install --repack "$DLBASE/SabyDesktop/master/linux/deb_repo/sbis-libstdc++12.deb" || warning 'Failed to install sbis-libstdc++12'
        fi
        epm install --repack \
            "$DLBASE/SabyDesktop/master/linux/deb_repo/saby.deb" \
            "$DLBASE/SabyCenter/master/linux/sabycenter.deb" \
            "$DLBASE/NmhTransport/master/linux/nmh-transport.deb"
        ;;
    *)
        fatal "Only rpm and deb package formats are supported"
        ;;
esac

# Sanity check: was the repack actually applied?
# After repack.d/saby.sh's move_dir, /opt/Tensor/Saby/temp_saby must not exist.
SABYDIR="/opt/Tensor/Saby"
if [ -d "$SABYDIR/temp_saby" ] ; then
    warning "$SABYDIR/temp_saby still exists — repack.d/saby.sh did not run."
    warning "saby is installed in 'vendor temp_saby/' layout, the launcher $SABYDIR/saby is missing."
    warning "Possible cause: epm older than 3.64.63, or 'epm install --repack' did not trigger repack scripts."
fi

# Replacement for postinstall actions (maintainer scripts dropped via repack):

# 1. Saby plugin connector path (used by browsers via sbis3plugin)
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

# 3. Show post-install hints.
# We DON'T auto-start SabyCenter — registering a system daemon is left to the user
# (per saby.md: "сложнее и потенциально ломает поведение системы — оставлено пользователю").
# The unit file itself is shipped by repack.d/sabycenter.sh.
echo
echo "Saby installed. Note:"
echo "  - Run:  saby  (/usr/bin/saby symlink, also in menu and autostart)"
if serv SabyCenter is-active >/dev/null 2>&1 ; then
    echo "  - SabyCenter service: running (serv SabyCenter status)"
else
    echo "  - SabyCenter service: installed but NOT started."
    echo "    To enable + start at boot:  serv SabyCenter on"
    echo "    To start only this session: serv SabyCenter start"
fi
