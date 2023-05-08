#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "hplip-.*-plugin" ; then
    fatal "No idea how to handle $TAR"
fi

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=hplip-plugin
sh $TAR --target . --noexec || exit

case "$(epm print info -a)" in
    x86_64)
        arch="x86_64"
        ;;
    x86)
        arch="x86_32"
        ;;
    aarch64)
        arch="arm64"
        ;;
    armhf)
        arch="arm32"
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

VERSION="$(echo "$TAR" | sed -e "s|.*hplip-\(.*\)-plugin.run.*|\1|")" #"

mkdir -p usr/share/hplip/data/firmware
mkdir -p usr/share/hplip/fax/plugins
mkdir -p usr/share/hplip/prnt/plugins
mkdir -p usr/share/hplip/scan/plugins
mkdir -p usr/share/doc/hplip-plugin
mkdir -p var/lib/hp

install -m644 plugin.spec usr/share/hplip/
install -m644 hp_laserjet_*.fw.gz usr/share/hplip/data/firmware/
install -m755 fax_marvell-"$arch".so usr/share/hplip/fax/plugins/
install -m755 hbpl1-"$arch".so usr/share/hplip/prnt/plugins/
install -m755 lj-"$arch".so usr/share/hplip/prnt/plugins/
install -m755 bb_*-"$arch".so usr/share/hplip/scan/plugins/
install -m644 license.txt usr/share/doc/hplip-plugin/

# Create hplip.state used by hplip-tools
cat << EOF > hplip.state
[plugin]
installed = 1
eula = 1
version = $VERSION
EOF
install -m644 hplip.state var/lib/hp/

# Create symlinks
find usr/share/hplip -type f -name "*.so" | while read f; do
    lib_dir="${f%/*}"
    lib_name="${f##*/}"
    ln -vsf "$lib_name" "$lib_dir/${lib_name%%-*}.so"
done

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME usr/share/hplip usr/share/doc/hplip-plugin var/lib/hp/hplip.state || exit

return_tar $PKGNAME
