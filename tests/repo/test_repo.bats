#!/usr/bin/env bats
# Tests for epm repo commands

load helpers

setup() {
    setup_test_root
}

teardown() {
    teardown_test_root
}

# ============ repo list ============

@test "repo list: empty sources.list returns empty" {
    touch "$TEST_ROOT/etc/apt/sources.list"
    run run_epm --quiet repo list
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "repo list: shows active repos" {
    use_fixture sources.list.basic
    run run_epm --quiet repo list
    [ "$status" -eq 0 ]
    [[ "$output" == *"ftp.basealt.ru"* ]]
}

@test "repo list: hides commented repos by default" {
    use_fixture sources.list.commented
    run run_epm --quiet repo list
    [ "$status" -eq 0 ]
    [[ "$output" == *"ftp.basealt.ru"* ]]
    [[ "$output" != *"mirror.yandex.ru"* ]]
}

@test "repo list --all: shows commented repos" {
    use_fixture sources.list.commented
    run run_epm --quiet repo list --all
    [ "$status" -eq 0 ]
    [[ "$output" == *"ftp.basealt.ru"* ]]
    [[ "$output" == *"mirror.yandex.ru"* ]]
}

@test "repo list --disabled: shows only commented repos" {
    use_fixture sources.list.commented
    run run_epm --quiet repo list --disabled
    [ "$status" -eq 0 ]
    [[ "$output" != *"ftp.basealt.ru"* ]]
    [[ "$output" == *"mirror.yandex.ru"* ]]
}

@test "repo list: combines sources.list and sources.list.d" {
    use_fixture sources.list.basic
    use_fixture_d task.list
    run run_epm --quiet repo list
    [ "$status" -eq 0 ]
    [[ "$output" == *"ftp.basealt.ru"* ]]
    [[ "$output" == *"tasks/123456"* ]]
}

# ============ repo disable ============

@test "repo disable: comments active repo" {
    use_fixture sources.list.basic
    run_epm repo disable ftp.basealt.ru
    repo_commented "ftp.basealt.ru"
}

@test "repo disable: idempotent when repeated" {
    use_fixture sources.list.basic
    run_epm repo disable ftp.basealt.ru
    local after_first=$(cat "$TEST_ROOT/etc/apt/sources.list")
    run_epm repo disable ftp.basealt.ru 2>/dev/null || true
    local after_second=$(cat "$TEST_ROOT/etc/apt/sources.list")
    [ "$after_first" = "$after_second" ]
}

# ============ repo enable ============

@test "repo enable: uncomments disabled repo" {
    use_fixture sources.list.commented
    run_epm repo enable mirror.yandex.ru
    repo_exists "rpm [alt] http://mirror.yandex.ru"
}

@test "repo enable: returns error when nothing to enable" {
    use_fixture sources.list.basic
    run run_epm repo enable nonexistent
    [ "$status" -ne 0 ]
}

# ============ multi-pattern filtering (AND logic) ============

@test "repo disable: AND logic with multiple patterns" {
    use_fixture sources.list.mixed
    # disable only x86_64 basealt repo (not noarch)
    run_epm repo disable ftp.basealt.ru x86_64
    repo_commented "ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64"
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch"
}

@test "repo disable: exclusion with ~pattern" {
    use_fixture sources.list.mixed
    # disable all basealt except noarch
    run_epm repo disable ftp.basealt.ru ~noarch
    repo_commented "ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64"
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch"
}

@test "repo list: OR pattern (a|b)" {
    use_fixture sources.list.mixed
    run run_epm --quiet repo list '(x86_64|noarch)'
    [ "$status" -eq 0 ]
    # should match both x86_64 and noarch repos
    [[ "$output" == *"x86_64"* ]]
    [[ "$output" == *"noarch"* ]]
}

@test "repo list: [abc] character class" {
    use_fixture sources.list.basic
    run run_epm --quiet repo list '[xn]'
    [ "$status" -eq 0 ]
    # [xn] should match x86_64 or noarch
    [[ "$output" == *"x86_64"* ]] || [[ "$output" == *"noarch"* ]]
}

@test "repo list: escaped \\[\\] for literal brackets" {
    use_fixture sources.list.basic
    run run_epm --quiet repo list '\[alt\]'
    [ "$status" -eq 0 ]
    # should find [alt] in sources
    [[ "$output" == *"[alt]"* ]]
}

# ============ repo add ============

@test "repo add: single RPM repo line is added" {
    touch "$TEST_ROOT/etc/apt/sources.list"
    run_epm repo add "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch classic"
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch classic"
}

@test "repo add: doesn't add duplicate repos" {
    touch "$TEST_ROOT/etc/apt/sources.list"
    run_epm repo add "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64 classic"
    run_epm repo add "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64 classic"
    # Count occurrences - should be exactly 1, not 2
    count=$(grep -c "^rpm \[alt\] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64 classic" "$TEST_ROOT/etc/apt/sources.list" 2>/dev/null || echo 0)
    [ "$count" -eq 1 ]
}

@test "repo add: handles brackets in repo URLs correctly (no regex interpretation)" {
    touch "$TEST_ROOT/etc/apt/sources.list"
    # Add first arch
    run_epm repo add "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch classic"
    # Add second arch - should not be skipped due to [alt] being interpreted as regex
    run_epm repo add "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64 classic"
    # Both should exist
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch classic"
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64 classic"
}

# ============ addrepo sisyphus ============

@test "addrepo sisyphus: adds all three architectures" {
    touch "$TEST_ROOT/etc/apt/sources.list"
    run_epm addrepo sisyphus
    # Should add exactly 3 lines (noarch, x86_64, x86_64-i586)
    local count=$(grep -c "^rpm \[alt\] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/" "$TEST_ROOT/etc/apt/sources.list" 2>/dev/null || echo 0)
    [ "$count" -eq 3 ]
    # Check each architecture
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/noarch classic"
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64 classic"
    repo_exists "rpm [alt] http://ftp.basealt.ru/pub/distributions ALTLinux/Sisyphus/x86_64-i586 classic"
}
