#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Lexmark-UPD-PPD-Files-1.0-05252022.x86_64.rpm
BASENAME=$(basename $TAR .rpm)
VERSION=$(echo $BASENAME | sed -e 's|Lexmark-UPD-PPD-Files-||' | sed -e 's|.x86_64||')

erc unpack $TAR || fatal

# Install PPDs
# PPD_ROOT="usr/share/ppd"
PPD_ROOT="usr/share/cups/model"
mkdir opt
install -Dm644 -t "$PPD_ROOT/Lexmark_PPD/" usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/GlobalPPD_1.4/*.ppd

# Install filter scripts
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/GlobalPPD_1.4/LexFaxPnHFilter"
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/GlobalPPD_1.4/queueCreation.sh"

# Install filter bins
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/GlobalPPD_1.4/lib64/LexCommandFileFilterG2"
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/GlobalPPD_1.4/lib64/cupsversion"

# Install license file
install -Dm644 -t "usr/share/doc/$PRODUCT/" "usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/License_EU2-0111-en.txt"
install -Dm644 -t "usr/share/doc/$PRODUCT/" "usr/local/Lexmark/ppd/Lexmark-UPD-PPD-Files/License_EU2-0111-ru.txt"
rm -fr usr/local

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr opt || fatal

return_tar $PKGNAME.tar
