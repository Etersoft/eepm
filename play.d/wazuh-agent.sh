#!/bin/sh

PKGNAME=wazuh-agent
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Wazuh agent (host-based security monitoring) from the official Wazuh repo"
URL="https://wazuh.com/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

# official Wazuh yum repo; the bucket forbids directory listing, so read the
# latest version from its repodata, and build a direct URL for a pinned version
REPOURL="https://packages.wazuh.com/4.x/yum"

if [ "$VERSION" = "*" ] ; then
    filename=$(get_rpm_repo_latest_file "$REPOURL" "wazuh-agent-[0-9.]*-[0-9]*\.$arch\.rpm")
    [ -n "$filename" ] || fatal "Can't get the latest Wazuh agent version from $REPOURL"
    PKGURL="$REPOURL/$filename"
else
    PKGURL="$REPOURL/wazuh-agent-$VERSION-1.$arch.rpm"
fi

install_pkgurl

echo
echo 'Note: configure the agent before the first start (point it to your manager):
    /var/ossec/bin/agent-auth -m MANAGER_IP    # register on the Wazuh manager
    edit /var/ossec/etc/ossec.conf: <address>MANAGER_IP</address>
    serv wazuh-agent on && serv wazuh-agent start'
