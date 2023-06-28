#!/bin/sh

[ "$1" != "--run" ] && echo "Fix missed 32 bit package modules on 64 bit system" && exit

[ "$(epm print info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

epm play i586-support

get_list_alt()
{

for i in glibc-nss glibc-gconv-modules \
         libnm \
         sssd-client \
         primus \
         vulkan-amdgpu libvulkan1 \
         libd3d \
         $(epmqp --short libnss | grep "^libnss-") \
         $(epmqp --short xorg-dri | grep "^xorg-dri-")
do
    epm --quiet installed $i && LIST="$LIST i586-$i"
done

for i in $(epmqp --short nvidia_glx | grep "^nvidia_glx") ; do
    epm status --installed $i || continue
    # install i586-* only for actual packages
    epm status --installable $i && LIST="$LIST i586-$i"
done
}

get_list_fedora()
{

# /usr/share/locale/de/LC_MESSAGES/NetworkManager.mo from NetworkManager-libnm conflicts
#         NetworkManager-libnm 

for i in \
         sssd-client \
         mesa-vulkan-drivers mesa-dri-drivers vulkan-loader mesa-libd3d
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
    "fedora"|"centos"|"redos"|"rhel")
        get_list_fedora
        ;;
    *)
        info "Unsupported $(epm print info -e) system. Just skipping the operation."
        exit
        ;;
esac

echo
echo "Installing all appropiate 32 bit packages ..."
epm install --no-remove $LIST
RES=$?

[ "$RES" = "0" ] || echo "Try do epm upgrade before."

exit $RES

