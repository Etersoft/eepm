#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt "/usr/lib/GameCenterShowcase"

fix_desktop_file "Exec=/usr/lib/GameCenterShowcase/GameCenterShowcase" "Exec=GameCenterShowcase"

remove_file /usr/bin/GameCenterShowcase

add_requires libcurl4-openssl
cat <<'EOF' | create_exec_file "/usr/bin/GameCenterShowcase"
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib64/libcurl4-openssl${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec /opt/GameCenterShowcase/GameCenterShowcase "$@"
EOF
