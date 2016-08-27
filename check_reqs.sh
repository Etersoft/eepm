#!/bin/sh
/usr/lib/rpm/shell.req bin/epm-* | sort -u | tee ./check_eepm.log
git diff ./check_eepm.log
