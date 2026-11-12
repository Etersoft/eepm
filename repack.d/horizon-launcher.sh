#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

cat <<'EOF' | create_exec_file /usr/bin/horizon-launcher
#!/bin/sh
export HORIZON_LAUNCHER_NO_SELF_UPDATE=1
export HORIZON_LAUNCHER_DESKTOP_EXEC=/usr/bin/horizon-launcher
exec /opt/horizon-launcher/horizon-launcher "$@"
EOF
