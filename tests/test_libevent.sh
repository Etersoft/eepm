# hack, todo: update libevent in p10
get_libevent()
{
    local libdir
    for libdir in /usr/lib/x86_64-linux-gnu /usr/lib64 /lib64 ; do
        basename $(ls $libdir/libevent-2.1.so.[0-9] 2>/dev/null) 2>/dev/null
    done | head -n1
}

get_libevent
