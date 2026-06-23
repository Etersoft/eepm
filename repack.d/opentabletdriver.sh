#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/usr/lib/opentabletdriver

. $(dirname $0)/common.sh

create_dotnet_wrapper()
{
    local name="$1"
    local target="$2"

    cat <<EOF | create_exec_file "/usr/bin/$name"
#!/bin/sh
if [ -z "\$DOTNET_ROOT" ] ; then
    for d in /usr/lib64/dotnet /usr/share/dotnet /usr/lib/dotnet ; do
        if [ -x "\$d/dotnet" ] ; then
            DOTNET_ROOT="\$d"
            export DOTNET_ROOT
            export DOTNET_ROOT_X64="\$d"
            break
        fi
    done
fi
exec "$target" "\$@"
EOF
}

create_dotnet_wrapper otd "$PRODUCTDIR/OpenTabletDriver.Console"
create_dotnet_wrapper otd-daemon "$PRODUCTDIR/OpenTabletDriver.Daemon"
create_dotnet_wrapper otd-gui "$PRODUCTDIR/OpenTabletDriver.UX.Gtk"

# .NET runtime is resolved at startup through hostfxr rather than plain ELF NEEDED
# entries. Keep these names ignored if they ever leak into auto-detected lib requires,
# and add the package dependency explicitly instead.
ignore_lib_requires libhostfxr.so libhostpolicy.so libcoreclr.so

case "$(epm print info -p)" in
    rpm)
        # On ALT/main there is no soname provider for libhostfxr.so, while the package
        # dependency works and pulls dotnet-hostfxr-8.0 transitively.
        add_requires dotnet-runtime-8.0
        ;;
    deb)
        # If deb support is re-enabled later, keep the dependency package-based too.
        add_directrequires dotnet-runtime-8.0
        ;;
esac
