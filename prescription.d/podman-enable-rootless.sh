#!/bin/sh

[ "$1" != "--run" ] && echo "Basic Setup to Use of Podman in a Rootless environment" && exit

. $(dirname $0)/common.sh

assure_root

login="/etc/login.defs"
passwd="/etc/passwd"

uid_min=$(grep "^UID_MIN" $login | awk '{print $2}')
uid_max=$(grep "^UID_MAX" $login | awk '{print $2}')

users=$(awk -F':' -v min="$uid_min" -v max="$uid_max" '{ if ($3 >= min && $3 <= max && $7 != "/sbin/nologin") print $1 }' "$passwd")

a= sysctl -w kernel.unprivileged_userns_clone=1

a= control newgidmap public
a= control newuidmap public

a= setcap cap_setuid+ep /usr/bin/newuidmap
a= setcap cap_setgid+ep /usr/bin/newgidmap

for i in $users ; do
    if ! grep -q $i /etc/subuid /etc/subgid ; then
        usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$i"
    fi
done

epm install sysctl-conf-userns podman

echo "To finish the configuration, enter the command 'podman system migrate' as a normal user"
