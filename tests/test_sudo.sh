#!/bin/bash

dorun()
{
    eval "$@"
}

sudorun()
{
    sudo "$@"
}

#run "EDITOR=vim crontab -e"
#sudorun EDITOR=vim crontab -e
dorun rpm -q --queryformat "%{size}@%{name}-%{version}-%{release}\\\n" mc
dorun rpm -q --queryformat '%{size}@%{name}-%{version}-%{release}\\n' mc
#dorun dpkg-query -W --showformat="\\\${Package}-\\\${Version}\\\n" -- mc
#dorun dpkg-query -W --showformat='\${Package}-\${Version}\\n' -- mc
