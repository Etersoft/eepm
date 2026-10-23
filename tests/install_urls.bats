#!/usr/bin/env bats

setup() {
    load_helper() { :; }
    . "$BATS_TEST_DIRNAME/../bin/epm-download"
    PMTYPE=pacman
    PKGFORMAT=pkg.tar.zst
    get_package_type() { echo pkg.tar.zst; }
    pkg_urls='https://example.org/eepm-1-1-x86_64.pkg.tar.zst'
    pkg_names=eepm-extra
    pkg_files=/tmp/local.pkg.tar.zst
    repack=''
}

@test "pacman routes remote archives to file installation and keeps repository names" {
    __handle_pkg_urls_to_install
    [ "$pkg_names" = eepm-extra ]
    [ "$pkg_files" = '/tmp/local.pkg.tar.zst https://example.org/eepm-1-1-x86_64.pkg.tar.zst' ]
    [ -z "$pkg_urls" ]
}

@test "pacman accepts remote archives without local files" {
    pkg_files=''
    __handle_pkg_urls_to_install
    [ "$pkg_files" = 'https://example.org/eepm-1-1-x86_64.pkg.tar.zst' ]
    [ "$pkg_names" = eepm-extra ]
}

@test "dnf continues routing remote archives to package installation" {
    PMTYPE=dnf-rpm
    __use_url_install
    [ "$pkg_names" = 'eepm-extra https://example.org/eepm-1-1-x86_64.pkg.tar.zst' ]
    [ "$pkg_files" = /tmp/local.pkg.tar.zst ]
}

@test "repack still requires downloading remote archives" {
    repack=1
    run __use_url_install
    [ "$status" -eq 1 ]
}
