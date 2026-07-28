#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ShikiWatch
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

[ -d "$BUILDROOT$PRODUCTDIR" ] || {
    ROOTDIR="$(basename "$(find "$BUILDROOT" -mindepth 1 -maxdepth 1 -type d | head -n1)")"
    move_to_opt "/$ROOTDIR" || fatal
}

if [ "$(epm print info -s)" = "alt" ] ; then
    # ShikiWatch 0.15.0 bundles libsentry.so built against CURL_OPENSSL_4.
    ignore_lib_requires libcurl.so.4
    add_requires libcurl4-openssl
    CURLLIBPATH="/usr/lib64/libcurl4-openssl:"
fi

if [ -f "$BUILDROOT$PRODUCTDIR/usr/bin/$PRODUCT" ] ; then
    epm assure objdump binutils
    case "$(epm print info -e)" in
        ALTLinux/p11)
            if objdump -T "$BUILDROOT$PRODUCTDIR/usr/bin/$PRODUCT" | grep -q '_Znwm$' ; then
                # On p11 ShikiWatch 0.15.0 trips Flutter's libc++ startup check on exported operator new.
                epm assure patchelf
                SYMBOLMAP="$(mktemp)"
                cat > "$SYMBOLMAP" <<EOF
_Znwm _shikiwatch_Znwm
_Znam _shikiwatch_Znam
_ZnwmRKSt9nothrow_t _shikiwatch_ZnwmRKSt9nothrow_t
_ZnamRKSt9nothrow_t _shikiwatch_ZnamRKSt9nothrow_t
_ZnwmSt11align_val_t _shikiwatch_ZnwmSt11align_val_t
_ZnamSt11align_val_t _shikiwatch_ZnamSt11align_val_t
_ZnwmSt11align_val_tRKSt9nothrow_t _shikiwatch_ZnwmSt11align_val_tRKSt9nothrow_t
_ZnamSt11align_val_tRKSt9nothrow_t _shikiwatch_ZnamSt11align_val_tRKSt9nothrow_t
EOF
                patchelf --rename-dynamic-symbols "$SYMBOLMAP" "$BUILDROOT$PRODUCTDIR/usr/bin/$PRODUCT" || fatal
                rm -f "$SYMBOLMAP"
            fi
            ;;
    esac
fi

if objdump -p "$BUILDROOT$PRODUCTDIR/usr/bin/$PRODUCT" | grep -q 'NEEDED.*libsentry.so' ; then
    # Keep Sentry's native library load out of the ELF startup path.
    epm assure patchelf
    patchelf --remove-needed libsentry.so "$BUILDROOT$PRODUCTDIR/usr/bin/$PRODUCT" || fatal
fi

cat <<EOF | create_exec_file "/usr/bin/$PRODUCT"
#!/bin/sh
export SENTRY_NATIVE_BACKEND=none
export LD_LIBRARY_PATH="${CURLLIBPATH}$PRODUCTDIR/usr/bin/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "$PRODUCTDIR/usr/bin/$PRODUCT" "\$@"
EOF

add_bin_link_command shikiwatch $PRODUCT

if [ -f "$BUILDROOT$PRODUCTDIR/usr/share/applications/$PRODUCT.desktop" ] ; then
    install_file "$PRODUCTDIR/usr/share/applications/$PRODUCT.desktop" "/usr/share/applications/$PRODUCT.desktop"
fi
if ! ls "$BUILDROOT"/usr/share/icons/hicolor/*x*/apps/$PRODUCT.* >/dev/null 2>&1 ; then
    for icon in "$BUILDROOT$PRODUCTDIR"/usr/share/icons/hicolor/*x*/apps/* ; do
        [ -f "$icon" ] || continue
        icon="${icon#$BUILDROOT$PRODUCTDIR}"
        install_file "$PRODUCTDIR$icon" "$icon"
    done
fi

fix_desktop_file "Exec=AppRun" "Exec=$PRODUCT"
fix_desktop_file "Exec=usr/bin/$PRODUCT" "Exec=$PRODUCT"
fix_desktop_file "Exec=$PRODUCTDIR/usr/bin/$PRODUCT" "Exec=$PRODUCT"
subst "s|^Icon=.*|Icon=$PRODUCT|" "$BUILDROOT"/usr/share/applications/*.desktop

add_requires mpv

# Some bundled/optional runtime parts are not used as system Java libraries.
ignore_lib_requires 'libjvm.so()(64bit)'
