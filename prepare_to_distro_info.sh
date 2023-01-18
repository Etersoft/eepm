#!/bin/sh
# tac 2  | grep "^commit " | sed -e "s|^commit ||g" -e "s| .*||" > 2.2.log
# sed -i -e "s|distr_info|distro_info|" 0001-*
# for i in $(cat 2.3.list) ; do git am $i ; done
