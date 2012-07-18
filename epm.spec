Name: epm
Version: 0.1
Release: alt1

Summary: EPM — Etersoft package manager

License: GPLv2
Group: Development/Other
Url: http://wiki.etersoft.ru/EPM

Packager: Vitaly Lipatov <lav@altlinux.ru>

# git-clone http://git.altlinux.org/people/lav/packages/epm.git
Source: ftp://updates.etersoft.ru/pub/Etersoft/Sisyphus/sources/tarball/%name-%version.tar

BuildArchitectures: noarch

%description
Etersoft package manager for any platform.

%prep
%setup

%install
# install to datadir and so on
%makeinstall

%files
%doc README
%_bindir/epm*

%changelog
* Wed Jul 18 2012 Vitaly Lipatov <lav@altlinux.ru> 0.1-alt1
- initial build for ALT Linux Sisyphus
