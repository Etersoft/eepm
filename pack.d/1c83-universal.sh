#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

BASENAME=$(basename "$1" | sed -e 's|\.zip$||')
VERSION=$(echo "$BASENAME" | sed -n 's/.*_\([0-9]\+\)_\([0-9]\+\)_\([0-9]\+\)_\([0-9]\+\).*/\1.\2.\3.\4/p')

erc unpack "$FILENAME" || fatal
cd $BASENAME

__remove_libstdc(){

    rm -f opt/1cv8/x86_64/$VERSION/libstdc++.so.6
    rm -f opt/1cv8/x86_64/$VERSION/libgcc_s.so.1
    rm -f opt/1cv8/common/libgcc_s.so.1
}

packages_list=$(echo "1c-enterprise*")

for file in $packages_list; do

    # Skip files containing 'nls' in the name
    if echo "$file" | grep -q 'nls'; then
        continue
    fi

    case $file in
        1c-enterprise-*-server-*)
            erc unpack "$file" || fatal
            __remove_libstdc
            erc pack 1c-enterprise-server-$VERSION.tar opt || fatal
            rm $file
            ;;
       
        1c-enterprise-*-thin-client-*)
            erc unpack "$file" || fatal

            mv 1c-enterprise-*-thin-client-*/opt opt
            mv 1c-enterprise-*-thin-client-*/usr usr

            __remove_libstdc
            rm -r $file $(basename $file | sed -e 's|\.rpm||' -e 's|\.deb||')
            
            erc pack 1c-enterprise-thin-client-$VERSION.tar opt usr || fatal

            ;;

        1c-enterprise-*-client-*)
            erc unpack "$file" || fatal
            
            mv 1c-enterprise-*-client-*/opt opt
            mv 1c-enterprise-*-client-*/usr usr
            
            __remove_libstdc
            rm -r $file $(basename $file | sed -e 's|\.rpm||' -e 's|\.deb||')

            erc pack 1c-enterprise-client-$VERSION.tar opt usr || fatal
            # Clien also contains thin client
            rm 1c-enterprise-*-thin-client-*
            break
            ;;
    esac
done

epm install --repack $(echo 1c-enterprise-$VERSION*) 
return_tar 1c-enterprise-*.tar
