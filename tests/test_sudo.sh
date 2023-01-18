#!/bin/bash

dorun()
{
    eval "$@"
}

dorun2()
{
    "$@"
}

sudorun()
{
    sudo "$@"
}

#run "EDITOR=vim crontab -e"
#sudorun EDITOR=vim crontab -e
dorun LANG=ru rpm -q --queryformat "%{size}@%{name}-%{version}-%{release}\\\n" mc
dorun rpm -q --queryformat '%{size}@%{name}-%{version}-%{release}\\n' mc
#dorun dpkg-query -W --showformat="\\\${Package}-\\\${Version}\\\n" -- mc
#dorun dpkg-query -W --showformat='\${Package}-\${Version}\\n' -- mc

echo
echo 'R \\$'
dorun2 env LANG=ru rpm -q --queryformat "\\$USER%{size}@%{name}-%{version}-%{release}\\\n" mc

echo
echo 'R \$'
dorun2 env LANG=ru rpm -q --queryformat "\$USER%{size}@%{name}-%{version}-%{release}\\n" mc

echo
echo 'R $'
dorun2 env LANG=ru rpm -q --queryformat "$USER%{size}@%{name}-%{version}-%{release}\n" mc
echo "==="
dorun2 env LANG=en_US.UTF-8 locale
sudorun env LANG=en_RU.UTF-8 locale
#sudorun LANG=en_RU.UTF-8 locale

echo '1====================='
echo dorun
dorun echo 'lib(x86_64)'
echo dorun2
dorun2 echo 'lib(x86_64)'
echo sudorun
sudorun echo 'lib(x86_64)'

echo '2====================='
echo dorun
dorun echo 'lib\(x86_64\)'
echo dorun2
dorun2 echo 'lib\(x86_64\)'
echo sudorun
sudorun echo 'lib\(x86_64\)'

echo '3====================='
echo dorun
dorun echo lib(x86_64)
echo dorun2
dorun2 echo lib(x86_64)
echo sudorun
sudorun echo lib(x86_64)
