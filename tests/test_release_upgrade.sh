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
for helper in epm-repofix epm-release_upgrade ; do
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
REPO_SEPARATOR=" "
packages="$(get_fix_release_pkg --force Deferred)"
for package in apt-conf-sisyphus apt-conf-branch- apt-conf-deferred- branding-alt-sisyphus-release alt-os-release ; do
    echo "$packages" | grep -qx "$package"
done
! echo "$packages" | grep -qx 'altlinux-release-deferred'
# Run the real upgrade orchestration; package commands never reach the host.
docmd() { "$@"; }
try_change_alt_repo() { :; }
end_change_alt_repo() { :; }
__p11_upgrade_fix() { :; }
__check_system() { :; }
SIMULATE_OVERWRITE=yes
EXPECT_DEFERRED=yes
for branch in p8 p9 p10 p11 Sisyphus Deferred ; do
    write_repo Sisyphus
    __switch_alt_to_distro "$branch" Deferred >/dev/null || fatal "Upgrade failed"
    assert_deferred
done
# Detect current repositories independently of the installed release package.
for branch in p10 p11 c10f2 ; do
    write_repo "$branch/branch"
    [ "$(__detect_alt_release_by_repo)" = "$branch" ]
done
write_repo Sisyphus
[ "$(__detect_alt_release_by_repo)" = Sisyphus ]
echo 'rpm [alt] https://download.etersoft.ru/pub Etersoft/Sisyphus/Deferred/noarch classic' > "$APT_ALL_SOURCES_LIST"
echo '  # rpm [p11] https://mirror.yandex.ru/altlinux p11/branch/x86_64 classic' >> "$APT_ALL_SOURCES_LIST"
[ "$(__detect_alt_release_by_repo)" = Deferred ]
echo 'rpm [p11] https://mirror.yandex.ru/altlinux p11/branch/x86_64 classic' >> "$APT_ALL_SOURCES_LIST"
if __detect_alt_release_by_repo >/dev/null; then fatal 'Mixed repositories must not identify a single release'; fi

# A resumed upgrade must reach the target switch before any package transaction.
# Keep the original FROM to simulate stale branding and an explicitly supplied source.
SIMULATE_OVERWRITE=''
docmd() { echo "$*" >> "$TESTDIR/steps"; }
__switch_repo_to() { echo "switch $*" >> "$TESTDIR/steps"; }
for transition in 'p11 Deferred' 'p10 Deferred' 'Deferred Deferred' 'Sisyphus Deferred' 'p10 p11' 'p9 p10' 'c10f1 c10f2' 'p8 Sisyphus' 'p9 Sisyphus' 'p10 Sisyphus' 'p11 Sisyphus' 'Deferred Sisyphus' 'Sisyphus Sisyphus' ; do
    read -r source target <<< "$transition"
    case "$target" in
        Sisyphus) write_repo Sisyphus ;;
        Deferred) echo 'rpm [alt] https://download.etersoft.ru/pub Etersoft/Sisyphus/Deferred/x86_64 classic' > "$APT_ALL_SOURCES_LIST" ;;
        *) write_repo "$target/branch" ;;
    esac
    : > "$TESTDIR/steps"
    __switch_alt_to_distro "$source" "$target" || fatal 'Resume failed'
    [ "$(head -n1 "$TESTDIR/steps")" = "switch $target" ] || fatal "Old repository preparation ran for $transition"
    grep -q '^epm .*upgrade$' "$TESTDIR/steps" || fatal 'Target upgrade was skipped'
done
# A fresh transition still prepares the old repository before switching.
write_repo p11/branch
: > "$TESTDIR/steps"
__switch_alt_to_distro p11 Deferred || fatal 'Fresh upgrade failed'
[ "$(head -n1 "$TESTDIR/steps")" = 'epm upgrade' ] || fatal 'Fresh upgrade preparation was skipped'
grep -q '^switch Deferred$' "$TESTDIR/steps"

# A fresh Sisyphus transition still upgrades from the source repository first.
for source in p8 p9 p10 p11 Deferred ; do
    if [ "$source" = Deferred ] ; then
        echo 'rpm [alt] https://download.etersoft.ru/pub Etersoft/Sisyphus/Deferred/x86_64 classic' > "$APT_ALL_SOURCES_LIST"
    else
        write_repo "$source/branch"
    fi
    : > "$TESTDIR/steps"
    __switch_alt_to_distro "$source" Sisyphus || fatal 'Fresh Sisyphus upgrade failed'
    sed '/^switch Sisyphus$/q' "$TESTDIR/steps" | grep -qx 'epm upgrade' || fatal 'Source upgrade was skipped'
    grep -qx 'switch Sisyphus' "$TESTDIR/steps"
done

# Verify the public command dispatch accepts the lowercase spelling.
assure_safe_run() { :; }
__alt_repofix() { :; }
__switch_alt_to_distro() { [ "$1 $2" = "p11 $expected_target" ] || fatal 'Wrong upgrade target'; }
BASEDISTRNAME=alt
DISTRVERSION=p11
for expected_target in Deferred Sisyphus ; do
    DISTRVERSION=p11
    write_repo p11/branch
    target_arg="$(echo "$expected_target" | tr '[:upper:]' '[:lower:]')"
    epm_release_upgrade "$target_arg" >/dev/null || fatal "Dispatch failed"
done
echo 'All release-upgrade Deferred and Sisyphus tests passed.'
