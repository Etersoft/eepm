#!/usr/bin/env bats
# Unit tests for epm-sh-functions

load helpers

setup() {
    load_epm_sh_functions
}

# ============ isnumber ============

@test "isnumber: positive number" {
    run isnumber 123
    [ "$status" -eq 0 ]
}

@test "isnumber: zero" {
    run isnumber 0
    [ "$status" -eq 0 ]
}

@test "isnumber: negative number" {
    run isnumber -123
    [ "$status" -eq 1 ]
}

@test "isnumber: string" {
    run isnumber abc
    [ "$status" -eq 1 ]
}

@test "isnumber: mixed" {
    run isnumber 123abc
    [ "$status" -eq 1 ]
}

@test "isnumber: empty" {
    run isnumber ""
    [ "$status" -eq 1 ]
}

# ============ rhas ============

@test "rhas: string contains pattern" {
    run rhas "hello world" "wor"
    [ "$status" -eq 0 ]
}

@test "rhas: string does not contain pattern" {
    run rhas "hello world" "xyz"
    [ "$status" -eq 1 ]
}

@test "rhas: regex pattern" {
    run rhas "hello123" "[0-9]+"
    [ "$status" -eq 0 ]
}

@test "rhas: empty string" {
    run rhas "" "abc"
    [ "$status" -eq 1 ]
}

# ============ rihas (case-insensitive) ============

@test "rihas: case insensitive match" {
    run rihas "Hello World" "WORLD"
    [ "$status" -eq 0 ]
}

@test "rihas: no match" {
    run rihas "hello" "XYZ"
    [ "$status" -eq 1 ]
}

# ============ startwith ============

@test "startwith: string starts with prefix" {
    run startwith "hello world" "hello"
    [ "$status" -eq 0 ]
}

@test "startwith: string does not start with prefix" {
    run startwith "hello world" "world"
    [ "$status" -eq 1 ]
}

@test "startwith: empty prefix" {
    run startwith "hello" ""
    [ "$status" -eq 0 ]
}

# ============ is_abs_path ============

@test "is_abs_path: absolute path" {
    run is_abs_path "/usr/bin"
    [ "$status" -eq 0 ]
}

@test "is_abs_path: relative path" {
    run is_abs_path "usr/bin"
    [ "$status" -eq 1 ]
}

@test "is_abs_path: dot path" {
    run is_abs_path "./bin"
    [ "$status" -eq 1 ]
}

@test "is_abs_path: root" {
    run is_abs_path "/"
    [ "$status" -eq 0 ]
}

# ============ is_dirpath ============

@test "is_dirpath: absolute path" {
    # is_dirpath checks if path starts with / or equals "."
    run is_dirpath "/usr/bin"
    [ "$status" -eq 0 ]
}

@test "is_dirpath: dot path" {
    run is_dirpath "."
    [ "$status" -eq 0 ]
}

@test "is_dirpath: relative path" {
    # relative paths like foo/bar/ don't start with /
    run is_dirpath "foo/bar/"
    [ "$status" -eq 1 ]
}

# ============ is_wildcard ============

@test "is_wildcard: asterisk" {
    run is_wildcard "*.txt"
    [ "$status" -eq 0 ]
}

@test "is_wildcard: question mark" {
    run is_wildcard "file?.txt"
    [ "$status" -eq 0 ]
}

@test "is_wildcard: brackets" {
    run is_wildcard "file[0-9].txt"
    [ "$status" -eq 0 ]
}

@test "is_wildcard: no wildcard" {
    run is_wildcard "file.txt"
    [ "$status" -eq 1 ]
}

# ============ is_url ============

@test "is_url: http url" {
    run is_url "http://example.com"
    [ "$status" -eq 0 ]
}

@test "is_url: https url" {
    run is_url "https://example.com/path"
    [ "$status" -eq 0 ]
}

@test "is_url: ftp url" {
    run is_url "ftp://ftp.example.com"
    [ "$status" -eq 0 ]
}

@test "is_url: not a url" {
    run is_url "/usr/bin/file"
    [ "$status" -eq 1 ]
}

@test "is_url: not a url (no protocol)" {
    run is_url "example.com"
    [ "$status" -eq 1 ]
}

# ============ has_space ============

@test "has_space: string with space" {
    run has_space "hello world"
    [ "$status" -eq 0 ]
}

@test "has_space: string without space" {
    run has_space "helloworld"
    [ "$status" -eq 1 ]
}

@test "has_space: string with tab" {
    run has_space "hello	world"
    [ "$status" -eq 0 ]
}

# ============ strip_spaces ============

@test "strip_spaces: multiple spaces" {
    result=$(strip_spaces "  hello   world  ")
    [ "$result" = "hello world" ]
}

@test "strip_spaces: single spaces" {
    result=$(strip_spaces "a b c")
    [ "$result" = "a b c" ]
}

@test "strip_spaces: no spaces" {
    result=$(strip_spaces "hello")
    [ "$result" = "hello" ]
}

# ============ firstupper ============

@test "firstupper: lowercase word" {
    result=$(firstupper "hello")
    [ "$result" = "Hello" ]
}

@test "firstupper: already uppercase" {
    result=$(firstupper "Hello")
    [ "$result" = "Hello" ]
}

@test "firstupper: all uppercase" {
    result=$(firstupper "HELLO")
    [ "$result" = "HELLO" ]
}

# ============ tolower ============

@test "tolower: uppercase" {
    result=$(tolower "HELLO")
    [ "$result" = "hello" ]
}

@test "tolower: mixed case" {
    result=$(tolower "HeLLo WoRLD")
    [ "$result" = "hello world" ]
}

@test "tolower: already lowercase" {
    result=$(tolower "hello")
    [ "$result" = "hello" ]
}

# ============ firstword ============

@test "firstword: multiple words" {
    result=$(firstword "one two three")
    [ "$result" = "one" ]
}

@test "firstword: single word" {
    result=$(firstword "single")
    [ "$result" = "single" ]
}

@test "firstword: leading spaces" {
    result=$(firstword "  first second")
    [ "$result" = "first" ]
}

# ============ lastword ============

@test "lastword: multiple words" {
    result=$(lastword "one two three")
    [ "$result" = "three" ]
}

@test "lastword: single word" {
    result=$(lastword "single")
    [ "$result" = "single" ]
}

@test "lastword: trailing spaces" {
    result=$(lastword "first second  ")
    [ "$result" = "second" ]
}

# ============ get_firstarg ============

@test "get_firstarg: multiple args" {
    result=$(get_firstarg one two three)
    [ "$result" = "one" ]
}

@test "get_firstarg: single arg" {
    result=$(get_firstarg single)
    [ "$result" = "single" ]
}

# ============ get_lastarg ============

@test "get_lastarg: multiple args" {
    result=$(get_lastarg one two three)
    [ "$result" = "three" ]
}

@test "get_lastarg: single arg" {
    result=$(get_lastarg single)
    [ "$result" = "single" ]
}

# ============ sed_escape ============

@test "sed_escape: slash" {
    result=$(sed_escape "a/b/c")
    [ "$result" = 'a\/b\/c' ]
}

@test "sed_escape: no special chars" {
    result=$(sed_escape "abc")
    [ "$result" = "abc" ]
}

# ============ __convert_glob__to_regexp ============

@test "__convert_glob__to_regexp: asterisk" {
    result=$(__convert_glob__to_regexp "*.txt")
    [ "$result" = ".*\\.txt" ]
}

@test "__convert_glob__to_regexp: question mark" {
    result=$(__convert_glob__to_regexp "file?.txt")
    [ "$result" = "file.\\.txt" ]
}

@test "__convert_glob__to_regexp: no wildcards" {
    result=$(__convert_glob__to_regexp "file.txt")
    [ "$result" = "file\\.txt" ]
}

@test "__convert_glob__to_regexp: complex pattern" {
    result=$(__convert_glob__to_regexp "lib*-devel")
    [ "$result" = "lib.*-devel" ]
}

# ============ __escape_regex_special ============

@test "__escape_regex_special: dot" {
    result=$(__escape_regex_special "file.txt")
    [ "$result" = 'file\.txt' ]
}

@test "__escape_regex_special: asterisk not escaped" {
    # __escape_regex_special escapes \.^$(){}+[] but NOT *
    result=$(__escape_regex_special "a*b")
    [ "$result" = "a*b" ]
}

@test "__escape_regex_special: brackets" {
    result=$(__escape_regex_special "[abc]")
    [ "$result" = '\[abc\]' ]
}

@test "__escape_regex_special: no special chars" {
    result=$(__escape_regex_special "abc123")
    [ "$result" = "abc123" ]
}
