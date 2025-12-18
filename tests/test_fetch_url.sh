#!/bin/sh

# Test that fetch_url returns error code on failure

TESTDIR=$(realpath "$(dirname "$0")")
export SHAREDIR="$TESTDIR/../bin"
export PATH="$SHAREDIR:$PATH"

. "$SHAREDIR/epm-sh-functions"

test_fetch_url_success()
{
    local result
    result="$(fetch_url "https://httpbin.org/get")" || {
        echo "FAILED: fetch_url should succeed for valid URL"
        return 1
    }
    [ -n "$result" ] || {
        echo "FAILED: fetch_url returned empty result for valid URL"
        return 1
    }
    echo "OK: fetch_url succeeds for valid URL"
}

test_fetch_url_failure()
{
    local result
    result="$(fetch_url "https://httpbin.org/status/404")" && {
        echo "FAILED: fetch_url should fail for 404 URL"
        return 1
    }
    echo "OK: fetch_url returns error for 404 URL"
}

test_fetch_url_or_return()
{
    inner_func()
    {
        local res
        res="$(fetch_url "https://httpbin.org/status/404")" || return 1
        echo "should not reach here"
        return 0
    }

    inner_func && {
        echo "FAILED: || return should propagate error"
        return 1
    }
    echo "OK: || return works correctly with fetch_url"
}

echo "Testing fetch_url error handling..."
test_fetch_url_success
test_fetch_url_failure
test_fetch_url_or_return
