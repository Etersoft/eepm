#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: File tools|" $SPEC
subst "s|^License:.*$|License: Apache-2.0|" $SPEC
subst "s|^URL:.*|URL: https://k3s.io|" $SPEC
subst "s|^Summary:.*|Summary: K3s - Lightweight Kubernetes|" $SPEC

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

subst '1iConflicts: kubernetes-client' $SPEC

# Check https://get.k3s.io/

UNITDIR=/lib/systemd/system/
[ -d "$UNITDIR" ] || UNITDIR=/usr/lib/systemd/system/

mkdir -p .$UNITDIR
cat >.$UNITDIR/k3s.service << EOF
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

pack_file $UNITDIR/k3s.service

mkdir -p etc/systemd/system/
cat >etc/systemd/system/k3s.service.env << EOF
# K3S_URL=
# K3S_TOKEN=
# K3S_CLUSTER_SECRET=
EOF

pack_file /etc/systemd/system/k3s.service.env

