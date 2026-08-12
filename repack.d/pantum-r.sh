#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=pantum-r

. $(dirname $0)/common.sh

# pantum-r and pantum share ~69 files (e.g. /etc/sane.d/dll.d/pantum6500)
add_conflicts pantum

if [ -d "$BUILDROOT/usr/lib/sane" ] ; then
    mkdir -p "$BUILDROOT/usr/lib64/sane"
    for f in "$BUILDROOT/usr/lib/sane/"* ; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        move_file "/usr/lib/sane/$name" "/usr/lib64/sane/$name"
    done
    remove_dir /usr/lib/sane
fi

# Debian style duplicates (x86_64-linux-gnu and i386-linux-gnu handled by generic.sh)
remove_dir /usr/lib/aarch64-linux-gnu
remove_dir /usr/lib/arm-linux-gnueabihf

# duplicates main files
remove_dir /usr/local

# Upstream deb carries temporary extracted libcupsimage files under /opt.
remove_dir "/opt/$PRODUCT/temp"

# Uses system Qt5 for the scanner GUI.
ignore_lib_requires libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5PrintSupport.so.5 libQt5Widgets.so.5
add_unirequires libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5PrintSupport.so.5 libQt5Widgets.so.5

# Upstream links against obsolete libjbig.so.0; distros ship libjbig.so.2.1.
case "$(epm print info -s)" in
    alt)
        epm assure libjbig2.1 || fatal
        jbig_req=libjbig2.1
        ;;
    fedora)
        epm assure jbigkit-libs || fatal
        jbig_req=libjbig.so.2.1
        ;;
    *)
        epm assure libjbig.so.2.1 || fatal
        jbig_req=libjbig.so.2.1
        ;;
esac

is_soname_present libjbig.so.2.1 || fatal "Can't find libjbig.so.2.1"
epm assure patchelf || fatal

# Patch upstream ELF files instead of shipping global /usr/lib64/libjbig.so.0,
# which can conflict later if a distro adds a proper provider for this SONAME.
files="$(mktemp)" || fatal
find "$BUILDROOT" -type f > "$files" || fatal
while read -r f ; do
    patchelf --print-needed "$f" 2>/dev/null | grep -q '^libjbig\.so\.0$' || continue
    patchelf --replace-needed libjbig.so.0 libjbig.so.2.1 "$f" || fatal
done < "$files"
rm -f "$files"

ignore_lib_requires libjbig.so.0
add_unirequires "$jbig_req"
