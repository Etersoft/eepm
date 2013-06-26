#!/bin/sh
#
# Copyright (C) 2012  Etersoft
# Copyright (C) 2012  Vitaly Lipatov <lav@etersoft.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

PROGDIR=$(dirname $0)
[ "$PROGDIR" = "." ] && PROGDIR=$(pwd)

# will replaced to /usr/share/eepm during install
SHAREDIR=$PROGDIR

load_helper()
{
    local CMD="$SHAREDIR/$1"
    # do not use fatal() here, it can be initial state
    [ -r "$CMD" ] || { echo "FATAL: Have no $CMD helper file" ; exit 1; }
    . $CMD
}



# File bin/epm-sh-functions:

isatty()
{
	# Set a sane TERM required for tput
	[ -n "$TERM" ] || TERM=dumb
	export TERM
	test -t 1
}

check_tty()
{
	isatty || return
	which tput >/dev/null 2>/dev/null || return
	# FreeBSD does not support tput -S
	echo | tput -S >/dev/null 2>/dev/null || return
	[ -z "$USETTY" ] || return
	export USETTY=1
}

: ${BLACK:=0} ${RED:=1} ${GREEN:=2} ${YELLOW:=3} ${BLUE:=4} ${MAGENTA:=5} ${CYAN:=6} ${WHITE:=7}

set_boldcolor()
{
	[ "$USETTY" = "1" ] || return
	{
		echo bold
		echo setaf $1
	} |tput -S
}

restore_color()
{
	[ "$USETTY" = "1" ] || return
	{
		echo op; # set Original color Pair.
		echo sgr0; # turn off all special graphics mode (bold in our case).
	} |tput -S
}

echover()
{
    [ -n "$verbose" ] || return
    echo "$*" >&2
}

set_target_pkg_env()
{
	[ -n "$DISTRNAME" ] || fatal "Run set_target_pkg_env without DISTRNAME"
	PKGFORMAT=$($DISTRVENDOR -p "$DISTRNAME")
	PKGVENDOR=$($DISTRVENDOR -s "$DISTRNAME")
	RPMVENDOR=$($DISTRVENDOR -n "$DISTRNAME")
}

realpath()
{
        readlink -f "$@"
}

showcmd()
{
	if [ -z "$quiet" ] ; then
		set_boldcolor $GREEN
		local PROMTSIG="\$"
		[ "$UID" = 0 ] && PROMTSIG="#"
		echo " $PROMTSIG $@"
		restore_color
	fi >&2
}

docmd()
{
	showcmd "$@"
	"$@"
}

docmd_foreach()
{
	local cmd
	cmd="$1"
	#showcmd "$@"
	shift
	for pkg in "$@" ; do
		docmd $cmd $pkg
	done
}

sudocmd()
{
	showcmd "$SUDO $@"
	$SUDO "$@"
}

sudocmd_foreach()
{
	local cmd
	cmd="$1"
	#showcmd "$@"
	shift
	for pkg in "$@" ; do
		sudocmd $cmd $pkg
	done
}


filter_strip_spaces()
{
        # possible use just
        #xargs echo
        sed -e "s| \+| |g" | \
                sed -e "s|^ ||" | sed -e "s| \$||"
}

strip_spaces()
{
        echo "$*" | filter_strip_spaces
}

subst_option()
{
	eval "[ -n \"\$$1\" ]" && echo "$2" || echo "$3"
}

store_output()
{
    # use make_temp_file from etersoft-build-utils
    RC_STDOUT=$(mktemp)
    #RC_STDERR=$(mktemp)
    "$@" 2>&1 | tee $RC_STDOUT
    # http://tldp.org/LDP/abs/html/bashver3.html#PIPEFAILREF
    return $PIPESTATUS
}

clean_store_output()
{
    rm -f $RC_STDOUT
}


epm()
{
	$PROGDIR/epm $@
}

fatal()
{
	if [ -z "$TEXTDOMAIN" ] ; then
		echo "Error: $@" >&2
	fi
	exit 1
}

warning()
{
	if [ -z "$TEXTDOMAIN" ] ; then
		echo "Warning: $@" >&2
	fi
}

set_sudo()
{
	SUDO=""
	# skip SUDO if disabled
	[ -n "$EPMNOSUDO" ] && return

	# set SUDO not for root user
	[ -n "$UID" ] || UID=`id -u`

	# do not need sudo
	[ $UID = "0" ] && return

	# use sudo if possible
	which sudo >/dev/null 2>/dev/null && SUDO="sudo" && return

	SUDO="fatal 'Can't find sudo. Please install sudo or run epm under root.'"
}

get_help()
{
    grep -- "# $1" $0 | while read n ; do
        opt=$(echo $n | sed -e "s|) # $1:.*||g")
        desc=$(echo $n | sed -e "s|.*) # $1:||g")
        printf "    %-20s %s\n" $opt "$desc"
    done
}


set_pm_type()
{
	local CMD

	# Fill for use: PMTYPE, DISTRNAME, DISTRVERSION, PKGFORMAT, PKGVENDOR, RPMVENDOR
	DISTRVENDOR=internal_distr_info
	[ -n "$DISTRNAME" ] || DISTRNAME=$($DISTRVENDOR -d) || fatal "Can't get distro name."
	[ -n "$DISTRVERSION" ] || DISTRVERSION=$($DISTRVENDOR -v)
	set_target_pkg_env

if [ -n "$FORCEPM" ] ; then
	PMTYPE=$FORCEPM
	return
fi

case $DISTRNAME in
	ALTLinux|PCLinux)
		CMD="apt-rpm"
		#which deepsolver 2>/dev/null >/dev/null && CMD=deepsolver-rpm
		;;
	PCLinux)
		CMD="apt-rpm"
		;;
	Ubuntu|Debian|Mint)
		CMD="apt-dpkg"
		;;
	Mandriva|ROSA)
		CMD="urpm-rpm"
		;;
	FreeBSD|NetBSD|OpenBSD|Solaris)
		CMD="pkgsrc"
		;;
	Gentoo)
		CMD="emerge"
		;;
	ArchLinux)
		CMD="pacman"
		;;
	Fedora|LinuxXP|ASPLinux|CentOS|RHEL|Scientific)
		CMD="yum-rpm"
		;;
	Slackware)
		CMD="slackpkg"
		;;
	SUSE|SLED|SLES)
		CMD="zypper-rpm"
		;;
	Windows)
		CMD="chocolatey"
		;;
	MacOS)
		CMD="homebrew"
		;;
	OpenWRT)
		CMD="ipkg"
		;;
	*)
		fatal "Have no suitable DISTRNAME $DISTRNAME"
		;;
esac
PMTYPE=$CMD
}


# File bin/epm-addrepo:

epm_addrepo()
{
case $PMTYPE in
	apt-rpm)
		sudocmd apt-repo add $pkg_filenames
		;;
	apt-dpkg)
		echo "You need manually add repo to /etc/apt/sources.list"
		;;
	yum-rpm)
		echo "You need manually add repo to /etc/yum.repos.d/"
		;;
	urpm-rpm)
		sudocmd urpmi.addmedia $pkg_filenames
		;;
	zypper-rpm)
		sudocmd zypper ar $pkg_filenames
		;;
	emerge)
		sudocmd layman -a $pkg_filenames
		;;
	pacman)
		echo "You need manually add repo to /etc/pacman.conf"
		# Only for alone packages:
		#sudocmd repo-add $pkg_filenames
		;;
	npackd)
		sudocmd npackdcl add-repo --url=$pkg_filenames
		;;
	slackpkg)
		echo "You need manually add repo to /etc/slackpkg/mirrors"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-autoremove:

epm_autoremove()
{
case $PMTYPE in
	apt-rpm)
		# ALT Linux only
		sudocmd remove-old-kernels
		;;
	apt-dpkg)
		sudocmd apt-get autoremove
		;;
	aura)
		sudocmd aura -Oj
		;;
	yum-rpm)
		# cleanup orphanes?
		while true ; do
			docmd package-cleanup --leaves $(subst_option non_interactive --assumeyes)
			# FIXME: package-cleanup have to use stderr for errors
			local PKGLIST=$(package-cleanup --leaves | grep -v "Loaded plugins" | grep -v "Unable to")
			[ -n "$PKGLIST" ] || break
			sudocmd yum remove $PKGLIST
		done
		;;
	urpm-rpm)
		sudocmd urpme --auto-orphans
		;;
	emerge)
		sudocmd emerge --depclean
		docmd epm --skip-installed install gentoolkit
		sudocmd revdep-rebuild
		;;
	pacman)
		sudocmd pacman -Qdtq | sudocmd pacman -Rs -
		;;
	slackpkg)
		# clean-system removes non official packages
		#sudocmd slackpkg clean-system
		;;
	#zypper-rpm)
	#	sudocmd zypper clean
	#	;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-changelog:


__epm_changelog_files()
{
	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm|yum-rpm|zypper-rpm|urpm-rpm)
			docmd_foreach "rpm -p --changelog" $@ | less
			;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac

}

__epm_changelog_local_names()
{
	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm|yum-rpm|urpm-rpm|zypper-rpm)
			docmd_foreach "rpm --changelog" $@ | less
			;;
		apt-dpkg)
			# FIXME: only first pkg
			docmd zcat /usr/share/doc/$1/changelog.Debian.gz | less
			;;
		emerge)
			docmd view /usr/portage/category/$1/ChangeLog | less
			# docmd equery changes -f $1 | less
			;;
		pacman)
			docmd pacman -Qc $1 | less
			;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac
}

__epm_changelog_unlocal_names()
{
	[ -z "$*" ] && return

	case $PMTYPE in
		#apt-rpm)
		#	docmd_foreach "rpm --changelog" $@ | less
		#	;;
		#apt-dpkg)
		#	# FIXME: only first pkg
		#	docmd zcat /usr/share/doc/$1/changelog.Debian.gz | less
		#	;;
		#yum-rpm)
		#	sudocmd yum clean all
		#	;;
		#urpm-rpm)
		#	sudocmd urpmi --clean
		#	;;
		#zypper-rpm)
		#	sudocmd zypper clean
		#	;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac

}


epm_changelog()
{
	[ -n "$pkg_filenames" ] || fatal "Run changelog without params"

	__epm_changelog_files $pkg_files

	local pkg
	for pkg in $pkg_names ; do
		if is_installed $pkg ; then
			__epm_changelog_local_names $pkg
		else
			__epm_changelog_unlocal_names $pkg
		fi
	done
}

# File bin/epm-check:

epm_check()
{
case $PMTYPE in
	apt-rpm|apt-dpkg)
		#sudocmd apt-get check || exit
		#sudocmd apt-get update || exit
		sudocmd apt-get -f install || exit
		;;
	apt-dpkg)
		#sudocmd apt-get update || exit
		#sudocmd apt-get check || exit
		sudocmd apt-get -f install || exit
		sudocmd apt-get autoremove
		;;
	yum-rpm)
		docmd yum check
		docmd package-cleanup --problems

		#docmd package-cleanup --dupes
		sudocmd package-cleanup --cleandupes

		docmd rpm -Va --nofiles --nodigest
		;;
	emerge)
		sudocmd revdep-rebuild
		;;
	urpm-rpm)
		#sudocmd urpme --auto-orphans
		;;
	zypper-rpm)
		sudocmd zypper verify || exit
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-checkpkg:

check_rpm_integrity()
{
	docmd rpm --checksig $@
}

check_deb_integrity()
{
	# FIXME: debsums -ca package ?
	docmd dpkg --contents $@
}

check_bz2_integrity()
{
	docmd bunzip -t $1
}

check_tbz_integrity()
{
	check_bz2_integrity $@
}

check_gz_integrity()
{
	docmd gunzip -t $1
}

check_tgz_integrity()
{
	check_gz_integrity $@
}

check_zip_integrity()
{
	docmd unzip -t $@
}

check_rar_integrity()
{
	docmd unrar t $@
}

check_xz_integrity()
{
	docmd xz -t $1
}

check_7z_integrity()
{
	docmd 7z t $1
}

check_exe_integrity()
{
	# skip
	true
}

check_ebuild_integrity()
{
	# skip
	true
}

check_pkg_integrity()
{
	local EXT=`echo "$1" | sed -e "s|.*\.\([a-z0-9]*\)\$|\1|g"`
	local PKG="$1"
	local RET
	# TODO: Попробовать здесь оставить возможность перегрузки функций
	case $EXT in
	rpm)
		docmd rpm --checksig $1
		;;
	deb)
		# FIXME: debsums -ca package ?
		docmd dpkg --contents $1 >/dev/null && echo "Package $1 is correct."
		;;
	bz2)
		docmd bunzip -t $1
		;;
	*)
		check_${EXT}_integrity "$PKG" || fatal "Unknown package extension '$EXT' in $PKG package"
		;;
	esac
}

__epm_check_installed_pkg()
{
case $PMTYPE in
	*-rpm)
		docmd rpm -V $@
		;;
	*-dpkg)
		docmd debsums $@
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}


epm_checkpkg()
{
	if [ -n "$pkg_names" ] ; then
		__epm_check_installed_pkg $pkg_names
		return
	fi

	[ -n "$pkg_files" ] || fatal "Run without names"
	local pkg
	for pkg in $pkg_files ; do
		check_pkg_integrity $pkg || fatal "Broken package $pkg"
	done
}

# File bin/epm-clean:

epm_clean()
{
case $PMTYPE in
	apt-rpm|apt-dpkg)
		sudocmd apt-get clean
		;;
	yum-rpm)
		sudocmd yum clean all
		#sudocmd yum makecache
		;;
	dnf-rpm)
		sudocmd dnf clean all
		;;
	urpm-rpm)
		sudocmd urpmi --clean
		;;
	pacman)
		sudocmd pacman -Sc
		;;
	zypper-rpm)
		sudocmd zypper clean
		;;
	nix)
		sudocmd nix-collect-garbage
		;;
	slackpkg)
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac
	echo "It is recommend to run 'epm autoremove' also"

}

# File bin/epm-filelist:


__epm_filelist_file()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm|yum-rpm|urpm-rpm|zypper-rpm)
			CMD="rpm -qlp"
			;;
		apt-dpkg)
			CMD="dpkg --contents"
			;;
		*)
			fatal "Have no suitable query command for $PMTYPE"
			;;
	esac

	docmd $CMD $@
}

__epm_filelist_name()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		apt-rpm)
			CMD="rpm -ql"
			;;
		apt-dpkg)
			CMD="dpkg -L"
			;;
		yum-rpm)
			CMD="rpm -ql"
			;;
		urpm-rpm)
			CMD="rpm -ql"
			;;
		zypper-rpm)
			CMD="rpm -ql"
			;;
		pacman)
			docmd pacman -Ql $pkg_names | sed -e "s|.* ||g"
			return
			;;
		slackpkg)
			is_installed $pkg_names || fatal "Query filelist for non installed packages does not realized"
			docmd awk 'BEGIN{desk=1}{if(/^FILE LIST:$/){desk=0} else if (desk==0) {print}}' /var/log/packages/${pkg_filenames}*
			return
			;;
		*)
			fatal "Have no suitable query command for $PMTYPE"
			;;
	esac

	docmd $CMD $pkg_names && return
	is_installed $pkg_names || fatal "Query filelist for non installed packages does not realized"
}


epm_filelist()
{
	[ -n "$pkg_filenames" ] || fatal "Run query without names"


	__epm_filelist_file $pkg_files || return
	__epm_filelist_name $pkg_names || return

}

# File bin/epm-info:


__epm_info_rpm_low()
{
	if [ -n "$pkg_files" ] ; then
		docmd rpm -qip $pkg_files
	fi
	[ -z "$pkg_names" ] && return
	is_installed $pkg_names && docmd rpm -qi $pkg_names && return
}

epm_info()
{
case $PMTYPE in
	apt-rpm)
		__epm_info_rpm_low && return
		docmd apt-cache show $pkg_names
		;;
	apt-dpkg)
		if [ -n "$pkg_files" ] ; then
			docmd dpkg -I $pkg_files
		fi
		[ -z "$pkg_names" ] && return
		is_installed $pkg_names && docmd dpkg -p $pkg_names && return
		docmd apt-cache show $pkg_names
		;;
	yum-rpm)
		__epm_info_rpm_low && return
		docmd yum info $pkg_names
		;;
	dnf-rpm)
		__epm_info_rpm_low && return
		docmd dnf info $pkg_names
		;;
	zypper-rpm)
		__epm_info_rpm_low && return
		docmd zypper info $pkg_names
		;;
	pacman)
		is_installed $pkg_names && docmd pacman -Qi $pkg_names && return
		docmd pacman -Si $pkg_names
		;;
	aura)
		is_installed $pkg_names && docmd pacman -Qi $pkg_names && return
		docmd aura -Ai $pkg_names
		;;
	npackd)
		# FIXME: --version=
		docmd npackdcl info --package=$pkg_names
		;;
	slackpkg)
		docmd /usr/sbin/slackpkg info $pkg_names
		;;
	ipkg)
		docmd ipkg info $pkg_names
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-install:


filter_out_installed_packages()
{
	[ -z "$skip_installed" ] && cat && return

	case $PKGFORMAT in
		"rpm")
			LANG=C LC_ALL=C xargs -n1 rpm -q 2>&1 | grep 'is not installed' |
				sed -e 's|^.*package \(.*\) is not installed.*|\1|g'
			;;
		# dpkg -l lists some non ii status (un, etc)
		#"deb")
		#	LANG=C LC_ALL=C xargs -n1 dpkg -l 2>&1 | grep -i 'no packages found matching' |
		#		sed -e 's|\.\+$||g' -e 's|^.*[Nn]o packages found matching \(.*\)|\1|g'
		#	;;
		*)
			for i in $(cat) ; do
				is_installed $i || echo $i
			done
			;;
	esac | sed -e "s|rpm-build-altlinux-compat[^ ]*||g" | filter_strip_spaces
}

__use_zypper_no_gpg_checks()
{
    a= zypper install --help 2>&1 | grep -q -- "--no-gpg-checks" && echo "--no-gpg-checks"
}

epm_install_names()
{
	if [ -n "$non_interactive" ] ; then
		epm_ni_install_names "$@"
		return
	fi

	[ -z "$1" ] && return
	case $PMTYPE in
		apt-rpm|apt-dpkg)
			sudocmd apt-get $APTOPTIONS install $@
			return ;;
		deepsolver-rpm)
			sudocmd ds-install $@
			return ;;
		urpm-rpm)
			sudocmd urpmi $URPMOPTIONS $@
			return ;;
		pkgsrc)
			sudocmd pkg_add -r $@
			return ;;
		emerge)
			sudocmd emerge -uD $@
			return ;;
		pacman)
			sudocmd pacman -S $force $nodeps $@
			return ;;
		aura)
			sudocmd aura -A $force $nodeps $@
			return ;;
		yum-rpm)
			sudocmd yum $YUMOPTIONS install $@
			return ;;
		dnf-rpm)
			sudocmd dnf install $@
			return ;;
		zypper-rpm)
			sudocmd zypper install $ZYPPEROPTIONS $@
			return ;;
		mpkg)
			sudocmd mpkg install $@
			return ;;
		npackd)
			separate_installed $@
			# FIXME: fix return status
			[ -n "$pkg_noninstalled" ] && sudocmd npackdcl add --package=$@ $pkg_noninstalled
			[ -n "$pkg_installed" ] && sudocmd npackdcl update --package=$@ $pkg_installed
			return ;;
		slackpkg)
			separate_installed $@
			[ -n "$pkg_noninstalled" ] && sudocmd_foreach "/usr/sbin/slackpkg install" $pkg_noninstalled
			[ -n "$pkg_installed" ] && sudocmd_foreach "/usr/sbin/slackpkg upgrade" $pkg_installed
			return ;;
		homebrew)
			separate_installed $@
			[ -n "$pkg_noninstalled" ] && sudocmd brew install $pkg_noninstalled
			[ -n "$pkg_installed" ] && sudocmd brew upgrade $pkg_installed
			return ;;
		ipkg)
			[ -n "$force" ] && force=-force-depends
			sudocmd ipkg $force install $@
			return ;;
		nix)
			separate_installed $@
			[ -n "$pkg_noninstalled" ] && sudocmd nix-env --install $pkg_noninstalled
			[ -n "$pkg_installed" ] && sudocmd nix-env --upgrade $pkg_installed
			return ;;
		*)
			fatal "Have no suitable install command for $PMTYPE"
			;;
	esac
}

epm_ni_install_names()
{
	[ -z "$1" ] && return
	case $PMTYPE in
		apt-rpm|apt-dpkg)
			sudocmd apt-get -y --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $APTOPTIONS install $@
			return ;;
		yum-rpm)
			sudocmd yum -y $YUMOPTIONS install $@
			return ;;
		urpm-rpm)
			sudocmd urpmi --auto $URPMOPTIONS $@
			return ;;
		zypper-rpm)
			# FIXME: returns true ever no package found, need check for "no found", "Nothing to do."
			yes | sudocmd zypper --non-interactive $ZYPPEROPTIONS install $@
			return ;;
		pkgsrc)
			sudocmd pkg_add -r $@
			return ;;
		emerge)
			sudocmd emerge -uD $@
			return ;;
		pacman)
			sudocmd pacman -S --noconfirm $force $nodeps $@
			return ;;
		aura)
			sudocmd aura -A $force $nodeps $@
			return ;;
		npackd)
			#  npackdcl update --package=<package> (remove old and install new)
			sudocmd npackdcl add --package=$@
			return ;;
		chocolatey)
			docmd chocolatey install $@
			return ;;
		ipkg)
			sudocmd ipkg -force-defaults install $@
			return ;;
		nix)
			sudocmd nix-env --install $@
			return ;;
		slackpkg)
			separate_installed $@
			# FIXME: broken status when use batch and default answer
			[ -n "$pkg_noninstalled" ] && sudocmd_foreach "/usr/sbin/slackpkg -batch=on -default_answer=yes install" $pkg_noninstalled
			[ -n "$pkg_installed" ] && sudocmd_foreach "/usr/sbin/slackpkg -batch=on -default_answer=yes upgrade" $pkg_installed
			return ;;
		*)
			fatal "Have no suitable appropriate install command for $PMTYPE"
			;;
	esac
}

__epm_check_if_rpm_already_installed()
{
	# Not: we can make optimize if just check version?
	LANG=C $SUDO rpm -Uvh $force $nodeps $@ 2>&1 | grep -q "is already installed"
}


epm_install_files()
{
    [ -z "$1" ] && return

    case $PMTYPE in
        apt-rpm)
            sudocmd rpm -Uvh $force $nodeps $@ && return
            local RES=$?

            __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level
            [ -n "$nodeps" ] && return $RES

            # use install_names
            ;;
        apt-dpkg)
            # the new version of the conf. file is installed with a .dpkg-dist suffix
            if [ -n "$non_interactive" ] ; then
                DPKGOPTIONS="--force-confdef --force-confold"
            fi
            # FIXME: return false in case no install and in case install with broken deps
            sudocmd dpkg $DPKGOPTIONS -i $@
            local RES=$?
            # if run with --nodeps, do not fallback on hi level

            [ -n "$nodeps" ] && return $RES
            # fall to apt-get -f install for fix deps
            # can't use APTOPTIONS with empty install args
            epm_install_names -f

            # repeat install for get correct status
            sudocmd dpkg $DPKGOPTIONS -i $@
            return
            ;;
        yum-rpm|dnf-rpm)
            sudocmd rpm -Uvh $force $nodeps $@ && return
            # if run with --nodeps, do not fallback on hi level

            __epm_check_if_rpm_already_installed $@ && return

            [ -n "$nodeps" ] && return
            YUMOPTIONS=--nogpgcheck
            # use install_names
            ;;
        zypper-rpm)
            sudocmd rpm -Uvh $force $nodeps $@ && return
            local RES=$?

            __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level

            [ -n "$nodeps" ] && return $RES
            ZYPPEROPTIONS=$(__use_zypper_no_gpg_checks)
            # use install_names
            ;;
        urpm-rpm)
            sudocmd rpm -Uvh $force $nodeps $@ && return
            local RES=$?

            __epm_check_if_rpm_already_installed $@ && return

            # if run with --nodeps, do not fallback on hi level
            [ -n "$nodeps" ] && return $RES

            URPMOPTIONS=--no-verify-rpm
            # use install_names
            ;;
        pkgsrc)
            sudocmd pkg_add $@
            return ;;
        emerge)
            load_helper epm-install-emerge
            sudocmd epm_install_emerge $@
            return ;;
        pacman)
            sudocmd pacman -U --noconfirm $force $nodeps $@ && return
            local RES=$?

            [ -n "$nodeps" ] && return $RES
            sudocmd pacman -U $force $@
            return ;;
        slackpkg)
            sudocmd /sbin/installpkg $@
            return ;;
    esac

    # other systems can install file package via ordinary command
    epm_install_names "$@"
}

epm_print_install_command()
{
    case $PMTYPE in
        apt-rpm|yum-rpm|urpm-rpm|zypper-rpm|dnf-rpm)
            echo "rpm -Uvh --force $nodeps $@"
            ;;
        apt-dpkg)
            echo "dpkg -i $@"
            ;;
        pkgsrc)
            echo "pkg_add $@"
            ;;
        emerge)
            # need be placed in /usr/portage/packages/somewhere
            echo "emerge --usepkg $@"
            ;;
        pacman)
            echo "pacman -U --noconfirm --force $nodeps $@"
            ;;
        slackpkg)
            echo "/sbin/installpkg $@"
            ;;
        npackd)
            echo "npackdcl add --package=$@"
            ;;
        ipkg)
            echo "ipkg install $@"
            ;;
        *)
            fatal "Have no suitable appropriate install command for $PMTYPE"
            ;;
    esac
}


epm_install()
{
    if [ -n "$show_command_only" ] ; then
        epm_print_install_command $pkg_filenames
        return
    fi

    [ -n "$pkg_files$pkg_names" ] || { echo "Skip empty install list" ; return 22 ; }

    local names="$(echo $pkg_names | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    [ -z "$files$names" ] && echo "Skip empty install list" && return 22

    epm_install_names $names || return
    epm_install_files $files
}

# File bin/epm-Install:


epm_Install()
{
    # copied from epm_install
    local names="$(echo $pkg_names | filter_out_installed_packages)"
    local files="$(echo $pkg_files | filter_out_installed_packages)"

    [ -z "$files$names" ] && echo "Skip empty install list" && return 22

	# do update only if really need install something
	case $PMTYPE in
		yum-rpm)
			;;
		*)
			epm_update || return
			;;
	esac

    epm_install_names $names || return
    epm_install_files $files

}

# File bin/epm-install-emerge:



__emerge_install_ebuild()
{
	local EBUILD="$1"
	[ -s "$EBUILD" ] || fatal ".ebuild file '$EBUILD' is missing"

	# load ebuild and get vars
	. $(pwd)/$EBUILD
	[ -n "$SRC_URI" ] || fatal "Can't load SRC_URI from $EBUILD"

	# try to detect tarballs
	local TARBALLS=
	local BASEDIR=$(dirname $EBUILD)
	for i in $SRC_URI ; do
		[ -s "$BASEDIR/$(basename $i)" ] || continue
		TARBALLS="$TARBALLS $BASEDIR/$(basename $i)"
	done

	local PORTAGENAME=epm
	local LP=/usr/local/portage/$PORTAGENAME
	docmd mkdir -p $LP/
	MAKECONF=/etc/portage/make.conf
	[ -r "$MAKECONF" ] || MAKECONF=/etc/make.conf
	if ! grep -v "^#" $MAKECONF | grep -q $LP ; then
		echo "PORTDIR_OVERLAY=\"$LP \${PORTDIR_OVERLAY}\"" >>$MAKECONF
		# Overlay name
		mkdir -p $LP/profiles/
		echo "$PORTAGENAME" > $LP/profiles/repo_name
	fi

	# copy tarballs
	local DDIR=/usr/portage/distfiles
	[ -d /var/calculate/remote/distfiles ] && DDIR=/var/calculate/remote/distfiles
	docmd cp -f $TARBALLS $DDIR/ || return

	# copy ebuild
	docmd cp -f $EBUILD $LP/ || return
	cd $LP
	docmd ebuild $(basename $EBUILD) digest
	cd -
	# FIXME: more correcty get name
	local PKGNAME=$(echo $EBUILD | sed -e "s|-[0-9].*||g")
	docmd emerge -av $PKGNAME || return
}

__emerge_install_tbz2()
{
	local TGDIR=/usr/portage/packages/app-arch
	mkdir -p $TGDIR
	cp $i $TGDIR || return
	docmd emerge --usepkg $TGDIR/$(basename $i) || return
}

epm_install_emerge()
{
	local EBUILD=
	#local TARBALLS=
	local i

	# search ebuild in the args
	for i in $* ; do
		if echo $i | grep -q ebuild ; then
			__emerge_install_ebuild $i || return
		elif echo $i | grep -q "\.tbz2$" ; then
			__emerge_install_tbz2 $i || return
	#	else
	#		TARBALLS="$TARBALLS $i"
		fi
	done
}

# File bin/epm-kernel_update:

epm_kernel_update()
{
	echo "Start update system kernel to the latest version"

	case $DISTRNAME in
	ALTLinux)
		sudocmd update-kernel
		return ;;
	esac

	case $PMTYPE in
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac
}

# File bin/epm-packages:

epm_packages()
{
	local CMD

case $PMTYPE in
	apt-rpm)
		CMD="rpm -qa $pkg_filenames"
		[ -n "$short" ] && CMD="rpm -qa --queryformat %{name}\n $pkg_filenames"
		;;
	apt-dpkg)
		CMD="dpkg -l $pkg_filenames"
		[ -n "$short" ] && CMD="dpkg-query -W --showformat=\${Package}\n $pkg_filenames"
		;;
	yum-rpm|urpm-rpm|zypper-rpm|dnf-rpm)
		CMD="rpm -qa $pkg_filenames"
		[ -n "$short" ] && CMD="rpm -qa --queryformat %{name}\n $pkg_filenames"
		;;
	emerge)
		CMD="qlist -I"
		;;
	pkgsrc)
		CMD="pkg_info"
		;;
	pacman)
		CMD="pacman -Qs $pkg_filenames"
		if [ -n "$short" ] ; then
			docmd $CMD | sed -e "s| .*||g" -e "s|.*/||g" | grep -v "^$"
			return
		fi
		;;
	npackd)
		CMD="npackdcl list --status=installed"
		# TODO: use search if pkg_filenames is not empty
		;;
	slackpkg)
		CMD="ls -1 /var/log/packages/"
		if [ -n "$short" ] ; then
			docmd ls -1 /var/log/packages/ | sed -e "s|-[0-9].*||g"
			return
		fi
		;;
	homebrew)
		CMD="brew $pkg_filenames"
		;;
	ipkg)
		CMD="ipkg list"
		;;
	*)
		fatal "Have no suitable query command for $PMTYPE"
		;;
esac

docmd $CMD

}

# File bin/epm-programs:


epm_programs()
{
	local DESKTOPDIR=/usr/share/applications
	[ -d "$DESKTOPDIR" ] || fatal "There is no $DESKTOPDIR dir on the system."
	#find /usr/share/applications -type f -name "*.desktop" | while read f; do pkg_files="$f" quiet=1 short=1 epm_query_file ; done | sort -u
	showcmd "find /usr/share/applications -type f -name "*.desktop" | xargs $0 -qf --quiet --short | sort -u"
	find /usr/share/applications -type f -name "*.desktop" | \
		xargs $0 -qf --quiet --short | sort -u
}

# File bin/epm-provides:

epm_provides()
{
	local CMD
	[ -n "$pkg_filenames" ] || fatal "Run query without names"

case $PMTYPE in
	*-rpm)
		CMD="rpm -q --provides -p"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

[ -n "$pkg_files" ] && docmd $CMD $pkg_files

case $PMTYPE in
	apt-rpm)
		if is_installed $pkg_names ; then
			CMD="rpm -q --provides"
		else
			CMD="apt-cache depends"
		fi
		;;
	urpm-rpm|zypper-rpm)
		if is_installed $pkg_names ; then
			CMD="rpm -q --provides"
		else
			fatal "FIXME: use hi level commands"
		fi
		;;
	emerge)
		CMD="equery files"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

[ -n "$pkg_names" ] && docmd $CMD $pkg_names

}

# File bin/epm-query:



_query_via_packages_list()
{
	local res=0
	local firstpkg=$1
	shift
	# separate first line for print out command
	short=1 pkg_filenames=$firstpkg epm_packages | grep -- "^$firstpkg$" || res=1
	for pkg in "$@" ; do
		short=1 pkg_filenames=$pkg epm_packages 2>/dev/null | grep -- "^$pkg$" || res=1
	done
	return $res
}

__epm_query_file()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		*-rpm)
			CMD="rpm -qp"
			;;
		apt-dpkg)
			CMD="dpkg-deb --show"
			# TODO: make rpm-like output
			#showcmd dpkg -l $pkg_filenames
			#dpkg -l $pkg_filenames | grep "^ii"
			#return
			;;
		*)
			fatal "Do not know command for query file package"
			;;
	esac

	docmd $CMD $@
}

__epm_query_name()
{
	local CMD

	[ -z "$*" ] && return

	case $PMTYPE in
		*-rpm)
			CMD="rpm -q"
			;;
		apt-dpkg)
			#docmd dpkg -l $@
			docmd dpkg -l $@ | grep "^ii"
			# TODO: make rpm-like output
			#showcmd dpkg -l $pkg_filenames
			#dpkg -l $pkg_filenames | grep "^ii"
			return
			;;
		npackd)
			CMD="npackdcl path --package=$@"
			;;
		brew)
			warning "fix query"
			return 1
			;;
		*)
			_query_via_packages_list $@
			return
			;;
	esac

	docmd $CMD $@
}

is_installed()
{
	#pkg_filenames="$@" epm_query >/dev/null
	epm installed $@ >/dev/null 2>/dev/null
}

separate_installed()
{
	pkg_installed=
	pkg_noninstalled=
	for i in $* ; do
		is_installed $i && pkg_installed="$pkg_installed $i" || pkg_noninstalled="$pkg_noninstalled $i"
	done
}

epm_query()
{
	[ -n "$pkg_filenames" ] || fatal "Run query without names"

	__epm_query_file $pkg_files || return

	__epm_query_name $pkg_names || return
}

# File bin/epm-query_file:



__do_query_real_file()
{
	local LINKTO1 LINKTO
	local TOFILE
	
	# get canonical path
	if [ -e "$1" ] ; then
		TOFILE=$1
	else
		TOFILE=`which $1 2>/dev/null || echo $1`
		if [ "$TOFILE" != "$1" ] ; then
		echo "Note: $1 is placed as $TOFILE"
		fi
	fi
	
	# get value of symbolic link
	if [ -L "$TOFILE" ] ; then
		__do_query $TOFILE
		LINKTO=`readlink "$TOFILE"`
		echo "Note: $TOFILE is link to $LINKTO"
		__do_query_real_file "$LINKTO"
	fi
	FULLFILEPATH=`realpath $TOFILE`
}

dpkg_print_name_version()
{
	local ver i
	for i in $* ; do
		ver=$(dpkg -s $i 2>/dev/null | grep "Version:" | sed -e "s|Version: ||g")
		if [ -z "$ver" ] ; then
			echo "$i"
		else
			echo "$i-$ver"
		fi
	done
}


__do_query()
{
    local CMD
    case $PMTYPE in
        apt-rpm)
            CMD="rpm -qf"
            ;;
        apt-dpkg)
            showcmd dpkg -S $1
            dpkg_print_name_version $(dpkg -S $1 | grep -v "^diversion by" | sed -e "s|:.*||")
            return ;;
        yum-rpm|urpm-rpm)
            CMD="rpm -qf"
            ;;
        zypper-rpm)
            CMD="rpm -qf"
            ;;
        emerge)
            CMD="equery belongs"
            ;;
        pacman)
            CMD="pacman -Qo"
            ;;
        slackpkg)
            # note: need remove leading slash for grep
            docmd grep -R -- "$(echo $@ | sed -e 's|^/\+||g')" /var/log/packages | sed -e "s|/var/log/packages/||g"
            return
            ;;
        ipkg)
            CMD="ipkg files"
            ;;
        *)
            fatal "Have no suitable query command for $PMTYPE"
            ;;
    esac

    docmd $CMD $@
}


__do_short_query()
{
    local CMD
    case $PMTYPE in
        *-rpm)
            CMD="rpm -qf --queryformat %{NAME}\n"
            ;;
        NOapt-dpkg)
            showcmd dpkg -S $1
            dpkg_print_name_version $(dpkg -S $1 | sed -e "s|:.*||" | grep -v "^diversion by")
            return ;;
        NOemerge)
            CMD="equery belongs"
            ;;
        NOpacman)
            CMD="pacman -Qo"
            ;;
        NOslackpkg)
            # note: need remove leading slash for grep
            docmd grep -R "$(echo $@ | sed -e 's|^/\+||g')" /var/log/packages | sed -e "s|/var/log/packages/||g"
            return
            ;;
        *)
            fatal "Have no suitable query command for $PMTYPE"
            ;;
    esac

    docmd $CMD $@
}


epm_query_file()
{
    # in short mode print handle only real names and do short output
    # TODO: move to separate command?
    if [ -n "$short" ] ; then
        [ -n "$pkg_files" ] || fatal "Run query without file names (needed path to files)"
        __do_short_query $pkg_files
         return
    fi

    # file can exists or not
    [ -n "$pkg_filenames" ] || fatal "Run query without file names"

    for pkg in $pkg_filenames ; do
        __do_query_real_file "$pkg"
        __do_query $FULLFILEPATH || pkg_filenames=$pkg epm_search_file
    done

}

# File bin/epm-query_package:


epm_query_package()
{
	#showcmd grep --color "$pkg_filenames"
	pkg_filenames= epm_packages | grep --color -- "$pkg_filenames"
}

# File bin/epm-reinstall:


epm_reinstall_names()
{
	[ -n "$1" ] || return
	case $PMTYPE in
		apt-rpm|apt-dpkg)
			sudocmd apt-get --reinstall install $@
			return ;;
		dnf-rpm)
			sudocmd dnf reinstall $@
			return ;;
		slackpkg)
			sudocmd /usr/sbin/slackpkg reinstall $@
			return ;;
	esac

	# fallback to generic install
	epm_install_names $@
}

epm_reinstall_files()
{
    [ -z "$1" ] && return

    case $PMTYPE in
        apt-rpm)
            sudocmd rpm -Uvh --force $@ && return
            sudocmd apt-get --reinstall install $@
            return ;;
        apt-pkg)
            sudocmd dpkg -i $@
            return ;;
        slackpkg)
            sudocmd /sbin/installpkg $@
            return ;;
    esac

    # other systems can install file package via ordinary command
    epm_reinstall_names $@
}


epm_reinstall()
{
    [ -n "$pkg_filenames" ] || fatal "Run install without packages"

    epm_reinstall_names $pkg_names
    epm_reinstall_files $pkg_files
}


# File bin/epm-release-upgrade:

epm_release_upgrade()
{
	echo "Start upgrade whole system to the next release"
	echo "Check also http://wiki.etersoft.ru/Admin/UpdateLinux"

	case $PMTYPE in
	apt-rpm)
		docmd epm update
		docmd epm install apt rpm
		showcmd "TODO: change repo"
		docmd epm Upgrade
		;;
	apt-dpkg)
		sudocmd do-release-upgrade -d
		;;
	yum-rpm)
		docmd epm install rpm yum
		sudocmd yum clean all
		# TODO
		showcmd rpm -Uvh http://mirror.yandex.ru/fedora/linux/releases/16/Fedora/x86_64/os/Packages/fedora-release-16-1.noarch.rpm
		docmd epm Upgrade
		;;
	urpm-rpm)
		sudocmd urpmi.removemedia -av
		# TODO
		showcmd urpmi.addmedia --distrib http://mirror.yandex.ru/mandriva/devel/2010.2/i586/
		sudocmd urpmi --auto-update --replacefiles
		;;
	zypper-rpm)
		docmd epm repolist
		# TODO
		# sudocmd zypper rr <номер_репозитория>
		showcmd rr N
		showcmd epm ar http://mirror.yandex.ru/opensuse/distribution/11.1/repo/oss 11.1oss
		showcmd zypper ref
		docmd epm update
		docmd epm install rpm zypper
		docmd epm upgrade
		;;
	pacman)
		epm Upgrade
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac

	sudocmd $CMD $pkg_filenames
}

# File bin/epm-remove:

epm_remove_low()
{
	[ -z "$1" ] && return
	case $PMTYPE in
		apt-rpm|yum-rpm|zypper-rpm|urpm-rpm|dnf-rpm)
			sudocmd rpm -ev $nodeps $@
			return ;;
		apt-dpkg)
			sudocmd dpkg -P $(subst_option nodeps --force-all) $@
			return ;;
		pkgsrc)
			sudocmd pkg_delete -r $@
			return ;;
		emerge)
			sudocmd emerge --unmerge $@
			return ;;
		pacman)
			sudocmd pacman -R $@
			return ;;
		slackpkg)
			sudocmd /sbin/removepkg $@
			return ;;
	esac
	return 1
}

epm_remove_names()
{
	[ -z "$1" ] && return

	case $PMTYPE in
		apt-rpm|apt-dpkg)
			sudocmd apt-get remove --purge $@
			return ;;
		deepsolver-rpm)
			sudocmd ds-remove $@
			return ;;
		urpm-rpm)
			sudocmd urpme $@
			return ;;
		pkgsrc) # without dependencies
			sudocmd pkg_delete $@
			return ;;
		emerge)
			#sudocmd emerge --unmerge $@
			sudocmd emerge -aC $@
			return ;;
		pacman)
			sudocmd pacman -Rc $@
			return ;;
		yum-rpm)
			sudocmd yum remove $@
			return ;;
		dnf-rpm)
			sudocmd dnf remove $@
			return ;;
		zypper-rpm)
			sudocmd zypper remove $@
			return ;;
		mpkg)
			sudocmd mpkg remove $@
			return ;;
		npackd)
			sudocmd npackdcl remove --package=$@
			return ;;
		nix)
			sudocmd nix-env --uninstall $@
			return ;;
		chocolatey)
			sudocmd chocolatey uninstall $@
			return ;;
		slackpkg)
			sudocmd /usr/sbin/slackpkg remove $@
			return ;;
		homebrew)
			sudocmd brew remove $@
			return ;;
		ipkg)
			sudocmd ipkg $(subst_option force -force-depends) remove $@
			return ;;
		*)
			fatal "Have no suitable command for $PMTYPE"
			;;
	esac
}

epm_remove_nonint()
{
	case $PMTYPE in
		apt-rpm|apt-dpkg)
			sudocmd apt-get -y --force-yes remove --purge $@
			return ;;
		urpm-rpm)
			sudocmd urpme --auto $@
			return ;;
		pacman)
			sudocmd pacman -Rc --noconfirm $@
			return ;;
		yum-rpm)
			sudocmd yum -y remove $@
			return ;;
		zypper-rpm)
			sudocmd zypper --non-interactive remove $@
			return ;;
		slackpkg)
			sudocmd /usr/sbin/slackpkg -batch=on -default_answer=yes remove $@
			return ;;
		ipkg)
			sudocmd ipkg -force-defaults remove $@
			return ;;
	esac
	return 5
}

epm_print_remove_command()
{
	case $PMTYPE in
		apt-rpm|yum-rpm|zypper-rpm|urpm-rpm|dnf-rpm)
			echo "rpm -ev $nodeps $@"
			;;
		apt-dpkg)
			echo "dpkg -P $@"
			;;
		pkgsrc)
			echo "pkg_delete -r $@"
			;;
		pacman)
			echo "pacman -R $@"
			;;
		emerge)
			echo "emerge --unmerge $@"
			;;
		slackpkg)
			echo "/sbin/removepkg $@"
			;;
		ipkg)
			echo "ipkg remove $@"
			;;
		*)
			fatal "Have no suitable appropriate remove command for $PMTYPE"
			;;
	esac
}


epm_remove()
{
	if [ -n "$show_command_only" ] ; then
		epm_print_remove_command $pkg_filenames
		return
	fi

	[ -n "$pkg_files" ] && fatal "FIXME: remove by package file is not supported yet"

	[ -n "$pkg_filenames" ] || fatal "Run remove without args"
	epm_remove_low $pkg_filenames && return

	if [ -n "$non_interactive" ] ; then
		epm_remove_nonint $pkg_filenames
		local RET=$?
		# if not separate command, use usual command
		[ "$RET" = "5" ] || return $RET
	fi

	epm_remove_names $pkg_filenames
}


# File bin/epm-removerepo:

epm_removerepo()
{
case $PMTYPE in
	apt-rpm)
		sudocmd apt-repo rm $pkg_filenames
		;;
	apt-dpkg)
		echo "You need remove repo from /etc/apt/sources.list"
		;;
	yum-rpm)
		echo "You need remove repo from /etc/yum.repos.d/"
		;;
	urpm-rpm)
		sudocmd urpmi.removemedia $pkg_filenames
		;;
	zypper-rpm)
		sudocmd zypper removerepo $pkg_filenames
		;;
	emerge)
		sudocmd layman -d$pkg_filenames
		;;
	pacman)
		echo "You need remove repo from /etc/pacman.conf"
		;;
	npackd)
		sudocmd npackdcl remove-repo --url=$pkg_filenames
		;;
	slackpkg)
		echo "You need remove repo from /etc/slackpkg/mirrors"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-repolist:

print_apt_sources_list()
{
    local i
    for i in $@ ; do
        test -r "$i" || continue
        #echo
        #echo "$i:"
        grep -v -- "^#" $i
    done | grep -v -- "^ *\$"
}

epm_repolist()
{
case $PMTYPE in
	apt-rpm)
		docmd apt-repo list
		;;
	deepsolver-rpm)
		docmd ds-conf
		;;
	apt-dpkg)
		showcmd cat /etc/apt/sources.list*
		print_apt_sources_list /etc/apt/sources.list /etc/apt/sources.list.d/*.list
		;;
	yum-rpm)
		docmd yum repolist
		;;
	dnf-rpm)
		docmd dnf repolist -v
		;;
	urpm-rpm)
		docmd urpmq --list-url
		;;
	zypper-rpm)
		docmd zypper sl -d
		;;
	emerge)
		docmd layman -L
		;;
	pacman)
		docmd grep -v -- "^#\|^$" /etc/pacman.conf
		;;
	slackpkg)
		docmd grep -v -- "^#\|^$" /etc/slackpkg/mirrors
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

}

# File bin/epm-requires:

epm_requires()
{
	local CMD
	[ -n "$pkg_filenames" ] || fatal "Run query without names"

case $PMTYPE in
	apt-rpm|urpm-rpm|zypper-rpm|yum-rpm)
		CMD="rpm -q --requires -p"
		;;
	apt-dpkg)
		showcmd dpkg -s $pkg_files
		a= dpkg -s $pkg_names | grep "^Depends:" | sed "s|^Depends:||g"
		return
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

[ -n "$pkg_files" ] && docmd $CMD $pkg_files

case $PMTYPE in
	apt-rpm|urpm-rpm|zypper-rpm)
		# FIXME: use hi level commands
		CMD="rpm -q --requires"
		;;
	yum-rpm)
		CMD="yum deplist"
		;;
	pacman)
		CMD="pactree"
		;;
	apt-dpkg)
		CMD="apt-cache depends"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac


[ -n "$pkg_names" ] && docmd $CMD $pkg_names

}

# File bin/epm-search:


epm_search()
{
	local CMD
	[ -n "$pkg_filenames" ] || fatal "Run search without names"

case $PMTYPE in
	apt-rpm|apt-dpkg)
		CMD="apt-cache search"
		;;
	urpm-rpm)
		CMD="urpmq -y"
		;;
	pkgsrc)
		CMD="pkg_info -x"
		;;
	emerge)
		CMD="emerge --search"
		;;
	pacman)
		CMD="pacman -Ss"
		;;
	aura)
		CMD="aura -As"
		;;
	yum-rpm)
		CMD="yum search"
		;;
	dnf-rpm)
		CMD="dnf search"
		;;
	zypper-rpm)
		CMD="zypper search"
		;;
	mpkg)
		CMD="mpkg search"
		;;
	npackd)
		docmd npackdcl search --query="$pkg_filenames" --status=all
		return
		;;
	chocolatey)
		CMD="chocolatey list"
		;;
	slackpkg)
		# FIXME
		echo "FIXME: need case insensitive search"
		docmd_foreach "/usr/sbin/slackpkg search" $pkg_filenames
		return
		;;
	homebrew)
		CMD="brew search"
		;;
	*)
		fatal "Have no suitable search command for $PMTYPE"
		;;
esac

docmd $CMD $pkg_filenames

}

# File bin/epm-search_file:

local_content_search()
{
    local SYSARCH
    SYSARCH=$(uname -m)
    [ "$SYSARCH" = "x86_64" ] || SYSARCH=i586

    local REPODIR=/var/ftp/pub/ALTLinux/Sisyphus
    local CI=$REPODIR/$SYSARCH/base/contents_index
    local CINOA=$REPODIR/noarch/base/contents_index
    #local OUTCMD="less"
    #[ -n "$USETTY" ] || OUTCMD="cat"
    OUTCMD="cat"

    test -r $CI && test -r $CINOA || fatal "Can't locate $CI or $CINOA"

    {
        [ -n "$USETTY" ] && echo "Search in $CI and $CINOA for $1..."
        grep -h -- ".*$1.*\t" $CI $CINOA | sed -e "s|\(.*\)\t\(.*\)|\2: \1|g"
    } | $OUTCMD
}

epm_search_file()
{
	local CMD
	[ -n "$pkg_filenames" ] || fatal "Run search without names"

case $PMTYPE in
	apt-rpm)
		local_content_search $pkg_filenames
		return ;;
	apt-dpkg)
		sudocmd apt-file update
		docmd apt-file search $pkg_filenames
		return ;;
	yum-rpm)
		CMD="yum provides"
		;;
	dnf-rpm)
		CMD="dnf provides"
		;;
	urpm-rpm)
		CMD="urpmf"
		;;
	zypper-rpm)
		CMD="zypper wp vi"
		;;
	pacman)
		CMD="pacman -Qo"
		;;
	slackpkg)
		CMD="/usr/sbin/slackpkg file-search"
		;;
	ipkg)
		CMD="ipkg search"
		;;
	*)
		fatal "Have no suitable search file command for $PMTYPE"
		;;
esac

docmd $CMD $pkg_filenames

}

# File bin/epm-simulate:


__use_zypper_dry_run()
{
    a= zypper install --help 2>&1 | grep -q -- "--dry-run" && echo "--dry-run"
}

__use_yum_assumeno()
{
    a= yum --help 2>&1 | grep -q -- "--assumeno"
}


__check_yum_result()
{
    grep "^No package" $1 && return 1
    grep "^Complete!" $1 && return 0
    grep "^Exiting on user Command" $1 && return 0
    grep "^Exiting on user command" $1 && return 0
    # return default result by default
    return $2
}


_epm_do_simulate()
{
    local CMD
    local RES=0
    local filenames="$*"

    case $PMTYPE in
    	apt-rpm|apt-dpkg)
    		CMD="apt-get --simulate install"
    		;;
    	yum-rpm)
    		if __use_yum_assumeno ; then
    			LC_ALL=C store_output sudocmd yum --assumeno install $filenames
    			__check_yum_result $RC_STDOUT $?
    		else
    			LC_ALL=C echo n | store_output sudocmd yum install $filenames
    			__check_yum_result $RC_STDOUT $?
    		fi
    		RES=$?
    		clean_store_output
    		return $RES ;;
    	urpm-rpm)
    		CMD="urpmi --test --auto"
    		;;
    	zypper-rpm)
    		if ! __use_zypper_dry_run >/dev/null ; then
    			echo "zypper is too old: does not support --dry-run"
    			return
    		fi
    		CMD="zypper --non-interactive install"
    		;;
    	emerge)
    		local res=0
    		for pkg in $filenames ; do
			is_installed $pkg && continue
			docmd emerge --pretend $pkg && continue
			pkg=1
			break
    		done
    		return $res ;;
    	pacman)
    		showcmd $SUDO pacman -v -S $filenames
    		echo no | $SUDO pacman -v -S $filenames
    		return ;;
    	slackpkg)
    		#docmd /usr/sbin/slackpkg -batch=on -default_answer=yes download
    		# just try search every package
    		# FIXME: epm_search have to return false status code if the package does not found
    		local pkg res
    		res=0
    		for pkg in $filenames ; do
    			pkg_filenames="$pkg-[0-9]" epm_search | grep -E "(installed|upgrade)" && continue
    			pkg_filenames="$pkg" epm_search | grep -E "(installed|upgrade)" && continue
    			res=1
    			echo "Does not found in repository."
    		done
    		return $res ;;
    	*)
    		fatal "Have no suitable simulate command for $PMTYPE"
    		;;
    esac

    sudocmd $CMD $filenames
}

epm_simulate()
{
    [ -z "$pkg_filenames" ] && echo "Skip empty list" && return 22

    local filenames="$(echo $pkg_filenames | filter_out_installed_packages)"

    [ -z "$filenames" ] && echo "All packages are already installed" && return 0

    _epm_do_simulate $filenames
    local RES=$?
    if [ -z "$quiet" ] ; then
        [ "$RES" = 0 ] && echo "Result: $filenames package(s) CAN BE installed" || echo "Result: There are PROBLEMS with install some package(s)"
    fi
    return $RES
}


# File bin/epm-update:


epm_update()
{
	echo "Run command for update remote package repository database"

case $PMTYPE in
	apt-rpm)
		sudocmd apt-get update || exit
		#sudocmd apt-get -f install || exit
		;;
	apt-dpkg)
		sudocmd apt-get update || exit
		#sudocmd apt-get -f install || exit
		#sudocmd apt-get autoremove
		;;
	yum-rpm)
		sudocmd yum check-update
		;;
	urpm-rpm)
		sudocmd urpmi.update -a
		;;
	pacman)
		sudocmd pacman -S -y
		;;
	aura)
		sudocmd aura -A -y
		;;
	zypper-rpm)
		sudocmd zypper refresh
		;;
	emerge)
		sudocmd emerge --sync
		;;
	slackpkg)
		sudocmd /usr/sbin/slackpkg update
		;;
	deepsolver-rpm)
		sudocmd ds-update
		;;
	npackd)
		sudocmd packdcl detect # get packages from MSI database
		;;
	homebrew)
		sudocmd brew update
		;;
	ipkg)
		sudocmd ipkg update
		;;
	*)
		fatal "Have no suitable update command for $PMTYPE"
		;;
esac

}

# File bin/epm-upgrade:

epm_upgrade()
{
	local CMD
	echo "Run command for upgrade packages"

	case $PMTYPE in
	apt-rpm|apt-dpkg)
		# non_interactive
		# Функцию добавления параметра при условии
		CMD="apt-get dist-upgrade"
		;;
	yum-rpm)
		# can do update repobase automagically
		CMD="yum update"
		;;
	dnf-rpm)
		CMD="dnf update"
		;;
	urpm-rpm)
		# or --auto-select --replace-files
		CMD="urpmi --auto-update"
		;;
	zypper-rpm)
		CMD="zypper dist-upgrade"
		;;
	pacman)
		CMD="pacman -S -u $force"
		;;
	aura)
		CMD="aura -A -u"
		;;
	emerge)
		CMD="emerge -NuDa world"
		;;
	pkgsrc)
		CMD="freebsd-update fetch install"
		;;
	chocolatey)
		CMD="chocolatey update all"
		;;
	homebrew)
		CMD="brew upgrade"
		;;
	ipkg)
		CMD="ipkg upgrade"
		;;
	slackpkg)
		CMD="/usr/sbin/slackpkg upgrade-all"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
	esac

	sudocmd $CMD $pkg_filenames
}

# File bin/epm-Upgrade:


epm_Upgrade()
{
	case $PMTYPE in
		yum-rpm)
			;;
		*)
			epm_update || return
			;;
	esac

	epm_upgrade
}

# File bin/epm-whatdepends:

epm_whatdepends()
{
	local CMD
	[ -n "$pkg_names" ] || fatal "Run query without names"

case $PMTYPE in
	apt-rpm|apt-dpkg)
		CMD="apt-cache whatdepends"
		;;
	yum-rpm)
		CMD="repoquery --whatrequires"
		;;
	emerge)
		CMD="equery depends -a"
		;;
	*)
		fatal "Have no suitable command for $PMTYPE"
		;;
esac

[ -n "$pkg_names" ] && docmd $CMD $pkg_names

}
internal_distr_info()
{
#!/bin/sh
# Author: Vitaly Lipatov <lav@etersoft.ru>
# 2007, 2009, 2010, 2012 (c) Etersoft
# 2007 Public domain

# Detect the distro and version
# Welcome to send updates!

# You can set ROOTDIR to root system dir
#ROOTDIR=

# Check for DISTRO specific file in /etc
distro()
{
	#[ -n "$ROOTDIR" ] || return
	# fill global DISTROFILE
	DISTROFILE="$ROOTDIR/etc/$1"
	[ -f "$DISTROFILE" ]
}

# Has a distro file the specified word?
has()
{
	[ -n "$DISTROFILE" ] || exit 1
	grep "$*" "$DISTROFILE" >/dev/null 2>&1
}

# Translate DISTRIB_ID to vendor name (like %_vendor does)
rpmvendor()
{
	[ "$DISTRIB_ID" = "ALTLinux" ] && echo "alt" && return
	[ "$DISTRIB_ID" = "LinuxXP" ] && echo "lxp" && return
	echo "$DISTRIB_ID" | tr "[A-Z]" "[a-z]"
}

# Translate DISTRIB_ID name to package manner (like in the package release name)
pkgvendor()
{
	[ "$DISTRIB_ID" = "Mandriva" ] && echo "mdv" && return
	rpmvendor
}

# Print pkgtype (need DISTRIB_ID var)
pkgtype()
{
    case `pkgvendor` in
		freebsd) echo "tbz" ;;
		sunos) echo "pkg.gz" ;;
		slackware|mopslinux) echo "tgz" ;;
		archlinux) echo "pkg.tar.xz" ;;
		gentoo) echo "tbz2" ;;
		windows) echo "exe" ;;
		debian|ubuntu|mint|runtu) echo "deb" ;;
		alt|asplinux|suse|mandriva|rosa|mandrake|pclinux|sled|sles)
			echo "rpm" ;;
		fedora|redhat|scientific|centos|rhel)
			echo "rpm" ;;
		*)  echo "rpm" ;;
	esac
}

get_var()
{
	grep -i "^$1 *=" | head -n 1 | sed -e "s/^[^=]*[ \t]*=[ \t]*//"

}

# 2010.1 -> 2010
get_major_version()
{
	echo "$1" | sed -e "s/\..*//g"
}

# Default values
DISTRIB_ID="Generic"
DISTRIB_RELEASE=""

# Default with LSB
if distro lsb-release ; then
	DISTRIB_ID=`cat $DISTROFILE | get_var DISTRIB_ID`
	DISTRIB_RELEASE=`cat $DISTROFILE | get_var DISTRIB_RELEASE`
fi

# ALT Linux based
if distro altlinux-release ; then
	DISTRIB_ID="ALTLinux"
	if has Strawberry ; then DISTRIB_RELEASE="2.3"
	elif has Citron   ; then DISTRIB_RELEASE="2.4"
	elif has 20050723 ; then DISTRIB_RELEASE="3.0"
	elif has Ajuga    ; then DISTRIB_RELEASE="4.0"
	elif has 20070810 ; then DISTRIB_RELEASE="4.0"
	elif has "ALT Linux 4.0" ; then DISTRIB_RELEASE="4.0"
	elif has "ALT Linux 4.1" ; then DISTRIB_RELEASE="4.1"
	elif has Walnut   ; then DISTRIB_RELEASE="4.0"
	elif has 5.0      ; then DISTRIB_RELEASE="5.0"
	elif has 5.1      ; then DISTRIB_RELEASE="5.1"
	elif has "ALT Linux p5" ; then DISTRIB_RELEASE="p5"
	elif has "ALT Linux p6" ; then DISTRIB_RELEASE="p6"
	elif has "ALT Linux p7" ; then DISTRIB_RELEASE="p7"
	elif has 6.0      ; then DISTRIB_RELEASE="p6"
	elif has Centaurea ; then DISTRIB_RELEASE="p6"
	elif has Sisyphus ; then DISTRIB_RELEASE="Sisyphus"
	fi

elif distro gentoo-release ; then
	DISTRIB_ID="Gentoo"
	MAKEPROFILE=$(readlink $ROOTDIR/etc/portage/make.profile 2>/dev/null) || MAKEPROFILE=$(readlink $ROOTDIR/etc/make.profile)
	DISTRIB_RELEASE=`basename $MAKEPROFILE`
	echo $DISTRIB_RELEASE | grep -q "[0-9]" || DISTRIB_RELEASE=`basename $(dirname $MAKEPROFILE)`

# Slackware based
elif distro mopslinux-version ; then
	DISTRIB_ID="MOPSLinux"
	if   has 4.0 ; then DISTRIB_RELEASE="4.0"
	elif has 5.0 ; then DISTRIB_RELEASE="5.0"
	elif has 5.1 ; then DISTRIB_RELEASE="5.1"
	elif has 6.0 ; then DISTRIB_RELEASE="6.0"
	elif has 6.1 ; then DISTRIB_RELEASE="6.1"
	fi
elif distro slackware-version ; then
	DISTRIB_ID="Slackware"
	DISTRIB_RELEASE="$(grep -Eo [0-9]+\.[0-9]+ $DISTROFILE)"

elif distro arch-release ; then
	DISTRIB_ID="ArchLinux"
	DISTRIB_RELEASE="2010"
	if grep 2011 -q $ROOTDIR/etc/pacman.d/mirrorlist ; then
		DISTRIB_RELEASE="2011"
	fi

# for Ubuntu use standard LSB info
elif [ "$DISTRIB_ID" = "Ubuntu" ] && [ -n "$DISTRIB_RELEASE" ]; then
	# use LSB version
	true

# Debian based
elif distro debian_version ; then
	DISTRIB_ID="Debian"
	DISTRIB_RELEASE=`cat $DISTROFILE`


# Mandriva based
elif distro pclinuxos-release ; then
	DISTRIB_ID="PCLinux"
	if   has "2007" ; then DISTRIB_RELEASE="2007"
	elif has "2008" ; then DISTRIB_RELEASE="2008"
	elif has "2010" ; then DISTRIB_RELEASE="2010"
	fi

elif distro mandriva-release || distro mandrake-release ; then
	DISTRIB_ID="Mandriva"
	if   has 2005 ; then DISTRIB_RELEASE="2005"
	elif has 2006 ; then DISTRIB_RELEASE="2006"
	elif has 2007 ; then DISTRIB_RELEASE="2007"
	elif has 2008 ; then DISTRIB_RELEASE="2008"
	elif has 2009.0 ; then DISTRIB_RELEASE="2009.0"
	elif has 2009.1 ; then DISTRIB_RELEASE="2009.1"
	else
		# use /etc/lsb-release info by default
		if has ROSA ; then
			DISTRIB_ID="ROSA"
		fi
	fi

# Fedora based
elif distro linux-xp-release || distro lxp-release; then
	DISTRIB_ID="LinuxXP"
	if has "Attack of the Clones" ; then DISTRIB_RELEASE="2006"
	elif has "2007" ; then DISTRIB_RELEASE="2007"
	elif has "2008" ; then DISTRIB_RELEASE="2008"
	elif has "2009" ; then DISTRIB_RELEASE="2009"
	fi

elif distro asplinux-release ; then
	DISTRIB_ID="ASPLinux"
	if   has Karelia ; then DISTRIB_RELEASE="10"
	elif has Seliger ; then DISTRIB_RELEASE="11"
	elif has "11.1" ; then DISTRIB_RELEASE="11.1"
	elif has Ladoga ; then DISTRIB_RELEASE="11.2"
	elif has "11.2" ; then DISTRIB_RELEASE="11.2"
	elif has "12" ; then DISTRIB_RELEASE="12"
	elif has "13" ; then DISTRIB_RELEASE="13"
	elif has "14" ; then DISTRIB_RELEASE="14"
	elif has "15" ; then DISTRIB_RELEASE="15"
	fi

elif distro MCBC-release ; then
	DISTRIB_ID="MCBC"
	if   has 3.0 ; then DISTRIB_RELEASE="3.0"
	elif has 3.1 ; then DISTRIB_RELEASE="3.1"
	fi

elif distro fedora-release ; then
	DISTRIB_ID="Fedora"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "release" | sed -e "s|.*release \([0-9]*\).*|\1|g")

elif distro redhat-release ; then
	# FIXME if need
	# actually in the original RHEL: Red Hat Enterprise Linux .. release N
	DISTRIB_ID="RHEL"
	if has CentOS ; then
		DISTRIB_ID="CentOS"
	elif has Scientific ; then
		DISTRIB_ID="Scientific"
	fi
	if has Beryllium ; then
		DISTRIB_ID="Scientific"
		DISTRIB_RELEASE="4.1"
	elif has Shrike ; then
		DISTRIB_ID="RedHat"
		DISTRIB_RELEASE="9"
	elif has Taroon ; then 	DISTRIB_RELEASE="3"
	elif has "release 4" ; then DISTRIB_RELEASE="4"
	elif has "release 5" ; then DISTRIB_RELEASE="5"
	elif has "release 6" ; then DISTRIB_RELEASE="6"
	elif has "release 7" ; then DISTRIB_RELEASE="7"
	fi

# SUSE based
elif distro SuSe-release || distro SuSE-release ; then
	DISTRIB_ID="SUSE"
	DISTRIB_RELEASE=$(cat "$DISTROFILE" | grep "VERSION" | sed -e "s|^VERSION = ||g")
	if   has "SUSE Linux Enterprise Desktop" ; then
		DISTRIB_ID="SLED"
	elif has "SUSE Linux Enterprise Server" ; then
		DISTRIB_ID="SLES"
	fi

# fixme: can we detect by some file?
elif [ `uname` = "FreeBSD" ] ; then
	DISTRIB_ID="FreeBSD"
	UNAME=$(uname -r)
	DISTRIB_RELEASE=$(echo "$UNAME" | grep RELEASE | sed -e "s|\([0-9]\.[0-9]\)-RELEASE|\1|g")

# fixme: can we detect by some file?
elif [ `uname` = "SunOS" ] ; then
	DISTRIB_ID="SunOS"
	DISTRIB_RELEASE=$(uname -r)

# try use standart LSB info by default
elif distro lsb-release && [ -n "$DISTRIB_RELEASE" ]; then
	# use LSB
	true
fi

case $1 in
	-p)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		pkgtype
		exit 0
		;;
	-h)
		echo "distr_vendor - system name and version detection"
		echo "Usage: distr_vendor [options] [args]"
		echo "-p [SystemName] - print type of packaging system"
		echo "-d - print distro name"
		echo "-v - print version of distro"
		echo "-e - print full name of distro with version (by default)"
		echo "-s [SystemName] - print name of distro for build system (like in the package release name)"
		echo "-n [SystemName] - print vendor name (as _vendor macros in rpm)"
		echo "-V - print the version of $0"
		echo "-h - this help"
		exit 0
		;;
	-d)
		echo $DISTRIB_ID
		;;
	-v)
		echo $DISTRIB_RELEASE
		;;
	-s)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		pkgvendor
		exit 0
		;;
	-n)
		# override DISTRIB_ID
		test -n "$2" && DISTRIB_ID="$2"
		rpmvendor
		exit 0
		;;
	-V)
		echo "20120519"
		exit 0
		;;
	*)
		# if run without args, just printout Name/Version of the current system
		[ -n "$DISTRIB_RELEASE" ] && echo $DISTRIB_ID/$DISTRIB_RELEASE || echo $DISTRIB_ID
		;;
esac

}

#PATH=$PATH:/sbin:/usr/sbin

set_sudo

check_tty

#############################

phelp()
{
	echo "$Descr
$Usage
 Commands:
$(get_help HELPCMD)

 Options:
$(get_help HELPOPT)
"
}

print_version()
{
        echo "EPM package manager version 1.2.8"
        echo "Running on $($DISTRVENDOR) ('$PMTYPE' package manager uses '$PKGFORMAT' package format)"
        echo "Copyright (c) Etersoft 2012-2013"
        echo "This program may be freely redistributed under the terms of the GNU AGPLv3."
}


Usage="Usage: epm [options] <command> [package name(s), package files]..."
Descr="epm - EPM package manager"

set_pm_type

verbose=
quiet=
nodeps=
force=
short=
non_interactive=
skip_installed=
show_command_only=
epm_cmd=
pkg_files=
pkg_names=

progname="${0##*/}"

case $progname in
    epmi)
        epm_cmd=install
        ;;
    epme)
        epm_cmd=remove
        ;;
    epmcl)
        epm_cmd=changelog
        ;;
    epms)
        epm_cmd=search
        ;;
    epmq)
        epm_cmd=query
        ;;
    epmqi)
        epm_cmd=info
        ;;
    epmqf)
        epm_cmd=query_file
        ;;
    epmqa)
        epm_cmd=packages
        ;;
    epmqp)
        epm_cmd=query_package
        ;;
    epmql)
        epm_cmd=filelist
        ;;
    epmu)
        epm_cmd=update
        ;;
    epm|upm|eepm)
        ;;
    *)
        # epm by default
        # fatal "Unknown command: $progname"
        ;;
esac

check_command()
{
    # do not override command
    [ -z "$epm_cmd" ] || return

# Base commands
    case $1 in
    -i|install|add)       # HELPCMD: install package(s) from remote repositories or from local file
        epm_cmd=install
        ;;
    -e|-P|remove|delete|uninstall)  # HELPCMD: remove (delete) package(s) from the database and the system
        epm_cmd=remove
        ;;
    -s|search)            # HELPCMD: search in remote package repositories
        epm_cmd=search
        ;;
    -qp|query_package)    # HELPCMD: search in the list of installed packages
        epm_cmd=query_package
        ;;
    -qf|which|belongs)    # HELPCMD: query package(s) owning file
        epm_cmd=query_file
        ;;

# Useful commands
    reinstall)            # HELPCMD: reinstall package(s) from remote repositories or from local file
        epm_cmd=reinstall
        ;;
    Install)              # HELPCMD: perform update package repo info and install package(s) via install command
        epm_cmd=Install
        ;;
    -q|installed)         # HELPCMD: check presence of package(s)
        epm_cmd=query
        ;;
    -sf|sf|filesearch)    # HELPCMD: search in which package a file is included
        epm_cmd=search_file
        ;;
    -ql|filelist)         # HELPCMD: print package file list
        epm_cmd=filelist
        ;;
    check|fix|verify)     # HELPCMD: check local package base integrity and fix it
        epm_cmd=check
        ;;
    changelog|cl)         # HELPCMD: show changelog for package
        epm_cmd=changelog
        ;;
    -qi|info|show)        # HELPCMD: print package detail info
        epm_cmd=info
        ;;
    requires|deplist)     # HELPCMD: print package requires
        epm_cmd=requires
        ;;
    provides)             # HELPCMD: print package provides
        epm_cmd=provides
        ;;
    whatdepends)          # HELPCMD: print packages dependences on that
        epm_cmd=whatdepends
        ;;
    -qa|list|packages|-l) # HELPCMD: list of installed package(s)
        epm_cmd=packages
        ;;
    programs)             # HELPCMD: list of installed program(s)
        epm_cmd=programs
        ;;

# Repository control
    update)               # HELPCMD: update remote package repository databases
        epm_cmd=update
        ;;
    addrepo|ar)           # HELPCMD: add package repo
        epm_cmd=addrepo
        ;;
    repolist|sl|rl|listrepo) # HELPCMD: print repo list
        epm_cmd=repolist
        ;;
    removerepo|rr)        # HELPCMD: remove package repo
        epm_cmd=removerepo
        ;;
    release-upgrade)      # HELPCMD: update whole system to the next release
        epm_cmd=release_upgrade
        ;;
    kernel-update|kernel-upgrade|update-kernel)      # HELPCMD: update system kernel to the last repo version
        epm_cmd=kernel_update
        ;;

# Other commands
    clean)                # HELPCMD: clean local package cache
        epm_cmd=clean
        ;;
    autoremove)           # HELPCMD: auto remove unneeded package(s)
        epm_cmd=autoremove
        ;;
    upgrade|dist-upgrade) # HELPCMD: performs upgrades of package software distributions
        epm_cmd=upgrade
        ;;
    Upgrade)              # HELPCMD: performs update && upgrade command
        epm_cmd=Upgrade
        ;;
    simulate)             # HELPCMD: simulate install (it does check requires, minimally)
        epm_cmd=simulate
        ;;
    checkpkg|integrity)   # HELPCMD: check package integrity
        epm_cmd=checkpkg
        ;;

    *)
        return 1
        ;;
    esac
    return 0
}

check_option()
{
    case $1 in
    -h|--help|help)       # HELPOPT: this help
        phelp
        exit 0
        ;;
    -v|--version)         # HELPOPT: print version
        print_version
        exit 0
        ;;
    --verbose)            # HELPOPT: verbose mode
        verbose=1
        ;;
    --skip-installed)     # HELPOPT: skip already install during install
        skip_installed=1
        ;;
    --show-command-only)  # HELPOPT: show command only, do not any action (supports install and remove ONLY)
        show_command_only=1
        ;;
    --quiet)              # HELPOPT: quiet mode (do not print commands before exec)
        quiet=1
        ;;
    --nodeps)             # HELPOPT: skip dependency check (during install/simulate and so on)
        nodeps="--nodeps"
        ;;
    --force)              # HELPOPT: force install/remove package (f.i., override)
        force="--force"
        ;;
    --short)              # HELPOPT: short output (package instead package-version-release)
        short="--short"
        ;;
    --auto)               # HELPOPT: non interactive mode
        non_interactive=1
        ;;
    *)
        return 1
        ;;
    esac
    return 0
}

for opt in "$@" ; do
    check_command $opt && continue
    check_option $opt && continue

    if [ -f "$opt" ] && echo $opt | grep -q "\." ; then
        pkg_files="$pkg_files $opt"
    else
        pkg_names="$pkg_names $opt"
    fi
done

pkg_files=$(strip_spaces "$pkg_files")
pkg_names=$(strip_spaces "$pkg_names")

pkg_filenames=$(strip_spaces "$pkg_files $pkg_names")

# Just debug
#echover "command: $epm_cmd"
#echover "pkg_files=$pkg_files"
#echover "pkg_names=$pkg_names"

# Just printout help if run without args
if [ -z "$epm_cmd" ] ; then
    print_version
    echo
    fatal "Run $ $progname --help for get help"
fi

# Run helper for command
epm_$epm_cmd
# return last error code (from subroutine)
