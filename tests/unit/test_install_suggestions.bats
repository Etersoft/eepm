#!/usr/bin/env bats

load helpers

setup() {
    load_helper() { :; }
    source "$EPM_DIR/bin/epm-install"

    epm() {
        [ "$1" = status ] || return 1
        [ "$2" = --valid ] || return 1
        [ "$3" = present ]
    }
}

@test "suggestions are offered only when a requested package is absent" {
    run __epm_check_packages_not_found present missing

    [ "$status" -eq 0 ]
}

@test "broken dependencies do not make an existing package look absent" {
    run __epm_check_packages_not_found present

    [ "$status" -eq 1 ]
}
