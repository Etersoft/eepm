#!/bin/sh

PKGNAME=ascon-kompas-study-v25
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="KOMPAS-3D Study (educational version) from the official site"
URL="https://edu.ascon.ru/main/download/freeware/"
REPOURL="https://repo.ascon.ru/stable"
PERSONALREPOURL="https://repo.ascon.ru/personal"

# KOMPAS-3D with the study version configuration (selective install from the Ascon manual).
# The full set (ascon-kompas3d-study-v25-full) needs about 40 GB with the Polynom library.
PKGLIST="ascon-kompas3d-v25 $PKGNAME"

. $(dirname $0)/common.sh

# Ascon packages needed for KOMPAS-3D Study (from the stable repo, the last one is from the personal repo)
REPACKLIST="ascon-helpserver ascon-kompas-common ascon-kompas-fonts ascon-kompas-graphic-v25 ascon-kompas-plugins-v25 ascon-kompas3d-v25"

# print URL of the latest package $1 from Ascon RedOS repo $2
get_ascon_rpm_url()
{
    local url="$2/rpm/redos/8.0"
    local file
    file="$(get_rpm_repo_latest_file "$url" "$1-[0-9][^\"]*\.x86_64\.rpm")"
    [ -n "$file" ] || fatal "Can't find $1 package in $url"
    echo "$url/$file"
}

# repack RedOS packages for other distros (the package scripts are dropped on repack)
install_repacked()
{
    local i urls=''
    for i in $REPACKLIST ; do
        urls="$urls $(get_ascon_rpm_url $i "$REPOURL")" || exit
    done
    urls="$urls $(get_ascon_rpm_url $PKGNAME "$PERSONALREPOURL")" || exit

    export EEPM_INTERNAL_PKGNAME="$REPACKLIST $PKGNAME"
    epm install --repack $urls || exit

    # postinst of ascon-kompas-graphic: KOMPAS-3D aborts without CP1251 locale
    locale -a 2>/dev/null | grep -qi '^ru_RU\.cp1251$' && return
    case $(epm print info -g) in
        dnf-*|dnf5-*|yum-*)
            epm install --skip-installed glibc-locale-source
            ;;
        zypper-*)
            epm install --skip-installed glibc-i18ndata
            ;;
    esac
    esu localedef -i ru_RU -f CP1251 ru_RU.CP1251 || fatal 'Can'\''t generate ru_RU.CP1251 locale needed for KOMPAS-3D. Install glibc locale sources and run: localedef -i ru_RU -f CP1251 ru_RU.CP1251'
}

# The study version is in the personal repo, but requires packages from the stable repo,
# so both are added to the same disabled named repository used for ascon/<package> installs.
case $(epm print info -e) in
    ALTLinux/p10|ALTLinux/c10f*)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add --disabled --name ascon "rpm [ascon] $REPOURL/alt/ p10/x86_64 main"
        epm repo add --disabled --name ascon "rpm [ascon] $PERSONALREPOURL/alt/ p10/x86_64 main"
        ;;
    ALTLinux/p11|ALTLinux/Sisyphus)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add --disabled --name ascon "rpm [ascon] $REPOURL/alt/ p11/x86_64 main"
        epm repo add --disabled --name ascon "rpm [ascon] $PERSONALREPOURL/alt/ p11/x86_64 main"
        ;;
    RedOS/8.0)
        # Ascon signs the repo metadata only, packages are signed by a not published key
        # (repo_gpgcheck as in the Ascon install script)
        cd_to_temp_dir
        for i in ascon:$REPOURL ascon-personal:$PERSONALREPOURL ; do
            cat <<EOF
[${i%%:*}]
name=${i%%:*}
baseurl=${i#*:}/rpm/redos/8.0/
gpgcheck=0
repo_gpgcheck=1
gpgkey=${i#*:}/rpm/ascon.gpg
EOF
        done > ascon.repo
        epm repo add "$PKGDIR/ascon.repo" || exit
        cd - >/dev/null || fatal
        ;;
    *)
        case $(epm print info -g) in
            apt-dpkg)
                # Ascon repo is for Astra Linux 1.8 (Debian 12 based), use it on any deb based distro
                epm repo addkey "$REPOURL/deb/ascon.gpg"
                epm repo add --disabled --name ascon "deb [signed-by=/etc/apt/trusted.gpg.d/ascon.gpg] $REPOURL/deb 1.8_x86-64 main"
                epm repo add --disabled --name ascon "deb [signed-by=/etc/apt/trusted.gpg.d/ascon.gpg] $PERSONALREPOURL/deb 1.8_x86-64 main"
                ;;
            *)
                install_repacked
                exit
                ;;
        esac
        ;;
esac

case $(epm print info -g) in
    apt-rpm)
        # Ascon RPMs omit post-install dependencies on fc-cache and CP1251 maps,
        # and some X libraries linked by KOMPAS-3D binaries.
        epm install --skip-installed fontconfig glibc-locales \
            libXScrnSaver libXv libfontenc libxcbutil-icccm libxcbutil-keysyms libxkbfile || exit
        epm install $(printf 'ascon/%s ' $PKGLIST) || exit
        ;;
    apt-dpkg)
        # Ascon postinst scripts run locale-gen (CP1251 locale) and update-desktop-database,
        # and some libraries linked by KOMPAS-3D binaries are not in the package dependencies.
        epm install --skip-installed locales desktop-file-utils \
            libatomic1 libxcb-res0 libxcb-xkb1 || exit
        epm install $(printf 'ascon/%s ' $PKGLIST) || exit
        ;;
    *)
        epm update
        # Ascon postinst scripts run fc-cache and update-mime-database,
        # and some libraries linked by KOMPAS-3D binaries are not in the package dependencies.
        epm install --skip-installed fontconfig shared-mime-info \
            libXScrnSaver libXv libXxf86vm libdrm libfontenc libglvnd-glx libxkbfile xcb-util-keysyms xcb-util-wm || exit
        epm install $PKGLIST || exit
        ;;
esac
