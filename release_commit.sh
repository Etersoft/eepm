#!/bin/sh

# load common functions, compatible with local and installed script
. /usr/share/eterbuild/eterbuild
load_mod spec etersoft

SPECNAME=eepm.spec
version="$(get_version $SPECNAME)"

git add packed
git commit packed -m "commit packed $version"
git tag -a "$version" -e -m "$(rpmlog --last-changelog)"
git push pub.github $version
