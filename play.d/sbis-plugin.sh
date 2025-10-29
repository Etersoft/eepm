#!/bin/sh

PKGNAME="sbis3plugin sbis-libstdc++12 sbis3plugin-additions saby-minimal-core"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Desktop plugin for convenient work in the browser"
URL="https://saby.ru/help/plugin/sbis3plugin"

. $(dirname $0)/common.sh


epm install --scripts \
    https://update-msk1.sbis.ru/Sbis3Plugin/master/linux/rpm_repo/sbis-libstdc++12-12.2.1-4.el7.x86_64.rpm \
    https://update-msk1.sbis.ru/Sbis3Plugin/master/linux/rpm_repo/saby-minimal-core.rpm \
    https://update-msk1.sbis.ru/Sbis3Plugin/master/linux/rpm_repo/sbis3plugin-additions.rpm \
    https://update-msk1.sbis.ru/Sbis3Plugin/master/linux/rpm_repo/sbis3plugin.rpm
