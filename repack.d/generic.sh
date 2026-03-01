#!/bin/sh -x

# Generic repack script. Called before special script.

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"
SUBGENERIC="$5"

# firstly, pack $PRODUCTDIR if used
. $(dirname $0)/common.sh

# Security: reject packages containing .eepm.yaml (could be used for command injection)
if find "$BUILDROOT" -name "*.eepm.yaml" 2>/dev/null | grep -q . ; then
    fatal "Package contains .eepm.yaml file which is not allowed (security risk)"
fi

# commented out: conflicts with already installed package
# drop %dir for existed system dirs
#for i in $(grep '^%dir "' $spec | sed -e 's|^%dir  *"\(.*\)".*|\1|' ) ; do #"
#    echo "$i" | grep -q '^/opt/' && continue
#    [ -d "$i" ] && [ -n "$verbose" ] && echo "drop dir $i from packing, it exists in the system"
#done

# replace dir "/path/dir" -> %dir "/path/dir"
grep '^"/' $SPEC | sed -e 's|^"\(/.*\)"$|\1|' | while read i ; do
    # add dir as %dir in the filelist
    if [ -d "$BUILDROOT$i" ] && [ ! -L "$BUILDROOT$i" ] ; then
        subst "s|^\(\"$i\"\)$|%dir \1|" $SPEC
    fi
done

# replace dir /path/dir -> %dir /path/dir
grep '^/' $SPEC | while read i ; do
    # add dir as %dir in the filelist
    if [ -d "$BUILDROOT$i" ] && [ ! -L "$BUILDROOT$i" ] ; then
        subst "s|^\($i\)$|%dir \1|" $SPEC
    fi
done

__icons_res_list="apps scalable symbolic 8x8 14x14 16x16 20x20 22x22 24x24 28x28 32x32 36x36 42x42 45x45 48x48 64 64x64 72x72 96x96 128x128 144x144 160x160 192x192 256x256 256x256@2x 480x480 512 512x512 1024x1024"
__icons_type_list="actions animations apps categories devices emblems emotes filesystems intl mimetypes places status stock"

__get_icons_hicolor_list()
{
    local i j
    for i in ${__icons_res_list} ; do
        echo "/usr/share/icons/hicolor/$i"
        for j in ${__icons_type_list}; do
            echo "/usr/share/icons/hicolor/$i/$j"
        done
    done
}

__get_icons_gnome_list()
{
    local i j
    for i in ${__icons_res_list} ; do
        echo "/usr/share/icons/gnome/$i"
        for j in ${__icons_type_list}; do
            echo "/usr/share/icons/gnome/$i/$j"
        done
    done
}

# drop forbidded paths
# https://bugzilla.altlinux.org/show_bug.cgi?id=38842
for i in / /etc /etc/init.d /etc/systemd /bin /opt /usr /usr/bin /usr/lib /usr/lib64 /usr/share /usr/share/doc /var /var/log /var/run \
        /etc/cron.daily /usr/share/pixmaps /usr/share/man /usr/share/man/man1 /usr/share/appdata /usr/share/applications /usr/share/menu \
        /usr/share/mime /usr/share/mime/packages /usr/share/icons \
        /usr/share/icons/gnome $(__get_icons_gnome_list) \
        /usr/share/icons/hicolor $(__get_icons_hicolor_list) ; do
    sed -i \
        -e "s|/\./|/|" \
        -e "s|^%dir[[:space:]]\"$i/*\"$||" \
        -e "s|^%dir[[:space:]]$i/*$||" \
        -e "s|^\"$i/*\"$||" \
        -e "s|^$i/*$||" \
        $SPEC
done

# Arch clean
for i in /.BUILDINFO /.MTREE /.PKGINFO ; do
    remove_file $i
done

flag_python3=''

for i in lib/python3 lib/python2.7 ; do
    t=$i
    if [ -d $BUILDROOT/usr/$i/dist-packages ] ; then
        mv -v $BUILDROOT/usr/$i/dist-packages $BUILDROOT/usr/$t/site-packages
        subst "s|/usr/$i/dist-packages|/usr/$t/site-packages|" $SPEC
    fi
done

# move Debian multiarch lib paths to standard paths (not needed for deb target)
if [ "$(epm print info -p)" != "deb" ] ; then
    move_dir /usr/lib/x86_64-linux-gnu /usr/lib64
    move_dir /usr/lib/i386-linux-gnu /usr/lib
fi

for i in $BUILDROOT/usr/bin/* ; do
    [ -L "$i" ] && continue
    [ -f "$i" ] || continue
    if ! [ -x "$i" ] ; then
        warning "file ${i#$BUILDROOT} is not executable, fixing"
        chmod a+x "$i"
    fi
    grep -Eq '^#!/usr/bin/python|^#!/usr/bin/env python' $i && flag_python3=1
    subst 's|^#!/usr/bin/python$|#!/usr/bin/python3|' $i
    subst 's|^#!/usr/bin/env python$|#!/usr/bin/env python3|' $i
done

# check for .py scripts
find $BUILDROOT -name "*.py" | grep -q "\.py$" && flag_python3=1
# can't use subst in find's exec (subst can be as function only)
find $BUILDROOT -name "*.py" -exec sed -i -e '1{/python3/n};1i#!/usr/bin/python3' {} \;

if [ -n "$flag_python3" ] ; then
    if [ "$(epm print info -s)" = "alt" ] && [ -z "$EPM_RPMBUILD" ] ; then
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

# disable /usr/lib/.build-id generating
subst "1i%global _build_id_links none" $SPEC

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
summary="$(grep "^Summary: " $SPEC | sed -e "s|Summary: ||g" | head -n1)"
[ -n "$summary" ] || set_rpm_field "Summary" "$PRODUCT (fixme: was empty Summary after alien)"
set_rpm_field "Distribution" "EEPM"

# for deb/rpm (alien path): update description with repack info
if [ -z "$SUBGENERIC" ] ; then
    subst "s|^\((Converted from a\) \(.*\) \(package.*\)|(Repacked from binary \2 package with EPM $(epm --short --version))\n\1 \2 \3|" $SPEC
fi

# for appimage/tar: replace dash with tilde in version suffix (like -b1 -> ~b1) for correct version comparison
# for rpm/deb: suffix is already in Release field
version=$(grep "^Version:" $SPEC | sed 's/Version: //')
if [ -n "$SUBGENERIC" ] && echo "$version" | grep -q '-' ; then
    new_version=$(echo "$version" | sed 's/-/~/')
    subst "s|^Version: $version|Version: $new_version|" $SPEC
fi
# add our prefix to release (preserves original release for rpm/deb)
subst "s|^Release: |Release: epm1.repacked.|" $SPEC

if ! grep "^%defattr" $SPEC ; then
    subst "s|^%files$|%files\n%defattr(-,root,root,755)|" $SPEC
fi

# only for rpm
if [ -z "$SUBGENERIC" ] ; then
    fix_cpio_bug_links
fi
