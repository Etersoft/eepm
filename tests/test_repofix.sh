#!/bin/sh

# test func
regexp_subst()
{
	echo "regexp_subst: $*"
	local expression="$1"
	shift
        cp -f "$1" "$1.tmp"
	sed -i -r -e "$expression" "$1.tmp"
	diff -u "$1" "$1.tmp" || echo "NO CHANGES!"
	rm -f "$1.tmp"
}

__replace_text_in_alt_repo()
{
	local i
	for i in test_repofix.sources.list ; do
		[ -s "$i" ] || continue
		regexp_subst "$1" "$i"
	done
}

# TODO drop updates using
__alt_repofix()
{
	local TO="$1"
	__replace_text_in_alt_repo "/^ *#/! s!\[updates\]![$TO]!g"
	__replace_text_in_alt_repo "/^ *#/! s!\[[tpc][6-9]\]![$TO]!g"
}

echo 
echo "=== to p9"
__alt_repofix p9
echo
echo "=== to Sisyphus"
__alt_repofix alt
