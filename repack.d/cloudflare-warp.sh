#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# libdartjni is not linked by warp-taskbar and only adds an unsatisfied libjvm requirement.
remove_file /usr/lib/warp/lib/libdartjni.so

if [ "$(epm print info -s)" = "alt" ] ; then
    # libsentry.so requires CURL_OPENSSL_4, but the default libcurl can provide CURL_GNUTLS_4.
    ignore_lib_requires libcurl.so.4
    add_requires libcurl4-openssl
    remove_file /bin/warp-taskbar
    cat <<'EOF' | create_exec_file /bin/warp-taskbar
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib64/libcurl4-openssl${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec /usr/lib/warp/warp-taskbar "$@"
EOF
fi

if [ "$(epm print info -s)" = "fedora" ] ; then
    ignore_lib_requires 'libjavascriptcoregtk-4.0.so.18()(64bit)' 'libwebkit2gtk-4.0.so.37()(64bit)'
fi
