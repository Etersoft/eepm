#!/usr/bin/env bats
# Unit tests for epm-sh-altlinux

load helpers

setup() {
    load_epm_sh_altlinux
}

# ============ is_taskarg (single arg) ============

@test "is_taskarg: plain number" {
    run is_taskarg 123456
    [ "$status" -eq 0 ]
}

@test "is_taskarg: number with hash" {
    run is_taskarg "#123456"
    [ "$status" -eq 0 ]
}

@test "is_taskarg: number with space and hash" {
    run is_taskarg " #123456"
    [ "$status" -eq 0 ]
}

@test "is_taskarg: number/package" {
    run is_taskarg 123456/foo
    [ "$status" -eq 0 ]
}

@test "is_taskarg: task/number" {
    run is_taskarg task/123456
    [ "$status" -eq 0 ]
}

@test "is_taskarg: task/number/package" {
    run is_taskarg task/123456/foo
    [ "$status" -eq 0 ]
}

@test "is_taskarg: not a task (package name)" {
    run is_taskarg packagename
    [ "$status" -eq 1 ]
}

@test "is_taskarg: not a task (foo/bar)" {
    run is_taskarg foo/bar
    [ "$status" -eq 1 ]
}

@test "is_taskarg: empty" {
    run is_taskarg ""
    [ "$status" -eq 1 ]
}

# ============ is_taskarg (multiple args) ============

@test "is_taskarg: multiple args, one valid" {
    run is_taskarg foo 123456 bar
    [ "$status" -eq 0 ]
}

@test "is_taskarg: multiple args, none valid" {
    run is_taskarg foo bar baz
    [ "$status" -eq 1 ]
}

@test "is_taskarg: multiple args, hash format valid" {
    run is_taskarg foo "#123456" bar
    [ "$status" -eq 0 ]
}

# ============ get_tasknumber_from_arg ============

@test "get_tasknumber_from_arg: plain number" {
    result=$(get_tasknumber_from_arg 123456)
    [ "$result" = "123456" ]
}

@test "get_tasknumber_from_arg: number with hash" {
    result=$(get_tasknumber_from_arg "#123456")
    [ "$result" = "123456" ]
}

@test "get_tasknumber_from_arg: number with space and hash" {
    result=$(get_tasknumber_from_arg " #123456")
    [ "$result" = "123456" ]
}

@test "get_tasknumber_from_arg: number/package" {
    result=$(get_tasknumber_from_arg 123456/foo)
    [ "$result" = "123456" ]
}

@test "get_tasknumber_from_arg: task/number" {
    result=$(get_tasknumber_from_arg task/123456)
    [ "$result" = "123456" ]
}

@test "get_tasknumber_from_arg: task/number/package" {
    result=$(get_tasknumber_from_arg task/123456/foo)
    [ "$result" = "123456" ]
}

@test "get_tasknumber_from_arg: not a number returns empty" {
    run get_tasknumber_from_arg notanumber
    [ -z "$output" ]
}

@test "get_tasknumber_from_arg: package/subpackage returns empty" {
    run get_tasknumber_from_arg foo/bar
    [ -z "$output" ]
}

# ============ get_pkgname_from_taskarg ============

@test "get_pkgname_from_taskarg: number/package" {
    result=$(get_pkgname_from_taskarg 123456/foo)
    [ "$result" = "foo" ]
}

@test "get_pkgname_from_taskarg: task/number/package" {
    result=$(get_pkgname_from_taskarg task/123456/bar)
    [ "$result" = "bar" ]
}

@test "get_pkgname_from_taskarg: plain number returns empty" {
    result=$(get_pkgname_from_taskarg 123456)
    [ -z "$result" ]
}

@test "get_pkgname_from_taskarg: task/number returns empty" {
    result=$(get_pkgname_from_taskarg task/123456)
    [ -z "$result" ]
}

@test "get_pkgname_from_taskarg: non-task path returns empty" {
    result=$(get_pkgname_from_taskarg foo/bar)
    [ -z "$result" ]
}
