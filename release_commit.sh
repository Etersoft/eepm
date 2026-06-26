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

docmd ./pack_in_onefile.sh || exit

docmd git add packed
docmd git commit packed -m "commit packed $version"

docmd push_tag $version
docmd gpush pub.github


docmd rpmpub /var/ftp/pub/Korinf/sources
#rpmpub /var/ftp/pub/Etersoft/EPM/$baseversion/sources

docmd ssh builder@builder /srv/builder/Projects/korinf/bin-common/eepm.sh x86_64/ALTLinux/Sisyphus || exit

# publication to the Additives repo is disabled
#docmd epm repo pkgupdate /var/ftp/pub/Etersoft/XimperLinux/Current/Additives /var/ftp/pub/Korinf/x86_64/ALTLinux/Sisyphus/eepm-*.rpm
#docmd epm repo index /var/ftp/pub/Etersoft/XimperLinux/Current/Additives
#/home/lav/Projects/XimperLinux/repo-scripts/additives-genbasedir-sign.sh /var/ftp/pub/Etersoft/XimperLinux/Current/Additives
