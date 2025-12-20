#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rlinux
PRODUCTDIR=/opt/$PRODUCT

. "$(dirname "$0")/common.sh"

move_to_opt /usr/local/R-Linux
remove_file /usr/local/R-Linux/bin/rlinux

install_file "opt/$PRODUCT/share/logo_48.png" /usr/share/pixmaps/rtt-rlinux.png
install_file "opt/$PRODUCT/share/rtt-rlinux.desktop" /usr/share/applications/rtt-rlinux.desktop

head -n -12 "opt/$PRODUCT/bin/rlinux" > "opt/$PRODUCT/bin/rlinux.tmp"
mv "opt/$PRODUCT/bin/rlinux.tmp" "opt/$PRODUCT/bin/rlinux"

cat <<'EOF' >> "opt/$PRODUCT/bin/rlinux"
    # Elevate (fixed)
    if [ -x "$GKSUDO" ]; then
         $GKSUDO --description $DESKFILE $RSSTARTUP $@
    elif [ -x "$KDESUDO" ]; then
        $KDESUDO $RSSTARTUP --- "$envi" $@
    elif [ -x "$PKEXEC" ]; then
        $PKEXEC $RSSTARTUP --- "$envi" $@
    else
        $TRAMPLIN $@ > /dev/null 2>&1
    fi
fi
EOF

chmod a+x $BUILDROOT/$PRODUCTDIR/bin/rlinux

subst "s|/usr/local/R-Linux|$PRODUCTDIR|g" "opt/$PRODUCT/bin/rlinux"
add_bin_link_command $PRODUCT /opt/$PRODUCT/bin/rlinux

fix_desktop_file /usr/local/R-Linux/bin/rlinux $PRODUCT
add_requires polkit

