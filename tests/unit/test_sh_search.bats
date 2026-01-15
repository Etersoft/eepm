#!/usr/bin/env bats
# Unit tests for epm-sh-search

load helpers

setup() {
    load_epm_sh_search
}

# ============ __epm_get_longest_word ============

@test "__epm_get_longest_word: single word" {
    result=$(__epm_get_longest_word "hello")
    [ "$result" = "hello" ]
}

@test "__epm_get_longest_word: multiple words as args" {
    result=$(__epm_get_longest_word "hi" "hello" "hey")
    [ "$result" = "hello" ]
}

@test "__epm_get_longest_word: skip exclusion patterns" {
    result=$(__epm_get_longest_word "short" "~excluded" "medium")
    [ "$result" = "medium" ]
}

@test "__epm_get_longest_word: OR pattern extracts words" {
    result=$(__epm_get_longest_word "(bash|zsh)")
    [ "$result" = "bash" ]
}

@test "__epm_get_longest_word: OR pattern picks longest" {
    result=$(__epm_get_longest_word "(ab|abcdef|abc)")
    [ "$result" = "abcdef" ]
}

@test "__epm_get_longest_word: glob pattern cleaned" {
    result=$(__epm_get_longest_word "lib*-devel")
    [ "$result" = "-devel" ] || [ "$result" = "lib" ]
}

@test "__epm_get_longest_word: complex pattern" {
    result=$(__epm_get_longest_word "short" "(firefox|chromium)" "~skip")
    [ "$result" = "chromium" ]
}

@test "__epm_get_longest_word: path as pattern" {
    result=$(__epm_get_longest_word "bash" "/usr/bin")
    [ "$result" = "/usr/bin" ]
}

@test "__epm_get_longest_word: empty returns empty" {
    result=$(__epm_get_longest_word)
    [ -z "$result" ]
}

@test "__epm_get_longest_word: only exclusions returns empty" {
    result=$(__epm_get_longest_word "~foo" "~bar")
    [ -z "$result" ]
}

# ============ __epm_glob_to_regexp ============

@test "__epm_glob_to_regexp: asterisk to .*" {
    result=$(__epm_glob_to_regexp "*.txt")
    [ "$result" = ".*\\.txt" ]
}

@test "__epm_glob_to_regexp: question mark to ." {
    result=$(__epm_glob_to_regexp "file?.txt")
    [ "$result" = "file.\\.txt" ]
}

@test "__epm_glob_to_regexp: escape dot" {
    result=$(__epm_glob_to_regexp "file.txt")
    [ "$result" = "file\\.txt" ]
}

@test "__epm_glob_to_regexp: escape curly braces" {
    result=$(__epm_glob_to_regexp "file{1,2}")
    [ "$result" = "file\\{1,2\\}" ]
}

@test "__epm_glob_to_regexp: preserve OR pattern" {
    result=$(__epm_glob_to_regexp "(a|b)")
    [ "$result" = "(a|b)" ]
}

@test "__epm_glob_to_regexp: preserve brackets" {
    result=$(__epm_glob_to_regexp "[abc]")
    [ "$result" = "[abc]" ]
}

@test "__epm_glob_to_regexp: complex glob" {
    result=$(__epm_glob_to_regexp "lib*-?.so")
    [ "$result" = "lib.*-.\\.so" ]
}

# ============ __epm_get_color_pattern ============

@test "__epm_get_color_pattern: single pattern" {
    result=$(__epm_get_color_pattern "foo")
    [ "$result" = "foo" ]
}

@test "__epm_get_color_pattern: multiple patterns joined with |" {
    result=$(__epm_get_color_pattern "foo" "bar")
    [ "$result" = "foo|bar" ]
}

@test "__epm_get_color_pattern: skip exclusions" {
    result=$(__epm_get_color_pattern "foo" "~excluded" "bar")
    [ "$result" = "foo|bar" ]
}

@test "__epm_get_color_pattern: empty returns empty" {
    result=$(__epm_get_color_pattern)
    [ -z "$result" ]
}

@test "__epm_get_color_pattern: only exclusions returns empty" {
    result=$(__epm_get_color_pattern "~foo" "~bar")
    [ -z "$result" ]
}

@test "__epm_get_color_pattern: glob converted to regexp" {
    result=$(__epm_get_color_pattern "*.txt")
    [ "$result" = ".*\\.txt" ]
}

# ============ __epm_search_make_grep ============

@test "__epm_search_make_grep: single pattern" {
    result=$(__epm_search_make_grep "foo")
    [[ "$result" == *'grep -E -i -- "foo"'* ]]
}

@test "__epm_search_make_grep: multiple patterns (AND logic)" {
    result=$(__epm_search_make_grep "foo" "bar")
    [[ "$result" == *'grep -E -i -- "foo"'* ]]
    [[ "$result" == *'grep -E -i -- "bar"'* ]]
}

@test "__epm_search_make_grep: exclusion pattern" {
    result=$(__epm_search_make_grep "foo" "~bar")
    [[ "$result" == *'grep -E -i -v -- "bar"'* ]]
    [[ "$result" == *'grep -E -i -- "foo"'* ]]
}

@test "__epm_search_make_grep: short mode adds sed" {
    short=1
    result=$(__epm_search_make_grep "foo")
    [[ "$result" == *'sed -e "s| .*||g"'* ]]
    unset short
}

@test "__epm_search_make_grep: empty returns empty" {
    result=$(__epm_search_make_grep)
    [ -z "$result" ]
}
