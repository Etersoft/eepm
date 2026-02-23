#!/bin/bash

# TODO: use epm from the sources

fatal()
{
    exit 1
}

[ -n "$LOGDIR" ] || LOGDIR=~
TDIR=$LOGDIR/epm-play-versions
EDIR=$LOGDIR/epm-errors
LDIR=$LOGDIR/epm-logs
RDIR=$LOGDIR/epm-requires
FDIR=$LOGDIR/epm-filelist
mkdir -p $TDIR/ $EDIR/ $LDIR/ $RDIR/ $FDIR/

rm -f $EDIR/errors.txt

# run with EPM=/usr/bin/epm to test package
[ -n "$EPM" ] || EPM=$(realpath $(dirname $0)/../bin/epm)

install_app()
{
    local app="$1"
    local applog="$1"
    local alt="$2"
    [ -n "$alt" ] && applog="$applog=$alt" && alt=" = $alt"

    echo -n "epm play $playopt $app $alt ..."
    $EPM play $playopt --verbose --auto $app $alt >$EDIR/$applog 2>&1
    local RES=$?
    [ "$RES" = 0 ] && echo "OK" || echo "FAILED"
    [ "$RES" = 0 ] || return $RES

    mv -f $EDIR/$applog $LDIR/$applog

    local pkgname="$($EPM play --package-name $app $alt)"
    # get version and release from installed package
    local version="$($EPM print version for package $pkgname)"
    local release="$($EPM print release for package $pkgname)"
    # extract RELEASE (everything after epm1.repacked.)
    local pkgrel=$(echo "$release" | sed -n 's/epm1\.repacked\.//p')
    # write "VERSION RELEASE" format
    echo "$version $pkgrel" > $TDIR/$pkgname 2>$EDIR/$pkgname && rm -f $EDIR/$pkgname
    [ -s $TDIR/$pkgname ] || echo "empty file $TDIR/$pkgname" >>$EDIR/errors.txt
    $EPM req $pkgname >$RDIR/$applog
    $EPM ql $pkgname >$FDIR/$applog
}

install_app_alt()
{
    local app="$1"
    local productalt="$($EPM play $playopt --product-alternatives $app)"

    if [ -z "$productalt" ] ; then
        install_app $app
        return
    fi

    # оставляем дефолтный вариант в конце в системе
    for i in $productalt "" ; do
        $EPM play $playopt --remove --auto $app
        install_app $app $i
    done
}

if [ "$1" = "--ipfs" ] ; then
    playopt="$1"
    shift
fi

if [ "$1" = "--force" ] ; then
    playopt="$playopt $1"
    shift
fi

if [ "$1" = "--slow" ] ; then
    slow="60"
    shift
fi

if [ -n "$1" ] ; then
    install_app_alt "$1"
    exit
fi

distr="$($EPM print info -s)"
# install/update all, prioritizing apps with missing or oldest logs
sort_apps_by_log_age()
{
    local app logfile
    while read app ; do
        logfile="$LDIR/$app"
        if [ ! -f "$logfile" ] ; then
            echo "0 $app"
        else
            echo "$(stat -c %Y "$logfile") $app"
        fi
    done | sort -n | sed 's/^[^ ]* //'
}

$EPM play $playopt --list-all --short | sort_apps_by_log_age | while read app ; do
    # hack for broken gitlab-runner
    [ "$distr" != "alt" ] && [ "$app" = "gitlab-runner" ] && continue
    install_app_alt $app </dev/null
    [ -n "$slow" ] && sleep $slow
done

# save eepm version
$EPM --short --version > $TDIR/eepm

commit_git()
{
    cd "$1" || return
    [ -d .git ] || git init
    git add *
    git commit -m "updated"
}

commit_git $TDIR
commit_git $EDIR
commit_git $LDIR
commit_git $RDIR
commit_git $FDIR

cd $TMP
rm -rf tmp.* rpm-tmp.*

exit 0
