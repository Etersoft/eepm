__get_app_description()
{
    local arch="$2"
    #__run_script "$1" --description "$2" 2>/dev/null
    if grep -q '^SUPPORTEDARCHES=.*\<'"$arch"'\>' "$psdir/$1.sh"; then
        grep -oP "^DESCRIPTION=[\"']*\K[^\"']+" "$psdir/$1.sh"
    fi
}

psdir=../play.d
app=i586-openssl098

__get_app_description $app x86_64


__get_app_package()
{
    #__run_script "$1" --package-name "$2" "$3" 2>/dev/null
    grep -oP "^PKGNAME=[\"']\K.*[^\"']+" "$psdir/$1.sh"
}

__get_app_package $app
