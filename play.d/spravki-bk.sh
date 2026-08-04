#!/bin/sh

PKGNAME=spravki-bk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Система подготовки отчетности «Справки БК»"
URL="http://www.kremlin.ru/structure/additional/12/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# WARNING: kremlin.ru does not support HTTPS, checksum verification is critical
# Update the corresponding checksum whenever the vendor archive version changes.
# Select the vendor package matching the current distribution.
case "$(epm print info -s)" in
    alt)
        # Checksum for ALT Workstation version 3.0.5 (2026-04-21).
        PKGURL="http://static.kremlin.ru/media/events/files/ru/LAZRHYPWbZgiETKbbzAlfBFD7ijsCRQy.zip"
        spravki_bk_checksum="sha256:b76ac44b89f382d7d1d493528dd9d30a578ee0a250277c3f84c5a85165b59781"
        ;;
    astra|debian)
        # Checksum for Astra Linux version 3.0.5 (2026-04-21).
        PKGURL="http://static.kremlin.ru/media/events/files/ru/I462T1pPzQf2IOAXT6KXj99RA8AJbrK4.zip"
        spravki_bk_checksum="sha256:4c4b11803620836a0bccf968ce9dac201e1dbb694abd87b7bcbab7635d15b598"
        ;;
    rosa|redos|fedora)
        # Checksum for RED OS version 3.0.5 (2026-04-21).
        PKGURL="http://static.kremlin.ru/media/events/files/ru/a0Q2WaJKkImDjSTqBiY4tCmxnBa2jWXU.zip"
        spravki_bk_checksum="sha256:53be8952190c3208933a2f12567df8afbc1fa7ad45e3aa5e73c1892410bad396"
        ;;
    *)
        fatal "$1 is not supported"
        ;;
esac

install_pack_pkgurl "" "$spravki_bk_checksum"
