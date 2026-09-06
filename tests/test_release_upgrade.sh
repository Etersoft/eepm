#!/bin/bash
# Exercise release switching with isolated repository files and mocked package operations.
set -e
SHAREDIR="$(cd "$(dirname "$0")/../bin" && pwd)"
CONFIGDIR="$(cd "$SHAREDIR/../etc" && pwd)"
TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT
mkdir -p "$TESTDIR/macros.d"
APT_ALL_SOURCES_LIST="$TESTDIR/sources.list"
load_helper() { :; }
fatal() { echo "FATAL: $*" >&2; exit 1; }
info() { :; }
warning() { :; }
confirm_info() { :; }
assure_root() { :; }
regexp_subst() { sed -E -i "$1" "$2"; }
. "$SHAREDIR/epm-repomirrors"
. "$SHAREDIR/epm-repochange"
# Redirect all hardcoded RPM macro paths, including those in the upgrade flow.
for helper in epm-repofix ; do
    sed "s|/etc/rpm/macros.d|$TESTDIR/macros.d|g" "$SHAREDIR/$helper" > "$TESTDIR/$helper"
    . "$TESTDIR/$helper"
done
__alt_repofix() { __alt_replace_sign_name '[alt]'; }
write_repo() { echo "rpm [p11] https://mirror.yandex.ru/altlinux${REPO_SEPARATOR:- }$1/x86_64 classic" > "$APT_ALL_SOURCES_LIST"; }
epm()
{
    [ "$1" != --quiet ] || shift
    case "$*" in
        'repo list') cat "$APT_ALL_SOURCES_LIST" ;;
        'repo change etersoft')
            __ALT_MIRROR_DB=''
            local pattern
            pattern="$(__alt_mirror_change_pattern etersoft)"
            __subst_with_repo_url "$(cat "$APT_ALL_SOURCES_LIST")" "$pattern" > "$TESTDIR/changed"
            mv "$TESTDIR/changed" "$APT_ALL_SOURCES_LIST"
            ;;
        'installed apt-conf-branch'|'installed apt-conf-deferred') return 0 ;;
        installed*|query*|qf*) return 1 ;;
        install*|upgrade)
            # Simulate apt-conf-sisyphus replacing repositories during a transaction.
            if [ "${SIMULATE_OVERWRITE:-}" = yes ]; then write_repo Sisyphus; fi
            ;;
        *downgrade)
            if [ "${EXPECT_DEFERRED:-}" = yes ]; then assert_deferred; fi
            ;;
    esac
    return 0
}
assert_deferred()
{
    grep -q 'https://download.etersoft.ru/pub Etersoft/Sisyphus/Deferred/x86_64 classic' "$APT_ALL_SOURCES_LIST" || fatal 'Deferred URL missing'
    ! grep -q 'ALTLinux/Sisyphus\|altlinux Sisyphus' "$APT_ALL_SOURCES_LIST" || fatal 'Sisyphus repo remains'
}
for REPO_SEPARATOR in " " / ; do
for branch in p10/branch p11/branch Sisyphus ; do
    write_repo "$branch"
    epm_reposwitch Deferred >/dev/null || fatal "Switch failed"
    assert_deferred
    epm_reposwitch deferred >/dev/null || fatal "Switch failed"
    assert_deferred
    grep -qx '%_priority_distbranch sisyphus' "$TESTDIR/macros.d/priority_distbranch"
    epm_reposwitch p11 >/dev/null || fatal "Switch failed"
    grep -q 'ALTLinux/p11/branch/x86_64' "$APT_ALL_SOURCES_LIST"
done
done
echo 'All Deferred repository switching tests passed.'
