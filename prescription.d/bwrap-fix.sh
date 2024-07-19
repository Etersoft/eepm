#!/bin/sh

[ "$1" != "--run" ] && echo "Enable unprivileged bubblewrap mode" && exit

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

epm install --skip-installed  sysctl-conf-userns

# https://bugzilla.altlinux.org/46690 and https://github.com/flatpak/flatpak/wiki/User-namespace-requirements
cat <<EOL > /etc/systemd/system/check-bwrap.service
[Unit]
Description=Check and fix permissions for bwrap
Wants=check-bwrap.path

[Service]
Type=oneshot
ExecStart=/bin/bash -c "CURRENT_PERMISSIONS=\$(stat -c '%a' /usr/bin/bwrap); if [ '\$CURRENT_PERMISSIONS' != '775' ]; then chmod 0755 /usr/bin/bwrap; fi"
EOL

cat <<EOL > /etc/systemd/system/check-bwrap.path
[Unit]
Description=Watch /usr/bin/bwrap for changes

[Path]
PathModified=/usr/bin/bwrap

[Install]
WantedBy=multi-user.target
EOL

serv on check-bwrap.path
serv start check-bwrap.service
