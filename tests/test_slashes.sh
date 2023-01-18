#!/bin/sh

filter_from_requires()
{
    local i="$1"
    echo "1i%filter_from_requires /^$i.*/d"
}

filter_from_requires '\\/opt\\/google\\/chrome\\/WidevineCdm'
