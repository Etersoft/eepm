#!/bin/sh

SUPPORTEDARCHES='x86_64'
DESCRIPTION="Fix missed 32 bit package modules on 64 bit system"

. $(dirname $0)/common.sh

[ "$(epm print info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

epm prescription i586-support

get_list_alt()
{
repo="$(epm print info -r)"

for i in glibc-nss glibc-gconv-modules \
         libnm \
         sssd-client \
         primus \
         libvulkan1 \
         libd3d \
         libgamemodeauto0 \
         vkBasalt \
         mangohud \
         $(epmqp --short libnss | grep "^libnss-" | grep -v "libnss-fallback") \
         $(epmqp --short xorg-dri | grep "^xorg-dri-")
do
    epm status --installed $i && LIST="$LIST i586-$i"
done

[ "$repo" = "p10" ] && for i in \
         vulkan-amdgpu
do
    epm status --installed $i && LIST="$LIST i586-$i"
done

for i in \
          libxnvctrl0 \
          libnvidia-ml \
          $(epmqp --short nvidia_glx | grep "^nvidia_glx")
do
    # https://bugs.etersoft.ru/show_bug.cgi?id=17831
    epm status --installed $i && epm status --installable i586-$i && LIST="$LIST i586-$i"
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
    epm status --installed $i && LIST="$LIST $i.i686"
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
info "Installing all appropiate 32 bit packages ..."
noremove=''
[ -n "$auto" ] && noremove='--no-remove'
epm install $noremove $LIST
RES=$?

[ "$RES" = "0" ] || info "Try do epm upgrade before and check epm repo list."

exit $RES

