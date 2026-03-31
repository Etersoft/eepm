#!/bin/sh -x

# Post script, called after special (or default) script.

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# add libs requires (after all ignore_lib_requires calls)
add_libs_requires

# remove temp files
rm -f "$BUILDROOT/.eepm_ignore_lib_requires"
rm -f "$BUILDROOT/.eepm_ignore_lib_path"
rm -f "$BUILDROOT/.eepm_stop_libs_requires"

# remove forbidden paths owned by the filesystem package to avoid conflicts
# https://bugzilla.altlinux.org/show_bug.cgi?id=38842
for i in / /bin /sbin /opt \
        /etc /etc/init.d /etc/systemd /etc/opt /etc/sysconfig /etc/default /etc/cron.daily \
        /etc/xdg /etc/xdg/autostart \
        /lib /lib64 /lib/systemd /lib/systemd/system \
        /usr /usr/bin /usr/sbin /usr/lib /usr/lib64 /usr/libexec \
        /usr/share /usr/share/doc /usr/share/fonts /usr/share/info /usr/share/sounds \
        /usr/share/pixmaps /usr/share/man /usr/share/man/man1 /usr/share/appdata /usr/share/applications /usr/share/menu \
        /usr/share/mime /usr/share/mime/icons /usr/share/mime/packages \
        /usr/share/icons /usr/share/icons/gnome /usr/share/icons/hicolor \
        /usr/share/icons/hicolor/16x16 /usr/share/icons/hicolor/16x16/apps \
        /usr/share/icons/hicolor/32x32 /usr/share/icons/hicolor/32x32/apps \
        /usr/share/icons/hicolor/48x48 /usr/share/icons/hicolor/48x48/apps \
        /usr/share/polkit-1 /usr/share/polkit-1/actions /usr/share/polkit-1/rules.d \
        /usr/share/dbus-1 /usr/share/dbus-1/system.d /usr/share/dbus-1/services /usr/share/dbus-1/system-services \
        /usr/share/bash-completion /usr/share/bash-completion/completions \
        /usr/share/fish /usr/share/fish/vendor_completions.d \
        /usr/share/zsh /usr/share/zsh/site-functions \
        /usr/share/licenses \
        /usr/lib/systemd /usr/lib/systemd/system /usr/lib/sysusers.d \
        /var /var/cache /var/lib /var/log /var/opt /var/run ; do
    sed \
        -e "s|/\./|/|" \
        -e "s|^%dir[[:space:]]\"$i/*\"$||" \
        -e "s|^%dir[[:space:]]$i/*$||" \
        -e "s|^\"$i/*\"$||" \
        -e "s|^$i/*$||" \
        < $SPEC > $SPEC.new
    diff -u $SPEC $SPEC.new || warning "There was some introduced system paths in the spec file"
    mv $SPEC.new $SPEC
done

for DESKTOPFILE in $BUILDROOT/usr/share/applications/*.desktop ; do
    [ -f "$DESKTOPFILE" ] || continue

    EXEC="$(get_desktop_value "$DESKTOPFILE" "Exec")"
    if echo "$EXEC" | grep -q "/" ; then
        warning "Exec path in desktop file $DESKTOPFILE contains slashes: $EXEC"
    elif [ ! -s "./usr/bin/$EXEC" ] ; then
        if [ -L "./usr/bin/$EXEC" ] ; then
            if [ ! -s ".$(readlink "./usr/bin/$EXEC")" ] ; then
                warning "Exec from desktop file $DESKTOPFILE exists as broken symlink /usr/bin/$EXEC to $(readlink "./usr/bin/$EXEC")"
            fi
        else
            warning "Exec from desktop file $DESKTOPFILE missed in /usr/bin: $EXEC"
        fi
    elif [ ! -x "./usr/bin/$EXEC" ] ; then
        warning "Exec from desktop file $DESKTOPFILE exists in /usr/bin, but not executable: $EXEC"
    elif [ -z "$EXEC" ] ; then
        warning "Exec from desktop file $DESKTOPFILE is missed"
    fi

    desktopfile="$(basename "$DESKTOPFILE" .desktop)"
    ICON="$(get_desktop_value "$DESKTOPFILE" "Icon")"

    # rename generic icon.png to product name to avoid conflicts between packages
    if [ -f "$BUILDROOT/usr/share/pixmaps/icon.png" ] ; then
        if [ -z "$ICON" ] || [ "$ICON" = "icon" ] || [ "$ICON" = "icon.png" ] ; then
            newicon="$PRODUCT"
            mv "$BUILDROOT/usr/share/pixmaps/icon.png" "$BUILDROOT/usr/share/pixmaps/$newicon.png"
            subst "s|/usr/share/pixmaps/icon\.png|/usr/share/pixmaps/$newicon.png|" $SPEC
            subst "s|^Icon=.*|Icon=$newicon|" "$DESKTOPFILE"
            ICON="$newicon"
        fi
    fi

    if [ "$ICON" != "$desktopfile" ] ; then
        warning "Icon '$ICON' from desktop file $DESKTOPFILE is not the same as desktop file name."
    fi
done
