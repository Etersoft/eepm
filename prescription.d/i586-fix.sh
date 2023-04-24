#!/bin/sh

[ "$1" != "--run" ] && echo "Fix missed 32 bit package modules on 64 bit system" && exit

[ "$(epm print info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

get_list_alt()
{

for i in glibc-nss glibc-gconv-modules \
         libnm \
         sssd-client \
         primus \
         vulkan-amdgpu libvulkan1 \
         $(epmqp --short nvidia_glx | grep "^nvidia_glx") \
         $(epmqp --short libnss | grep "^libnss-") \
         $(epmqp --short xorg-dri | grep "^xorg-dri-")
do
    epm --quiet installed $i && LIST="$LIST i586-$i"
done
}

get_list_fedora()
{

# /usr/share/locale/de/LC_MESSAGES/NetworkManager.mo from NetworkManager-libnm conflicts
#         NetworkManager-libnm 

for i in \
         sssd-client \
         mesa-vulkan-drivers mesa-dri-drivers vulkan-loader
do
    epm --quiet installed $i && LIST="$LIST $i.i686"
done
}

vendor="$(epm print info -s)"

LIST=''
echo
echo "Checking for installed packages ... "

case "$vendor" in
    "alt")
        get_list_alt
        ;;
    "fedora"|"centos"|"redos")
        get_list_fedora
        ;;
    *)
        info "Unsupported $(epm print info -e) system. Just skipping the operation."
        exit
        ;;
esac

echo
echo "Installing all appropiate 32 bit packages ..."
epm install $LIST

