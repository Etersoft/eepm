#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

[ "$1" != "--run" ] && echo "Install Zoom client from the official site" && exit

arch=$(distro_info --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i586|i386)
        arch=$arch ;;
    *)
        fatal "Unsupported arch $arch for $(distro_info -d)"
esac

if [ "$(distro_info -d)" = "ALTLinux" ] ; then
    epm install https://zoom.us/client/latest/zoom_$arch.rpm
    exit
fi

# TODO: there are more complex distro dependent url
epm --noscripts install "https://zoom.us/client/latest/zoom_$arch.$(distro_info -p)"
