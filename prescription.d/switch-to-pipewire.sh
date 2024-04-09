#!/bin/sh

[ "$1" != "--run" ] && echo "Switch to using Pipeware" && exit

. $(dirname $0)/common.sh


display_help()
{
    echo "
Использование: epm play switch-to-pipewire [option]
--global
    Запуск под рутом: нужен для глобального включения(enable) службы pipewire после установки. 
    Но запуск(start) этой службы глобально невозможен, так как pipewire работает под пользователем. 

--user
    Запуск под пользователем: можно сразу включить(enable) службу и запустить(start) её, 
    но только для конкретного пользователя, у остальных пользователей остаётся pulseaudio."
    exit
}

case "${3}" in

    '--user' )
        is_root && fatal "User installation possible only without root"
        args='--user --now' ;;

    '--global')
        assure_root
        args='--global' ;;

    '--help' | *)
        display_help;;
esac


if [ "$(epm print info -s)" = "rosa" ]; then
    dnf_auto='' && [ -n "$auto" ] && dnf_auto='-y'
    a= dnf swap pulseaudio pipewire --allow-erasing $dnf_auto
    exit
fi

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux or ROSA are supported"

epm update

epm install pipewire pipewire-utils pipewire-libs
# TODO: user??
a= systemctl $args disable pulseaudio.service pulseaudio.socket
a= systemctl $args enable pipewire pipewire-pulse
a= systemctl $args enable pipewire-media-session.service
a= systemctl $args mask pulseaudio
#systemctl reboot

echo "Done."
if [[ $args == '--global' ]]; then
    echo 'Just you need restart your session to use Pipeware'
fi