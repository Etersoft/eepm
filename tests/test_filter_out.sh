#!/bin/sh

load_helper()
{
    . ../bin/$1
}

PMTYPE=apt-rpm

. ../bin/epm-sh-altlinux
. ../bin/epm-sh-functions
. ../bin/epm-sh-filter
. ../bin/epm-sh-install

#installlist=$(../bin/epm --short qp glusterfs6)
installlist="libglusterfs6
glusterfs6-gfevents
glusterfs6
glusterfs6-client
glusterfs6-vim
glusterfs6-rdma
glusterfs6-georeplication
libglusterfs6-api
glusterfs6-thin-arbiter
python3-module-glusterfs6
glusterfs6-server"

echo "=== Test filter_out_installed_packages ==="
echo "input: $installlist"
echo "non installed (filter_out_installed_packages):"
echo "$installlist" | (skip_installed='yes' filter_out_installed_packages)

echo ""
echo "=== Test __filter_pkglist_installed ==="
testlist="bash coreutils nonexistent-pkg-12345"
echo "input: $testlist"
echo "installed:"
echo "$testlist" | __filter_pkglist_installed

echo ""
echo "=== Test __filter_pkglist_not_installed ==="
echo "input: $testlist"
echo "not installed:"
echo "$testlist" | __filter_pkglist_not_installed

echo ""
echo "=== Test epm filter CLI ==="
echo "input: $testlist"
echo "epm filter --installed:"
../bin/epm filter --installed $testlist
echo "epm filter --not-installed:"
../bin/epm filter --not-installed $testlist
