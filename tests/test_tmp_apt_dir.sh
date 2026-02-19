#!/bin/sh
# Tests for temporary APT directory functions in epm-sh-backend
# Tests: __generate_alt_sourceslist, __setup_tmp_apt_dir, __get_system_sourceslist,
#        __generate_task_sourceslist

PASSED=0
FAILED=0

check()
{
    local desc="$1"
    local expected="$2"
    local actual="$3"
    if [ "$expected" = "$actual" ] ; then
        echo "  OK: $desc"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: $desc"
        echo "    expected: '$expected'"
        echo "    actual:   '$actual'"
        FAILED=$((FAILED + 1))
    fi
}

check_contains()
{
    local desc="$1"
    local pattern="$2"
    local actual="$3"
    if echo "$actual" | grep -qE "$pattern" ; then
        echo "  OK: $desc"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: $desc (pattern '$pattern' not found)"
        echo "    actual: $(echo "$actual" | head -5)"
        FAILED=$((FAILED + 1))
    fi
}

check_not_contains()
{
    local desc="$1"
    local pattern="$2"
    local actual="$3"
    if echo "$actual" | grep -qE "$pattern" ; then
        echo "  FAIL: $desc (pattern '$pattern' unexpectedly found)"
        echo "    actual: $(echo "$actual" | head -5)"
        FAILED=$((FAILED + 1))
    else
        echo "  OK: $desc"
        PASSED=$((PASSED + 1))
    fi
}

check_dir_exists()
{
    local desc="$1"
    local path="$2"
    if [ -d "$path" ] ; then
        echo "  OK: $desc"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: $desc (dir '$path' does not exist)"
        FAILED=$((FAILED + 1))
    fi
}

check_file_exists()
{
    local desc="$1"
    local path="$2"
    if [ -e "$path" ] ; then
        echo "  OK: $desc"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: $desc (path '$path' does not exist)"
        FAILED=$((FAILED + 1))
    fi
}

count_lines()
{
    echo "$1" | grep -c .
}

# --- Setup: load only needed functions without full epm init ---
TESTDIR="$(cd "$(dirname "$0")" && pwd)"
PROGDIR="$(cd "$TESTDIR/../bin" && pwd)"
SHAREDIR="$PROGDIR"
CONFIGDIR="$PROGDIR/../etc"

# Minimal stubs for functions used by epm-sh-backend
rhas()
{
    echo "$1" | grep -E -q -- "$2"
}

warning()
{
    echo "WARNING: $*" >&2
}

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

debug()
{
    :
}

remove_on_exit()
{
    # in tests, just remember for cleanup
    __TEST_CLEANUP="$__TEST_CLEANUP $*"
}

# Set distro variables (simulate ALT x86_64)
DISTRARCH="x86_64"
DISTRVERSION="Sisyphus"
BASEDISTRNAME="alt"
PMTYPE="apt-rpm"

# Source epm-sh-backend directly
. "$PROGDIR/epm-sh-backend"


# ============================================================
echo
echo "=== Test __generate_alt_sourceslist for branches ==="

result="$(__generate_alt_sourceslist p10)"

check_contains "p10: has basealt URL" "ftp\.basealt\.ru/pub/distributions" "$result"
check_contains "p10: has ALTLinux/p10/branch" "ALTLinux/p10/branch" "$result"
check_contains "p10: has noarch" "noarch classic" "$result"
check_contains "p10: has [p10] sign" '\[p10\]' "$result"
check_contains "p10: has x86_64 line" "x86_64 classic" "$result"
check_contains "p10: has x86_64-i586 line" "x86_64-i586 classic" "$result"
check_not_contains "p10: no archive URL" "ftp\.altlinux\.org" "$result"
check "p10: 3 lines (noarch, x86_64, x86_64-i586)" "3" "$(count_lines "$result")"

result_sis="$(__generate_alt_sourceslist Sisyphus)"

check_contains "Sisyphus: has Sisyphus path" "ALTLinux/Sisyphus/" "$result_sis"
check_contains "Sisyphus: has [alt] sign" '\[alt\]' "$result_sis"
check_not_contains "Sisyphus: no /branch path" "/branch/" "$result_sis"
check "Sisyphus: 3 lines" "3" "$(count_lines "$result_sis")"

result_c10="$(__generate_alt_sourceslist c10f2)"

check_contains "c10f2: has [cert8] sign" '\[cert8\]' "$result_c10"
check_contains "c10f2: has c10f2/branch" "c10f2/branch" "$result_c10"

# Test lowercase handling
result_sis2="$(__generate_alt_sourceslist sisyphus)"
check_contains "sisyphus (lower): has Sisyphus path" "ALTLinux/Sisyphus/" "$result_sis2"


# ============================================================
echo
echo "=== Test __generate_alt_sourceslist for archive ==="

result_arch="$(__generate_alt_sourceslist archive p10 2023/01/15)"

check_contains "archive p10: has altlinux.org URL" "ftp\.altlinux\.org/pub/distributions" "$result_arch"
check_contains "archive p10: has archive/p10/date/2023/01/15" "archive/p10/date/2023/01/15" "$result_arch"
check_contains "archive p10: has noarch" "noarch classic" "$result_arch"
check_contains "archive p10: has [p10] sign" '\[p10\]' "$result_arch"
check_contains "archive p10: has x86_64" "x86_64 classic" "$result_arch"
check_contains "archive p10: has x86_64-i586" "x86_64-i586 classic" "$result_arch"
check_not_contains "archive p10: no basealt URL" "ftp\.basealt\.ru" "$result_arch"
check "archive p10: 3 lines" "3" "$(count_lines "$result_arch")"

result_arch_sis="$(__generate_alt_sourceslist archive Sisyphus 2024/06/01)"

check_contains "archive Sisyphus: has archive/sisyphus/date" "archive/sisyphus/date/2024/06/01" "$result_arch_sis"
check_contains "archive Sisyphus: has [alt] sign" '\[alt\]' "$result_arch_sis"

# Test that branch case is preserved in path (lowered)
result_arch_P10="$(__generate_alt_sourceslist archive P10 2023/01/15)"
check_contains "archive P10: lowered to p10" "archive/p10/date/2023/01/15" "$result_arch_P10"

# Test c10f1 archive
result_arch_c10="$(__generate_alt_sourceslist archive c10f1 2024/03/20)"
check_contains "archive c10f1: has [cert8] sign" '\[cert8\]' "$result_arch_c10"
check_contains "archive c10f1: has archive/c10f1/date" "archive/c10f1/date/2024/03/20" "$result_arch_c10"


# ============================================================
echo
echo "=== Test __setup_tmp_apt_dir ==="

__setup_tmp_apt_dir

check_dir_exists "tmpdir created" "$__EPM_APT_TMPDIR"
check_dir_exists "lists/partial created" "$__EPM_APT_TMPDIR/lists/partial"
check_dir_exists "sourceparts created" "$__EPM_APT_TMPDIR/sourceparts"
check_file_exists "apt.conf created" "$__EPM_APT_TMPDIR/apt.conf"
apt_conf="$(cat "$__EPM_APT_TMPDIR/apt.conf")"
check_contains "apt.conf has sourcelist" "Dir::Etc::sourcelist" "$apt_conf"
check_contains "apt.conf has sourceparts" "Dir::Etc::sourceparts" "$apt_conf"
check_contains "apt.conf has lists dir" "Dir::State::lists" "$apt_conf"
check_contains "apt.conf has pkgcache" "Dir::Cache::pkgcache" "$apt_conf"
check_contains "apt.conf has srcpkgcache" "Dir::Cache::srcpkgcache" "$apt_conf"
check_contains "apt.conf points to tmpdir" "$__EPM_APT_TMPDIR" "$apt_conf"
check "REPO_OPTIONS uses -c" "-c $__EPM_APT_TMPDIR/apt.conf" "$__EPM_APT_REPO_OPTIONS"

# Write sources.list and verify it works
__generate_alt_sourceslist p10 > "$__EPM_APT_TMPDIR/sources.list"
check_file_exists "sources.list written to tmpdir" "$__EPM_APT_TMPDIR/sources.list"
tmpdir_content="$(cat "$__EPM_APT_TMPDIR/sources.list")"
check_contains "tmpdir sources.list has p10" "ALTLinux/p10/branch" "$tmpdir_content"

# Cleanup first tmpdir
rm -rf "$__EPM_APT_TMPDIR"

# Test that calling again creates a new directory
__setup_tmp_apt_dir
first_dir="$__EPM_APT_TMPDIR"
__setup_tmp_apt_dir
check "second call creates different dir" "1" "$([ "$first_dir" != "$__EPM_APT_TMPDIR" ] && echo 1 || echo 0)"
rm -rf "$first_dir" "$__EPM_APT_TMPDIR"


# ============================================================
echo
echo "=== Test __get_system_sourceslist ==="

if [ -r /etc/apt/sources.list ] ; then
    sys_sources="$(__get_system_sourceslist)"
    check_contains "system sources: has rpm lines" "^rpm " "$sys_sources"

    # Verify main sources.list content is included
    main_line="$(head -1 /etc/apt/sources.list)"
    if [ -n "$main_line" ] ; then
        escaped="$(echo "$main_line" | sed 's|[].[^$*+?{}()|\\]|\\&|g')"
        check_contains "system sources: includes main sources.list" "$escaped" "$sys_sources"
    fi

    # Check that sources.list.d files are included
    has_extra="$(ls /etc/apt/sources.list.d/*.list 2>/dev/null | head -1)"
    if [ -n "$has_extra" ] ; then
        extra_line="$(grep -m1 '^rpm' "$has_extra")"
        if [ -n "$extra_line" ] ; then
            escaped="$(echo "$extra_line" | sed 's|[].[^$*+?{}()|\\]|\\&|g')"
            check_contains "system sources: includes sources.list.d" "$escaped" "$sys_sources"
        fi
    fi
else
    echo "  SKIP: no /etc/apt/sources.list (not an APT system)"
fi


# ============================================================
echo
echo "=== Test __generate_task_sourceslist ==="

# Test with non-existent task — should produce empty output with warning
result_bad_task="$(__generate_task_sourceslist 999999999 2>/dev/null)"
check "non-existent task: empty result" "" "$result_bad_task"


# ============================================================
echo
echo "=== Test system repos are not modified ==="

if [ -r /etc/apt/sources.list ] ; then
    sources_before="$(md5sum /etc/apt/sources.list | cut -d' ' -f1)"
    lists_before="$(ls -la /var/lib/apt/lists/ 2>/dev/null | md5sum | cut -d' ' -f1)"

    # Run __setup_tmp_apt_dir + write sources
    __setup_tmp_apt_dir
    __generate_alt_sourceslist p10 > "$__EPM_APT_TMPDIR/sources.list"
    { __get_system_sourceslist ; echo "rpm http://example.com test noarch classic" ; } > "$__EPM_APT_TMPDIR/sources.list"

    sources_after="$(md5sum /etc/apt/sources.list | cut -d' ' -f1)"
    lists_after="$(ls -la /var/lib/apt/lists/ 2>/dev/null | md5sum | cut -d' ' -f1)"

    check "sources.list unchanged after tmpdir ops" "$sources_before" "$sources_after"
    check "/var/lib/apt/lists unchanged after tmpdir ops" "$lists_before" "$lists_after"

    # Verify tmpdir has different content from system
    tmpdir_content="$(cat "$__EPM_APT_TMPDIR/sources.list")"
    check_contains "tmpdir has extra repo line" "example\.com" "$tmpdir_content"

    rm -rf "$__EPM_APT_TMPDIR"
    __EPM_APT_TMPDIR=""
    __EPM_APT_REPO_OPTIONS=""
else
    echo "  SKIP: no /etc/apt/sources.list"
fi


# ============================================================
echo
echo "=== Test combined: branch sources.list + tmpdir structure ==="

__setup_tmp_apt_dir
__generate_alt_sourceslist archive p10 2023/01/15 > "$__EPM_APT_TMPDIR/sources.list"

# Verify complete integration
check_file_exists "archive sources.list in tmpdir" "$__EPM_APT_TMPDIR/sources.list"
content="$(cat "$__EPM_APT_TMPDIR/sources.list")"
check_contains "combined: has archive URL" "archive/p10/date/2023/01/15" "$content"
check "combined: 3 repo lines" "3" "$(count_lines "$content")"
# Verify apt.conf and REPO_OPTIONS point to this tmpdir
check_file_exists "combined: apt.conf exists" "$__EPM_APT_TMPDIR/apt.conf"
check "combined: REPO_OPTIONS is -c apt.conf" "-c $__EPM_APT_TMPDIR/apt.conf" "$__EPM_APT_REPO_OPTIONS"

rm -rf "$__EPM_APT_TMPDIR"


# ============================================================
# Cleanup
for d in $__TEST_CLEANUP ; do
    [ -e "$d" ] && rm -rf "$d"
done

echo
echo "=== Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
[ "$FAILED" -eq 0 ] && echo "All tests passed." || echo "Some tests FAILED!"
exit $FAILED
