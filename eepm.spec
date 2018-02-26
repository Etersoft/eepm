Name: eepm
Version: 2.4.6
Release: alt1

Summary: Etersoft EPM package manager

License: AGPLv3
Group: System/Configuration/Packaging
Url: http://wiki.etersoft.ru/EPM

Packager: Vitaly Lipatov <lav@altlinux.ru>

# git-clone http://git.etersoft.ru/projects/korinf/eepm.git
Source: ftp://updates.etersoft.ru/pub/Etersoft/Sisyphus/sources/tarball/%name-%version.tar

BuildArchitectures: noarch

# Contains the same command epm
Conflicts: epm

Provides: upm

%if %_vendor == "alt"
# FIXHERE: Replace with target platform package manager
Requires: apt rpm
%endif

%description
Etersoft EPM is the package manager for any platform
and any platform version. It provides
universal interface to any package manager.
Can be useful for system administrators working
with various distros.

See detailed description here: http://wiki.etersoft.ru/EPM

%prep
%setup

%install
# install to datadir and so on
# do not use uncommon makeinstall_std here
%make_install install DESTDIR=%buildroot datadir=%_datadir bindir=%_bindir mandir=%_mandir version=%version-%release
#install -m 0755 packed/epm.sh %buildroot/%_datadir/%name/epm-packed.sh
#install -m 0755 packed/serv.sh %buildroot/%_datadir/%name/serv-packed.sh

mkdir -p %buildroot%_sysconfdir/eepm/
cat <<EOF >%buildroot%_sysconfdir/eepm/eepm.conf
# EEPM config (will insource in epm shell script)
# Not known variable yet

#verbose=--verbose
#quiet==--quiet
EOF

mkdir -p %buildroot%_sysconfdir/eepm/repack.d/
cp repack.d/*.sh %buildroot%_sysconfdir/eepm/repack.d/
chmod 0755 %buildroot%_sysconfdir/eepm/repack.d/*.sh

mkdir -p %buildroot%_sysconfdir/bash_completion.d/
install -m 0644 bash_completion/serv %buildroot%_sysconfdir/bash_completion.d/serv
ln -s serv %buildroot%_sysconfdir/bash_completion.d/cerv

# shebang.req.files
chmod a+x %buildroot%_datadir/%name/{serv-,epm-}*
chmod a+x %buildroot%_datadir/%name/tools_*

%if %_vendor == "alt"
# use external eget
rm -f %buildroot%_datadir/%name/tools_eget
%endif

%files
%doc README TODO LICENSE
%dir %_sysconfdir/eepm/
%dir %_sysconfdir/eepm/repack.d/
%config(noreplace) %_sysconfdir/eepm/eepm.conf
%config(noreplace) %_sysconfdir/eepm/repack.d/*.sh
%_bindir/epm*
%_bindir/eepm
%_bindir/upm
%_bindir/serv
%_bindir/cerv
%_bindir/distr_info
%_man1dir/*
%_datadir/%name/
%_sysconfdir/bash_completion.d/serv
%_sysconfdir/bash_completion.d/cerv

%changelog
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
