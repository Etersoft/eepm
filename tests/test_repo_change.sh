#!/bin/sh
# Unit tests for epm repo change / mirrors URL pattern matching
# Tests sed_escape_relaxed, __url_to_sed_pattern, __url_to_change_pattern
# and the full substitution pipeline

TESTDIR="$(mktemp -d)"
PASSED=0
FAILED=0

cleanup()
{
    rm -rf "$TESTDIR"
}
trap cleanup EXIT

assert_eq()
{
    local desc="$1"
    local expected="$2"
    local actual="$3"
    if [ "$expected" = "$actual" ] ; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
        echo "FAIL: $desc"
        echo "  expected: $expected"
        echo "  actual:   $actual"
    fi
}

# --- Load functions under test ---

SHAREDIR="$(cd "$(dirname "$0")/../bin" && pwd)"
CONFIGDIR="$(cd "$(dirname "$0")/../etc" && pwd)"

# minimal stubs
showcmd() { :; }
warning() { :; }
fatal() { echo "FATAL: $*" >&2; exit 1; }

. "$SHAREDIR/epm-sh-functions" 2>/dev/null

# source mirror functions (need __load_alt_mirror_db etc.)
# stub epm command
epm() { :; }
__load_alt_mirror_db() {
    [ -n "$__ALT_MIRROR_DB" ] && return
    local mirror_file="$CONFIGDIR/mirrors-alt.list"
    __ALT_MIRROR_DB="$(grep -v '^#' "$mirror_file" | grep -v '^$')"
    __ALT_MIRROR_DB_VISIBLE="$(sed -n '/^# Legacy/q;p' "$mirror_file" | grep -v '^#' | grep -v '^$')"
}

# source repochange functions
. "$SHAREDIR/epm-repochange" 2>/dev/null

# source repomirrors for __url_to_change_pattern
. "$SHAREDIR/epm-repomirrors" 2>/dev/null


echo "=== sed_escape_relaxed ==="

r=$(sed_escape_relaxed "rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic")
# Should match both slash and space formats
echo "rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic" | grep -q "$r"
assert_eq "relaxed matches slash format" "0" "$?"

echo "rpm [p11] http://mirror.yandex.ru/altlinux p11/branch/x86_64 classic" | grep -q "$r"
assert_eq "relaxed matches space format" "0" "$?"

echo "#rpm [p11] http://mirror.yandex.ru/altlinux p11/branch/x86_64 classic" | grep -q "^[[:space:]]*#[[:space:]]*$r"
assert_eq "relaxed matches commented space format" "0" "$?"

echo "rpm [p11] http://completely.different.ru/something classic" | grep -q "$r"
assert_eq "relaxed does NOT match different URL" "1" "$?"


echo ""
echo "=== __url_to_sed_pattern ==="

p=$(__url_to_sed_pattern "https://download.etersoft.ru/pub/ALTLinux")
assert_eq "etersoft pattern" '//download.etersoft.ru/pub\([/ ]\)ALTLinux' "$p"

p=$(__url_to_sed_pattern "https://mirror.yandex.ru/altlinux")
assert_eq "yandex pattern" '//mirror.yandex.ru\([/ ]\)altlinux' "$p"

p=$(__url_to_sed_pattern "https://mirror.cs.msu.ru/alt")
assert_eq "msu pattern" '//mirror.cs.msu.ru\([/ ]\)alt' "$p"


echo ""
echo "=== __url_to_change_pattern ==="

p=$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")
assert_eq "yandex change" '//mirror.yandex.ru\1altlinux' "$p"

p=$(__url_to_change_pattern "https://download.etersoft.ru/pub/ALTLinux")
assert_eq "etersoft change" '//download.etersoft.ru/pub\1ALTLinux' "$p"


echo ""
echo "=== sed substitution preserves separator ==="

pat=$(__url_to_sed_pattern "https://download.etersoft.ru/pub/ALTLinux")
repl=$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")

# space format: pub ALTLinux -> yandex.ru altlinux (preserves space)
r=$(echo "rpm [p11] http://download.etersoft.ru/pub ALTLinux/p11/branch/x86_64 classic" | sed -e "s|$pat|$repl|")
assert_eq "space preserved: etersoft->yandex" \
    "rpm [p11] http://mirror.yandex.ru altlinux/p11/branch/x86_64 classic" "$r"

# slash format: pub/ALTLinux -> yandex.ru/altlinux (preserves slash)
r=$(echo "rpm [p11] http://download.etersoft.ru/pub/ALTLinux/p11/branch/x86_64 classic" | sed -e "s|$pat|$repl|")
assert_eq "slash preserved: etersoft->yandex" \
    "rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic" "$r"


echo ""
echo "=== [alt] tag preserved during substitution ==="

pat=$(__url_to_sed_pattern "https://mirror.yandex.ru/altlinux")
repl=$(__url_to_change_pattern "https://download.etersoft.ru/pub/ALTLinux")

r=$(echo "rpm [alt] http://mirror.yandex.ru/altlinux/Sisyphus/x86_64 classic" | sed -e "s|$pat|$repl|")
assert_eq "[alt] preserved: yandex->etersoft" \
    "rpm [alt] http://download.etersoft.ru/pub/ALTLinux/Sisyphus/x86_64 classic" "$r"

pat=$(__url_to_sed_pattern "https://download.etersoft.ru/pub/ALTLinux")
repl=$(__url_to_change_pattern "https://mirror.cs.msu.ru/alt")

r=$(echo "rpm [alt] http://download.etersoft.ru/pub/ALTLinux/Sisyphus/x86_64 classic" | sed -e "s|$pat|$repl|")
assert_eq "[alt] preserved: etersoft->msu" \
    "rpm [alt] http://mirror.cs.msu.ru/alt/Sisyphus/x86_64 classic" "$r"


echo ""
echo "=== __subst_with_repo_url full pipeline ==="

# Test with updates.etersoft.ru (legacy mirror)
r=$(__subst_with_repo_url "rpm [p11] http://updates.etersoft.ru/pub ALTLinux/p11/branch/x86_64 classic" \
    "$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")")
assert_eq "updates.etersoft->yandex" \
    "rpm [p11] http://mirror.yandex.ru altlinux/p11/branch/x86_64 classic" "$r"

# Test with download.etersoft.ru/pub/ALTLinux (slash format)
r=$(__subst_with_repo_url "rpm [p11] http://download.etersoft.ru/pub/ALTLinux/p11/branch/x86_64 classic" \
    "$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")")
assert_eq "download.etersoft->yandex" \
    "rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic" "$r"

# Non-matching URL should not change
r=$(__subst_with_repo_url "rpm [p11] http://unknown.mirror.ru/something/p11/branch/x86_64 classic" \
    "$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")")
assert_eq "unknown mirror unchanged" \
    "rpm [p11] http://unknown.mirror.ru/something/p11/branch/x86_64 classic" "$r"


echo ""
echo "=== round-trip: etersoft -> yandex -> etersoft ==="

line="rpm [p11] http://download.etersoft.ru/pub/ALTLinux/p11/branch/x86_64 classic"

step1=$(__subst_with_repo_url "$line" "$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")")
step2=$(__subst_with_repo_url "$step1" "$(__url_to_change_pattern "https://download.etersoft.ru/pub/ALTLinux")")

assert_eq "round-trip slash format" "$line" "$step2"

line="rpm [p11] http://download.etersoft.ru/pub ALTLinux/p11/branch/x86_64 classic"

step1=$(__subst_with_repo_url "$line" "$(__url_to_change_pattern "https://mirror.yandex.ru/altlinux")")
step2=$(__subst_with_repo_url "$step1" "$(__url_to_change_pattern "https://download.etersoft.ru/pub/ALTLinux")")

assert_eq "round-trip space format" "$line" "$step2"


echo ""
echo "=== comment/uncomment with relaxed matching ==="

# Simulate: addrepo generates line with slash format, but file has space format
ADDREPO_LINE="rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic"
FILE_LINE="#rpm [p11] http://mirror.yandex.ru/altlinux p11/branch/x86_64 classic"

echo "$FILE_LINE" > "$TESTDIR/test.list"
relaxed=$(sed_escape_relaxed "$ADDREPO_LINE")
sed -i -e "s|^[[:space:]]*#[[:space:]]*\($relaxed\)|\1|" "$TESTDIR/test.list"
result=$(cat "$TESTDIR/test.list")
assert_eq "uncomment relaxed: slash matches space" \
    "rpm [p11] http://mirror.yandex.ru/altlinux p11/branch/x86_64 classic" "$result"

# Reverse: file has slash, search has space
FILE_LINE="#rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic"
SEARCH_LINE="rpm [p11] http://mirror.yandex.ru altlinux/p11/branch/x86_64 classic"

echo "$FILE_LINE" > "$TESTDIR/test.list"
relaxed=$(sed_escape_relaxed "$SEARCH_LINE")
sed -i -e "s|^[[:space:]]*#[[:space:]]*\($relaxed\)|\1|" "$TESTDIR/test.list"
result=$(cat "$TESTDIR/test.list")
assert_eq "uncomment relaxed: space matches slash" \
    "rpm [p11] http://mirror.yandex.ru/altlinux/p11/branch/x86_64 classic" "$result"


echo ""
echo "=== Deferred mirror detection ==="

# Stub __is_deferred_repo
__is_deferred_repo() { return 0; }
__ALT_MIRROR_DB=""
__ALT_MIRROR_DB_VISIBLE=""
__load_alt_mirror_db() {
    [ -n "$__ALT_MIRROR_DB" ] && return
    local mirror_file="$CONFIGDIR/mirrors-deferred.list"
    if [ -f "$mirror_file" ] ; then
        __ALT_MIRROR_DB="$(grep -v '^#' "$mirror_file" | grep -v '^$')"
        __ALT_MIRROR_DB_VISIBLE="$(sed -n '/^# Legacy/q;p' "$mirror_file" | grep -v '^#' | grep -v '^$')"
    fi
}
__load_alt_mirror_db
count=$(echo "$__ALT_MIRROR_DB_VISIBLE" | wc -l)
assert_eq "deferred has 2 visible mirrors" "2" "$count"
echo "$__ALT_MIRROR_DB_VISIBLE" | grep -q "etersoft"
assert_eq "deferred has etersoft" "0" "$?"
echo "$__ALT_MIRROR_DB_VISIBLE" | grep -q "eterfund"
assert_eq "deferred has eterfund" "0" "$?"


echo ""
echo "================================"
echo "Passed: $PASSED  Failed: $FAILED"
[ "$FAILED" = "0" ] && echo "ALL TESTS PASSED" || echo "SOME TESTS FAILED"
exit "$FAILED"
