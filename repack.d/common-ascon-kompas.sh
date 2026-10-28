#!/bin/sh

# common part for repack KOMPAS-3D packages from the Ascon repo
# used BUILDROOT and SPEC variables

. $(dirname $0)/common.sh

# KOMPAS-3D libraries (with unversioned sonames), bundled Qt6 and libomp are shipped
# by other Ascon packages (mostly ascon-kompas-graphic) and found via RUNPATH
# (grep -w patterns for requires like libkSys.so()(64bit), without backslashes: they are lost in xargs)
ignore_lib_requires '^lib[^.]*[.]so()' '^lib[^.]*[.]so$' '^libQt6.*' '^libomp[.]so[.]5'
