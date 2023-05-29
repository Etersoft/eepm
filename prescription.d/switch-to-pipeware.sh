#!/bin/sh

[ "$1" != "--run" ] && echo "Switch to using Pipeware" && exit

. $(dirname $0)/common.sh

assure_root
exit

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"


epm install pipewire pipewire-utils pipewire-libs
# TODO: user??
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user --now enable pipewire pipewire-pulse
systemctl --user --now enable pipewire-media-session.service
systemctl --user mask pulseaudio
#systemctl reboot

echo "Done. Just you need reboot your system to use Pipeware."
