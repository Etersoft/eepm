#!/bin/sh

# Usage: remove_file <path_to_file>
remove_file()
{
    local file="$1"
    [ -f $BUILDROOT/$file ] || return

    rm -fv $BUILDROOT/$file
    subst "s|.*$file.*||" $SPEC
}


# Usage: pack_file <path_to_file>
pack_file()
{
    grep -q "^$1$" $SPEC && return
    grep -q "\"$1\"" $SPEC && return
    subst "s|%files|%files\n$1|" $SPEC
}


add_bin_link_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e $BUILDROOT/usr/bin/$name ] && return

    mkdir -p $BUILDROOT/usr/bin/
    ln -s $target $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}


add_bin_exec_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e $BUILDROOT/usr/bin/$name ] && return

    mkdir -p $BUILDROOT/usr/bin/
    echo "exec $target \"\$@\"" > $BUILDROOT/usr/bin/$name
    chmod 0755 $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}

# move files to $PRODUCTDIR
move_to_opt()
{
    local from="$1"
    [ -n "$from" ] || from="/usr/share/$PRODUCT"
    mkdir -p $BUILDROOT$PRODUCTDIR/
    mv $BUILDROOT/$from/* $BUILDROOT$PRODUCTDIR/
    subst "s|$from|$PRODUCTDIR|g" $SPEC
}

