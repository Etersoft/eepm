Name: epm
Version: 0.2
Release: alt1

Summary: EPM package manager

License: GPLv2
Group: System/Configuration/Packaging
Url: http://wiki.etersoft.ru/EPM

Packager: Vitaly Lipatov <lav@altlinux.ru>

# git-clone http://git.altlinux.org/people/lav/packages/epm.git
Source: ftp://updates.etersoft.ru/pub/Etersoft/Sisyphus/sources/tarball/%name-%version.tar

BuildArchitectures: noarch

%description
EPM is the package manager for any platform
and any platform version. It provides
universal interface to any package manager.

%prep
%setup

%install
# install to datadir and so on
%makeinstall

%files
%doc README TODO
%_bindir/epm*
%_bindir/distr_info

%changelog
* Thu Jul 19 2012 Vitaly Lipatov <lav@altlinux.ru> 0.2-alt1
- cleanup spec, fix autorequires
- add distr_info (renamed distr_vendor)
- rewrite install, simulate, checkpkg

* Wed Jul 18 2012 Vitaly Lipatov <lav@altlinux.ru> 0.1-alt1
- initial build for ALT Linux Sisyphus
