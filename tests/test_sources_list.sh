#!/bin/sh

. ../bin/epm-repofix

#__fix_apt_sources_list
perl -pe "$SUBST_ALT_RULE" <test_sources.list >test_sources.list.out

#echo "Fixes:"
#diff -u test_sources.list test_sources.list.out

echo "==========="
echo "Diffs:"
diff -u test_sources.list.reference test_sources.list.out && echo DONE
