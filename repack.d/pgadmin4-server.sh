#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/pgadmin4

. $(dirname $0)/common.sh

move_to_opt /usr/pgadmin4

# The bundled venv keeps its packages under lib/python3.<minor>/site-packages (the
# layout the venv was built with), but some distros (e.g. ALT) look them up under
# the unversioned lib/python3/site-packages. Add the compat symlink so the venv
# interpreter finds its own packages (flask, sqlalchemy, ...) instead of
# ModuleNotFoundError. The symlink is new, so it must be registered in %files
# (pack_file) or rpmbuild drops it as an unpackaged file.
pyabi=''
for vlib in "$BUILDROOT$PRODUCTDIR/venv/lib" "$BUILDROOT$PRODUCTDIR/venv/lib64" ; do
    [ -d "$vlib" ] || continue
    for pydir in "$vlib"/python3.* ; do
        [ -d "$pydir" ] || continue
        ln -sfn "$(basename "$pydir")" "$vlib/python3"
        pack_file "$(echo "$vlib/python3" | sed -e "s|^$BUILDROOT||")"
        pyabi="$(basename "$pydir" | sed 's/^python//')"
        break
    done
done

# The venv ships cpython-<minor> .so and symlinks into the system python stdlib, so it
# needs exactly that interpreter ABI, not just any python3 (python3 provides
# python(abi) = <minor>).
[ -n "$pyabi" ] && add_requires "python(abi) = $pyabi"

add_requires libkrb5.so.3 libpq.so.5
