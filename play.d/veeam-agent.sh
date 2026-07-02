#!/bin/sh

PKGNAME=veeam
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Veeam Agent for Linux from the official Veeam repository"
URL="https://www.veeam.com/linux-backup-free.html"

. $(dirname $0)/common.sh

# Veeam ships as several rpms (veeam, veeam-libs, blksnap, blksnap-ueficert);
# allow repack to produce all of them.
export EEPM_INTERNAL_PKGNAME='veeam veeam-libs blksnap blksnap-ueficert'

# NOTE: Veeam suspended operations in Russia in 2022, and repository.veeam.com
# answers HTTP 403 from Russian networks. From a RU egress the download/repo
# update fails with 403 — route repository.veeam.com through a foreign gateway
# (e.g. IGW "geo" mode) before running this.

# Snapshot module: modern kernels (>= 5.10) use 'blksnap' (built via DKMS);
# the legacy 'veeamsnap' module (kernels <= 5.18) is gone from the el9 repo.

REPOBASE="https://repository.veeam.com/backup/linux/agent/rpm/el"
KEYURL="https://repository.veeam.com/keys/RPM-E6FBD664"

# pick el8 / el9 repo branch by distro base version (default 9)
elver=9
[ "$(epm print info --base-version)" = "8" ] && elver=8

REPOURL="$REPOBASE/$elver/x86_64"

case "$(epm print info -g)" in
    dnf-*|yum-*)
        # native repo: works out of the box on RHEL/Rocky/Alma/CentOS/Oracle/
        # RedOS/ROSA/etc. blksnap builds via DKMS (needs dkms, gcc, kernel headers).
        epm repo addkey veeam "$REPOURL/" "$KEYURL" "Veeam Backup for GNU/Linux"
        epm install $PKGNAME blksnap
        ;;
    apt-rpm)
        # ALT: a foreign yum repo is rejected by apt (unknown vendor ID), so
        # fetch the packages directly from the el9 branch and install them.
        # blksnap is a DKMS source package, so it needs dkms + kernel headers
        # + gcc to build the module for the running ALT kernel.
        epm assure dkms
        # DKMS build tools for blksnap; headers for the running ALT kernel are
        # also required (kernel-headers-modules-<flavour>).
        epm assure gcc make perl

        [ "$VERSION" = "*" ] && VERSION="6.3.2.1405"
        [ -n "$RELEASE" ] || RELEASE="1"

        # native rpm install skips repack, so force it: repack.d/{veeam,blksnap}.sh
        # rewrite the RHEL-style Requires into ALT-resolvable soname Requires.
        epm repack --install \
            "$REPOBASE/9/x86_64/veeam-libs-$VERSION-$RELEASE.x86_64.rpm" \
            "$REPOBASE/9/x86_64/veeam-$VERSION-$RELEASE.el9.x86_64.rpm" \
            "$REPOBASE/9/x86_64/blksnap-$VERSION-$RELEASE.noarch.rpm" \
            "$REPOBASE/9/x86_64/blksnap-ueficert-$VERSION-$RELEASE.noarch.rpm"

        # repack strips package scripts, so the blksnap DKMS source is not
        # auto-registered: register and build it for the running kernel.
        # Needs matching kernel headers (kernel-headers-modules-<flavour>).
        sudocmd dkms add -m blksnap -v "$VERSION" 2>/dev/null
        sudocmd dkms install -m blksnap -v "$VERSION" -k "$(uname -r)" 2>/dev/null || true
        ;;
    *)
        fatal "Unsupported package backend for $PKGNAME: $(epm print info -g). Ask application vendor for a support."
        ;;
esac

cat <<EOF

Note:
Veeam Agent is configured and run interactively by:
    # veeamconfig

To manage the veeamservice systemd unit:
    # serv veeamservice on

If blksnap DKMS build failed, install the kernel headers for the running
kernel (kernel-headers-modules-...) and gcc, then rebuild with:
    # dkms autoinstall
EOF
