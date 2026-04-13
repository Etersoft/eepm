#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

untar_payload()
{
    match=$(grep --text --line-number '^PAYLOAD:$' $1 | cut -d ':' -f 1)
    payload_start=$((match + 1))
    tail -n +$payload_start $1 | tar -zxvf -
}

ROOTDIR=$(pwd)

# Linux-драйвер-сканирования-Катюша-M247.zip
erc --here unpack $TAR || fatal 
mv Linux*/Katusha_Scanner_M247_ubuntu64_*.tar.gz .
rmdir Linux*

# Katusha_Scanner_M247_ubuntu64_V110.tar.gz
erc --here unpack Katusha_Scanner_M247_ubuntu64_*.tar.gz || fatal
rm Katusha_Scanner_M247_ubuntu64_*.tar.gz

cd Katusha_Scanner_M247_ubuntu64_*/ || fatal

# needed to extract deb package
untar_payload LinuxInstaller_x86_64.sh

# sane-1.0-27.x86-64
cd "$(ls -d sane*/)" || fatal

# check if sane-1.0-27.x86-64.deb exist
DEBNAME="$(echo sane*.deb)"
[ -s "$DEBNAME" ] || fatal

BASENAME=$(basename $DEBNAME deb)
VERSION=$(echo $BASENAME | sed -e 's|sane-||'| sed -e 's|.x86-64.||')
PKGNAME=${PRODUCT}-${VERSION}

# needed because the path contains spaces
mv $DEBNAME $ROOTDIR/$PKGNAME.deb

cd $ROOTDIR

# erc unpack supports deb unpacking only via patool
epm assure patool || fatal

# needed because the control file have issues
erc --here unpack $PKGNAME.deb || fatal
# avoid cd to deb
rm $PKGNAME.deb
cd "$(ls -d katusha*/)" || fatal

SANELIB=usr/lib/sane
if [ "$(epm print info -b)" = "64" ] ; then
    SANELIB=usr/lib64/sane
    [ -d /usr/lib/x86_64-linux-gnu ] && SANELIB=usr/lib/x86_64-linux-gnu/sane
fi

mkdir -p "$SANELIB"
if [ -d usr/lib/x86_64-linux-gnu/sane ] && [ "$SANELIB" != "usr/lib/x86_64-linux-gnu/sane" ] ; then
    mv usr/lib/x86_64-linux-gnu/sane/* "$SANELIB/"
    rmdir usr/lib/x86_64-linux-gnu/sane
fi
rm -r usr/lib/x86_64-linux-gnu

(
    cd "$SANELIB" || fatal
    ln -s libsane-katusham247.so.1.0.27 libsane-katusham247.so
    ln -s libsane-katusham247.so.1.0.27 libsane-katusham247.so.1
    rm libsane-katusham247.la
)

mkdir -p etc/sane.d/dll.d
echo "katusham247" > etc/sane.d/dll.d/katusham247
chmod a+rw etc/udev/rules.d/65-scanner.rules


erc pack $PKGNAME.tar etc usr || fatal
return_tar $PKGNAME.tar
