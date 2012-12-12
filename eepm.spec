Name: eepm
Version: 1.1.1
Release: alt1

Summary: Etersoft EPM package manager

License: AFGPLv3
Group: System/Configuration/Packaging
Url: http://wiki.etersoft.ru/EPM

Packager: Vitaly Lipatov <lav@altlinux.ru>

# git-clone http://git.altlinux.org/people/lav/packages/epm.git
Source: ftp://updates.etersoft.ru/pub/Etersoft/Sisyphus/sources/tarball/%name-%version.tar

BuildArchitectures: noarch

# Contains the same command epm
Conflicts: epm

Provides: upm

%if %_vendor == "alt"
Requires: apt rpm apt-repo
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

%build
%__subst "s|@VERSION@|%version-%release|g" bin/epm bin/serv

%install
# install to datadir and so on
%makeinstall
./pack_in_onefile.sh
install -m 0755 *packed.sh %buildroot/%_datadir/%name/
mkdir -p %buildroot%_sysconfdir/bash_completion.d/
install -m 0644 bash_completion/serv %buildroot%_sysconfdir/bash_completion.d/serv

%files
%doc README TODO LICENSE
%_bindir/epm*
%_bindir/eepm
%_bindir/upm
%_bindir/serv
%_bindir/distr_info
%_datadir/%name/
%_sysconfdir/bash_completion.d/serv

%changelog
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
