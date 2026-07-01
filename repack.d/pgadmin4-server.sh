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

# Upstream builds the venv with --system-site-packages (include-system-site-packages =
# true). On the origin distro pgAdmin then pulls a few optional deps (oauth2client,
# pyOpenSSL) from the system python; on other distros those system packages are
# ABI-incompatible with the bundled cryptography and crash pgAdmin at startup
# (AttributeError: module 'lib' has no attribute 'GEN_EMAIL' from a mismatched system
# pyOpenSSL). Make the venv hermetic: it already bundles everything it needs, and the
# optional imports are guarded by try/except ImportError, so with the system leak gone
# they degrade gracefully (google-auth, also bundled, stays as the auth backend).
cfg="$BUILDROOT$PRODUCTDIR/venv/pyvenv.cfg"
[ -f "$cfg" ] && subst 's/^include-system-site-packages *=.*/include-system-site-packages = false/' "$cfg"

# psycopg (64-bit) inside the venv dlopens libpq/libkrb5 at runtime, but the venv .so
# is not scanned by auto-req, so these must be declared manually. Use add_unirequires so
# the ()(64bit) ELF-class marker is added: a bare "libpq.so.5" on ALT is provided by the
# i586 *.32bit compat package, so the real 64-bit libpq5 never gets pulled in and the
# server backend fails to start (desktop then hangs on the splash screen).
add_unirequires "libkrb5.so.3 libpq.so.5"
