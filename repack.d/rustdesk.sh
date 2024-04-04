#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# put service file to the normal place
install_file usr/share/rustdesk/files/systemd/rustdesk.service /etc/systemd/system/$PRODUCT.service
remove_dir /usr/share/rustdesk/files/systemd

VERSION=$(grep "^Version:" $SPEC | sed -e "s|Version: ||")

if [ "$VERSION" = "1.1.8" ] || [ "$VERSION" = "1.1.9" ] ; then
echo "Note: use 1.1.x compatibility script"
echo "Categories=GNOME;GTK;Network;RemoteAccess;" >> usr/share/applications/$PRODUCT.desktop

add_libs_requires

[ "$(epm print info -s)" = "alt" ] || exit 0

add_unirequires xdotool

if ! epm install --skip-installed --no-remove python3-module-pynput ; then
    case "$(epm print info -e)" in
        ALTLinux/p9)
            # https://git.altlinux.org/tasks/316570/
            epm install --no-remove 316570
            ;;
   esac
fi

exit
fi

#### 1.2.3 and above

move_to_opt /usr/lib/rustdesk

subst "s|^Categories.*|Categories=GNOME;GTK;Network;RemoteAccess;|" usr/share/applications/$PRODUCT.desktop

add_bin_link_command

add_unirequires curl
add_libs_requires
