#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_conflicts kubernetes-client
# /usr/bin/ctr
add_conflicts containerd

# Check https://get.k3s.io/

UNITDIR=/lib/systemd/system/
[ -d "$UNITDIR" ] || UNITDIR=/usr/lib/systemd/system/

mkdir -p .$UNITDIR
cat <<EOF | create_file $UNITDIR/k3s.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/%N
EnvironmentFile=-/etc/sysconfig/%N
EnvironmentFile=-/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yes
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/k3s server
EOF

cat <<EOF | create_file /etc/systemd/system/k3s.service.env
# K3S_URL=
# K3S_TOKEN=
# K3S_CLUSTER_SECRET=
EOF
