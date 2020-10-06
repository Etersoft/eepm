#!/bin/sh

load_helper()
{
    . ../bin/$1
}

PMTYPE=apt-rpm

. ../bin/epm-sh-altlinux
. ../bin/epm-sh-functions
. ../bin/epm-install

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
echo "installed: $installlist"
echo "non installed:"
echo "$installlist" | (skip_installed='yes' filter_out_installed_packages)
#echo "$installlist" | __fast_hack_for_filter_out_installed_rpm
