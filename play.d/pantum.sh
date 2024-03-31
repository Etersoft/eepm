#!/bin/sh

PKGNAME=pantum
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="CUPS and SANE drivers for Pantum series printer and scanner"
URL="https://www.pantum.ru/support/download/driver/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# 1.1.99
#PKGURL="https://drivers.pantum.ru/userfiles/files/download/%E9%A9%B1%E5%8A%A8%E6%96%87%E4%BB%B6/2013/Pantum%20Ubuntu%20Driver%20V1_1_99-1.zip"

# all printer here
# 1.1.106
PKGURL="https://drivers.pantum.ru/userfiles/files/download/drive/2013/0619/Pantum%20Ubuntu%20Driver%20V1_1_106(1).zip"

#case $(epm print info -p) in
#    *)
#        PKGURL="https://drivers.pantum.ru/userfiles/files/download/drive/4020/linux%E5%85%B6%E4%BB%96%E7%B3%BB%E7%BB%9F%EF%BC%88ru%EF%BC%89/pantum-1_1_101-1_el8_x86_64.zip"
#        ;;
#    *)
#        #PKGURL="https://drivers.pantum.ru/userfiles/files/download/drive/4020/linux%E5%85%B6%E4%BB%96%E7%B3%BB%E7%BB%9F%EF%BC%88ru%EF%BC%89/pantum_1_1_101-1_amd64.zip"
#        ;;
#esac

case $(epm print info -e) in
    AstraLinuxSE/1.7*)
        PKGURL="https://drivers.pantum.ru/userfiles/files/download/drive/4020/linux%E5%85%B6%E4%BB%96%E7%B3%BB%E7%BB%9F%EF%BC%88ru%EF%BC%89/pantum_1_1_101-1astra1_amd64.zip"
        ;;
#    Ubuntu/*)
#        # 1.1.106
#        PKGURL="https://drivers.pantum.ru/userfiles/files/download/drive/2013/0619/Pantum%20Ubuntu%20Driver%20V1_1_106(1).zip"
#        ;;
esac

install_pack_pkgurl

#PKGURL="https://drivers.pantum.ru/userfiles/files/download/%E9%A9%B1%E5%8A%A8%E6%96%87%E4%BB%B6/%E6%A0%87%E7%AD%BE%E6%9C%BA/Linux/linux_pantum.7z"

#epm pack --install $PKGNAME "$PKGURL"
