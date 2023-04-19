#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=freeoffice2021
PRODUCTDIR=/usr/share/freeoffice2021
VERSION=free21

PREINSTALL_PACKAGES="coreutils file gawk grep libcurl libGL libX11 libXext libXmu libXrandr libXrender sed xprop"

. $(dirname $0)/common.sh


#subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

remove_file $PRODUCTDIR/add_rpm_repo.sh

filter_from_requires dnf gconftool-2 gnomevfs-info kfile rpmkeys yum

#use_system_xdg $PRODUCTDIR/mime/xdg-utils
remove_dir $PRODUCTDIR/mime/xdg-utils

for i in planmaker presentations textmaker ; do
    install_file $PRODUCTDIR/mime/$i-$VERSION.desktop /usr/share/applications/$i-$VERSION.desktop
done

cd $BUILDROOT$PRODUCTDIR || fatal

epm install --skip-installed xdg-utils

THEME=hicolor
# as in desktop files
FREENAME=free
for i in 16 24 32 48 64 128 256 512 1024 ; do
    for app in prl tml pml ; do
        install_file icons/${app}_$i.png /usr/share/icons/$THEME/${i}x${i}/apps/application-x-"$app"21"$FREENAME".png
    done
done

# TODO: improve mime associations, icons

install_mimetypes_icon()
{
    local size="$1"
    shift
    local app="$1"
    shift

    local v
    for v in $* ; do
        install_file icons/${app}_$size.png /usr/share/icons/$THEME/${size}x${size}/mimetypes/$v.png
    done
}

for i in 48 16 32 64 128 ; do
    install_mimetypes_icon $i tmd application-x-tmd application-x-tmv

# app='tmd_mso'
#                    for VAR in application-rtf text-rtf application-msword application-msword-template application-vnd.ms-word application-x-doc application-x-pocket-word application-vnd.openxmlformats-officedocument.wordprocessingml.document application-vnd.openxmlformats-officedocument.wordprocessingml.template application-vnd.ms-word.document.macroenabled.12 application-vnd.ms-word.template.macroenabled.12 ; do
# app='tmd_oth'
#                    for VAR in application-x-pocket-word application-vnd.oasis.opendocument.text text-rtf application-vnd.sun.xml.writer application-vnd.sun.xml.writer.template application-vnd.wordperfect application-vnd.oasis.open

    install_mimetypes_icon $i pmd application-x-pmd application-x-pmv application-x-pmdx application/x-pagemaker

# app='pmd_mso'
#                    for VAR in application-x-sylk application-excel application-x-excel application-x-ms-excel application-x-msexcel application-x-xls application-xls application-vnd.ms-excel application-vnd.openxmlformats-officedocument.spreadsheetml.sheet application-vnd.openxmlformats-officedocument.spreadsheetml.template application-vnd.ms-excel.sheet.macroenabled.12 application-vnd.ms-excel.template.macroenabled.12 text-spreadsheet ; do
# app='pmd_oth'
#                    for VAR in text-csv application-x-dif application-x-prn application-vnd.stardivision.calc ; do

    install_mimetypes_icon $i prd application-x-prd application-x-prs application-x-prv

# app='prd_mso'
#                    for VAR in application-ppt application-mspowerpoint application-vnd.ms-powerpoint application-vnd.ms-powerpoint.presentation.macroenabled.12 application-vnd.ms-powerpoint.slideshow.macroEnabled.12 application-vnd.openxmlformats-officedocument.presentationml.presentation application-vnd.openxmlformats-officedocument.presentationml.template application-vnd.openxmlformats-officedocument.presentationml.slideshow ; do
done

# CHECKME
install_file $PRODUCTDIR/mime/softmaker-freeoffice21.xml /usr/share/mime/application/softmaker-freeoffice21.xml
install_file $PRODUCTDIR/mime/softmaker-freeoffice21.mime /usr/share/mime-info/softmaker-freeoffice21.mime

epm tool erc dwr.tar.lzma || fatal
# override stub files
mv -v dwr.tar/* . || fatal
remove_file dwr.tar.lzma

