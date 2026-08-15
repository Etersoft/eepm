#!/bin/sh

# Adapt the upstream payload and provide per-user Steam integration.
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/lib/millennium || fatal "Can't move Millennium to $PRODUCTDIR"

# The x86 bootstrap falls back to /usr/lib/millennium/libmillennium_x86.so
# when MILLENNIUM_RUNTIME_PATH is unset. Preserve that fallback path.
# https://github.com/SteamClientHomebrew/Millennium/blob/main/scripts/install.sh
ln -s "$PRODUCTDIR" "$BUILDROOT/usr/lib/millennium" || fatal
pack_file /usr/lib/millennium

# Upstream ships executable ELF helpers without an executable mode in some
# releases. Fix all ELF files, including shared libraries, without naming helpers.
find "$BUILDROOT$PRODUCTDIR" -type f | while IFS= read -r file ; do
    file -b "$file" | grep -q '^ELF ' || continue
    chmod 755 "$file" || exit 1
done || fatal "Can't fix Millennium executable permissions"

create_exec_file /usr/bin/millennium-setup <<'EOF'
#!/bin/sh

usage()
{
    echo 'Usage: millennium-setup [--help|--remove]'
    echo 'Run as a regular user to enable Millennium, or --remove before removing the package.'
}

action=install
case "$#:$1" in
    0:) ;;
    1:--help|1:-h) usage ; exit 0 ;;
    1:--remove) action=remove ;;
    *) usage >&2 ; exit 1 ;;
esac

if [ "$(id -u)" -eq 0 ] ; then
    echo 'Do not run millennium-setup as root.' >&2
    exit 1
fi

steam_dir="$HOME/.steam/steam"

# Accept only the expected target for this hook, including older epm packages.
is_millennium_hook()
{
    [ -L "$1" ] || return 1
    case "$(readlink "$1")" in
        "/opt/millennium/$2"|"/usr/lib/millennium/$2") return 0 ;;
    esac
    return 1
}

hooks='ubuntu12_32/libXtst.so.6:libmillennium_bootstrap_x86.so
ubuntu12_64/libXtst.so.6:libmillennium_bootstrap_hhx64.so
ubuntu12_64/libmillennium_hhx64.so:libmillennium_hhx64.so'

if [ "$action" = remove ] ; then
    echo "$hooks" | while IFS=: read -r relative target ; do
        hook="$steam_dir/$relative"
        if is_millennium_hook "$hook" "$target" ; then
            rm -f "$hook" || exit 1
        fi
    done || exit 1
    echo 'Millennium is disabled. Restart Steam.'
    exit 0
fi

for directory in ubuntu12_32 ubuntu12_64 ; do
    [ -d "$steam_dir/$directory" ] || {
        echo 'Run Steam once before millennium-setup.' >&2
        exit 1
    }
done

# Validate every destination before changing any hooks or the Steam beta setting.
echo "$hooks" | while IFS=: read -r relative target ; do
    hook="$steam_dir/$relative"
    if [ -e "$hook" ] || [ -L "$hook" ] ; then
        is_millennium_hook "$hook" "$target" || {
            echo "Refusing to overwrite $hook: not a Millennium symlink." >&2
            exit 1
        }
    fi
done || exit 1

# Match upstream's first-install behavior by switching Steam to the stable client.
beta_file="$steam_dir/package/beta"
if [ -f "$beta_file" ] ; then
    rm -f "$beta_file" || exit 1
    echo 'Steam beta is disabled; re-enable it in Settings if needed.'
fi

echo "$hooks" | while IFS=: read -r relative target ; do
    ln -sf "/opt/millennium/$target" "$steam_dir/$relative" || exit 1
done || exit 1

echo 'Millennium is enabled. Restart Steam to load it.'
EOF
