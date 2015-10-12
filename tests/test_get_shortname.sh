#!/bin/sh

check()
{
	[ "$2" != "$3" ] && echo "FATAL with '$1': result '$3' do not match with '$2'" || echo "OK for '$1' with '$2'"
}

check_file()
{
	check "$1" "$2" $(../bin/epm print name from filename "$1")
}

check_pkgfile()
{
	check "$1" "$2" $(../bin/epm print pkgname from filename "$1")
}


check_pkg()
{
	check "$1" "$2" $(../bin/epm print name "$1")
}

echo "check_file"
check_file pkg-source-1.0.src.rpm pkg-source
check_file pkg-source_1.0.src.rpm pkg-source
check_file pkg-source[-_]1.0.src.rpm pkg-source
check_file pkg-source*.src.rpm pkg-source
check_file pkg-source-1.0-2.0*.src.rpm pkg-source-1.0
check_file pkg-source-1.0_2.0*.src.rpm pkg-source-1.0
check_file libpq5.2-9.0eter-9.0.4-alt14.i586.rpm libpq5.2-9.0eter
check_file bison_2.7.1.dfsg-1_i386.deb bison
check_file postgre-etersoft9.0_9.0.4-eter14ubuntu_i386.deb postgre-etersoft9.0
check_file libpq5.2-9.0eter-9.0.4-alt14.i586.rpm libpq5.2-9.0eter

echo
echo "check_pkgfile"
check_pkgfile libpq5.2-9.0eter-9.0.4-alt14.i586.rpm libpq5.2-9.0eter-9.0.4-alt14
check_pkgfile bison_2.7.1.dfsg-1_i386.deb bison-2.7.1.dfsg-1
check_pkgfile postgre-etersoft9.0_9.0.4-eter14ubuntu_i386.deb postgre-etersoft9.0-9.0.4-eter14ubuntu
check_pkgfile libpq5.2-9.0eter-9.0.4-alt14.i586.rpm libpq5.2-9.0eter-9.0.4-alt14

echo
echo "check_pkg"
check_pkg pkg-source-1.0 pkg-source
check_pkg pkg-source_1.0 pkg-source
check_pkg pkg-source[-_]1.0 pkg-source
check_pkg pkg-source* pkg-source
check_pkg pkg-source-1.0-2.0 pkg-source-1.0
check_pkg pkg-source-1.0_2.0 pkg-source-1.0
check_pkg libpq5.2-9.0eter-9.0.4-alt14 libpq5.2-9.0eter
check_pkg libpjlib-util2-2.1.0.0.ast20130823-1 libpjlib-util2
check_pkg rpm-build-python-tools-0.36.2-alt1 rpm-build-python-tools
check_pkg saxon9-B.9.0.0.8-alt2 saxon9
check_pkg rootfiles-alt-alt11 rootfiles
check_pkg git-bzr-1.1_48_g61d6007-alt1.1 git-bzr
check_pkg liblz4-r127-alt1.svn20141224 liblz4
check_pkg libijs-0.35_9.15-alt1 libijs

echo
echo "check_pkg"
check_pkg pkg-1.0.spec pkg
check_pkg pkg-source-1.0.spec pkg-source
check_pkg pkg-source-less-1.0.spec pkg-source-less
check_pkg pkg123-1.0.spec pkg123
check_pkg pkg123[_-]1.0.spec pkg123
check_pkg pkg*.spec pkg
