#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

fix_desktop_file "Categories=.*" "Categories=Office;Viewer;"

# installed or available in the repo
has_soname()
{
    is_soname_present "$1" && return
    [ -n "$(epm whatprovides "$1()(64bit)" 2>/dev/null)" ]
}

# 2026.39+ is linked with libtesseract.so.4 (Ubuntu 22.04), uses only stable C API (TessBaseAPI*)
# use libtesseract.so.5 if there is no tesseract 4 in the system (ALT p11, Sisyphus)
if grep -q 'libtesseract\.so\.4' usr/bin/open-pdf-studio && ! has_soname libtesseract.so.4 && has_soname libtesseract.so.5 ; then
    epm assure patchelf || exit
    a='' patchelf --replace-needed libtesseract.so.4 libtesseract.so.5 usr/bin/open-pdf-studio || fatal
fi
