remove_on_exit()
{
   list_on_exit="$1"
}

fatal()
{
   echo "$*" >&2
   exit 1
}

# guarantied temp file/dir removed on exit
epm_mktemp()
{
    local tmp
    tmp="$(2mktemp "$@")" || fatal "Can't create temp file"
    remove_on_exit "$tmp"
    echo "$tmp"
}

test_func()
{
    local tm
    tm=$(epm_mktemp) || fatal "ETEST"
    echo "tm:$tm"
}

file=$(epm_mktemp)
test_func

echo "file:$file"
echo "list_on_exit: $list_on_exit"
