#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

# firstly, pack $PRODUCTDIR if used
. $(dirname $0)/common.sh

flag_python3=''

for i in lib/python3 lib/python2.7 ; do
    t=$i
    if [ -d $BUILDROOT/usr/$i/dist-packages ] ; then
        mv -v $BUILDROOT/usr/$i/dist-packages $BUILDROOT/usr/$t/site-packages
        subst "s|/usr/$i/dist-packages|/usr/$t/site-packages|" $SPEC
    fi
done

for i in $BUILDROOT/usr/bin/* ; do
    [ -L "$i" ] && continue
    [ -f "$i" ] || continue
    grep -Eq '^#!/usr/bin/python|^#!/usr/bin/env python' $i && flag_python3=1
    subst 's|^#!/usr/bin/python$|#!/usr/bin/python3|' $i
    subst 's|^#!/usr/bin/env python$|#!/usr/bin/env python3|' $i
done

# check for .py scripts
find $BUILDROOT -name "*.py" | grep -q "\.py$" && flag_python3=1
# can't use subst in find's exec (subst can be as function only)
find $BUILDROOT -name "*.py" -exec sed -i -e '1{/python3/n};1i#!/usr/bin/python3' {} \;

if [ -n "$flag_python3" ] ; then
    if [ "$(epm print info -s)" = "alt" ] ; then
        epm install --skip-installed rpm-build-python3
        subst "1i%add_python3_lib_path /usr" $SPEC
        # by some unknown reason there are no packages provide that (https://github.com/Etersoft/eepm/issues/22)
        subst "1i%add_python3_req_skip gi.repository.GLib" $SPEC
    fi
fi

# hack:
# TODO: check for tarball, detect root dir
#echo $BUILDROOT | grep -q "tar.*tmpdir/" && move_to_opt /liteide

# no auto req/prov by default
set_autoreq no
set_autoprov no

# Set high Epoche to override repository package
subst "s|^\(Name: .*\)$|# Override repository package\nEpoch: 100\n\1|g" $SPEC

[ -d $BUILDROOT/usr/lib/.build-id ] && remove_dir /usr/lib/.build-id || :

# disablle rpmlint (for ROSA)
subst "1i%global _build_pkgcheck_set %nil" $SPEC
subst "1i%global _build_pkgcheck_srpm %nil" $SPEC

set_rpm_field()
{
    local field="$1"
    local value="$2"
    if grep -q "^$field:" $SPEC ; then
        [ -n "$value" ] || return
        subst "s|^$field:.*|$field: $value|" $SPEC
    else
        [ -n "$value" ] || value="Stub"
        subst "1i$field: $value" $SPEC
    fi
}


# FIXME: where is a source of the bug with empty Summary?
set_rpm_field "Summary" "$PRODUCT (fixme: was empty Summary after alien)"
# clean version
subst "s|^\(Version: .*\)~.*|\1|" $SPEC
# add our prefix to release
subst "s|^Release: |Release: epm1.repacked.|" $SPEC
set_rpm_field "Distribution" "EEPM"


if [ -r "$PKG.eepm.yaml" ] ; then
    eval $(epm tool yaml $PKG.eepm.yaml | grep -E '(summary|description|upstream_file|upstream_url|url|appname|arches|group|license)=' ) #'
    # for tarballs fix permissions
    chmod $verbose -R a+rX *

    set_rpm_field "Group" "$group"
    set_rpm_field "License" "$license"
    set_rpm_field "URL" "$url"
    set_rpm_field "Summary" "$summary"
    [ -n "$upstream_file" ] || upstream_file="binary package $PRODUCT"
    [ -n "$upstream_url" ] && upstream_file="$upstream_url"
    [ -n "$description" ] && subst "s|^\((Converted from a\) \(.*\) \(package.*\)|$description\n(Repacked from $upstream_file with $(epm --short --version))\n\1 \2 \3|" $SPEC
else
    subst "s|^\((Converted from a\) \(.*\) \(package.*\)|(Repacked from binary \2 package with $(epm --short --version))\n\1 \2 \3|" $SPEC
fi

fix_cpio_bug_links
