#!/bin/sh
# Loaded by common.sh only in the native DEB backend.

# Change one exact upstream relation to the prepared sibling's output version.
# No relation is changed unless the recipe requests it explicitly.
set_deb_requires_version()
{
    local name="$1" info="$EPM_DEB_SET_DIR/$1/info" old new
    [ -f "$info" ] || fatal "Missing DEB component in repack set: $name"
    old="$(sed -n '2p' "$info")"
    new="$(sed -n '3p' "$info")"
    perl "$EPM_DEB_CONTROL_HELPER" exact "$BUILDROOT/DEBIAN/control" "$name" "$old" "$new"
}

# Private library directories, relative to the package's root (e.g. /opt/app).
# The backend scans after all recipes have prepared their trees.
scan_deb_requires()
{
    local dir
    touch "$EPM_DEB_STATE/scan"
    for dir in "$@" ; do
        case "$dir/" in */../*|*/./*) fatal "Invalid package library path: $dir" ;; esac
        case "$dir" in /*) ;; *) fatal "Expected absolute package library path: $dir" ;; esac
        [ -d "$BUILDROOT$dir" ] || fatal "Missing library directory: $dir"
        printf '%s\n' "$dir" >> "$EPM_DEB_STATE/library-paths"
    done
}

# Only explicit sibling packages are searched, never all installed applications.
add_deb_library_provider()
{
    local name
    for name in "$@" ; do
        [ -f "$EPM_DEB_SET_DIR/$name/info" ] || fatal "Missing library provider: $name"
        printf '%s\n' "$name" >> "$EPM_DEB_STATE/providers"
    done
}

