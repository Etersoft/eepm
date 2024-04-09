#!/bin/sh

# load common functions, compatible with local and installed script
. /usr/share/eterbuild/eterbuild
load_mod spec etersoft

push_tag()
{
    local version="$1"
    git tag -a "$version" -e -s -m "$(rpmlog -q --last-changelog | sed -e 's|^* ||')"
    git push pub.github $version
    git push pub.gitlab $version
}

if [ -n "$1" ] ; then
    [ "$(git tag -l "$1")" = "$1" ] || fatal "Can't find tag '$1' in the repo."
    push_tag $1
    exit
fi

SPECNAME=eepm.spec
version="$(get_version $SPECNAME)"
baseversion=$(echo "$version" | sed -e 's|\.[0-9]*$||')
minorversion=$(echo "$baseversion" | sed -e 's|.*\.||')

[ "$((minorversion%2))" = 1 ] && version="$version-beta"

./pack_in_onefile.sh || exit

git add packed
git commit packed -m "commit packed $version"

push_tag $version
gpush pub.github


rpmpub /var/ftp/pub/Korinf/sources
#rpmpub /var/ftp/pub/Etersoft/EPM/$baseversion/sources
