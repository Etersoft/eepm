#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

[ "$1" != "--run" ] && echo "Install Vivaldi browser from the official site" && exit

# TODO: use --debian-arch?
# convert to debian notation
case "$(distro_info -a)" in
    x86_64)
        arch=amd64
        ;;
    x86)
        arch=i386
        ;;
    armhf)
        arch=armhf
        ;;
    *)
        fatal "$(distro_info -a) arch is not supported"
        ;;
esac

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi

# TODO:
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi-ffmpeg-codecs


# return delimiter sign in depend of package type
get_pkg_name_delimiter()
{
   local pkgtype="$1"
   [ -n "$pkgtype" ] && pkgtype="$($DISTRVENDOR -p)"

   [ "$pkgtype" = "deb" ] && echo "_" && return
   echo "-"
}


# https://repo.vivaldi.com/archive/rpm/x86_64/
# https://repo.vivaldi.com/archive/rpm/x86_64/vivaldi-stable-3.4.2066.86-1.x86_64.rpm
# https://repo.vivaldi.com/archive/rpm/i386/vivaldi-stable-3.4.2066.86-1.i386.rpm
# https://repo.vivaldi.com/archive/deb/pool/main/
#ds=$(get_pkg_name_delimiter)
#epm install "https://downloads.vivaldi.com/stable/vivaldi-stable$ds${_rpmversion}${ds/-/./}$arch.$(distro_info -p)"

# epm uses eget to download * names
epm install "https://repo.vivaldi.com/archive/deb/pool/main/vivaldi-stable_*_$arch.deb"
