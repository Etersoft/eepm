%define _unpackaged_files_terminate_build 1
Name: eepm
Version: 3.61.4
Release: alt1

Summary: Etersoft EPM package manager

License: AGPL-3.0+
Group: System/Configuration/Packaging
Url: http://wiki.etersoft.ru/EPM

Packager: Vitaly Lipatov <lav@altlinux.ru>

# Source-url: https://github.com/Etersoft/eepm/archive/refs/tags/%version.tar.gz
Source: %name-%version.tar

BuildArchitectures: noarch

%if "%_vendor" == "alt"
Obsoletes: epm
Provides: epm = %EVR

# FIXHERE: Replace with target platform package manager
Requires: apt rpm
# apt-scripts missed on ALT SP 8, update-kernel is extra in containers
#Requires: apt-scripts update-kernel
# TODO: don't use at all
Requires: apt-repo

%endif

AutoProv:no
AutoReq:no

# TODO: drop gzip (used in some pack.d/repack.d/play.d)
Requires: coreutils diffutils findutils file gawk grep gzip less sed bash termutils

%description
Etersoft EPM is the package manager for any platform
and any platform version. It provides
universal interface to any package manager.
Can be useful for system administrators working
with various distros.

See detailed description here: http://wiki.etersoft.ru/EPM

%package repack
Summary: Etersoft EPM package manager (repack requirements)
Group: System/Configuration/Packaging
Requires: %name = %EVR
Requires: alien dpkg patchelf p7zip
Requires: /usr/bin/rpmbuild

%description repack
This package has requirements needed for using epm repack on ALT
(repack rpm packages and repack/install deb packages).

See https://bugzilla.altlinux.org/show_bug.cgi?id=34308 for
a discussion about extra requirements.

%prep
%setup

%install
%make_install install DESTDIR=%buildroot \
	datadir=%_datadir bindir=%_bindir mandir=%_mandir \
	sysconfdir=%_sysconfdir version=%version-%release

%files
%doc README.md TODO LICENSE
%dir %_sysconfdir/eepm/
%dir %_sysconfdir/eepm/play.d/
%dir %_sysconfdir/eepm/pack.d/
%dir %_sysconfdir/eepm/repack.d/
%dir %_sysconfdir/eepm/prescription.d/
%config(noreplace) %_sysconfdir/eepm/eepm.conf
%config(noreplace) %_sysconfdir/eepm/serv.conf
%config(noreplace) %_sysconfdir/eepm/*.list
%config(noreplace) %_sysconfdir/eepm/repack.d/*
%config(noreplace) %_sysconfdir/eepm/pack.d/*
%config(noreplace) %_sysconfdir/eepm/play.d/*
%config(noreplace) %_sysconfdir/eepm/prescription.d/*
%_bindir/epm*
%_bindir/eepm
%_bindir/serv
%_bindir/distr_info
%_bindir/esu
%dir /var/lib/eepm/
%dir /var/cache/eepm/
%_man1dir/*
%_datadir/%name/
%_sysconfdir/bash_completion.d/serv
%_sysconfdir/bash_completion.d/eepm

%if "%_vendor" == "alt"
%files repack
%endif


%changelog
* Wed Apr 03 2024 Vitaly Lipatov <lav@altlinux.ru> 3.61.4-alt1
- epm-repack-rpm: check package name after spec fixing
- epm play yandex-messanger: rename package chats to yandex-messenger
- epm play r7-office-organizer*: fix removing on ALT (fix package name)
- epm play.d/common.sh: allow a few packages in PKGNAME (assume they with the same version)
- epm play: add i586-openssl098
- epm-programs: add --short support
- epm play telegram: add direct URL support
- epm play mailruagent: rewritten
- epm repack cascadeur: rewritten
- epm pack flashplayer: move all code from repack rule
- epm pack Telegram: move desktop/icons from repack rule
- epm pack 64Gram: move icons/desktop from repack rules
- epm repack cuda-z: move icons/desktop from repack rule
- epm repack vkteams: move icons/desktop from repack rule
- epm play: Added snap support

* Tue Apr 02 2024 Vitaly Lipatov <lav@altlinux.ru> 3.61.3-alt1
- epm play chrome: fix downloading
- epm play: add popcorn-time
- epm play: add tradingview
- epm play element-desktop: add direct URL
- epm play kyodialog: update to 9.3
- epm play: add support for run direct script
- epm play.d/common.sh: do fatal if there are a few packages in PKGNAME
- epm play onlyoffice: fix is_glibc_enough call

* Mon Apr 01 2024 Vitaly Lipatov <lav@altlinux.ru> 3.61.2-alt1
- epm play: fix forcing version with --ipfs
- epm play myoffice: add direct download for known version
- epm pack snap4arduino: use .tar as intermediate archive
- epm play librewolf: fix download for ALT 10
- distr_info: add initial support for OpenMandrivaLx
- epm play: rewrite r7-office-organizer, add r7-office-organizer-pro
- epm repack rudesktop: drop original requires

* Mon Apr 01 2024 Vitaly Lipatov <lav@altlinux.ru> 3.61.1-alt1
- epm release-upgrade: add rule for OpenMandrivaLX (untested)
- epm repack.d/common.sh: add tags Requires, Conflicts, Provides after main tags
- epm play: fix icons install for JetBrains products
- epm repack: add apache-netbeans rule to ignore some deps
- epm play anydesk: use direct link to workaround against buggy vendor server

* Mon Apr 01 2024 Vitaly Lipatov <lav@altlinux.ru> 3.61.0-alt1
- epm play angie: update distros
- epm play: add kyocera-sane
- epm repack ungoogled-chromium: fix duplication .desktop file
- epm repack 64gram: disable autoupdate
- epm pack/repack: download package in any case
- rsync_alt_contents_index: add warning if rsync check is failed
- epm play guardant: use repack for all rpm based distros
- epm pack sidequest: fix icons install
- epm play virtualhere: replace legacy converting code to epm pack using
- epm play snap4arduino: rewrite via epm pack
- epm play sublime: rewrite via epm pack
- epm play.d: introduce warn_version_is_not_supported() and use it
- epm play logseq: move repacking to pack.d
- epm play liteide: move repacking to pack.d
- epm play: add URL where missed
- epm play common: switch to update to latest known version
- epm play common.sh: use last unknown version if --ipfs in use
- epm play: replace epm tool eget with just eget
- epm play: add mytonwallet
- epm repack: add check if the package name is the same as was in play.d script
- epm pack.d/generic-appimage.sh: improve PRODUCT/VERSION separating
- epm play xod-ide: fix downloading and repacking
- epm repack.d/generic-appimage.sh: set PRODUCTCUR (as lowercased PRODUCT) and create link if they differs
- epm play: cleanup rudesktop download and repacking
- epm play.d: add override_pkgname and use it
- epm play telegram: fix beta support
- epm play: install latest tested version by default
- epm repack.d/generic.sh: fill only empty Summary
- eget: add support square brackets as wildcards
- epm-repack-rpm: run fix spec after repack scripts
- epm play pantum: full rewrite
- epm play epsonscan2: rewrite, split epsonscan2-non-free-plugin separately
- epm play epson-printer-utility: cleanup
- epm repack: add support for .appimage (low case) extension
- epm pack.d/generic-appimage.sh: don't override package version with X-AppImage-Version (can be wrong)
- epm play: fix version issues (installing by version package we get before)
- epm play.d/common.sh: implement install_pkgurl and install_pack_pkgurl and use it (repack rpm packages for any distro)
- epm play piktomir: clean up via pack.d/piktomir.sh
- epm play: remove obsoleted sputnik-browser, net.downloadhelper.coapp.sh
- epm play cnrdrvcups-ufr2: enable repack for rpm
- epm play aksusbd: update to 9.15, switch to IPFS
- epm pack.d/generic-appimage.sh: fix for version started with v
- epm play: add NotepadNext
- epm pack: add create_file() and use it
- epm repack: huge cleanup
- epm repack: remove unused scripts

* Thu Mar 28 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.13-alt1
- epm play: add mailspring
- epm-remove: stop hi level removing when --noscripts is used
- epm play telegram: add check for glibc 2.28
- epm play: add sidequest
- epm play: add element-desktop
- epm play: add mattermost-desktop
- epm-assure: keep installed packages
- epm-autoremove: stop on AstraLinux (unsupported by the distro)
- epm: allow scripts in Kaspersky packages
- epm repack PacketTracker: improved for 8.2 and 8.2.1
- epm play packet-tracer: add install from sysnettechsolutions
- epm play: add epson-printer-utility
- epm-repack-rpm: use fakeroot when is not root (to avoid alien warning about root)
- vdhcoapp: fix package name
- eget: hide missed Brave's ipfs error
- eget: add support for a new IPFS gateways
- epm play: add nwjs-ffmpeg-prebuilt
- epm repack trueconf: fix for trueconf client since 8.4.0.1957

* Tue Mar 26 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.12-alt1
- eget: fix --check using (also allow --check for backward compatibility)
- epm play: add yandex-messenger
- epm play: add pfusp (Ricoh SP-1120N / SP-1125N / SP-1130N Image Scanner Driver)
- epm play: add webots

* Sun Mar 24 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.11-alt1
- repack.d: remove scripts with only add_libs_requires (it is default behaviour)
- epm play: add xnconvert
- epm-pack: change HOME to $(pwd) for pack.d scripts
- epm play brave: drop dev build
- epm play: add reaper
- epm pack.d/generic-appimage.sh: add workaround for empty version in the desktop file
- epm play yuzu: switch to IPFS archive
- epm play virtualhere: fix version retrieving
- epm repack net.downloadhelper.coapp.noffmpeg: add conflict to net.downloadhelper.coapp
- epm play todoist: cleanup for new AppImage naming scheme
- epm pack generic-snap.sh: fix icon placement and desktop file
- epm play geogebra: restore install via IPFS store
- epm play freeplane: fix download URL
- epm repack ipera-mediaserver: fix requires
- epm play t1client: update download URL
- epm pack far2l-portable: fix package name as far2l-portable
- epm play yandex-music: fix package name
- epm-full_upgrade: don't stop if epm play is failed
- epm pack: add davinchi-resolve
- epm pack: add postman
- add epm Downgrade (update and downgrade)
- epm play lunacy: don't install if glibc is too old
- epm repack postman: packing as electron app
- epm play: add unsupported docker-desktop
- eget: replace --check with --check-url and --check-site

* Sun Mar 17 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.10-alt1
- distr_info: identify all Fedora based system as Fedora
- epm-addrepo: fixes for URLs to ALT repos
- epm pack vkteams: fix unpacking
- epm play: add wing (ALT bug 47465)
- epm play teamviewer: add aarch64
- epm play: print package description before install
- epm play: add ridoclnx
- epm repack r7-office: add comment
- epm play: onlyoffice.sh: use --repack for all platforms
- epm repack: update onlyoffice-desktopeditors
- epm repack: add support for --verbose and --nodeps

* Mon Mar 11 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.9-alt1
- epm repack.d/common.sh: skip alt specific on non ALT systems
- epm pack.d/generic-appimage.sh: get VERSION from X-AppImage-Version field of a desktop file
- epm repack: run add_libs_requires by default
- epm play viber: use AppImage
- epm play: add tonkeeper
- epm repack: add net.downloadhelper.coapp.noffmpeg
- epm play r7-office: update for support new versions
- add_chromium_deps(): remove libatopology.so.2
- epm repack balena-etcher: move to /opt
- epm repack: add hack for get AppImage version from URL
- epm play: add neovide
- epm repack librewolf: fix repacking

* Mon Mar 11 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.8-alt1
- epm-sh-altlinux-contents-index: fix update content index
- epm repack plex-desktop: fix repack with eepm-rpm-build
- epm-search: don't use -- in dnf/yum search
- set_sudo: check sudo twice
- distr_info: use lastest ID_LIKE word
- distr_info: fix Android version detection
- epm play yandexmusic: update download package name
- repack.d/generic.sh: disable /usr/lib/.build-id generating
- epm repack google-chrome-stable: fix summary, add conflicts to google-chrome-preinstall
- repack.d/unigine-superposition.sh: stop require libQt5Test.so.5
- epm play: rename yandexmusic.sh to yandex-music.sh
- epm play: don't check if a play script is executable
- epm repack teamspeak3: add libwebp6 install (fix github issue 64)
- epm repack teamspeak3: remove unusable libqwayland*
- epm play teamspeak: update versions
- epm play: add singularityapp (fix github issue 49)
- epm requires: check every file separately
- epm repack singularityapp: remove common libs
- epm play: add vk-messenger (fix github issue 50)

* Tue Feb 20 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.7-alt1
- epm-update: skip apt-cache (use too much time)
- /etc/pkgallowscripts.list: allow scripts for eepm as a hack
- epmp switch-to-nvidia.sh: added check kflavour
- epm-repofix: rewrite epm repo change
- epm prescription i586-fix: no remove in auto mode
- epm repack anydesk: add missed gtk gl libs
- epm play switch-to-nvidia.sh: add --force support
- epm play switch-to-nvidia: cleanup check_run_kernel
- epm repack sbb: fix libcurl-gnutls.so.4(64bit) require (ALT bug 47890)

* Thu Feb 08 2024 Vitaly Lipatov <lav@altlinux.ru> 3.60.6-alt1
- epm repack net.downloadhelper.coapp: add json for browsers
- add ALT_BRANCH_ID support for ALT SP Workstation
- repack.d/net.downloadhelper.coapp.sh: fix path
- epm play rstudio: add ROSA support
- epm-repack-rpm: try use hard link during copying
- epm-sh-functions: fix BIGTMPDIR
- epm repack librewolf: fix dependencies
- epm-epm_install: use SYSTEMARCH for distro independent arch checking
- epm-repolist: add support for apt-dpkg
- epm play wine: add support for wow64 build
- epm prescription switch-to-nvidia: fixed check kernel version and added make-initrd
- epm play: add upscayl (thx @bbadon)
- epm play: add yandexmusic

* Sat Dec 23 2023 Vitaly Lipatov <lav@altlinux.ru> 3.60.5-alt1
- epm repack Telegram: disable updater
- epm play telegram: set maximal version for glibc
- epm play viber: use only latest Viber version
- epm play vdhcoapp: add support for 2.x version

* Tue Nov 21 2023 Vitaly Lipatov <lav@altlinux.ru> 3.60.4-alt1
- epm play vivaldi: disable install external codecs
- epm-sh-functions: allow override error comment with EPMPROMOMESSAGE
- epm pack k3s: add symlinks
- epm-install: fix broken grep rule
- epm prescription switch-no-nvidia: add ROSA support via kroko-cli
- epm prescription switch-no-pipeware: add ROSA support
- epm repo change: add support for ftp.altlinux.org and mirror.eterfund.org
- __epm_assure_7zip: install 7-zip firstly
- epm pack: fix dir permissions for AppImage
- update switch-to-nvidia.sh. More packages. Add vesa as cleanup xorg trigger (#45)
- update switch-to-nvidia.sh (#46)
- epm repack Telegram: revert desktop name to origin
- epm addrepo: add deferred repo support
- update switch-to-nvidia.sh (#47)
- epm play librewolf: repack for alt
- epm repack: add workaround for missed icons
- epm play: add xod-ide support
- epm-update: update local packages list only if /etc/bash_completion.d is exists

* Fri Sep 22 2023 Vitaly Lipatov <lav@altlinux.ru> 3.60.3-alt1
- epm repack: add support for plk-sane
- epm play: add webcord
- epm play pantum: replaced set_autoreq by add_libs_requires
- epm play powershell: fix get version from github
- epm play rememberthemilk: hidden from the list
- epm play duplicati: replaced set_autoreq by add_libs_requires
- epm play kyodialog: replaced set_autoreq by add_libs_requires
- epm play firefox-nigtly: replaced set_autoreq by add_libs_requires
- epm play duckstation: move to preview version
- epm play t1client: added ignore_lib_requires libmng.so.1
- epm play far2l-portable: move to AppImage

* Fri Sep 22 2023 Vitaly Lipatov <lav@altlinux.ru> 3.60.2-alt1
- epm play steam: fix bug
- epm play common.sh: allow removing for packages from the distro repo
- epm repack generic.sh: override version with value from eepm.yaml file
- epm play: add guardant (glds)
- epm repack atom: fix packing with eepm-rpm-build
- epm prescription switch-to-nvidia: added nvidia-modprobe (for the nvenc codec to work)
- epm repack wps-office: fix broken deps
- epm-sh-functions: fix BIGTMPDIR
- epm play zoom: fix broken deps
- epm play common.sh: accelerated find provides, fix objdump a.out, skipping empty lines in function add_libs_requires
- epm play spotify: fix broken deps
- epm play sane-panakvs: replaced set_autoreq by add_libs_requires
- epm play realvnc-viewer: replaced set_autoreq by add_libs_requires
- epm play realvnc-server: replaced set_autoreq by add_libs_requires
- epm play pycharm-professional: replaced set_autoreq by add_libs_requires
- epm play jetbrains-toolbox: replaced set_autoreq by add_libs_requires
- epm play: add SKIPREPACK for packages allowed install nonmodified
- epm repack: add printer-driver-pantum.sh
- epm play angie: fix repo for ALT and Astra
- erc: fixed 7z working with spaces in names
- erc: added assume Yes on all queries for unpack with 7z

* Sat Aug 26 2023 Vitaly Lipatov <lav@altlinux.ru> 3.60.1-alt1
- epm repack common.sh: speedup requires retrieving
- epm repack-rpm: try install eepm-rpm-build
- epm repack: use cpio fixing only for rpm/deb
- epm repack: fix chat-gpt repack issue

* Thu Aug 24 2023 Vitaly Lipatov <lav@altlinux.ru> 3.60.0-alt1
- epm play: add teamspeak3, teamspeak5, chatgpg-desktop, idea-community
- epm play: add rememberthemilk, rupost, powershell, dbeaver
- epm play: add thinlic-client, balena-etcher, bitwig-studio
- epm play angie: update supported distros
- epm: fix args for epm tool
- epm play: add 1c-connect
- epm-check_updated_repo: add support for LISTS from apt-config (see ALT bug 46987)
- epm repack yandex-browser: set update-ffmpeg as non executable
- epm repack generic.sh: do fix_cpio_bug_links (workaround for ALT bug 42189)
- epm repack teamviewer: rewrite
- epm repack: telegram: fix .desktop filename to work correctly in Wayland
- epm prescription: add glusterfs10, glusterfs11
- epm-downgrade: restore suddenly removed code for full downgrade (ALT bug 47048)
- epm repack bitwarden: use electron deps
- epm repack: rewrite with UNIREQUIRES and predefined lists
- epm repack: add missed yandex-browser-corporate-codecs-ffmpeg-extra.sh
- epm play steam: install only from repo on ALT
- use LC_ALL=C instead of LANG=C
- epm-repack-rpm: use eepm-rpmbuild if available
- epm play trueconf: fix package name
- epm play: add trueconf-server
- epm repack *codecs-ffmpeg: disable autoreq, cleanup
- epm restore: add pyproject.toml support
- epm play: check available glibc, not distro version
- epm play common: add is_openssl_enough, is_pkg_enough, is_glibc_enough
- epm repack: add is_soname_present and use it for chat-gpt
- epm play rudesktop: repack for ALT
- ercat: add --quiet support
- epm repo add: fix quoting, add --force support
- epm play wine: don't install wine-mono, wine-gecko directly
- epm repack kyodialog: fix version
- epm-install-alt: fix install kernel modules
- epm play: drop support for options without --
- epm repack: stop autoreq: yes for some scripts
- epm repack generic-appimage: use add_libs_requires
- epm repack: skip ALT only macros using when epm-rpm-build is used
- epm play: use ffmpeg-plugin-browser on ALT
- epm repack: skip /usr/lib and /usr/lib64 dir
- epm play rustdesk: allow install latest 1.2.2 version and fix 1.1.9 install
- fix breaking typo in i586-support.sh
- epm repack cnrdrvcups-ufr2-uk: fix issue with fixed libjbig

* Sat Jul 22 2023 Vitaly Lipatov <lav@altlinux.ru> 3.59.0-alt1
- epm play: add rpcs3, pcsx2, duckstation
- epm play signal: switch to new way to get the latest version
- epm play: add clion, idea, phpstorm, webstorm
- epm play: speed up apps list
- epm play opera: fix install on deb systems
- epm play yandex-browser: fix install corporate on rpm systems

* Fri Jul 21 2023 Vitaly Lipatov <lav@altlinux.ru> 3.58.4-alt1
- epm play: add pachca
- epm assure: don't print to stdout ever in --verbose
- epm pack hplip-plugin: add --nox11 (ALT bug 46507)
- epm repack: rewrite skype repacking (ALT bug 45502)
- epm play vkteams: implement via epm pack
- epm list: implement --upgradable
- epm play yandex-browser: install for ALT from rpm, add support for corporate package

* Fri Jul 21 2023 Vitaly Lipatov <lav@altlinux.ru> 3.58.3-alt1
- epm update --content-index: ignore errors
- epm update: refactoring
- epm play add yuzu support
- epm play add pgadmin4
- epm play bitrix24: repack always, improve repacking

* Wed Jul 19 2023 Vitaly Lipatov <lav@altlinux.ru> 3.58.2-alt1
- epm play teams: restore install, via web.archive.org
- epm play: add bitrix24
- epm play: add figma
- epm prescription switch-to-nvidia: update kernel only instead of full-upgrade, do i586-fix after all
- epm-repack-rpm: improve icon subdirs removing from packing
- distr_info: detect apt-get firstly
- epm repack: set umask 022 before repack

* Tue Jul 18 2023 Vitaly Lipatov <lav@altlinux.ru> 3.58.1-alt1
- epm repack cnrdrvcups-ufr2-uk: use UNIREQUIRES
- epm repack yandex-browser: fix Provides (ALT bug 46967)
- epm repack Telegram/64Gram: add deps from ldd output for the main binary
- epm repack code/codium/draw.io: use add_electron_deps
- epm requires: add ELF support
- distr_info: don't print orig version if it is the same as release
- epm prescription: update switch-to-nvidia
- epm repoindex: drop sudo
- distr_info: get_service_manager: use 1 process name by default

* Sat Jul 15 2023 Vitaly Lipatov <lav@altlinux.ru> 3.58.0-alt1
- distr_info: get_service_manager: check if systemd is running with pid 1
- epm play common.sh: use is_repacked for --installed
- epm repack ipera-client: add missed require (ALT bug 43761)
- epm-repack-rpm: call generic-default if there is no special repack script
- epm repack: use AutoReq: no, AutoProv: no by default
- epm-download: force download for repack
- epm mark showhold: add --short support for dnf
- epm mark: add checkhold
- epm mark: dnf: skip checking if versionlock is not installed
- distr_info: user HOME_URL if BUG_REPORT_URL is empty
- distr_info: use VENDOR_ID for select pkgtype
- epm repack: fix cnrdrvcups-ufr2-uk
- epm provides: add --short support for apt, separate requires by lines
- epm print compare version: implement via lua:print for non ALT rpm)
- epm repack common: implement add_unirequires and UNIREQUIRES support
- epm repack common: chmod 0755 all executable targets
- epm repack cuda-z: use UNIREQUIRES
- epm repack zoom: switch to UNIREQUIRES
- epm repack anydesk: switch to UNIREQUIRES
- epm repack: switch to add_electron_deps and add_chromium_deps
- epm play anydesk: fix download latest version

* Fri Jul 14 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.14-alt1
- epm play: rewrite packages list operation via join
- erc: don't expand symlink in a path to a archive
- erc: extract_archive(): add tgz unpacking
- epm repack wps-office: fix segfault (ALT bug 45683)
- epm play onlyoffice: all get any version from github releases
- epm play onlyoffice: use 7.3.3 for p9 and c9f2
- epm play: add t1client support
- epm pack kubo: install /usr/bin/ipfs as executable

* Wed Jul 12 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.13-alt1
- epm play: add portmaster
- epm play todoist: fix package name
- epm play ungoogled-chromium: keep old version due libc.so.6(GLIBC_2.33)
- epm play: remove repack for rudesktop
- epm pack: fix binary permissions for 64Gram/Telegram (7z issue)
- epm repack generic-appimage: fix EXEC getting from desktop file
- epm: add notify about --no-check-cerificate

* Mon Jul 03 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.12-alt1
- epm play: add unifiedremote
- epm sf: fix index update
- epm play libicu56: use http (ALT bug 46508)
- epm play vinteo.desktop: fix url (ALT bug 46501)
- epm repack synology-drive: fix libnautilus issue (ALT bug 46509)
- epm repack generic-appimage: get PRODUCTCUR from desktop file
- epm play mssql-tools: fix download url
- epm repack brave: disable AutoReq
- epm prescription i586-support: fix typo
- epm prescription i586-fix: check vulkan-amdgpu only on ALT p10
- erc: add support for repack tgz->tar in 7z mode
- erc: use tar for tar creating
- distr_info: treat 0.x version as Sisyphus

* Sun Jul 02 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.10-alt1
- epm play: add eXpress client
- epm play: add firefox-nightly
- epm play: add weasis
- eget: fix concatenate_url_and_filename()

* Thu Jun 29 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.9-alt1
- epm play: add hansoft-client
- epm prescription i586-fix: fix missed support
- epm print info: add epm version output
- epm check_updated_repo: apt based only

* Tue Jun 27 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.8-alt1
- epm list --available: fix for yum
- epm play steam: don't use deb if package can be installed from the repo
- epm play netbeans: fix install latest version (ALT bug 46505)
- epm play netbeans: change download url to support any released version, not latest only
- epm: fix description for epm sf
- epm repack anydesk: add all needed packages to requires
- generic-appimage: fix file permissions
- eepm.spec: drop update-kernel, apt-scripts from requires

* Wed Jun 07 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.7-alt1
- epm repack: add_requires: for ALT only
- epm repack audiorelay: disable AutoReq, add manual requires
- epm repack k3s.sh: fix unitdir (for systemd services)
- epm repack anydesk: fix requires
- epm play commfort-client: get version from the site
- epm-filelist: add missed module epm-check_updated_repo
- epm play i586-fix: call i586-support firstly
- epm play aksusbd: add support for i386, aarch64, armhf
- distr_info: export SYSTEMARCH (-a)
- epm play: fix (arch dependent) list for deb systems
- distr_info: don't export vars, set only
- epm-sh-functions: don't export DISTRVENDOR

* Mon May 29 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.6-alt1
- epm repo index: add x86_64-i586 support
- prescription: just add pipewire script
- epm clean: add --direct support and print about a possibility to use it
- epm check_updated_repo: add check if apt indexes is never updated
- don't handle ALTServer distro separately
- distr_info: fix ID_LIKE support, update tests

* Sun May 28 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.5-alt1
- distr_info: add ID_LIKE support and small fixes
- fix content info checking

* Sat May 27 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.4-alt1
- epm repopkg: always use i586 arch for 32 bit packages
- epm-sh-functions: hide missed TMPDIR warning
- epm provides: improve for dnf
- epm play logseq: fix name
- epm: check if /dev/stdin is pipe when check command in stdin

* Tue May 23 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.3-alt1
- added --nox11 to pack.d/far2l-portable.sh (ALT bug 45869)
- epm repack ungoogled-chromium: fix chrome-sandbox name
- epm repack discord: disable autoreq, add fixed reqs
- epm play flyview-server: add comments about user, create var dir (ALT bug 45630)

* Tue May 23 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.2-alt1
- i586-fix: added libd3d
- epm repack.d/generic.sh: improve python3 support
- simplify download via eget, parse result strictly
- epm full-upgrade: add --interactive support (ask for every step)
- esu: add messages if sudo or su is missed or not accessible
- epm addrepo: install apt-https if add https:// repo
- epm play: use https only
- epm play: add logseq support
- epm play: add freeplane
- epm requires/provides: add support for remote files (url)
- epm repack: ungoogled-chromium: fix chrome-sandbox name
- epm repack epsonscan2: fix linking
- epm repack 64Gram: fix updater disabling
- epm play cascadeur: revert to 2022.3.1 version
- epm filelist/search-file: move content index update to epm update

* Mon May 15 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.1-alt1
- epm-sh-functions: add more diag info about tmp, drop rmdir for removed tmp files
- revert "disable bash completion for epm (see alt bug 46146)"
- epm repack: restore fixing tarball files permissions
- epm repack mobirise: add libjpeg8 require for newest versions

* Mon May 15 2023 Vitaly Lipatov <lav@altlinux.ru> 3.57.0-alt1
- disable bash completion for epm (see alt bug 46146)
- epm play: add piktomir
- epm play: add epsonscan2
- epm repack gitkraken: disable perl requires (todo: remove embedded git?)
- epm-install: improve interactive mode
- epm download: check file after eget
- epm ei: check stable branch for eepm install only, trying install eepm from the repo
- epm ei: improve checking for url(s) returned from Korinf repo
- epm pack: rewrite and fix --repack logic

* Sun May 14 2023 Vitaly Lipatov <lav@altlinux.ru> 3.56.1-alt1
- eget: add --get-ipfs-cid to help, fix for case when IPFS is disabled (no accessible gateway)
- epm repack: fix hack for empty Summary
- epm pack.d/generic-snap.sh: fixes
- epm play: add plex-desktop
- epm pack.d: fix generic-appimage.sh
- epm download: use BIGTMPDIR for temp download dir

* Sun May 14 2023 Vitaly Lipatov <lav@altlinux.ru> 3.56.0-alt1
- epm repack hplip-plugin: add hplip require
- epm full-upgrade: fix --assumeyes option for flatpak
- epm play: use short epm version for get ipfs db
- epm policy: implement via dnf/yum info for dnf/yum based systems
- epm forbids * in any package names
- epm: add epm grep as alias for epm qp
- epm: modify PATH only for subprocess
- epm pack 1c83client: use esu instead of SUDO
- epm: introduce --debug and use it to enable bash -x
- improve load_helper to skip repeated include
- epm repack: use epm_status_repacked() instead if checking inplace
- epm pack: refactoring, move script runnning to a separate func
- epm: implement --put-to-repo=/path/repo support
- add epm tool yaml
- epm: fix --norepack option
- epm pack.d: add generic-snap.sh
- epm repack: implement all pack related things via pack code
- epm repack: set Distribution: EEPM, fix epm status

* Fri May 12 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.8-alt1
- epm play: add k3s
- epm play: add webdavmailrucloud
- epm autoorphans: implement skip packages on hold
- epm-sh-install: skip vendor/scripts warning in dryrun mode
- epm full-upgrade: implement --dry-run (--just-print) support
- add initial epm bash completion
- epm download __download_pkg_urls(): allow download any files
- epm full-upgrade: add --no-clean (via config too) to disable clean after upgrade
- epm play --list-installed-packages: print packages for hidden apps too
- epm repack discord: rewrite files install part
- epm repo reset: implement for ALT
- epm repo save/restore: add to help, change work dir
- epm repo status: implement for apt
- epm assure: move warning text from assure_exists()
- assure_exists(): make interactive by default, mark as auto installed (ALT bug 42240)
- epm repack jetbrains-toolbox: rewrite install script (ALT bug 45870)

* Mon May 08 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.7-alt1
- epm install kernel-module*: skip install if there is no any kernel
- epm play virtualbox-extpack: rewrite to use package install
- epm repack generic.sh: disable rpmlint
- epm play: add hplip-plugin
- epm update: save all available packages after update

* Mon May 08 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.6-alt1
- epm play: add flashplayer
- epm play: add audiorelay
- epm play: add virtualbox-extpack
- esu: add support for quoted args (with spaces)
- epm play: use esu instead of $SUDO
- epm play common.sh: check for package status before remove
- epm downgrade: download files by pkg_urls in a common place
- epm downgrade: run downgrade only for installed packages

* Sun May 07 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.5-alt1
- makefile: set path in esu too
- epm-sh-functions: set_sudo(): improve messages
- epm play: add virtualbox
- epm install: satisfied with any installed requested package
- epm install: implement correct install kernel module support
- epm-repo-addkey: hide extra requires (gnupg)

* Fri May 05 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.4-alt1
- epm play add gitkraken
- epm play: rename r7office to r7-office
- epm play: add r7-office-organizer
- epm status: add --certified support (for packages we trust)
- epm repack: fix some requires
- pack missed esu

* Fri May 05 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.3-alt1
- eget: fix github json handling (some servers return optimized nonformatted answer)
- epm install: add missed --simulate support for hilevel command
- epm i586-fix: add only installable ngvidia_glx i586 packages
- epm play i586-fix: use --no-remove for install
- epm repack: use --no-remove for install
- epm repack: use PREINSTALL_PACKAGES install way
- eget: use correct http download backend for ipfs via gateway
- epm play: add commfort-client (wine)
- epm-upgrade: for url download files to upgrade
- add esu command (sudo -l / su - wrapper)

* Wed May 03 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.2-alt1
- epm install: move alt, apt-dpkg, rpm install to separate files
- epm play: add joplin, novelwriter
- epm install: use --skip-installed when install requires for rpm package with --noscripts
- epm play brave: fix short name issue
- epm repack rpm: drop icons dirs from packing
- epm play yaradio-yamusic: fix icon packing
- epm repo addkey: allow missed url with gpg key
- epm repo add: add autoports supports
- epm repack unigine-superposition: fix icons packing
- epm repack common.sh remove_dir(): more correct removing
- epm repack net.downloadhelper.coapp: fix mozilla dir
- epm repack net.downloadhelper.coapp: use ffmpeg and xdg-open for the system

* Mon May 01 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.1-alt1
- epm play: fix bitwarden, wpsoffice, trueconf
- epm: add Requires: update-kernel for ALT
- distr_info: allow override distr via DISTRNAMEOVERRIDE or latest arg
- epm play: rewrite IPFS DB download, check epm specific version URL
- epm play common.sh: update to latest available version in any case
- epm repack trueconf: use requires from the original package
- epm repack trueconf-server: improve preinstall packages
- epm repack: drop old libicu in requires
- eget: add support for UTF-8 filename in Content-disposition
- epm: change CMDSHELL to /usr/bin/env bash and use CMDSHELL for call scripts

* Sun Apr 30 2023 Vitaly Lipatov <lav@altlinux.ru> 3.55.0-alt1
- epm play brave: fix download
- epm play anydesk: fix version
- epm play: add bitwarden
- epm play: add unityhub
- epm repo addkey: fix download key
- epm pack 1c83-client: fix unpacking, use erc
- epm play: add --remove all support
- eget: fix for brave go-ipfs
- epm repo addkey: allow key name as first arg
- epm status: add --installable
- epm play angie: use new order for epm repo addkey
- epm play: enable whatsapp support for other distro
- epm repack vk-calls: add /etc/tmpfiles.d/vk-calls.conf
- emp-sh-functions: set TMPDIR if missed
- epm repack: run repack scripts with buildroot dir as current dir
- epm: add unknown options to pkg_options
- epm: improve args separating
- for extra repos use eget, not rsync
- rewrite tmp file cleaning
- distr_info: resort functions
- optimization: use eval distr_info --print-eepm-env instead of separated calls
- use /usr/bin/env bash shebang

* Thu Apr 27 2023 Vitaly Lipatov <lav@altlinux.ru> 3.54.0-alt1
- epm play: fix synology-chat
- epm play: add youtube-music
- epm play: add angie support
- epm play/pack: add install some Pantum drivers
- epm play brave: rewrite
- epm pack: improve working with tmpdir, simplify
- epm fatal/warning: colorify only key word
- epm repo add: add Alpine support
- epm repo addkey: add Alpine support
- epm repo addkey: add dnf/yum support
- epm repo addkey: improve ALT support
- epm pack.d/common.sh: add exit to return_tar()
- epm play: fix version as second arg
- epm play wine: fix install with --only-i586
- epm upgrade: pass -V when --verbose (for apt based systems)
- epm install: improve --noscripts workaround
- epm-sh-functions erc(): install p7zip in any case

* Wed Apr 26 2023 Vitaly Lipatov <lav@altlinux.ru> 3.53.1-alt1
- epm play: add yaradio-yamusic
- epm play: add lycheeslicer support
- epm: use bash directly
- serv: add all initial detection, use bash directly
- epm play: add libicu56 (for ALT only)
- epm repack trueconf: update script
- epm play.d/common.sh: fix PKGNAME detection
- epm repack synology-drive: ignore if removed extra files is missed
- epm play: fix download name in various scripts
- epm play: update synology* scripts
- eepm.spec: drop BR: rpm-build-intro (isn't used anymore)

* Tue Apr 25 2023 Vitaly Lipatov <lav@altlinux.ru> 3.53.0-alt1
- epm repack microsoft-edge: use one file, add conflicts
- epm play: update IPFS DB every time (and merge with sort)
- epm status: add --validate (check for package correctness)
- epm play: add check for origin of install repo for all targets
- epm play: fix --force handling
- fatal(): add epm version to error message
- epm status --original: don't check Signature field
- epm autoorphans: don't call epm remove without packages
- pkgallowscripts.list: add lsb-cprocsp exclude
- i586-fix.sh: comment out NetworkManager-libnm
- make epm update-kernel no fatal on apt systems
- epm play: rewrite to support set version where possible
- rewrite check for package vendor and package source
- rename --thirdpart to --thirdparty

* Mon Apr 24 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.7-alt1
- makefile: drop bashisms
- epm restore: add meson.build support
- epm-sh-functions: set_sudo: improve sudo checking
- epm play zerotier-one: get latest version from the site
- implement epm status [--installed|--original|--thirdpart|--repacked]
- epm repack: save repacked packages with epm release
- epm-sh-functions: __epm_check_if_package_from_repo(): add check for empty Signature field
- epm play: check already installed package with is_repacked_package (implemented via epm status)
- epm play: add pencil support

* Sun Apr 23 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.6-alt1
- makefile: fix install play.d

* Sat Apr 22 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.5-alt1
- tools_json: replace egrep with grep -E
- eget: add -H (--header) support
- epm play icq: get latest version from snapcraft.io
- distr_info: fix Manjaro support
- epm ei: use --auto in pipe mode
- generic-appimage.sh: use cd & run (some progs runs only relative to current dir)
- epm play: add clibgrab
- eepm.spec: move install code to Makefile
- eepm.spec: update Source URL
- remove yum subpackage (will pack separately)

* Sat Apr 22 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.4-alt1
- epm play: add cnrdrvcups-ufr2 support
- epm repo add/remove: add korinf support
- erc-sh-archive: add diag message if backend is missed
- erc-sh-archive: add checking for 7zr and 7zz
- epm-sh-functions erc(): check if some erc backend is installed and install p7zip if missed
- epm-repack: add p7zip require
- allow EPM_BACKEND and SERV_BACKEND to force backend to use
- epm-release_upgrade: remove apt-conf-sisyphus only if installed

* Fri Apr 21 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.3-alt1
- epm repack aksusbd: create empty /etc/hasplm/nethasp.ini (ALT bug 44480)
- epm play: net.downloadhelper.coapp
- epm print: fix: check if file is real package
- epm update: check for new Korinf version not with eepm from stable ALT branches
- epm ei: do nothing on stable ALT branches

* Thu Apr 20 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.2-alt1
- epm play: add lithium support
- epm play: add aksusbd
- epm play cascadeur: get build-id and version from the site
- epm repack: install packages only on ALT
- epm repack softmaker-freeoffice-2021: fix
- epm install: ignore /home dir as possible bin dir
- eget: restore missed quotes after href

* Wed Apr 19 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.1-alt1
- distr_info: print empty package type if unknown
- distr_info: add NixOS support
- epm repack kubo: fix conflicts
- epm play codium: check if the package is already installed from repo
- epm play chromium-gost and yandex-browser: fix checking for the package from repo
- epm: add some nix support
- epm pack: add support for version as third arg
- epm play: add initial support for cascadeur

* Mon Apr 17 2023 Vitaly Lipatov <lav@altlinux.ru> 3.52.0-alt1
- epm-sh_functions: add colors to fatal() and warning()
- epm install: add warning when install third-party software
- rename chocolatey -> choco
- eget: improve globbing symbol translation
- epm play: add kubo support
- epm install: redirect install by path (/usr/bin/git) to install via hi-level commands for all distro
- epm play: add sane-panakvs (Panasonic Scanner Driver for Linux)
- epm play: add print out for all epm commands
- epm play okular-csp: some improvements
- epm print contructname: improve delimiter issue
- epm play: fix URLs with fixed eget wildcards
- eget: disable checking for magic CID if IPFS is used
- eget: check Brave IPFS after local ipfs in IPFS auto mode

* Sat Apr 15 2023 Vitaly Lipatov <lav@altlinux.ru> 3.51.2-alt1
- epm play: add zerotier-one
- epm: fix warmup issue again
- epm: fix query-package, query (fix epm_package param using)

* Sat Apr 15 2023 Vitaly Lipatov <lav@altlinux.ru> 3.51.1-alt1
- epm play: fix shift when --ipfs
- eget: don't return put error in gateway mode

* Sat Apr 15 2023 Vitaly Lipatov <lav@altlinux.ru> 3.51.0-alt1
- distr_info: add missed fields for old ALT distro
- epm repack: add support for remotedesktopmanager
- epm repack.d/generic-appimage.sh: use correct icon name
- epm repack.d/generic-appimage.sh: add alternative link too
- epm repack.d/generic-appimage.sh: install /usr/share/icons/hicolor... if exists
- epm repack.d/common-chromium-browser.sh: add add_deps()
- epm repack.d/generic-appimage.sh: add predefined deps for electron based apps
- epm play: add todoist support
- epm repack.d/common-chromium-browser.sh: install/add deps only on ALT
- eget: fix get real url again
- epm-autoremove: force mark sudo as manual (some bug in a distro?)
- epm prescription i586-fix.sh: add libnm (needed for Steam)
- add support for termux-pkg
- epm search: use direct args
- epm: implement list-available
- epm packages: use direct args
- drop epm list, epm -l aliases for epm packages
- epm: implement list (with --available and --installed options)
- epm: improve winget support
- epm play: refactoring
- epm: add --disable-interactivity alias for --non-interactive
- epm ei: add special case for eepm install
- eget: fix embedded mode

* Wed Apr 12 2023 Vitaly Lipatov <lav@altlinux.ru> 3.50.1-alt1
- eget: fix --check
- eget: add filename support in ipfs://Qm...filename=real.name
- epm play unigine: fix name producing, fix url
- eget: hide IPFS mode status when IPFS mode is disabled
- eget: fix quiet mode, add --quiet alias for -q

* Wed Apr 12 2023 Vitaly Lipatov <lav@altlinux.ru> 3.50.0-alt1
- epm tool: add which command
- play/repack/pack common.sh: use epm tool which for is_command
- ungoogled-chromium: fix sandbox
- epm play: add --ipfs support
- epm install: fix --replacepkgs again
- epm repack: fix warning when we have repacking rule
- epm ei: fix checking for interactive mode
- epm repack vinteo.desktop: fix repacking on ALT/p9
- epm-update: fix checking for new eepm package
- epm play --ipfs: initialize db with site prepared data
- distr_info: don't use GNU sed extension
- epm: add EPMMODE: package, single, pipe, git
- epm repack: use EPM <support@eepm.ru> packager and skip warning if a package packaged by one
- epm play unigine*: skip temp dir
- epm: improve AlpineLinux support
- epm: add stats command
- epm play okular: improve message about CryptoPro
- eget: big rewrite to support IPFS mode (EGET_IPFS=disabled,auto,brave,local,gateway)
- eget: add EGET_IPFS_DB file support (save after download, get when download)
- eget: add --get-filename, --get-real-url, --get-response, --get-ipfs-cid
- eget: use scat only for get remote content
- eget: refactoring wget/curl detection
- eget: add support for EGET_BACKEND=curl,wget
- eget: add hack to get headers ever if HEAD is not allowed
- eget: stop recursion with EGET_ vars

* Mon Apr 10 2023 Vitaly Lipatov <lav@altlinux.ru> 3.42.0-alt1
- epm play trueconf: fix libicu require
- epm ei: get real path before epm install (to fix ask about install)
- epm play: add mobirise, lunacy, ungoogled-chromium
- epm: drop less using
- epm play sweethome3d: support for latest version, rewrite repack

* Fri Apr 07 2023 Vitaly Lipatov <lav@altlinux.ru> 3.41.2-alt1
- serv: use is_command instead of direct which
- serv: use service type detection from epm print info --service-manager
- distr_info: use hascommand instead of direct which
- distr_info: add long option --service-manager, fix print info formatting
- distr_info: fix distro-version for ROSAFresh
- distr_info: fix reponame for ALTServer
- distr_info: return from ROSAFresh to ROSA

* Thu Apr 06 2023 Vitaly Lipatov <lav@altlinux.ru> 3.41.1-alt1
- epm play master-pdf-editor: fix download url
- distr_info: vendor rosafresh for ROSAFresh
- epm repack common.sh: implement file path support in filter_from_requires
- epm release-upgrade: fix syntax error

* Thu Apr 06 2023 Vitaly Lipatov <lav@altlinux.ru> 3.41.0-alt1
- remove direct which command using
- epm repack.d/example.sh: improve example
- repack.d/softmaker-freeoffice-2012.sh: don't use erc directly
- repack.d/portproton.sh: add some missed requires (gawk, tar, /usr/bin/convert)
- add compatibility layer (print_command_path, is_command, subst) to pack.d and repack.d
- epm pack/play/repack: add warning about .rpmnew files
- epm repack rustdesk.sh: fix for build nightly release
- epm history: print rpm sessions too
- epm download: fix for download several packages
- epm addrepo: add support for c9f*
- epm repo: add create command (epm repo index --init)
- epm repo comment: remove in favour epm repo disable
- epm play portproton: get latest release from github, not fixed version
- distr_info: print correct version for c9f*
- distr_info fix support for ROSAFresh

* Mon Apr 03 2023 Vitaly Lipatov <lav@altlinux.ru> 3.40.1-alt1
- epm play: add DJV2
- epm.spec: require bash instead of sh

* Fri Mar 31 2023 Vitaly Lipatov <lav@altlinux.ru> 3.40.0-alt1
- epm play: add alivecolors support
- epm play: add freeoffice
- epm addrepo: add astra repos with [arch-=i386]
- erc: use 7z if patool is missed
- erc: add --use-7z and --use-patool
- add prepare_to_eepm.sh
- eget: improve is_url checking
- eget: disable checking for globbing symbol ? in URL
- epm: add -y as --auto alias
- epm: print short help when run without params
- epm prescription: add i586-support
- epm install: don't use --replacepkgs when install only one package
- epm prescription: add nvidia-remove
- epm: add --norepack option
- epm pack: rewrite
- epm repack: move repack stoplist to /etc/eepm/repackstoplist.list
- epm repack generic.sh: skip links
- epm release-upgrade: print info about ALT wiki when update to ALT Sisyphus

* Thu Mar 30 2023 Vitaly Lipatov <lav@altlinux.ru> 3.39.3-alt1
- eget: make correct URL if file part parsed by mask separately
- epm play: add vuescan
- epm play: fix download url for anydesk (according to latest eget)
- epm play: add cuda-z support
- eget: big rewrite
- epm play: add netbeans
- epm ei: add help, rewrite parsing
- epm ei: add support to set Korinf URL
- epm addrepo: add support for AstraLinux

* Wed Mar 29 2023 Vitaly Lipatov <lav@altlinux.ru> 3.39.2-alt1
- epm ei: add fallback to vendor/repo dir
- distr_info: print bug report url
- distr_info: add default repo name (the same like distro version)
- epm download: use eget --latest if mask is not *.something
- epm: allow --dry-run for kernel-update/remove-old-kernels
- epm full-upgrade: skip snap if snap service is not running (ALT bug 45666)
- epm install: add --download-only support for repository packages (via epm download)
- epm download: implement package download for ALT via apt-get install --print-uris
- add epm download --url for apt-rpm and apt-dpkg systems

* Tue Mar 28 2023 Vitaly Lipatov <lav@altlinux.ru> 3.39.1-alt1
- distr_info: add --repo-name, --distro-name, --base-distro-name
- distr_info: add full version for Astra
- distr_info: add long options, rearrange default output

* Mon Mar 27 2023 Vitaly Lipatov <lav@altlinux.ru> 3.39.0-alt1
- epm repo implement enable/disable for ALT
- epm repo list:  add (-a|--all) support (print commented out lines)
- epm repo index/add: big rewrite
- epm repack: skip find requires for update_mpeg in yandex-browser and vivaldi
- epm repack yandex-browser: add fonts-ttf-google-noto-emoji-color require only if it is exists
- epm repo add: add support for various url and dir forms
- epm repo add: add support for short form: 'rpm url component' and use it
- eget: add support for URL in form file:/ or /path
- epm install: add --replacepkgs (and --test for --dry-run case) to rpm -Uvh

* Mon Mar 27 2023 Vitaly Lipatov <lav@altlinux.ru> 3.38.1-alt1
- epm repack unigine-superposition: fix issue with libssl/libcrypto
- epm repack: add initial cnrdrvcups-ufr2-uk
- epm: fix epm version checking
- epm play common.sh: fix checking for available version
- epm repo: add enable/disable support
- epm print: add arch
- epm repo add: add support for dir
- epm repo: implement initial support for create local repo (index,pkgadd,pkgdel,pkgupdate)

* Sun Mar 26 2023 Vitaly Lipatov <lav@altlinux.ru> 3.38.0-alt1
- epm prescription i586-fix: add missed nvidia_glx, primus
- epm repack: many fixes
- epm repack vinteo.desktop: skip lib.req for foreign binaries
- epm prescription common.sh: add is_root, assure_root
- epm play telegram: move repacking to pack.d
- epm play 64Gram: move packing to pack.d
- epm repack liteide.sh: add Conflicts to liteidex
- epm play common.sh: check app version in versioned epm info firstly
- epm repack: add --install support
- epm play common.sh: fix checking if update is needed
- epm full-upgrade: allow skip kernel update (via eepm.conf)
- epm kernel-update: disable remove-old-kernels after update
- eepm.spec: add Requires: apt-scripts (for emergencies)
- print note about autoremove only after epm clean (with caution!)
- epm play --update: skip updating if the package is on hold (see epm mark --help)
- eget: implement --check-mirrors
- epm ei: drop update_url_if_need_mirrored using, we hope eget will helps here
- epm play: drop update_url_if_need_mirrored, we hope eget will helps us
- epm pack: drop update_url_if_need_mirrored, we hope eget will help us
- epm play: drop check_url_is_accessible using
- set BIGTMPDIR and use in cd_to_temp_dir
- epm play ktalk: rename to correct name

* Fri Mar 24 2023 Vitaly Lipatov <lav@altlinux.ru> 3.37.0-alt1
- epm play master-pdf-editor: get package name from site
- epm play: add realvnc-server and realvnc-viewer
- epm repack ipera-mediaserver: drom libQt5 libGL from reqs
- epm tool: add erc and ercat
- eepm.spec: disable AutoReq at all, use direct requires
- epm play unigine-*: move unpacking to pack.d

* Fri Mar 24 2023 Vitaly Lipatov <lav@altlinux.ru> 3.36.2-alt1
- epm repack icq: fix requires (ALT bug 44899)
- epm repack vkteams: fix requires
- epm repack far2l-portable: add package meta info
- epm play wine: add missed wine-etersoft
- epm repack meridius: fix icon name
- epm repack: implement add_requires and use it
- epm repack liteide: fix desktop, add golang requires (ALT bug 45635)
- distro_info: add --glibc-version
- epm play jetbrains-toolbox: rewrite with epm pack
- epm play kyodialog: rewrite with epm pack

* Thu Mar 23 2023 Vitaly Lipatov <lav@altlinux.ru> 3.36.1-alt1
- epm-pack: install PKGFORMAT package after repack
- replace --download-only with --save-only
- epm repack generic.sh: add remove_dir /usr/lib/.build-id
- epm repack: add portproton.sh (add needed requires)
- epm-pack: reset EPMCURDIR as hack

* Thu Mar 23 2023 Vitaly Lipatov <lav@altlinux.ru> 3.36.0-alt1
- epm play: add far2l-portable
- epm-pack: add --verbose support
- epm pack 1c83-client: add support for unpack downloaded tar.gz
- epm install: add --download_only (save after repack) and --direct + --download_only (save before repack)
- epm repack 64Gram: fix name
- epm-sh-functions: hide direct /bin/echo using
- epm repack Autodesk_EAGLE: drop internal libxcb-dri?.so.0 (ALT bug 44898)
- remove CURDIR to EPMCURDIR and export it without override

* Tue Mar 21 2023 Vitaly Lipatov <lav@altlinux.ru> 3.35.1-alt1
- epm pack 1c83-client: fixes
- epm repack rstudio: fix chrome-sandbox
- epm play steam: add install Steam from the repo

* Mon Mar 20 2023 Vitaly Lipatov <lav@altlinux.ru> 3.35.0-alt1
- epm play: rewrite, add applications list support, use app=version form
- add epm pack
- epm play: add initial portproton support
- epm pack: add 1c83-client support
- rewrite all browser-codecs install via epm pack
- epm play opera: rewrite, fix other systems install
- epm play: move wine to play list
- epm repack: add r7-office (with support for 7.3)

* Sat Mar 18 2023 Vitaly Lipatov <lav@altlinux.ru> 3.34.1-alt1
- epm repack codium: fix path to binary
- epm repack rustdesk: fix install pynput
- epm play unigine: fix eget path
- epm repack unigine-superposition: drop patchelf direct req
- epm repack Telegram: fix autoupdate disable
- epm-repack: fix version parsing
- epm play telegram: add support for beta|version, install stable by default
- epm play rstudio: use build according to the distro
- epm play: add 64gram
- epm repack yandex-browser: add require fonts-ttf-google-noto-emoji-color
- epm play: add minecraft-launcher
- add epm moo
- epm-install: add non interactive install task (--auto support)

* Mon Mar 13 2023 Vitaly Lipatov <lav@altlinux.ru> 3.34.0-alt1
- epm prescription wine: fix wine-etersoft support
- epm play: add liteide support
- epm play: add unigine-valley support
- epm play: add unigine-superposition support
- epm play: add codium
- epm play rustdesk: restore pynput-service.py (need python3-module-pynput since it)
- epm play sputnik-browser: disable service
- epm-sh-altlinux: disable warning about x86_64-i586 in task

* Thu Mar 09 2023 Vitaly Lipatov <lav@altlinux.ru> 3.33.0-alt1
- epm repack iproject-client: add requires
- epm: add epmp alias for epm play
- epm-full_upgrade: add support for --no-{epm-play,flatpack,snap}
- epm play yandex-browser: allow install native rpm for other rpm systems than ALT
- add epm ei erc to assure erc
- epm-repolist: add info about --verbose
- epm repack i586-fix: add support for Fedora based distro
- epm repack viber: rewrite
- epm play: add vkcalls support
- epm full-upgrade: disable epm play --update for non ALT Systems
- epm-release_upgrade: fix RockyLinux upgrade
- revert "epm play mssql-server: fix url for rpm"
- epm-history: fix default list
- epm repack zoom.sh: improve packing (ALT bug 44988)
- epm play: add unigine-heaven support

* Tue Feb 28 2023 Vitaly Lipatov <lav@altlinux.ru> 3.32.0-alt1
- epm repack synology-drive: fix install on ALT p10 (try 2)
- /etc/eepm/eepm.conf: add full_upgrade_no_{epm_play,flatpack,snap} to disable during full_upgrade
- epm repack: fix pycharm-professional
- epm print compare: add dpkg support
- epm-history: add --installed/--removed/--updated

* Mon Feb 27 2023 Vitaly Lipatov <lav@altlinux.ru> 3.31.1-alt1
- epm play: add synology-drive support
- epm play: add synology-chat support
- epm repack onlyoffice-desktopeditors: small fixes
- epm repack: add FlashPrint5 support
- epm repack: add iproject-client support

* Fri Feb 24 2023 Vitaly Lipatov <lav@altlinux.ru> 3.31.0-alt1
- update_versions.sh: save eepm version too
- epm history: use journalctl -t apt-get for ALT
- epm-mark: fixes for mark auto/manual with dnf
- epm repack: add domination-client support
- epm play assistant: add warning about dangerous script
- epm repack: fix duplicate links add_bin_commands
- epm play vivaldi-codecs: add error checking
- epm repack common.sh: fixes for paths with spaces
- epm play teams: disabled (no longer be available)
- epm play mssql-server: fix url for rpm
- epm-update: check for available epm version
- epm play: add rocketchat support

* Wed Feb 08 2023 Vitaly Lipatov <lav@altlinux.ru> 3.30.0-alt1
- epm-repack: fix rpm package arch (add --target to rpmbuild)
- epm repack: add iwbdriver support (usable on 32 bit platform only)
- distr_info: add Solus (eopkg) support
- add eopkg package manager support (Solus system)
- epm repack rustdesk: support repacking 1.1.9 and nightly 1.2.0
- epm play rustdesk: allow install nigthly version (latest 1.1.9 as stable)
- pack example eepm.conf
- epm install: don't disable rpm scripts for packages from /etc/eepm/pkgallowscripts.list
- epm install: don't disable rpm scripts for vendors from /etc/eepm/vendorallowscripts.list
- epm play: add assistant, myoffice, r7-office to pkgallowscripts.list to use --scripts by default
- disable AutoReq (exclude shell) and AutoProv
- epm play mssql-server: fix changed download URL for ALT

* Wed Feb 01 2023 Vitaly Lipatov <lav@altlinux.ru> 3.29.1-alt1
- epm-epm_install: allow install a few packages simultaneously
- onefile_eget: add checking for curl too
- epm: add echocmd (special for command print out) and use it in the empty arg error message
- more intrusive advertising of the EPM channel in Telegram
- epm prescription: rewrite all php install scripts
- epm-epm_install: skip interactive for install from stdin
- fix bug with run script in epm() (fix regression from bf3b0a0d1d8fe58a0e905a2d2e4eb7a3e7a35e05)
- epm play teams: fix for other rpm based distro

* Wed Jan 25 2023 Vitaly Lipatov <lav@altlinux.ru> 3.29.0-alt1
- epm repack vkteams: fix packing on Sisyphus (ALT bug 44851)
- epm play vk: fix eget using (ALT bug 44866)
- epm play wine: override wine-common install
- epm-sh-altlinux-contents-index: use /tmp if TMPDIR is empty
- epm play: add aimp
- epm-addrepo: add crb support for Rocky Linux
- epm release-upgrade: add support for RockyLinux
- epm release-upgrade: don't restore repo if the final upgrade is failed
- epm repack fix rustdesk (ALT bug 44888)
- epm repack: fix getting version for AppImage
- distr_info: improve checking for default package manager
- epm release-upgrade: fix upgrade to Sisyphus
- epm play: add vinteo.desktop support
- epm-query: remove extra space after rpm package name in short mode
- epm-mark: add support for hold/unhold
- epm play: add --full-list-all
- epm repack zoom: fix repack (ALT bug 44988)
- epm search: switch to use glob symbols (not regexp)
- epm mark hold/unhold: add support for glob symbols
- epm-mark: add showhold
- epm-mark: big refactoring, add support for deb and dnf based systems
- add epm history command
- epm mark: add support for dnf, zypper, merge, pacman
- epm play librewolf: fix download URL
- epm repack vkteams: improve packing (ALT bug 44851)
- epm: add aliases: find->search, ls->packages

* Sun Jan 08 2023 Vitaly Lipatov <lav@altlinux.ru> 3.28.7-alt1
- epm repack librewolf: install required packages only on ALT
- epm repack Telegram: hide locally created desktop file (ALT bug 42402)
- epm repack meridius: fix packing

* Fri Dec 30 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.6-alt1
- epm play kyodialog: fix erc req
- epm-sh-functions: call the program internally without bash

* Fri Dec 30 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.5-alt1
- epm play: add librewolf support
- epm play wpsoffice: get app version from Arch repo

* Wed Dec 28 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.4-alt1
- epm play: add Kyocera printer driver
- distr_info: add MOC/MeSh support
- tests: add os-release tests
- epm play master-pdf-editor: add MOC support
- epm repack pantum: add libjpeg8 requires

* Mon Dec 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.3-alt1
- epm repack: add gitlab-runner repack
- epm play brave: add support for dev channel, do fallback to beta if release is missed
- epm autoremove: fix on deb systems (eterbug #16189)
- epm play gitlab-runner: repack on ALT
- epm repack trueconf: fix repack on Sisyphus (remove libtbbbind requires missed libhwloc.so.5)

* Fri Dec 23 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.2-alt1
- epm play: enable install chrome-remote-desktop
- spec: require apt-repo on ALT
- epm-install: restore workaround for install deb packages without apt-get (for old Ubuntu)

* Tue Dec 20 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.1-alt1
- epm requires: allow show also for non installed packages, improvements
- epm play: add iptvnator (ALT bug 44047)
- epm repack xnview: improve packing requires

* Sat Dec 17 2022 Vitaly Lipatov <lav@altlinux.ru> 3.28.0-alt1
- epm play r7office: fix install icons and associations (ALT bug 44093)
- epm repack teamviewer: fix packing
- epm repack rstudio: fix packing
- epm repack meridius: remove unused discord integration (ALT bug 44251)
- epm install: add --interactive support
- epm ei: ask before install a package
- epm play trueconf: drop unneeded workaround for install with --noscripts
- epm requires: add support for --short
- epm install: add workaround for --noscripts when using apt for additional requires

* Fri Dec 16 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.6-alt1
- epm play ktalk: fix package name (ktalk2 now) (ALT bug 44230)
- epm repack: clean created tmp dir
- epm repack: fixes for ktalk (ALT bug 43486)
- epm play: fix print description

* Fri Dec 16 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.5-alt1
- distr_info: add --full-version
- distr_info: fix Orel/orel checking for AstraLinux
- epm repack vkteams: fix packing
- epm play: add VK messenger
- epm repack vkteams: prevent local .desktop creating (ALT bug 43779)
- epm repack icq: prevent local .desktop creating (ALT bug 44250)
- epm repack: ignore mono autoreq in generic-appimage.sh (ALT bug 43993)

* Thu Dec 15 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.4-alt1
- remove dot in the end of wiki URL
- epm play yandex-browser-codecs-ffmpeg-extra: fix repack
- epm play: check if need update repo before install
- epm play: use trap EXIT to remove tmp files
- epm play pycharm-professional: fix install (ALT bug 44010)
- epm play: print description only for applications with supported arch (ALT bug 43932)
- epm play meridus: add support for install a given version
- epm play: update flyview install
- epm play flyview-server: add postinstall todo
- epm repack: add support for pantum
- epm repack brave-browser: fix repacking with broken cpio 2.13
- epm repack: add support for brscanads2200ads2700w
- epm repack: add libappindicator-gtk3 requirements for rustdesk
- epm repack zoom: fix missed libffmpeg.so (ALT bug 44533)

* Thu Oct 27 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.3-alt1
- epm repack spotify-client: fix icon packing error

* Sat Oct 15 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.2-alt1
- epm repack pycharm-professional: rename icons to pycharm-pro
- epm(): allow use it when run with pipe
- epm repack pycharm-professional: fix packing
- epm play flyview-client: fix package name
- epm repack: fix icq packing
- epm play okular-csp: remove repo also
- epm repack ipera-client: filter out requires for embedded libs
- eget: add --second-latest support
- epm play opera: improve download latest available Linux version

* Mon Oct 03 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.1-alt1
- epm repack Telegram: add Conflicts: telegram-desktop-binary
- epm epack pycharm-professional: fix version 2022.2.2 packing
- epm repack chromium-gost-stable: fix Name and Generic Name
- google-chrome-stable: fix Name and Generic Name
- epm repack chromium-gost-stable (ALT bug 43760)
- epm repack wps-office: drop /usr/share/desktop-directories/wps-office.directory (ALT bug 43751)
- epm play assistant: fix retrieving of a package URL

* Mon Sep 19 2022 Vitaly Lipatov <lav@altlinux.ru> 3.27.0-alt1
- epm play: add RStudio support (ALT bug 43794)
- epm full-upgrade: add update for flatpak and snap packages
- epm: force disable verbose in quiet mode
- epm repack slack: fix packing (ALT bug 43718)
- epm repack: fix ipera-client (ALT bug 43761)
- epm repack: fix ipera-mediaserver (ALT bug 43762)
- epm repack onlyoffice-desktopeditors: pack icons (ALT bug 43713)

* Wed Sep 14 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.10-alt1
- epm play: add meridius
- fix non_interactive options
- epm repack wps-office.sh: remove /etc/xdg/menus (ALT bug 43751)
- epm repack spotify-client.sh: fix icon name (ALT bug 43720)
- epm play yandex-disk: install also yandex-disk-indicator
- github testsuite.yml: don't use yander mirror
- epm play: add pycharm pro
- epm play: improve pycharm (ALT bug 43613)

* Wed Sep 07 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.9-alt1
- epm play: add Flyview (Ipera) server
- epm play wpsoffice: fix return
- epm-repack: fix packing dirs with spaces
- epm play common.sh: fix typo (ALT bug 43706)
- epm play assistant: add support for aarch64
- epm repack teamviewer: add libminizip require (ALT bug 43723)

* Sat Sep 03 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.8-alt1
- epm play: add wpsoffice
- update embedded eget
- epm repack common.sh: fix pack_dir
- epm play: add FlyView client

* Sat Aug 27 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.7-alt1
- epm repack fix pycharm-community on Sisyphus
- epm requires: filter out rpmlib(*  for rpm
- epm play: add trueconf client support

* Fri Aug 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.6-alt1
- epm-epm_install: support mirrors
- epm play master-pdf-editor: allow install on ALTLinux (ALT bug 43621)
- epm play r7office: add support for many distro
- epm play assistant: allow install on ALTServer
- epm play myoffice: enable package scripts for removing too (ALT bug 43626)
- epm repack common.sh: fix remove_dir (ALT bug 43613)
- epm repack atom-beta.sh: fix (ALT bug 43614)

* Thu Aug 25 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.5-alt1
- epm play: add VK Teams support
- epm repack icq: fix description
- epm repack skypeforlinux: fix packing (ALT bug 43615)
- epm repack: fix packing scripts
- epm-addrepo: fix typo (eterbug #15852)
- epm repack common.sh: set PRODUCTDIR to PRODUCTCUR if empty
- epm play: rewrite atom downloading and packing, add atom and atom beta support

* Mon Aug 22 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.4-alt1
- change AstraLinux to AstraLinuxCE/SE

* Mon Aug 22 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.3-alt1
- epm play: hide sputnik-browser (ALT bug 15741)
- epm play: add Master PDF Editor
- epm repack: fix /opt packing

* Sat Aug 20 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.2-alt1
- add epm --short --version
- epm-autoremove: enable real autoremove on yum based systems
- fix $@ using for set vars (eterbug 15846)
- epm repack icq: fix for ignore empty download
- epm full-upgrade: do fatal on errors
- epm play: return 0 if a package is already installed from the repo

* Fri Aug 19 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.1-alt1
- add epm play virtualhere
- more strong distro versions

* Thu Aug 18 2022 Vitaly Lipatov <lav@altlinux.ru> 3.26.0-alt1
- fix: epm-download: always download rpm packages on ALT directly
- epm play: add slack support
- big revert "fix quotes in format strings"

* Thu Aug 18 2022 Vitaly Lipatov <lav@altlinux.ru> 3.25.1-alt1
- epm repack icq: fix URL, ignore empty download
- epm repack yandex-browser: fix provides
- add epm play jetbrains-toolbox

* Thu Aug 18 2022 Vitaly Lipatov <lav@altlinux.ru> 3.25.0-alt1
- epm repack: always set Epoche: 100 to override repository package
- epm-search: fix support regexp not for apt only
- epm-download: always download rpm packages on ALT directly
- epm-tool: add json command support
- epm play: add pycharm support
- epm play: add icq support

* Tue Aug 16 2022 Vitaly Lipatov <lav@altlinux.ru> 3.24.3-alt1
- epm_query_file: fix --short query for rpm
- epm-query: fix --short query on rpm
- fix docmd using (remove extra quotes)

* Tue Aug 16 2022 Vitaly Lipatov <lav@altlinux.ru> 3.24.2-alt1
- fix quotes in format strings

* Tue Aug 16 2022 Vitaly Lipatov <lav@altlinux.ru> 3.24.1-alt1
- epm-check_updated_repo: stop autoupdate repo info (too buggy)
- epm play mssql-server: add Debian/Ubuntu support
- epm-sh-functions: docmd/sudorun: use eval to handle env
- epm install: separate install command for apt-dpkg and apt-rpm

* Mon Aug 15 2022 Vitaly Lipatov <lav@altlinux.ru> 3.24.0-alt1
- epm play yandex-browser: add checking for yandex-browser-stable package from ALT repo
- epm play opera: fix missed eget
- epm play gitlab-runner: fix download on deb systems
- epm-sh-functions: sudo -- don't allow vars, revert to just sudo
- epm: add ACCEPT_EULA=y for install deb packages in non interactive mode
- epm repack: set EEPM vendor for repacked packages
- epm play geogebra: fix download on deb systems
- epm play vivaldi: add snapshot support
- epm(): run the script via bash

* Mon Aug 15 2022 Vitaly Lipatov <lav@altlinux.ru> 3.23.4-alt1
- epm play: add support for opera beta and opera developer

* Mon Aug 15 2022 Vitaly Lipatov <lav@altlinux.ru> 3.23.3-alt1
- epm-release_upgrade: remove conflicts branding file before upgrade
- epm-repack: add support for EPM_REPACK_SCRIPTS_DIR
- epm play anydesk: no strict version
- epm play: add opera support

* Fri Aug 12 2022 Vitaly Lipatov <lav@altlinux.ru> 3.23.2-alt1
- distr_info: add --codename support
- epm: repo addkey support (add gpg key for a repo)
- epm play: add rustdesk support
- epm play: add Okular GOST support

* Fri Aug 12 2022 Vitaly Lipatov <lav@altlinux.ru> 3.23.1-alt1
- epm play ktalk: add pre requires (ALT bug 42558)
- common.sh: create shell wrapper with shebang (KDE runs Exec via execvp) (ALT bug 42641)
- epm repack: fix shebang for obsidian and chromium-gost-stable
- epm-query_file: follow a link ever if the link is not from a package

* Thu Aug 11 2022 Vitaly Lipatov <lav@altlinux.ru> 3.23.0-alt1
- epm-repack: fix package name-version before convert
- epm play Telegram: restore Conflicts: telegram-desktop
- epm-repack: on deb convert to an intermediate rpm package if we have repack.d rules
- epm play.d/common.sh: use mirror.eterfund for eepm.ru too
- distr_info: add error about unknown option
- epm play: allow direct run the scripts
- epm play sputnik-browser: cleanup, add verbose checking URI accessible
- epm play assistant: add URI checking and fix download on Ubuntu
- epm repack: use BIGTMPDIR conception (ALT bug 43491)

* Wed Aug 10 2022 Vitaly Lipatov <lav@altlinux.ru> 3.22.3-alt1
- epm play: add MyOffice support
- epm repack.d: fix quotes
- epm-download: fix permissions for downloaded file
- epm install/repack: big refactoring to support rpm/deb platform in common way
- epm-install: check if install by command
- epm play: add mirror check for yandex-browser-codecs-ffmpeg-extra

* Sun Aug 07 2022 Vitaly Lipatov <lav@altlinux.ru> 3.22.2-alt1
- repack.d/common.h: skip *_file/dir with empty arg
- repack.d/common.h: add filter_from_requires function
- add repack.d/rudesktop.sh
- epm repack.d: use filter_from_requires

* Sun Aug 07 2022 Vitaly Lipatov <lav@altlinux.ru> 3.22.1-alt1
- epm play rudesktop: fix eget using
- epm play assisant: fix locale for cyrillic URL
- epm-repofix: fix for Sisyphus
- epm play: add gitlab-runner install
- epm play code: fix link creating
- epm play: fix sublime-text packing

* Sat Aug 06 2022 Vitaly Lipatov <lav@altlinux.ru> 3.22.0-alt1
- generic-appimage.sh: drop MacOS only catalina dir (fix for balenaEtcher)
- distr_info: strip long version for ALT Workstation
- epm checkpkg: add --all support
- epm play: add --force for --update support
- epm play: add --list-installed-packages
- repack.d/generic.sh: more common python -> python2 shebang suport
- epm play: add signal messenger support (thanks, george@)
- epm autoorphans: skip packages installed via epm play

* Mon Aug 01 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.8-alt1
- eget: fix making file url from site url and filename
- eget: add --check support for check url if accessible
- play.d/common.sh: use eget --check in check_url_is_accessible
- play.d/common.sh: add update_url_if_need_mirrored
- epm play yandex-browser: use mirror.eterfund.org as mirror too

* Sun Jul 31 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.7-alt1
- epm-install: yum does not support --allowerasing
- don't expand package names on ROSA

* Sat Jul 30 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.6-alt1
- epm-autoremove: add --auto support for apt
- epm-remove: add missed --auto support for apt
- epm-install: add --allowerasing for yum/dnf install
- epm-query: don't use Epoche for hi level form
- distr_info: use RELS name for ROSA Server, fixes for ROSA
- eepm.spec: provides/obsoletes epm only on ALT

* Thu Jul 28 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.5-alt1
- epm-sh-functions: add sudo_allowed
- epm-filelist: fix sudo checking
- zypper: add --non-interactive support
- epm-install: always use apt for install deb packages

* Wed Jul 27 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.4-alt1
- distr_info: add support for Debian GNU/Linux
- epm print: disable name from package name guessing
- epm-addrepo: add support for install powertools on RHEL family

* Tue Jul 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.3-alt1
- epm-check: add support for --auto and --verbose
- epm-install: revert to old .deb install way

* Tue Jul 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.2-alt1
- distr_info: fix for RHEL
- distr_info: stop detect snappy
- epm-install: always use apt-get for install .deb file packages
- epm print: fix print name/version/release by string

* Tue Jul 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.1-alt1
- epm play wine: remove wine-gl and wine-twain packages
- epm-install: apt need ./ path for install deb packages
- epm play yandex-browser: add fallback for yandex-browser source URL

* Mon Jul 25 2022 Vitaly Lipatov <lav@altlinux.ru> 3.21.0-alt1
- epm-update: cd / before apt-get update
- distr_info: improve override support
- epm-print: fix arg for distr_info
- epm-check: add check_updated_repo before fix
- epm-install: use apt-get install as fallback when install files with dpkg
- epm repack: fix repack/install rpm on a deb system
- epm-query-file: fix --short for apt
- epm-sh-functions: disable eatmydata using

* Tue Jul 19 2022 Vitaly Lipatov <lav@altlinux.ru> 3.20.0-alt1
- epm play: skip update for hidden packages
- epm play.d: add rudesktop support
- epm-full-upgrade: add epm clean after all
- distr_info: big OS detection rewrite (based on /etc/os-release)
- epm-release_upgrade: allow upgrade/downgrade to c9
- epm-print: fix typo with rpm_query_package_format-field

* Sun Jul 17 2022 Vitaly Lipatov <lav@altlinux.ru> 3.19.4-alt1
- epm play assistant: parse site page to get download link
- epm play edge: add support for stable, beta and dev install
- epm play: refactoring
- epm-provides: fix for installed deb package
- epm-print: major rewrite for deb support

* Sat Jul 16 2022 Vitaly Lipatov <lav@altlinux.ru> 3.19.3-alt1
- distr_info: add ROSA/7 with yum support
- epm-repolist: dnf/yum: be verbose only when --verbose
- play/common.sh: add version checking
- epm-play: add --installed-version and --package-name support
- play.d/ktalk.sh: fix package name
- play.d/sputnik-browser.sh: use url from b2c-distrs channel

* Fri Jul 08 2022 Vitaly Lipatov <lav@altlinux.ru> 3.19.2-alt1
- pack_in_onefile.sh: use epm_main/serv_main functions for the main code
- use return instead of exit in functions
- epm play: add snap4arduino support (thanks, neurofreak@!)
- epm play: add draw.io support (thanks, Ilya Demyanov!)
- epm play: fix sublime download link
- repack.d/draw.io: add drawio and draw.io commands to /usr/bin
- distr_info: fix ROSA support

* Wed Jun 29 2022 Vitaly Lipatov <lav@altlinux.ru> 3.19.1-alt1
- epm repack: fix mssql-server install (ALT bug 42639), tested in hasher
- egrep -> grep -E
- epm repack: improve zoom repack
- epm play brave: install stable branch by default (beta or nightly as alternative)
- epm-upgrade: return error status if there are no packages for upgrade
- distr_info: detect kvm without systemd
- repack.d/Telegram.sh: fix icons download
- epm-query: fix removing packages with serial
- add epm repo comment
- epm release-upgrade: fixes

* Wed Apr 27 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.6-alt1
- prescription/php8.sh: fix upgrade
- repack.d/generic.sh: install rpm-build-python3 for build packages with python code
- epm-play: make --short list the same like full (ALT bug 42566)
- epm repack.d: don't use patchelf --add-rpath (missed in old patch-elf)
- epm repack mssql-server.sh: fix packing (ALT bug 42559)

* Fri Apr 22 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.5-alt1
- epm-update: fix error code in epm-update

* Fri Apr 22 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.4-alt1
- epm play sublime: fix download URL
- epm repack: fix onlyoffice-desktopeditors

* Fri Apr 22 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.3-alt1
- add epm tool command for call embedded tools like eget or estrlist
- epm play yandex-browser-codecs-ffmpeg-extra: use eget for download
- use epm tool eget instead of EGET variable
- epm repack AppImage: fix path to AppRun
- epm repack: fix fix_chrome_sandbox return code
- epm play: chrome-remote-desktop.sh: disable script
- epm repack zoom: small improvements

* Tue Apr 19 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.2-alt1
- epm-sh-functions: fix which command detection (deb based distro related)

* Tue Apr 19 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.1-alt1
- add check for sed, which and grep commands
- drop extra requires

* Mon Apr 18 2022 Vitaly Lipatov <lav@altlinux.ru> 3.18.0-alt1
- epm install/repack: add AppImage support
- epm repack: drop using fakeroot during repack to rpm
- epm repack: set TMPDIR if missed, set _allow_root_build in temp. .rpmmacros
- epm play: add ktalk support
- epm repack: fix_chrome_sandbox: set 4711 permissions
- epm repack: fix error code
- epm play/repack: big rules cleanup
- epm play: add duplicati support
- epm play vivaldi: fix download (ALT bug 42477)

* Fri Apr 15 2022 Vitaly Lipatov <lav@altlinux.ru> 3.17.3-alt1
- epm play: allow --remove for scripts (f.i., wine)
- epm-sh-functions: add URL described how to tune sudo
- update eget to 0.5.5
- epm play: add Sublime Text 4 support
- epm play telegram: add Group to the package

* Thu Apr 14 2022 Vitaly Lipatov <lav@altlinux.ru> 3.17.2-alt1
- epm-query: add -- after options, fix query --short for rpm
- epm play vivaldi-codecs-ffmpeg-extra: fix package name

* Thu Apr 14 2022 Vitaly Lipatov <lav@altlinux.ru> 3.17.1-alt1
- distr_info: interpret RedHatEnterpriseLinuxServer as RHEL
- epm play code: fix desktop file (ALT bug 42391)
- epm play brave: install beta by default (nightly as alternative)
- epm play vivaldi: add support for snapshot install
- epm play: allow subcommands without -- prefix
- distr_info: fix AstraLinux detection
- distr_info: add support for arm64 debian arch
- epm repack zoom: fix chrome-sandbox SGID (ALT bug 42412)
- epm play: add vivaldi-codecs-ffmpeg-extra
- distr_info: exclude pp10 possibility
- epm provides: more clean output for deb
- epm repack anydesk: fix requires (ALT bug 42403)
- epm play geogebra: fix install on i586 (ALT bug 42404)
- epm play zoom: fix install on i586 (ALT bug 42405)

* Thu Apr 07 2022 Vitaly Lipatov <lav@altlinux.ru> 3.17.0-alt1
- epm play yandex-browser: still update beta version if it is installed
- epm download: use downloaded name, not URL basename
- distr_info: add ALT MED72 support
- epm play: fix remove package for brave, chromium-gost and xnview
- epm play anydesk: force get 6.1.* packages, fix repack
- epm play: skip --update if the package is not installed
- epm play: implement list of installed packages via package manager
- epm: allow -v only for empty command
- epm play: cleanup downloading

* Thu Apr 07 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.10-alt1
- epm play assistant: add support for aarch64
- epm-play: check installed-app file before removing
- distr_info: check os-release and lsb-release after it
- distr_info: use only major part of a version (8.5 -> 8)
- epm play mssql-server: support --auto (--non-interactive)
- split common functions from common-chromium-browser.sh to chromium.sh
- epm repack Telegram: add icons, remove Updater
- epm repack: add initial spnxclient support

* Sun Apr 03 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.9-alt1
- epm play: sort installed apps, return status for update
- epm play: refactoring, fix tamtam, sputnik, chromium-gost install

* Sat Apr 02 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.8-alt1
- distr_info: improve default output (distro info)
- epm prescription wine: fix alt detection
- epm prescription: fix php8 install
- epm play: check for a script in prescription.d also, add --list-scripts for list prescription.d scripts
- epm prescription: implement via epm play functions
- epm prescription wine: fix for 32-bit system
- epm prescription: fix i586-fix/i586-remove
- epm play: drop obsoleted i586-wine-vanilla, i586-wine-etersoft, i586-wine

* Thu Mar 31 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.7-alt1
- epm repack Telegram: add telegram-desktop link
- epm-play: add --quiet support, rewrite help

* Wed Mar 30 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.6-alt1
- epm play: add Obsidian support
- epm play code: add version support (f.i. epm play code 1.42.1)
- distr_info: base distro name for ALT is alt
- distr_info: add support for ALT SPWorkstation

* Mon Mar 28 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.5-alt1
- epm repack code: move to /opt
- add support for ALTServer distro

* Mon Mar 28 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.4-alt1
- epm-full_upgrade: run commands separately
- epm play: refactor yandex-browser-codecs packing
- add support for epm play yandex-browser beta
- epm play: add --installed support, cleanup

* Mon Mar 28 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.3-alt1
- epm-play: fix description
- epm-download: implement for apt-get
- eepm: fix build: drop link to cerv

* Sun Mar 27 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.2-alt1
- epm repack: rename common.sh to generic.sh
- add patchelf to eepm-repack
- ci testsuite: install rpm-build-intro for build
- epm play: improve list and description out
- epm prescription: improve list

* Sat Mar 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.1-alt1
- tools_json: don't req gawk directly
- repack: update install_deps for chromium based browsers, use it for vivaldi

* Sat Mar 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.0-alt2
- update check_reqs.sh script, fix extra requires
- pack missed play.d

* Sat Mar 26 2022 Vitaly Lipatov <lav@altlinux.ru> 3.16.0-alt1
- move play files to play.d
- pack yandex-browser-stable (ALT bug 42238)
- epm-repofix: fix static apt-repo require
- epm-removerepo: fix removing repo by mask
- epm-play: fix SUDO for play scripts
- epm play mssql-*: add AstraLinux support
- epm repack: add fix_chrome_sandbox and use it
- epm repack: fix zoom linking
- epm play: rewrite geobra install

* Wed Mar 23 2022 Vitaly Lipatov <lav@altlinux.ru> 3.15.3-alt1
- spec: fix pkg system checking
- epm play: forbid install chromium-gost if it is already installed from the repo (ALT bug 41898)
- epm-full_upgrade: also run epm play --update all
- epm repo: add workaround for AstraLinux (add-apt-repository is broken)
- epm repack: fix anydesk repacking
- add EPM_VERBOSE support and allow verbose for repack scripts

* Sun Mar 20 2022 Vitaly Lipatov <lav@altlinux.ru> 3.15.2-alt1
- epm play: fix Autodesk Eagle install
- epm play eagle: add downloading workaround via IPFS
- epm play teamviewer: fix repacking

* Sun Mar 20 2022 Vitaly Lipatov <lav@altlinux.ru> 3.15.1-alt1
- glusterfs*.sh: fix returned error code (ALT bug 41429)
- epm-play: export SUDO for scripts
- epm play assistant: update version to 4.8
- epm play: add alternatives xbrowser/x-www-browser and webclient provides for all browsers
- epm play: update sputnik-browser to 5.6
- epm play: do correct repack for brave browser
- epm play scripts: cleanup
- epm play: move all chrome based browser code to the common file
- epm play: fix permissions (The Teams did not start)
- epm play geogebra
- epm play webex (ALT bug 42115)

* Sat Mar 19 2022 Vitaly Lipatov <lav@altlinux.ru> 3.15.0-alt1
- epm play: add R7 Office from the official site
- spec: drop ALT specific cases, use rpm-build-intro
- epm play xnview: remove libs embedded in Plugins
- epm-release_upgrade: add support for migrate from CentOS/8 to RockyLinux/8
- epm-release_upgrade: add migrate to Oracle Linux and CentOS Stream
- epm-repolist: allow args on ALT
- distr_info: add RockyLinux and OracleLinux support
- epm-release_upgrade: improve fix CentOS/8 repo
- distr_info pkgtype: add package type autodetect by package manager
- distr_info pkgmanager: detect package manager by commands in the system
- distr_info: add Alma Linux support
- epm play assistant: update version to 4.7
- epm-restore: fix for python_version <= 2.7
- epm-query_file: fix on deb systems
- epm qf: always use full path for rpm --query
- epm-release_upgrade: install systemd-settings-disable-kill-user-processes only if missed
- distr_info: add ALTServer support
- epm play: add Atom support
- epm-checkpkg: fix message
- epm play edge: fix binary interpreter (ALT bug 41921)
- epm play skype: set SUID for chrome-sandbox if userns_clone is not supported (ALT bug 41599)
- epm play zoom: fix repack (ALT bug 41775) (ALT bug 41954)
- epm play: add mssql-tools install
- epm-repack: allow multidigital versions
- epm play yandex-browser: add install yandex-browser-beta-codecs-ffmpeg-extra (ALT bug 40113)
- epm repack yandex-browser-beta.sh: improved

* Mon Dec 20 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.7-alt1
- add epm play mssql-server

* Thu Dec 16 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.6-alt1
- epm play: add initial --update [receipt|all] support (do update in any case as for now)
- distr_info: add FedoraLinux support (Fedora 35)
- prescriptions: remove -x
- distr_info: add openSUSE support
- skip eepm-yum packing on yum based systems
- epm-check_updated_repo: disable check if we never do apt-get update
- epm-install: pacman no more support --force

* Fri Dec 10 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.5-alt1
- epm-Upgrade: pass args to epm-upgrade
- yum: update supported actions
- move repo fix code from release_upgrade to repofix
- epm-repo: add epm repo switch <repo> command
- epm repack Telegram: add /usr/bin/Telegram command
- epm play: add XnViewMP support
- epm repack zoom: drop embedded libs from reqs
- epm removerepo: error if there is an option as arg

* Thu Oct 28 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.4-alt1
- eget: add / in the end of URL to avoid redirect

* Thu Oct 28 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.3-alt1
- sputnik-browser.sh: fix removing (ALT bug 41226)
- epm play viber: remove versioned libtiff5 require (ALT bug 41224)
- epm-release_upgrade: don't restart system-logind after install systemd-settings-disable-kill-user-processes
- epm-release_upgrade: don't install apt-conf-branch if apt-conf-branch-* is already installed
- epm-upgrade: don't allow unknown options (ALT bug 41225)

* Mon Oct 25 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.2-alt1
- epm-epm_install: don't need distro-info since 3.14.1
- move nvidia-clean-drivers to epm remove-old-kernels
- google-chrome-stable.sh: fix icon packing
- chromium-gost-stable.sh: cleanup
- google-chrome-stable.sh: don't pack menu file
- epm-play: fix removing from the list
- epm-sh-functions: wait after error when under screen
- epm play: add sputnik-browser

* Fri Sep 10 2021 Vitaly Lipatov <lav@altlinux.ru> 3.14.1-alt1
- epm-kernel_update: add kernel update for dnf-rpm
- epm-query-file: cleanup, print all symlinks chain
- epm-autoorphans: do update too
- epm: add epm purge alias for epm remove
- repack chromium-gost-stable.sh: small fixes
- epm: add --force-yes support
- epm-release-upgrade: pass --auto and --force-yes to epm upgrade/downgrade
- epm-release_upgrade: skip error on empty package list
- epm-upgrade: add support for upgrade installed packages (and package files, with -F)
- epm-downgrade: downgrade only installed packages (file packages with --oldpackage)
- always pack and use internal distr_info

* Mon Sep 06 2021 Vitaly Lipatov <lav@altlinux.ru> 3.13.3-alt1
- epm-release_upgrade: add downgrade after upgrade to Sisyphus
- epm-autoorphans: upgrade before run autoorphans
- epm-autoremove: small fix
- epm-downgrade: fix downgrade a package
- distr_name: update to 2.6
- pass name/version to distro_info
- pack eepm-yum only on ALT

* Sat Sep 04 2021 Vitaly Lipatov <lav@altlinux.ru> 3.13.2-alt1
- separate 'installed' from 'query' command
- epm-release_upgrade: mute screen checking
- epm-upgrade: restore repo list after error
- epm reposave: fix run under user
- epm dedup: fix rpm -e remove for common removing
- add --force to epm-remove (pass packages to apt in any case) and use it in autoorphans

* Fri Sep 03 2021 Vitaly Lipatov <lav@altlinux.ru> 3.13.1-alt1
- require /usr/bin/rpmbuild, not rpm-build package
- epm-release_upgrade: say install screen only it is not installed yet
- epm: fix parse options after main command
- epm: add separated release_downgrade command
- epm play sferum: add to the list
- epm-removerepo: check for a full string
- epm release-upgrade: install altlinux-release-* if needed
- epm upgrade: fix removing repo after upgrade
- epm: drop direct arg for info command

* Thu Sep 02 2021 Vitaly Lipatov <lav@altlinux.ru> 3.13.0-alt1
- big arg parsing rewrite
- epm-release_upgrade: add checking for local console, for screen using, for logind
- epm release-upgrade: try replace altlinux-release-sisyphus if target distro is not Sisyphus
- epm-reposave: fix bug with repo settings
- epm-query: fix query file output (fix --short support)
- epm-removerepo: restore remove all

* Wed Sep 01 2021 Vitaly Lipatov <lav@altlinux.ru> 3.12.0-alt1
- epm-query_file: allow --short in the same manner as usual
- play anydesk.sh: update for their updated site
- add epm play sferum
- add epm play steam (but hidden from play list)
- epm-play: add --short support
- epm-search: search in epm play --list-all too
- rewrite set_sudo (add return status, don' fail SUDO if nofail arg is there)
- epm play: drop Install word from descriptions (exclude true prescriptions)
- serv: separate enable/disable and on/off
- serv: add --short support for lists
- serv: don't use sudo for systemd if it is not needed
- add serv exists for check of service existence
- epm release-upgrade: try be assured we have dm service is enabled
- epm-play: don't list i586- only prescriptions

* Mon Aug 30 2021 Vitaly Lipatov <lav@altlinux.ru> 3.11.2-alt1
- fix sudorun
- add 'epm repo Add' command (do update after add)

* Sun Aug 29 2021 Vitaly Lipatov <lav@altlinux.ru> 3.11.1-alt1
- epm-downgrade: use epm-upgrade for apt-rpm PMTYPE, instead of direct apt-get dist-upgrade
- fix sudocmd using (don't quote command with args)
- epm-downgrade: fix downgrade to a task

* Sat Aug 28 2021 Vitaly Lipatov <lav@altlinux.ru> 3.11.0-alt1
- check sudo only when needed
- epm print: use local file for query_package_field only if it has .rpm extension
- epm-play: allow pass package name when --remove
- epm-epm_install: add distro_info and eepm if we try install epm or eepm package

* Thu Aug 26 2021 Vitaly Lipatov <lav@altlinux.ru> 3.10.5-alt1
- ignore dot part of the version for ALT (9.0 -> p9)
- epm-release_upgrade: drop p9.x support
- epm-autoremove: fix run autoremove
- epm-release_upgrade: fix messages
- epm-removerepo: fix remove repo status (warning about empty grep)
- set distro_info >= 2.5

* Thu Aug 26 2021 Vitaly Lipatov <lav@altlinux.ru> 3.10.4-alt1
- epm-repolist: --quiet support
- epm search-file: fix error introduced by the new repolist code, add --quiet support
- epm-removerepo: fix after new repolist

* Thu Aug 26 2021 Vitaly Lipatov <lav@altlinux.ru> 3.10.3-alt1
- epm-autoremove: fix bug with next cycle in direct mode
- epm-repolist: improve repolist
- epm-removerepo: improve remove repo by mask
- allow uninitialized sudo with password too (for interactive run)
- epm-whatdepends: allow --short mode, disable verbose mode by default

* Tue Aug 24 2021 Vitaly Lipatov <lav@altlinux.ru> 3.10.2-alt1
- add epmwd alias for epm wd command
- epm-autoorphans: add confirm step before removing
- epm-autoremove: big rewrite, add confirm before removing
- epm-autoremove: add i586-libs, debuginfo, devel, gem, ruby support
- epm-restore: add requirements/coverage.txt support
- epm-epm_install: install distro_info before eepm (on ALT)
- epm restore: add perl requirements generation by META.yml
- epm-restore: generate perl requires in perl(name.pm) form
- epm-restore: rewrite perl requires without shyaml (via perl Makefile.PL PRINT_PREREQ=1)
- epm-play: print fatal error if there is error during install
- epm-release_upgrade: don't touch apt-conf and alt-release during update to p10
- epm-release_upgrade: make dist-upgrade before start upgrade to p10 (see altbug# 40805)
- epm-play: pass an additional args to the scripts
- epm-release_upgrade: support upgrade from p9.1 and p9.2
- add epm play wine script (supports new wine with new package naming scheme install)

* Mon Aug 16 2021 Vitaly Lipatov <lav@altlinux.ru> 3.10.1-alt1
- epm-repack: get tarball version after some prefix only
- cleanup Telegram receipts
- epm play: add SweetHome3D support (hidden for now)
- epm-release_upgrade: allow update from p9.1 and p9.2

* Sun Aug 15 2021 Vitaly Lipatov <lav@altlinux.ru> 3.10.0-alt1
- distro_info: fix p10 name
- epm-release_upgrade: set distbranch priority before apt update
- epm-release_upgrade: update-kernel -t std-def for p10
- epm-release_upgrade: restore sources list on errors

* Tue Aug 03 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.15-alt1
- epm-repack: drop tilda from deb version
- epm-release_upgrade: add support for p10

* Fri Jul 16 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.14-alt1
- repack: fix packing chrome-remote-desktop, hide it from epm play list (ALT bug 40492)

* Sun Jul 11 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.13-alt1
- epm play: add install chrome-remote-desktop
- epm-assure: fix the result code (ALT bug 40391)

* Sun Jul 04 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.12-alt1
- epm-restore: add skip unrelated requires
- release_upgrade: fix gdb removing
- repack: fix copying to the place (ALT bug 40347)
- prescription.d/zoom.sh: repack always (ALT bug 40367)
- prescription.d/telegram.sh: download stable version if latest has no binary (ALT bug 40368)
- epm-assure: return error from apt (ALT bug 40202)

* Thu Apr 22 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.11-alt1
- prescription.d/anydesk.sh: use latest version
- epm play: add Autodesk EAGLE install
- epm repack: add support for install any tarball, keep name and version
- epm play: add Telegram Desktop

* Tue Apr 20 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.10-alt1
- rewrite anydesk install to use RHEL8 build
- yandex-browser.sh: add instruction about libffmpeg.so install
- epm-repack: run repack.d/common.sh before repack.d/script.sh
- add repack.d/common.sh: move dist-packages to site-packages for python modules in /usr/lib

* Sat Apr 10 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.9-alt1
- repack.d/teamviewer.sh: drop /bin/ip require (see ALT bug 39891)
- prescription.d/brave.sh: fix downloading (ALT bug 39818)

* Mon Apr 05 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.8-alt1
- assistant.sh: upgrade to 4.2, preinstall fontconfig-disable-type1-font-for-assistant
- epm-print: fix constructname
- distr_info: fix c9f1 detection

* Tue Mar 30 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.7-alt1
- play code.sh: fix code download

* Tue Mar 30 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.6-alt1
- tools_eget: improve error handling
- fix spotify-client repack (ALT bug 39817)
- fix install zoom on ALTLinux i586
- epm-print constructname: fix bashism

* Sat Mar 27 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.5-alt1
- distr_info: add -z for print current CPU MHz
- epm-remove: fix remove skipping on failed deps

* Mon Mar 15 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.4-alt1
- glusterfs9: skip devel packages during upgrade
- repack.d/PacketTracer.sh: add repack for Cisco PacketTracer
- distr_info: fix package type detection for Kali Linux

* Tue Mar 09 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.3-alt1
- prescription.d/code.sh: fix for deb based system
- add repack.d/sbb.sh (Sberbank client)
- don't require rpm directly

* Thu Mar 04 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.2-alt1
- epm-sh-altlinux-contents-index: use rsync -z only for uncompressed files
- epm-restore: add nupkg restore support
- distro_info: fix --distro-arch for rpm based systems

* Wed Mar 03 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.1-alt1
- rewrite contents_index retrieving
- epm-sh-altlinux-contents-index: improve content_index list informativity

* Wed Mar 03 2021 Vitaly Lipatov <lav@altlinux.ru> 3.9.0-alt1
- epm: use rsync to get contents_index for ALT (with rsyncable gzip mirror)

* Thu Feb 25 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.9-alt1
- epm-play: fix duplicates in the installed list
- epm remove: don't try removing after rpm -e said there is not such package

* Sat Feb 20 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.8-alt1
- epm-repack: be verbose only with --verbose
- add repack.d for trueconf-server (unsupported!)
- fix some bashisms

* Tue Feb 16 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.7-alt1
- epm-play: allow mask unvaluable prescription, hide glibc-restore
- epm-play: disable check for already installed (it is allowed upgrade)
- repack.d/code.sh: drop firefox installing (closes: #39693)

* Tue Feb 16 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.6-alt1
- repack.d/code.sh: use upstream script to run code
- epm-play: fix save installed app
- teamviewer.sh: add comment about serv teamviewerd on
- add env EPM_OPTIONS support

* Tue Feb 02 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.5-alt1
- epm restore: add requirements/ dir support
- add glusterfs9 install
- prescription: add Visual Studio Code install
- prescription: fix error code for assisant and discord

* Thu Jan 21 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.4-alt1
- yum: add version support, disable sudo using
- prescripion.d/i586-wine*: fix removing (ALT bug 39320)
- set_sudo: if sudo required a password, end with fatal error
- epm-release_upgrade: add switch from prefdm to display-manager after upgrade (see altbug #26405)
- add brave-browser install: prescription.d/brave.sh

* Wed Jan 20 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.3-alt1
- add reception.d/yandex-disk.sh
- small fixes for yum command

* Wed Jan 20 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.2-alt1
- serv: fix help
- repack.d/anydesk.sh: preinstall needed packages
- epm: add --assumeyes alias for --auto
- add and pack yum command in eepm-yum subpackage
- repack.d/yandex-browser-beta.sh: add missed yandex-browser while repack rpm package (ALT bug 39564)
- repack.d/yandex-browser-beta.sh: install all requires packages before repacking
- repack.d/ICAClient.sh: filterout libc.so.6(GLIBC_PRIVATE) (ALT bug 39565)

* Wed Jan 06 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.1-alt1
- repack.d/tamtam-app.sh: set SUID for chromium-sandbox
- epm-download: force download before install if wildcard is used in URL

* Wed Jan 06 2021 Vitaly Lipatov <lav@altlinux.ru> 3.8.0-alt1
- move package manager detection to distr_info

* Wed Jan 06 2021 Vitaly Lipatov <lav@altlinux.ru> 3.7.6-alt1
- prescription/chromium-gost.sh: fix removing
- serv: use systemd by default for any system
- chromium-gost-stable.sh: drop obsoleted menu file
- epm play: add yandex-browser, improve repacking
- epm play: add spotify install support
- epm play: add tamtam messenger install support
- distr_info: use /etc/os-release firstly, drop obsoleted code
- distr_info: set rolling version for ArchLinux

* Sun Dec 20 2020 Vitaly Lipatov <lav@altlinux.ru> 3.7.5-alt1
- microsoft-edge-dev.sh: add fix for missed alternatives in rpm package
- repack: microsoft-edge-dev add /usr/bin/microsoft-edge in spec if missed
- add repack microsoft-edge.sh (for future)
- separate code for play command
- get_local_alt_contents_index: skip task lines from repolist (ALT bug 38766)
- epm-remove: make empty arg list is ok (ALT bug 39322)
- prescriptions for php7/php8: fix return status
- glusterfs7.sh: don't install glusterfs7-cli
- epm-assure: fix reenterability
- tools_eget: fix direct download from github
- epm-autoremove: disable interactive for all parts (ALT bug 39321)
- epm-autoorphans: add --auto support; print list for --dry-run
- i586-wine: return error on error

* Mon Dec 07 2020 Andrey Cherepanov <cas@altlinux.org> 3.7.4-alt1
- repack: add rule for ICAClient

* Mon Nov 23 2020 Vitaly Lipatov <lav@altlinux.ru> 3.7.3-alt1
- glibc-restore.sh: don't touch glibc package
- is_active_systemd: base on static info about systemd running
- epm-release_upgrade: run __check_system (assure we still have systemd) after upgrade
- add tip about epm repo --help and improve epm repo --help
- epm-repofix: add hack to fix apt-repo urls, some improvements

* Wed Nov 18 2020 Vitaly Lipatov <lav@altlinux.ru> 3.7.2-alt1
- improve anydesk repack
- epm-print: add epm print info command
- serv: add test command (for nginx -t, cupsd -t and so on)
- epm-restore: fix epm restore command example

* Wed Nov 11 2020 Vitaly Lipatov <lav@altlinux.ru> 3.7.1-alt1
- epm-release_upgrade: use [alt] sign for Sisyphus
- epm-autoremove: supports for python2 and python3 separately
- epm-sh-install: don't check vendor if a package is unaccesible
- add prescription python2-remove
- repack: add lightworks.sh

* Tue Nov 10 2020 Vitaly Lipatov <lav@altlinux.ru> 3.7.0-alt1
- drop alternative name upm, provide epm
- epm-restore: some improvements
- improve teamviewer repack

* Fri Nov 06 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.8-alt1
- epm-restore: add support for various names of requirements.txt file
- epm play: add anydesk, assistant, onlyoffice support
- various small improvements

* Mon Nov 02 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.7-alt1
- epm-install: return 0 if all packages are filtered out
- epm-addrepo: use sudocmd for apt-repo
- epm-repofix: disable root checking

* Sun Nov 01 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.6-alt1
- epm-restore: add requirements_dev.txt, setup.py, require.json (npm)
- epm-release_upgrade: drop signs if there are unknown vendor ID during update from repo

* Wed Oct 28 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.5-alt1
- repack skypeforlinux: drop unneeded /opt/skypeforlinux dir
- add play for discord
- eget: add hack for skip mask if there ?...= (some args)
- epm-epm_install: don't use epm command
- add prescription for i586-remove
- epm: print command when run with --verbose or EPM_VERBOSE is set
- epm-remove: add --simulate support for deb

* Tue Oct 27 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.4-alt1
- add repack for teams (move to /opt, fix reqs)
- play: add viber support
- repack: move skype to /opt, fix reqs
- improve all prescriptions for play

* Mon Oct 26 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.3-alt1
- epm-release-upgrade: remove gdb before update to p9
- tools_eget: update to eget 4.0 (wget/curl support)
- epm-sh-functions: always use internal tools_eget
- epm-epm_install: fix for install more short name

* Sat Oct 24 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.2-alt1
- prescriptions: use DISTRVERNDOR instead of distro_info
- prescriptions: add --remove support
- epm-prescription: add support for --list, --list-all, --remove

* Sat Oct 24 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.1-alt1
- use has_space from estrlist (works with dash)
- epm-repack: implement initial stoplist support for deb packages we don't want convert
- epm-repack: make fatal any errors in repack scripts
- add prescription for teamviewer

* Sat Oct 24 2020 Vitaly Lipatov <lav@altlinux.ru> 3.6.0-alt1
- epm-install: add --noscripts support for rpm install
- epm-install: disable scripts by default for outside vendors
- add prescription for teams, vivaldi
- add repack for vivaldi-stable
- prescription, repack: add PROGDIR to PATH
- distr_info: sync with distro_info-1.7

* Fri Oct 23 2020 Vitaly Lipatov <lav@altlinux.ru> 3.5.0-alt1
- epm-autoremove: add --auto support
- epm-repack: skip system dir packing
- add repack script for microsoft-edge-dev
- epm: introduce play command: use for install
       edge, zoom, chrome, chromium-gost, skype
       from the official sites

* Wed Oct 21 2020 Vitaly Lipatov <lav@altlinux.ru> 3.4.0-alt2
- add epm-repack subpackage (just a static requirements)

* Mon Oct 19 2020 Vitaly Lipatov <lav@altlinux.ru> 3.4.0-alt1
- serv-list_startup: temp. fix for non systemd systems
- serv: add list-failed command
- epm-repack: add workaround for empty Summary
- add repack support for dialog-ee-x deb package
- epm: disable warming up by default
- epm addrepo/removerepo: fix repo manipulating on deb systems
- epm-addrepo: initial implementation of addkey for deb

* Mon Oct 19 2020 Vitaly Lipatov <lav@altlinux.ru> 3.3.5-alt1
- epm-repo: fix set
- epm-release_upgrade: big rewrite, add support for downgrade to с8
- epm-release_upgrade: allow two params: from and to

* Fri Oct 16 2020 Vitaly Lipatov <lav@altlinux.ru> 3.3.4-alt1
- epm: skip all args with spaces (we don't support it)
- epm-dedup: add --direct support to use epm internal implementation
- epm-repofix: add support for yandex and basealt
- epm-addrepo: add support for basealt and yandex repo sites
- epm-release_upgrade: replace etersoft-gpgkeys with alt-gpgkeys if we have not LINUX@Etersoft repo
- epm-repo: add set command implemented via clean & change
- epm-repack: don't intersect with source rpm package

* Sun Oct 11 2020 Vitaly Lipatov <lav@altlinux.ru> 3.3.3-alt1
- fix typo in get_task_packages

* Sat Oct 10 2020 Vitaly Lipatov <lav@altlinux.ru> 3.3.2-alt1
- mask direct in assure_exists
- epm-repofix: mask apt-repo using
- update tools_estrlist from estrlist package
- epm-remove: add --skip-missed

* Wed Oct 07 2020 Vitaly Lipatov <lav@altlinux.ru> 3.3.1-alt1
- get_task_packages: add arepo packages (i586) too
- epm-upgrade: drop devel subpackages from upgrade from a task
- update tools_estrlist from estrlist package
- update glibc-restore prescription

* Tue Oct 06 2020 Vitaly Lipatov <lav@altlinux.ru> 3.3.0-alt1
- add epm prescription support
- add prescription for install missed i586 packages (i586-fix)
- add prescriptions for wine, php7, glusterfs7, glusterfs8
- distr_info: sync with distro_info-1.3

* Wed Sep 30 2020 Vitaly Lipatov <lav@altlinux.ru> 3.2.6-alt1
- autoremove: use apt-get autoremove on ALT by default
- epm-mark: add apt-mark support for ALT and deb based systems
- epm-repack: add workaround for spaced paths to pkg
- add PackageKit commands
- zoom.sh: s/return/exit (ALT bug 39014)

* Mon Aug 24 2020 Vitaly Lipatov <lav@altlinux.ru> 3.2.5-alt1
- epm-repack: always use anypackage to rpm function for deb->rpm conversion
- epm-repack: drop dir "/" and other root dir paths from a file list
- epm-repack: improve cleanup tmp dir
- add repack scripts for InfoWatch products

* Fri Jul 24 2020 Andrey Cherepanov <cas@altlinux.org> 3.2.4-alt1
- fix repack rules for mssql-server: remove libcrypto-devel and fix path to sysctl

* Sat Jul 04 2020 Vitaly Lipatov <lav@altlinux.ru> 3.2.3-alt1
- epm-download: force download remote package on ALTtoo
- epm-assure: don't use direct epm call to package install
- epm-upgrade: add missed task number arg
- epm-sh-functions: disable broken eget output
- epm-Install: ignore failed update by force param

* Mon Jun 22 2020 Vitaly Lipatov <lav@altlinux.ru> 3.2.2-alt1
- filelist: fix grep by contents

* Mon May 18 2020 Vitaly Lipatov <lav@altlinux.ru> 3.2.1-alt1
- epm query_file: return error if file is missed
- add zoom repack rule

* Mon Mar 09 2020 Vitaly Lipatov <lav@altlinux.ru> 3.2.0-alt1
- epm: use packagekit name for PackageKit
- serv: add /etc/eepm/serv.conf support
- addrepo/removerepo: add dry-run support
- use dnf by default on Fedora based system
- epm: improve help
- implement epm repo [list|add|remove|fix]
- implement serv cat
- add epm repo clean|save|restore (just skeleton)

* Wed Feb 19 2020 Vitaly Lipatov <lav@altlinux.ru> 3.1.7-alt1
- epm repofix: replace sources.list only on ALT
- serv log: run without follow (-f) by default
- epm addrepo: fix add url
- epm-repofix: add initial support for repofix etersoft
- epm repofix: unified subst rules (fix for p9)

* Sun Feb 16 2020 Vitaly Lipatov <lav@altlinux.ru> 3.1.6-alt1
- removerepo: fix tasks remove
- rewrite removerepo
- epm remove: fix remove status

* Wed Feb 12 2020 Vitaly Lipatov <lav@altlinux.ru> 3.1.5-alt1
- epm-install: fix double run rpm installing on ALT
- epm-remove: don't use hilevel command if --nodeps
- epm-remove: change to a writable dir (/tmp) before remove
- epm-restore: temp. implementation of python requires translation to spec

* Wed Feb 05 2020 Vitaly Lipatov <lav@altlinux.ru> 3.1.4-alt1
- epm-repack: alien will use rpmbuild, assure we have it
- epm-repack: repack only selected packages with abs paths (eterbug #14411)
- epm: increase stdinput wait to 10 seconds
- epm-print: improve print pkgsourcename

* Fri Jan 31 2020 Vitaly Lipatov <lav@altlinux.ru> 3.1.3-alt1
- commit packed files
- distro_info related fixes
- add initial openrc support
- add restore command (install packages by project list (python's requirements.txt)
- epm install: forbid src.rpm installation
- epm repolist: support task number(s)
- epm repack: more cleanup output, print list of converted packages
- epm restore: add using ldd-requires for binary files

* Tue Nov 26 2019 Vitaly Lipatov <lav@altlinux.ru> 3.1.2-alt1
- improve homebrew support
- serv: add edit support for systemd
- fixes for ALT p9 detection
- epm query_file: use -- after options
- use external distro_info on non ALT systems
- epm: add support for a few tasks in addrepo/removerepo/install
- upgrade: add support for epm upgrade TASK (upgrade only already installed packages)
- remove TASK: remove all packages from the TASK
- release_upgrade: install alt-gpgkeys firstly

* Tue Nov 12 2019 Vitaly Lipatov <lav@altlinux.ru> 3.1.1-alt1
- epm-dedup: fix info message (ALT bug 37473)
- epm: add --no-stdin support (do not read commands from stdin)
- run internal eepm with --inscript (no read from stdin) (ALT bug 37209)

* Fri Nov 08 2019 Vitaly Lipatov <lav@altlinux.ru> 3.1.0-alt1
- add epm full-upgrade
- kernel update/remove: add --auto support (non interactive)
- is_active_systemd: rewrite systemd detection
- serv: add print out virtualization type (via systemd helper)

* Tue Nov 05 2019 Vitaly Lipatov <lav@altlinux.ru> 3.0.0-alt1
- distr_info: p9 support
- addrepo: add check for empty DISTRVERSION
- epm install: add support for several task numbers
- fix tasknumber checking
- addrepo: add support for dnf, add support for epel repo add
- release_upgrade: install etersoft-gpgkeys firstly if used one
- epm: add alias for policy (resolve) and release-upgrade (upgrade-system)
- add initial packagekit (pkcon) support
- more clean and strict rules
- workaround against ALT bug 37272

* Sat Sep 28 2019 Vitaly Lipatov <lav@altlinux.ru> 2.6.0-alt1
- add repack.d/XenDesktopVDA.sh (ALT bug 37167)
- fix systemd detection
- epm-check_updated_repo: fix wrong cleaned variable
- serv-log: add sshd support
- repack mssql-server.sh: improve requires

* Thu Aug 15 2019 Vitaly Lipatov <lav@altlinux.ru> 2.5.10-alt1
- move dedup code to the separate command
- epm dedup: add apt-get dedup from apt-get dedup support
- epm search: improve for zypper
- release_upgrade: rewrite to p9 upgrade support

* Fri May 17 2019 Vitaly Lipatov <lav@altlinux.ru> 2.5.9-alt1
- epm-check: use rpmevrcmp to delete old versions
- epm-sh-functions: improve systemd detection (docker support)
- support release upgrade for p9

* Tue Mar 26 2019 Vitaly Lipatov <lav@altlinux.ru> 2.5.8-alt1
- add trueconf-client repack config
- epm: set timeout for 2 secs
- fix broken pkg_filenames

* Mon Feb 25 2019 Vitaly Lipatov <lav@altlinux.ru> 2.5.7-alt1
- epm downgrade: add --auto support
- add CONFIGDIR support
- add repack scripts for chromium-gost and google-chrome
- fix comments

* Tue Feb 05 2019 Vitaly Lipatov <lav@altlinux.ru> 2.5.6-alt1
- check: improve remove dupls: remove identical packages, add common removing

* Fri Jan 25 2019 Vitaly Lipatov <lav@altlinux.ru> 2.5.5-alt1
- check: add fix duplicates
- epm: keep sssd-ad during upgrade

* Thu Nov 29 2018 Vitaly Lipatov <lav@altlinux.ru> 2.5.4-alt1
- add Amzn (Amazon Linux AMI) support
- rename README to README.md
- fix openSUSE Leap support
- epm-release_upgrade: force install make-initrd if exists when upgrade to Sisyphus

* Sat Oct 06 2018 Vitaly Lipatov <lav@altlinux.ru> 2.5.3-alt1
- distr_info -b: add 64 bit for aarch64
- epm-print: fix release output, add version-release support
- add yandex-browser-beta.sh
- add --short support for what-depends

* Tue Jul 24 2018 Vitaly Lipatov <lav@altlinux.ru> 2.5.2-alt1
- distr_info: add OpenWrt detection
- distr_info: drop obsoleted systems
- fix inputistty (implement via test -t)
- distr_info: use awk instead tr (broken in busybox on OpenWrt), cleanup code

* Tue Jul 17 2018 Vitaly Lipatov <lav@altlinux.ru> 2.5.1-alt1
- distr_info: small fixes
- epm-query: fix __print_suffix (skip for empty arg)

* Wed Jul 04 2018 Vitaly Lipatov <lav@altlinux.ru> 2.5.0-alt1
- epm autoremove: skip manually installed packages on ALT

* Mon Jun 18 2018 Vitaly Lipatov <lav@altlinux.ru> 2.4.9-alt1
- repack: run independently to user's .rpmmacros

* Thu Jun 07 2018 Vitaly Lipatov <lav@altlinux.ru> 2.4.8-alt1
- autoorphans: assure for package-cleanup for yum/dnf
- apt-dpkg: implement addrepo/removerepo
- addrepo: add ALT branch support
- distr_info: support ALT starter kits
- epm-packages: add arch on deb

* Mon Mar 19 2018 Vitaly Lipatov <lav@altlinux.ru> 2.4.7-alt1
- checkpkg: detect rpm --nosignature/--nogpg
- epm-query: fix check only names without arch

* Mon Feb 26 2018 Vitaly Lipatov <lav@altlinux.ru> 2.4.6-alt1
- distr_info: cleanup code, fix quotes
- checkpkg: check only md5 (skip gpg)
- implement repack for rpm to deb and deb to rpm conversion

* Sun Feb 04 2018 Vitaly Lipatov <lav@altlinux.ru> 2.4.5-alt1
- implement assure_distr and use it
- add repack command and move all repack code to a separate module

* Fri Dec 22 2017 Vitaly Lipatov <lav@altlinux.ru> 2.4.4-alt1
- distr_info: check if proc exists before use
- repack: add duplicati support

* Thu Dec 14 2017 Vitaly Lipatov <lav@altlinux.ru> 2.4.3-alt1
- implement __epm_search_internal
- full search output for Slackware only with --verbose
- fix simulate for Slackware

* Tue Dec 12 2017 Vitaly Lipatov <lav@altlinux.ru> 2.4.2-alt1
- epm-install: fix --skip-install with dnf/yum
- dnf/yum: fix install/remove current arch packages (https://bugzilla.redhat.com/show_bug.cgi?id=1525164)

* Tue Dec 12 2017 Vitaly Lipatov <lav@altlinux.ru> 2.4.1-alt1
- add teamviewer.sh for repack (ALT bug 34318)

* Sun Dec 10 2017 Vitaly Lipatov <lav@altlinux.ru> 2.4.0-alt1
- epm: add /etc/eepm/eepm.conf support
- epm install: add --repack support (binary rpm repacking before install)
- add --scripts support to repack foreign packages with alien
- epm-install: add /etc/eepm/repack.d/PKGNAME.sh support during repacking
- add mssql-server, skypeforlinux rules
- revert "epm whatdepends: use rdepends": miss many dependencies

* Sat Dec 09 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.6-alt1
- drop arch suffix adding (we can't distinct between arch/noarch)
- improve --skip-installed on x86_64 Fedora based: check for noarch too

* Thu Dec 07 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.5-alt1
- serv-status: mask stderr in is_service_running
- epm-query: fix list package by package
- serv list-all: cleanup output
- serv list: improve speed with run sudo once
- serv status: improve running state detection
- query: replace (x86-32) with .i686 for rpm/dnf

* Wed Dec 06 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.4-alt1
- apply prefix only if there are no other prefix

* Tue Dec 05 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.3-alt1
- add repo alias for repolist
- epm-install: add options support during cross install
- distr_info: distinct between x86 and x86_64 for -a
- epm install: expand package names with arch before isinstalled checking (eterbug #12332)

* Fri Dec 01 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.2-alt1
- fix --auto remove for dnf
- release_upgrade: do not update rpm apt when downgraded from Sisyphus
- release_upgrade: fix downgrade to p8
- release_upgrade: ask confirm before upgrade
- epm: add --non-interactive alias for --auto

* Sun Nov 19 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.1-alt1
- epm whatdepends: use rdepends
- repofix: fix signing when we have /
- query_file: only inform about epm sf using
- allow ei/ik install any package(s) from Korinf
- ei/ik: add support for --list [mask], install via eget

* Sun Nov 12 2017 Vitaly Lipatov <lav@altlinux.ru> 2.3.0-alt2
- epm: rewrite release_upgrade for ALT
- autoremove: small improvement
- remove: add support dry mode for rpm/apt

* Sat Nov 11 2017 Vitaly Lipatov <lav@altlinux.ru> 2.2.0-alt1
- use external eget on ALT
- disable one file version packing
- update internal eget to 2.0

* Fri Nov 10 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.10-alt1
- install: print low level install command if args is empty
- epm: add wd alias for whatdepends
- epm-clean: add --noconfirm for pacman
- fix and text install via url with wildcard

* Wed Nov 08 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.9-alt1
- tasknumber: fix bashism

* Thu Nov 02 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.8-alt1
- epm addrepo: use http for ALT archive, add date format checking
- ep-seach: use ~ for negate and ^ for a begin of line in __epm_search_make_grep

* Mon Oct 23 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.7-alt1
- improve addrepo (add archive DATE support) and removerepo (archive, tasks)

* Sun Oct 22 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.6-alt1
- add support for ALT girar task number to install/remove, improve addrepo/removerepo
- distr_info: add support for get info about arch, bus size, memory size, base os name
- add warmup bases support and use it

* Wed Oct 18 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.5-alt1
- distr_info: add firstupper function, implement full /etc/os-release checking
- add --dry-run support to remove, autoorphans, autoremove
- autoremove: add support for autoremove [libs|python|perl|libs-devel]

* Mon Oct 16 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.4-alt1
- add skip # in task number
- add support for just task number in removerepo
- repofix: add sign for Etersoft Sisyphus

* Thu Sep 14 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.3-alt1
- use force package selection only in non interactive install
- kernel_update: add update repo if needed
- install/upgrade: add debug output for apt when --verbose

* Fri Aug 04 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.2-alt1
- apt install: add force package selection (see ALT bug #22572)

* Mon Jul 31 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.1-alt1
- distr_info: fix tr using
- install --show-command-only supports hi level names now

* Sat Jul 22 2017 Vitaly Lipatov <lav@altlinux.ru> 2.1.0-alt1
- fix quotes (eterbug #11863)
- make shellcheck happy
- check_code.sh: skip global vars

* Fri Jul 21 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.9-alt1
- epm-filelist: add support with yum and dnf
- imlrement check for dnf via dnf check
- add support for ALT Linux t7

* Thu Jun 15 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.8-alt1
- make shellcheck more happy
- improve epm query
- epm-search-file: force overwrite list file
- epm-info: add support for local rpm and deb files

* Wed Apr 05 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.7-alt1
- serv-status: use -l for systemd status
- emp-query: improve for pacman
- epm-query: fix is_installed

* Mon Mar 13 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.6-alt1
- epm-packages: improve sort output
- hack to support old lz4

* Fri Mar 10 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.5-alt1
- epm sf: make compressed cache for local file too
- rewrite epm sf, colorify it
- more correct message when empty run

* Thu Mar 09 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.4-alt1
- epm-policy: move to hilevel package name
- implement local cache for contents index for ALT repos

* Tue Mar 07 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.3-alt1
- fix query hilevel name for yum/dnf
- epm install: fix install rpm on deb
- add missed in some cases AstraLinux and GosLinux

* Thu Mar 02 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.2-alt1
- distr_info: fix version detection for all ALT p8 distros
- add workaround for ALT rpm missed https support
- install librpm7 during upgrade to Sisyphus
- improve systemd checking

* Tue Feb 07 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.1-alt1
- autoremove: skip -32bit suffix

* Mon Jan 16 2017 Vitaly Lipatov <lav@altlinux.ru> 2.0.0-alt1
- distr_info: fix get lsb-release file with quoted fields
- epm-download: add filename empty checking
- epm info: add URL support
- epm upgrade: allow extra args
- release_upgrade: improve for Fedora
- epm-download: add support for urpm
- check_update_repo: check for /var/lib/apt/lists date
- query_file: improve check for relative path
- epm-automove: fix i586-lib issue
- fix systemd detection
- epm: add/remove autoimports

* Wed Dec 07 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.9-alt1
- add own realpath implementation if missed
- add openSUSE Tumbleweed support
- autoremove: do separate removing cycles for python/perl and libs
- epm-site: fix json parsing
- epm-download: realize download via info from packages.altlinux.org
- epm-install: add direct install (not via apt) support for ALT Linux
- addrepo: implement support for epm addrepo etersoft

* Thu Dec 01 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.8-alt1
- epm-install: move download code to epm-download
- epm-checkpkg: add support for checking package by url
- downgrade: use distro-sync for downgrade with yum/dnf
- autoorphans/autoremove: fix uses package-cleanup with yum/dnf
- epmqf: use realpath for exists files by default
- improve systemd detection

* Tue Nov 15 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.7-alt1
- fix build install
- small fixes

* Sun Oct 02 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.6-alt1
- epm: improve message about incorrect command
- workaround for sudo -h prints first line in stderr
- example support for service SERVICE log command

* Fri Sep 23 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.5-alt1
- fix systemd detection
- initial log command support
- fix anyservice list (need anyservice 0.5 or above)

* Fri Sep 23 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.4-alt1
- distr_info: fix checking on MacOS
- brew fixes
- autoremove: enable deep remove by default
- small fixes

* Wed Aug 24 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.3-alt1
- implement cross install for rpm and deb packages
- serv: add runit support (Void Linux)
- serv-reload: add fallback via restart
- serv-try_restart: add fallback via restart
- small fixes

* Tue Aug 23 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.2-alt1
- add Void Linux initial support
- addrepo/removerepo: fix used repo id string
- release-upgrade: fix direct apt-repo
- epm install: disable optimize when install foreign packages
- serv: more verbose
- rewrite query and packages

* Thu Aug 18 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.1-alt1
- upgrade: add --auto support for apt and yum/dnf
- serv: add reload command support
- improve eget to support -O file
- epm-install: add real support install by url
- epm_install: rewrite, use direct install via epm_install
- epm_install: rewrite with pkg_urls support using

* Wed Aug 17 2016 Vitaly Lipatov <lav@altlinux.ru> 1.9.0-alt1
- improve urpmi support
- serv: check anyservice support against anyservice version 0.3
- autoremove: ignore libvirt

* Mon Aug 15 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.8-alt1
- epm-install: skip low-level when install by path
- anyservice support fixes
- serv: some anyssh fixes

* Sun Aug 14 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.7-alt1
- realize autoorphans/autoremove for zypper >= 1.9.2 in SUSE
- introduce epm remove-old-kernels command
- epm clean: clean local repo cache only with --force
- serv: add anyservice support
- small fixes

* Tue Jul 19 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.6-alt1
- epm-sh-functions: fix sudo -- detection
- distr_info: add AstraLinux support
- epm-sh: add AstraLinux and Elbrus support
- add epmrl alias for epm rl
- epm-autoremove: add nvidia-clean-driver
- epm-autoremove: use ALTLinux case instead apt-rpm

* Sat Jun 25 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.5-alt1
- add Tiny Core Linux support (tcl, tce)
- improve dnf support: add release-upgrade
- improve ALT Linux release upgrade

* Mon May 30 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.4-alt1
- epm install: add initial support for cross install packages (deb/rpm packages on rpm/deb-based hosts)
- install: add --noremove support for apt
- repofix: add check for vendor key if set it
- add check if sudo supports --
- repofix: skip useless Sisyphus replacements
- release_upgrade: skip confirm if there are no changes
- epm-query: add semihack for check removed packages
- epm: add support for run script from stdin

* Mon May 23 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.3-alt1
- autoorphans: do real removing
- autoremove: add update-kernel version 0.9.9 checking
- autoorphans/autoremove: improve excludes

* Fri May 20 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.2-alt1
- epm_install: added command for install or update eepm package from all in one script
- add --no-remove support during upgrade
- epm-download: add yumdownloader support
- epm-autoorphans: realize print list
- epm-autoremove: realize with apt-cache list-nodeps from apt-scripts
- epm-assure: fix for existing path checking
- distr_info: drop subversion from Debian distro version

* Thu Apr 28 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.1-alt1
- release-upgrade: install altlinux-release-p? only if /etc/altlinux-release belongs to sisyphus

* Wed Apr 27 2016 Vitaly Lipatov <lav@altlinux.ru> 1.8.0-alt1
- commit packed files
- repofix: replace Etersoft branches only if have Etersoft key
- release_upgrade: install update-manager-core package for deb-based

* Sun Apr 24 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.6-alt1
- fix assure_exists
- epm-assure: improve version checking

* Sun Apr 24 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.5-alt1
- epm-print: add compare version command
- repofix: fix Sisyphus replace
- release_upgrade: do packages downgrade after changes to p8 from Sisyphus
- epm-assure: rewrite to realize correct version comparing
- kernel_update: run remove-old-kernels too

* Sat Apr 23 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.4-alt1
- release-upgrade: small logic improvements

* Sat Apr 23 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.3-alt1
- epm release-upgrade: check for glibc-core-2.17
- release-upgrade: add detect current system by apt repo
- release-upgrade: rewrite to support p8 -> Sisyphus and vice versa

* Wed Apr 20 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.2-alt1
- distr_info: fix os-release detection

* Wed Apr 20 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.1-alt1
- epm: added alpine apk package manager install, update, remove, qa, search commands
- fix Simply Linux 6.0 detection
- kernel_update: do not install kernel if it is not installed (for ovz containers)

* Tue Apr 19 2016 Vitaly Lipatov <lav@altlinux.ru> 1.7.0-alt1
- epm release-upgrade with ALT Linux p8 support
- epm-reinstall: add names filtering (to support epmqp some | epm reinstall)
- release-upgrade: print some info

* Tue Apr 19 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.9-alt1
- check if systemd is active
- release_upgrade: fix version

* Mon Apr 18 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.8-alt1
- small output fix
- rewrite release-upgrade

* Fri Apr 15 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.7-alt1
- release_upgrade: fix sign replacement
- fix epm_update
- set p8 sign and install apt-conf-branch
- repofix: add signs for ALT Linux or Etersoft branches

* Fri Apr 15 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.6-alt1
- release_upgrade: improve upgrade way
- epm: update copyright date

* Fri Apr 15 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.5-alt1
- restrict sudo args
- small fixes

* Fri Apr 15 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.4-alt1
- epm-repofix: use sed -r instead perl -pi
- pack_in_onefile: fix run positional load_helper
- initial support for upgrade ALT Linux release to p7 / p8
- fix repofix code

* Tue Apr 05 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.3-alt1
- epm-checksystem: add assure_exists time
- check_updated_repo fix epm update

* Thu Mar 17 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.2-alt2
- add check_reqs script and cleanup all reqs

* Thu Mar 17 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.2-alt1
- epm: print error for extra unallowed args
- drop time requires

* Fri Feb 26 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.1-alt1
- distr_info: add Simply Linux detection
- epm: use yum-config-manager for managing repo in yum based distros
- fix downgrade for LINUX@Etersoft, Debian, Ubuntu, add support for downgrade one or a few packages
- epm search: optimize grep when search for one word, apply short option before all, disable localized description
- epm-site: use https for packages.altlinux.org
- add serv print command
- serv: fix systemd detection

* Wed Jan 27 2016 Vitaly Lipatov <lav@altlinux.ru> 1.6.0-alt1
- release long term support version 1.6
- epm-print: add print specname
- rewrite eget

* Wed Dec 16 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.25-alt1
- epm-checksystem: fix working in packed
- fix packed version
- improve dnf support
- small fixes

* Tue Dec 01 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.24-alt1
- add support apt-cyg on Cygwin
- drop pks-db requires
- epm-check_updated_rep: do not check on deb systems
- epm-query: fix print package version for other systems

* Sun Nov 22 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.23-alt1
- epm install: disable update if try install local package files
- epm clean: remove partial files
- real check if package(s) is installed
- small improve print name

* Sun Oct 25 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.22-alt1
- distr_info: fix ALT Linux version detection
- epm: fix print help command
- fix epm repofix
- improve epm-filelist
- use short names when possible

* Tue Oct 13 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.21-alt1
- introduce epm print for print out package names and fields
- epm-site: use functions from epm-print
- epm-remove: do short package name from deb

* Mon Oct 12 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.20-alt1
- distr_info: add mcst support
- skip update checking for non root users have no nopassword sudo
- epm_checksystem: add initial file for check system health

* Wed Aug 26 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.19-alt1
- epm-clean: add deb-based support
- check_updated_repo: use $SUDO for check if updated
- epm-site: get url for noninstalled packages from packages.altlinux.org on ALT Linux

* Tue Aug 25 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.18-alt1
- epm: add policy (like apt-cache policy) command
- initial repofix code, need fix regexp and test
- epm-filelist: realize low level file list for rpm in the same code
- fix checking update files
- epm clean: clean all cached files on ALT

* Wed Aug 19 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.17-alt1
- fix update repo checking
- print Uwaga about eatmydata only if verbose mode
- changelog: use query rpm mode for --changelog

* Sun Aug 16 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.16-alt1
- run update if repo info older than 1 day
- epm-query_file: fix read link
- add epm url|site command (with -p arg for open at packages.altlinux.org)

* Wed Aug 12 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.15-alt1
- epm-assure: fix for dir checking support
- epm query file: fix recursion result and more quoting

* Fri Jul 24 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.14-alt1
- simulate: allow Exiting on user Command in any place of the line

* Tue Jul 21 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.13-alt1
- epm-assure: add support for checking any path on a file system
- small fixes

* Fri Jul 10 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.12-alt1
- epm: initial download package support
- fix update and simulate for dnf
- allow changelog and query file for dnf
- install: allow return command for dnf
- use dnf only if /var/lib/dnf/yumdb is exists

* Thu Jul 09 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.11-alt1
- epm-filelist: add support file list for noninstalled packages on deb
- introduce autoorphans command
- epm-install: add workaround to fix urls works
- fix behaviour when has dir with the same name like package
- serv: implement native restart
- use dnf on Fedora if exists

* Wed Feb 25 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.10-alt1
- serv-status: realize detection scheduled status for Ubuntu
- epm-sh: fix withtimeout

* Sat Feb 21 2015 Vitaly Lipatov <lav@altlinux.ru> 1.5.9-alt1
- fix withtimeout (was incorrect workaround)
- remove epm-eget -> tools-eget for exclude from one pack file
- add epmI == epm Install
- serv-enable: use chkconfig --add and chkconfig SERVICE on
- query_file: fix for dirs

* Wed Dec 24 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.8-alt1
- add initial snappy support
- remove extra deps

* Fri Dec 05 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.7-alt1
- checkpkg: add msi checking
- epm-packages: fix --sort
- serv-enable: assure chkconfig add
- autoremove: do not remove libnss-*, *debuginfo
- fatal exit if assure_exists is failed
- epm: fix search file in ALT Linux repo
- epm: add 'epm s' like epms
- initial eget commit

* Thu Jul 17 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.6-alt1
- assure we have a command rpm/dpkg when work with a package file
- fix for use package name list in quotes
- fix build without rpm-build-altlinux-compat

* Sat Jun 07 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.5-alt1
- fix epmqp, epm clean for FreeBSD
- epm programs: use /usr/local/share/applications on BSD systems
- epm reinstall: add pkgng support
- fix timeout using on FreeBSD

* Wed Jun 04 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.4-alt1
- add initial support for FreeBSD's pkgng
- add audit command for check installed packages against known vulnerabilities

* Wed May 28 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.3-alt1
- prefer to use init script directly
- introduce downgrade command
- use correct datadir

* Tue Mar 25 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.2-alt1
- use repolist for get local repo path
- support --auto for reinstall
- epm-requires: fix typo

* Wed Mar 05 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.1-alt1
- epm: check real file detection
- checkpkg: use assure for erc
- simulate: add missed --dry-run for zypper
- epm-check_updated: fix if perms is unsufficient

* Wed Feb 26 2014 Vitaly Lipatov <lav@altlinux.ru> 1.5.0-alt1
- distr_info: add Android detection
- add initial android support
- epm: use eatmydata on kernel update
- workaround for infinity wait in cat
- add aptitude support
- get repo info for first time
- add epm assure for check if command is exists
- epm: fix commands, helps, eatmydata using

* Tue Jan 28 2014 Vitaly Lipatov <lav@altlinux.ru> 1.4.6-alt1
- drop apt/rpm requires for non ALT distro
- epm-query_file: do search_file with full path if exists
- print about eatmydata only for u/i/r
- epm-search: add support --short option
- epm-search: remove unsupported --

* Tue Oct 29 2013 Vitaly Lipatov <lav@altlinux.ru> 1.4.5-alt1
- epm: check for -- after options
- fix bashisms
- epm provides/requires: fix for rpm files
- separate check input and output
- epm-filelist: add less
- realize autoremove orphaned packages (unused libs*)

* Tue Oct 22 2013 Vitaly Lipatov <lav@altlinux.ru> 1.4.4-alt1
- epm: get package names from stdin if it is pipe
- fix stderr issues

* Mon Oct 21 2013 Vitaly Lipatov <lav@altlinux.ru> 1.4.3-alt1
- rewrite code without bashisms
- search colorifer: fix colorifing all args
- epm: use eatmydata if installed (set EPMNOEATMYDATA for skip)
- add initial support for epm conflicts
- whatdepends/whatprovides: all use exists files as goals
- add epmsf as link to epm sf command
- epm: normalize options
- epmql (epm-filelist): add support for list files of the remote packages

* Tue Oct 08 2013 Vitaly Lipatov <lav@altlinux.ru> 1.4.2-alt1
- add initial support for guix
- rewrite epm_requires and epm_provides
- remove mandatory requires to apt-repo
- fix epm query on Gentoo (disable colorifing for grep)
- epm-query: support for short form of package name on Gentoo
- epm-query: realize is_installed via internal function (for pkg names only), speed optimize
- improve MacOS support
- epm-query: fix for query non installed packages
- epm-filelist: allow list of foreign packages
- introduce get_package_type and use it
- epm-remove: do not use --purge on apt-rpm
- epm-changelog: add support for noninstalled packages on ALT
- install: do non interactive really non interactive

* Thu Sep 05 2013 Vitaly Lipatov <lav@altlinux.ru> 1.4.1-alt1
- add initial man page file
- epm-filelist: add todo for less
- epm-search: add -- before search arg for support search "-some"
- improve whatprovides and whatdepends support

* Sun Aug 04 2013 Vitaly Lipatov <lav@altlinux.ru> 1.4.0-alt1
- query-package: make epmqp case insensitive
- epm-search: introduce grep extra args in search
- epm-search: output used grep command too
- epm-checkpkg: use erc when possible
- epm-query_package: allow grep sequence
- epm-search: try to colorize output
- add conary package manager support
- introduce epm-whatprovides

* Wed Jul 24 2013 Vitaly Lipatov <lav@altlinux.ru> 1.3.1-alt1
- epm-packages: add size sort support for rpm and dpkg
- fix epm query for non rpm/deb systems
- epm-install: rewrite pkg_(non)installed for get correct return status

* Thu Jul 11 2013 Vitaly Lipatov <lav@altlinux.ru> 1.3.0-alt1
- slackware: fix repo update, fix install pkg from file
- query, packages: print out in name-version format
- remove: add support for remove by package file
- remove: improve remove versioned packages via apt and yum

* Sat Jun 29 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.9-alt1
- fix simulate for ArchLinux and old yum
- small fixes

* Wed Jun 26 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.8-alt1
- add epmql short command for epm -ql
- autoremove: add --auto support for yum
- epm-simulate: rewrite check yum result with store_output

* Wed Jun 19 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.7-alt1
- add epmu == epm update command
- serv: fix without param checking
- serv: fixes for systemd after real use
- epm-install: fix Slackware install with sudocmd_foreach
- epm-install: do not fall to hi level if rpm is already installed

* Tue Apr 30 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.6-alt1
- epm Install: do package base update only if really need install something

* Thu Mar 21 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.5-alt1
- distr_info: add more correct support for Gentoo
- epm-install: add check for zypper's --no-gpg-checks
- epm-install: more strong installed status
- add Install command (update packages repo info and install package)

* Mon Mar 04 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.4-alt1
- epm-install: add support for direct install ebuild
- realize epm simulate for emerge
- fix autoremove, check, clean, etc.
- many fixes for npackd
- add epm whatdepends, provides commands

* Fri Feb 22 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.3-alt1
- add initial aura support
- epm-install: fix skip-installed for old Debian

* Wed Feb 20 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.2-alt1
- epm-checkpkg: add experimental case instead function call
- epm-simulate: accept Exiting on user Command (Fedora 17)
- epm-checkpkg: add support for check installed package integrity
- epm: do not add to pkg_files if filename has not dot (it is not package file)

* Tue Feb 19 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.1-alt1
- initial support for kernel-update
- add support ipkg on OpenWRT
- add support homebrew on MacOS
- add check for separate_installed
- small fixes

* Thu Feb 14 2013 Vitaly Lipatov <lav@altlinux.ru> 1.2.0-alt1
- epm-reinstall: fallback to install if the command is the same
- epm-install: realize already installed with is_installed for any distro
- epm-install: allow nodeps and force to pacman commands
- epm-query: optimize, use --short
- epm-simulate: fix for yum without --assumeno
- epm-packages: add short support for pacman
- epm-remove: add --nodeps support for dpkg

* Tue Feb 12 2013 Vitaly Lipatov <lav@altlinux.ru> 1.1.9-alt1
- fix install with dpkg
- add initial release-upgrade command
- add more pacman commands
- epm-packages: add --short support for dpkg and rpm
- add cerv alias for serv support

* Mon Feb 11 2013 Vitaly Lipatov <lav@altlinux.ru> 1.1.8-alt1
- add epm programs command (lists installed programs, detected by desktop files)
- add initial support for short output (just package name, without version-release)
- add short commands epmqi epmcl
- small fixes

* Tue Feb 05 2013 Vitaly Lipatov <lav@altlinux.ru> 1.1.7-alt1
- epm-install: user --force-confold for dpkg/apt on Debian/Ubunti in auto mode
- epm-autoremove: use apt-get autoremove
- serv-status: fix systemd support
- epm-simulate: skip simulate if zypper does not have --dry-run
- epm-install: try install with rpm before zypper use
- epm-install: fall to standalone apt install for fix deps

* Sat Feb 02 2013 Vitaly Lipatov <lav@altlinux.ru> 1.1.6-alt1
- epm-install: fix fallback from low level to hi level install
- serv: add support for FORCESERVICE
- add initial support for DNF package manager
- add epm Upgrade command (epm update && upgrade)

* Tue Jan 29 2013 Vitaly Lipatov <lav@altlinux.ru> 1.1.5-alt1
- serv: add systemd detect
- fix check for empty args
- epm-install: with --nodeps do not fallback on apt-get during install from file

* Tue Jan 01 2013 Vitaly Lipatov <lav@altlinux.ru> 1.1.4-alt1
- fix broken autoremove: rename epm-autoclean to epm-autoremove

* Thu Dec 27 2012 Vitaly Lipatov <lav@altlinux.ru> 1.1.3-alt1
- add initial deepsolver support
- checkpkg: print checking details, add 7z and rar support

* Thu Dec 13 2012 Vitaly Lipatov <lav@altlinux.ru> 1.1.2-alt1
- serv: allow additional params for start, stop and try_restart
- spec: replace @VERSION@ in serv too
- add print our commands to bash completion, to print usage

* Mon Dec 10 2012 Vitaly Lipatov <lav@altlinux.ru> 1.1.1-alt1
- serv: add usage command
- add README
- add initial bash_completion

* Mon Dec 10 2012 Vitaly Lipatov <lav@altlinux.ru> 1.1.0-alt3
- change license to AFGPLv3

* Sun Dec 09 2012 Vitaly Lipatov <lav@altlinux.ru> 1.1.0-alt2
- fix install links

* Sat Dec 08 2012 Vitaly Lipatov <lav@altlinux.ru> 1.1.0-alt1
- move included script to /usr/share/eepm
- introduce serv command for system services management
- add pack_in_onefile.sh: pack scripts on one file

* Sat Dec 08 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.7-alt1
- add epmq command as alias to epm -q (epm query)
- epm: rearrange command help
- epm-remove: warning about no support remove by package file

* Sat Nov 24 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.6-alt1
- epm: add changelog (cl) command
- add support for work without tput, with uncompat tput, allow USETTY=0 for disable tput use
- epm: write verbose output to stderr
- epm-filelist: add support for filelist of file package
- epm-query: add support for query file package
- epm-info: rewrite for support low level and hi level package info
- epm-simulate: return 0 if all needed packages are already installed

* Mon Oct 29 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.5-alt1
- epm-simulate: fix for non numeric version on Slackware (libjpeg-v8a)
- epm: intoduce autoremove command
- epm-search_file: do not use less
- epm-query_file: query package for every full path, not only last

* Fri Oct 26 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.4-alt1
- epm-simulate: fix simulate for yum
- epm-simulate: realize simulate for slackware
- epm-search: fix search for multiple packages in slackware
- epm-query: fix query for multiple names
- epm-query_file: more clean output on Slackware
- epm-simulate: print out result of the check

* Mon Oct 22 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.3-alt1
- rewrite set_sudo, skip SUDO if env. var EPMNOSUDO is not empty
- add initial support for window package manager Chocolatey
- add initial support for windows package manager Npackd
- epm-filelist: print package file list for slackware
- epm-query_file: add slackware support (thanks, bormant)
- distr_info: grep version from /etc/slackware-version  (thanks, bormant)
- set_sudo: print fatal error if needed absent sudo
- use full path to slackpkg/installpkg/removepkg on Slackware (thanks, bormant)
- epm-remove: add support for --show-command-only (thanks, bormant)
- epm-repolist: fix grep source list (thanks, bormant)

* Tue Sep 18 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.2-alt1
- replace all docmd $SUDO with sudocmd call
- fix install package rpm-build-altlinux-compat via package fullname

* Tue Sep 18 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.1-alt1
- epm: add --force support for install
- drop extra dependencies
- introduce epm requires|deplist
- install: yum local install is obsoleted, use just yum install

* Fri Aug 17 2012 Vitaly Lipatov <lav@altlinux.ru> 1.0.0-alt1
- release 1.0
- upgrade: add support for additional options
- filelist: add error for non installed packages
- use apt-repo on ALT Linux for repo manipulation
- repolist: print url on mandriva

* Tue Aug 07 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.7-alt1
- epm: fix use epm_packages
- simulate: return 2 if have no work
- install: support --auto for install files too
- install: run pacman for files with --noconfirm

* Mon Aug 06 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.6-alt1
- query: default realization via epm package list
- simulate: it is ok to run with empty list
- query_file: try search in global base if failed in installed
- search_file: realize search_file on ALT Linux via grep local contents_index
- remove: allow fallback to next level if target does not supported
- install files: allow fallback to hilevel install, add urpm support

* Sat Aug 04 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.5-alt1
- epm-install: add show-command-only support
- epm: update commands variations
- query_file: make output from dpkg like rpm -q
- epm-packages: allow filter list packages by one name

* Fri Aug 03 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.4-alt1
- add query package (-qp) support
- print command example in stderr
- add eepm link
- epm-info: try print info for installed package
- fix slackpkg install/reinstall/remove/simulate

* Thu Aug 02 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.3-alt1
- use slackpkg instead pkgtool for Slackware package manager name
- add missed command for Gentoo, Slackware, FreeBSD improve repo management commands
- fix using local with dash
- add --nodeps support for rpm in install/remove

* Wed Aug 01 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.2-alt1
- remove: try remove via low level command first
- install: drop DISTRNAME using
- add Slackware and add more distr in search

* Sat Jul 28 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9.1-alt1
- epm-simulate: add support for --skip-installed
- add more distr in epm -i, epm -e and add some bugs in epm -e
- add initial Slackware support (pkgtool)

* Fri Jul 27 2012 Vitaly Lipatov <lav@altlinux.ru> 0.9-alt1
- epm: add --nodeps options recognize
- add showcmd in addition to docmd
- add ArchLinux support (pacman) to all commands

* Fri Jul 27 2012 Vitaly Lipatov <lav@altlinux.ru> 0.8-alt1
- rename package to eepm
- add upm alias
- epm info fix: on apt, add: on yum
- add some Gentoo support, add some commands

* Thu Jul 26 2012 Vitaly Lipatov <lav@altlinux.ru> 0.7-alt1
- add commands: addrepo, removerepo, search_file, info, update some other
- epm: fill epm_cmd only one time
- epm: fix pkg_files, pkg_names fills
- epm-search: fix search on Mandriva
- search: rewrite with PMTYPE using
- add fix behaviour to check command

* Sun Jul 22 2012 Vitaly Lipatov <lav@altlinux.ru> 0.6-alt1
- add --skip-installed for skip aready installed packages
- epm-install: fix return status
- epm: fix commands, add missed checkpkg
- install/reinstall: try use rpm for files
- use PMTYPE and SUDO

* Sat Jul 21 2012 Vitaly Lipatov <lav@altlinux.ru> 0.5-alt1
- add quiet mode (no print commands before run)
- add color support for output
- add reinstall, fix epm -ql
- epm: get commands and options description from the code
- rewrite query_file, port rpmqf

* Fri Jul 20 2012 Vitaly Lipatov <lav@altlinux.ru> 0.4-alt1
- update TODO
- add check and repolist commands
- improve command description and add more commands
- docmd: use # under root account
- add print version

* Thu Jul 19 2012 Vitaly Lipatov <lav@altlinux.ru> 0.3-alt1
- add 'epm -ql, epm dist-upgrade'
- fix epm -qa, epm -qf, epm -s, epm -q
- add epm-packages
- epm-install full rewrite
- epm: improve help and add non interactive mode support

* Thu Jul 19 2012 Vitaly Lipatov <lav@altlinux.ru> 0.2-alt1
- cleanup spec, fix autorequires
- add distr_info (renamed distr_vendor)
- rewrite install, simulate, checkpkg

* Wed Jul 18 2012 Vitaly Lipatov <lav@altlinux.ru> 0.1-alt1
- initial build for ALT Linux Sisyphus
