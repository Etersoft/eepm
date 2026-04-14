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
LOCKDIR=$LOGDIR/epm-locks
mkdir -p $TDIR/ $EDIR/ $LDIR/ $RDIR/ $FDIR/ $LOCKDIR/

rm -f $EDIR/errors.txt

# run with EPM=/usr/bin/epm to test package
[ -n "$EPM" ] || EPM=$(realpath $(dirname $0)/../bin/epm)

install_app()
{
    local app="$1"
    local applog="$1"
    local alt="$2"
    [ -n "$alt" ] && applog="$applog=$alt" && alt=" = $alt"

    # skip if another instance is already building this app
    local lockfile="$LOCKDIR/$app.lock"
    exec 9>"$lockfile"
    if ! flock -n 9 ; then
        echo "epm play $playopt $app $alt ...SKIPPED (locked)"
        exec 9>&-
        return 0
    fi

    # remove before reinstall so --force is not needed (reqstoplist works without --force)
    $EPM play --remove --auto $app $alt >/dev/null 2>&1

    echo -n "epm play $playopt $app $alt ..."
    echo "$app$alt" > $LOGDIR/epm-current
    timeout 1h $EPM --allow-remove play $playopt --verbose --auto $app $alt >$EDIR/$applog 2>&1
    local RES=$?
    [ "$RES" = 0 ] && echo "OK" || echo "FAILED"
    [ "$RES" = 0 ] || { rm -f $LOGDIR/epm-current ; exec 9>&- ; return $RES ; }

    rm -f $LOGDIR/epm-current
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

    exec 9>&-
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

while [ -n "$1" ] ; do
    case "$1" in
        --ipfs)
            playopt="$playopt $1"
            ;;
        --slow)
            slow="60"
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ -n "$1" ] ; then
    install_app_alt "$1"
    exit
fi

distr="$($EPM print info -s)"
# install/update all, prioritizing apps with missing or oldest logs
sort_apps_by_log_age()
{
    local app logtime errtime ts
    while read app ; do
        logtime=0
        errtime=0
        [ -f "$LDIR/$app" ] && logtime=$(stat -c %Y "$LDIR/$app")
        [ -f "$EDIR/$app" ] && errtime=$(stat -c %Y "$EDIR/$app")
        # use the most recent of success/error log
        ts=$logtime
        [ "$errtime" -gt "$ts" ] && ts=$errtime
        echo "$ts $app"
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
