#!/bin/sh

BASEPKGNAME=postgrespro-1c
PRODUCTALT="18 17 16 15 14"
SUPPORTEDARCHES="x86_64"
SKIPREPACK=1
VERSION="$2"
DESCRIPTION="PostgreSQL for 1C from Postgres Professional"
URL="https://postgrespro.ru/products/1c"
TIPS="Run 'epm play postgrespro-1c=17' to install major version 17, 'epm play postgrespro-1c=17.5' to install exact version 17.5."

REPO="https://repo.postgrespro.ru/1c"

# epm play postgrespro-1c=17.5: the major version selects the package (postgrespro-1c-17)
case "$VERSION" in
    *.*)
        PGVERSION="$VERSION"
        VERSION="${VERSION%%.*}"
        ;;
esac

# used by common.sh to check for updates (within the installed major version only)
get_target_version()
{
    if [ -n "$PGVERSION" ] ; then
        echo "$PGVERSION"
        return
    fi
    fetch_url "$REPO/1c-$BRANCH/meta.json" | grep '"version"' | sed -e 's|.*"version": *"\([^"]*\)".*|\1|' | head -n1
}

# used by common.sh to remove all installed packages, not only the metapackage
get_remove_packages()
{
    echo "$PKGNAME-contrib $PKGNAME-server $PKGNAME-client $PKGNAME-libs"
}

. $(dirname $0)/common.sh

VERSION="$(get_target_version)"
[ -n "$VERSION" ] || fatal "Can't get version of $PKGNAME"
[ "${VERSION%%.*}" = "$BRANCH" ] || fatal "Version $VERSION does not belong to $PKGNAME"

# all released versions (including the latest one) are in the archive
BASEURL="$REPO/archive/1c-$VERSION"

pkgtype=rpm
arch=x86_64
tag=''
case "$(epm print info -e)" in
    ALTLinux/c10f*)
        dir="altlinux-spt/10/x86_64/RPMS.pgpro"
        ;;
    ALTLinux/p10)
        dir="altlinux/10/x86_64/RPMS.pgpro"
        ;;
    ALTLinux/p11|ALTLinux/Sisyphus)
        dir="altlinux/11/x86_64/RPMS.pgpro"
        ;;
    AstraLinuxSE/1.7*)
        pkgtype=deb
        dir="astra-smolensk/1.7/pool/main/p/$PKGNAME"
        ;;
    AstraLinuxSE/1.8*)
        pkgtype=deb
        dir="astra-smolensk/1.8/pool/main/p/$PKGNAME"
        ;;
    Debian/*|Ubuntu/*)
        pkgtype=deb
        dir="$(epm print info -s)/pool/main/p/$PKGNAME"
        tag=".$(epm print info --repo-name)"
        ;;
    RedOS/7.3*)
        dir="redos/7.3/os/x86_64/rpms"
        ;;
    RedOS/8*)
        dir="redos/8/os/x86_64/rpms"
        ;;
    ROSA/2021.1)
        dir="rosa/2021.1/os/x86_64/rpms"
        ;;
    AlmaLinux/*|CentOS/*|MSVSphere/*|Oracle/*|RHEL/*|RockyLinux/*)
        dir="rhel/$(epm print info --base-version)/os/x86_64/rpms"
        ;;
    SLES/15*|openSUSE/15*)
        dir="sles/15"
        ;;
    SLES/16*|openSUSE/16*)
        dir="sles/16"
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac
[ "$pkgtype" = "deb" ] && arch=amd64

files="$(fetch_url "$BASEURL/$dir/" | grep -o "href=\"[^\"]*\.$pkgtype\"" | sed -e 's|^href="||' -e 's|"$||')"
[ -n "$files" ] || fatal "$PKGNAME $VERSION is not available for $(epm print info -e)"

# print the file name of package $1 (version $2, may be a glob) from the listing
get_file()
{
    local i
    for i in $files ; do
        case "$i" in
            $1-$2-*.$arch.rpm|$1_$2-*${tag}_$arch.deb)
                echo "$i"
                return
                ;;
        esac
    done
    return 1
}

PKGURL=''
for i in '' -libs -client -server -contrib ; do
    file="$(get_file "$PKGNAME$i" "$VERSION")" || fatal "Can't find $PKGNAME$i $VERSION in $BASEURL/$dir"
    PKGURL="$PKGURL $BASEURL/$dir/$file"
done

# helper libraries, missed in RHEL-like and SUSE distros, are shipped by vendor
for i in libbacktrace:libbacktrace.so.0 libunwind:libunwind.so.8 ; do
    is_soname_present "${i#*:}" && continue
    file="$(get_file "${i%%:*}" "*")" || continue
    PKGURL="$PKGURL $BASEURL/$dir/$file"
done

if [ -n "$print_url" ] ; then
    echo "$PKGURL"
    exit 0
fi

# pgpro_tune (run by initdb from the package script) uses free, but packages don't require it
epm assure free procps || fatal

# vendor packages are built for every supported distro, install them as is:
# their scripts create postgres user, initialize the database and enable the service
epm install $PKGURL || exit

cat <<EOF

Note:
Postgres Pro for 1C $VERSION is installed into /opt/pgpro/1c-$BRANCH,
the database is in /var/lib/pgpro/1c-$BRANCH/data.
If the database is not initialized yet (Debian and Ubuntu packages don't do it), run:
    # /opt/pgpro/1c-$BRANCH/bin/pg-setup initdb
    # /opt/pgpro/1c-$BRANCH/bin/pg-setup service enable
    # /opt/pgpro/1c-$BRANCH/bin/pg-setup service start
EOF
