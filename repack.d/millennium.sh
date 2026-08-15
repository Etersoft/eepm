#!/bin/sh

# Add a removal scriptlet for the package built by pack.d/millennium.sh.
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Keep the scriptlet before %files, as required by the generated RPM spec.
sed '/^%files$/,$d' "$SPEC" > "$SPEC.new" || fatal
cat >> "$SPEC.new" <<'EOF'

%postun
# Remove only the symlinks created by millennium-setup.  Do not remove a
# replacement link or a regular Steam file created after Millennium was set up.
unlink_millennium_hook()
{
    hook="$1"

    [ -L "$hook" ] || return 0
    case "$(readlink "$hook")" in
        /usr/lib/millennium/libmillennium_bootstrap_x86.so|\
        /usr/lib/millennium/libmillennium_bootstrap_hhx64.so|\
        /usr/lib/millennium/libmillennium_hhx64.so)
            rm -f "$hook"
            ;;
    esac
}

# Package scriptlets run as root, so clean hooks for every regular user whose
# Steam directory exists.  This follows Millennium's own Arch package policy.
getent passwd | while IFS=: read -r _ _ uid _ _ home _ ; do
    [ "$uid" -ge 1000 ] 2>/dev/null || continue
    steam_dir="$home/.steam/steam"
    [ -d "$steam_dir" ] || continue

    unlink_millennium_hook "$steam_dir/ubuntu12_32/libXtst.so.6"
    unlink_millennium_hook "$steam_dir/ubuntu12_64/libXtst.so.6"
    unlink_millennium_hook "$steam_dir/ubuntu12_64/libmillennium_hhx64.so"
done
EOF
sed -n '/^%files$/,$p' "$SPEC" >> "$SPEC.new" || fatal
mv "$SPEC.new" "$SPEC" || fatal
