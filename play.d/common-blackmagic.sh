#!/bin/sh

# Blackmagic Design does not provide permanent direct download URLs.
# The URL discovery/registration approach is based on Nixpkgs:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/da/davinci-resolve/package.nix
# Synthetic registration data follows the same general approach:
# https://github.com/NixOS/nixpkgs/pull/551757
# Personal user data is deliberately not requested or transmitted.

BLACKMAGIC_DOWNLOADS_URL=https://www.blackmagicdesign.com/api/support/us/downloads.json
BLACKMAGIC_REGISTER_URL=https://www.blackmagicdesign.com/api/register/us/download
# Save the requested channel before common.sh resolves alternatives or versions.
BLACKMAGIC_CHANNEL="$VERSION"
# Limit PRODUCTALT to the requested edition so common.sh does not select an
# installed beta for a stable request. VERSION="*" skips app-versions; the saved
# request is resolved against the official catalog, including numeric versions.
case "$1" in
    --description|--product-alternatives|--info) ;;
    *)
        case "$BLACKMAGIC_CHANNEL" in
            ""|"*"|beta) ;;
            *[!0-9.b*?]*|[!0-9]*)
                echo "Use $BASEPKGNAME=<version>, $BASEPKGNAME=beta or a version pattern" >&2
                exit 1
                ;;
        esac
        case "$BLACKMAGIC_CHANNEL" in
            beta|*b*) PRODUCTALT=beta ;;
            *) PRODUCTALT="''" ;;
        esac
        VERSION="*"
        ;;
esac

# Input is the output of epm tool json -b. Compare numeric version components;
# a beta of the same base version is always older than the final release.
blackmagic_select_entry()
{
    awk -F '\t' -v product="$BASEPKGNAME" -v channel="$BLACKMAGIC_CHANNEL" '
        function newer(a,b, i,aa,bb) {
            if (b == "") return 1
            split(a,aa,"."); split(b,bb,".")
            for (i=1;i<=5;i++) {
                if (aa[i]+0 > bb[i]+0) return 1
                if (aa[i]+0 < bb[i]+0) return 0
            }
            return 0
        }
        function matches(version, pattern, i,c,re) {
            re="^"
            for (i=1;i<=length(pattern);i++) {
                c=substr(pattern,i,1)
                if (c == ".") re=re "[.]"
                else if (c == "*") re=re ".*"
                else if (c == "?") re=re "."
                else re=re c
            }
            return version ~ (re "$")
        }
        function value(path,field) { return fields[path SUBSEP field] }
        BEGIN { specific=(channel != "" && channel != "*" && channel != "beta") }
        {
            path=$1; field=path
            sub(/^.*,"/,"",field); sub(/"\]$/,"",field)
            sub(/,"[^",]*"\]$/,"",path)
            v=$2; sub(/^"/,"",v); sub(/"$/,"",v)
            fields[path SUBSEP field]=v
            if ($1 ~ /,"urls","Linux",[0-9]+,"product"\]$/ && v == product)
                entries[path]=1
        }
        END {
            for (path in entries) {
                title=value(path,"downloadTitle")
                major=value(path,"major"); minor=value(path,"minor")
                rel=value(path,"releaseNum"); beta=value(path,"beta")
                # Older catalog entries may lack structured version fields.
                t=title; sub(/^[^0-9]*/,"",t); split(t,parts,/[^0-9.]/)
                split(parts[1],nums,".")
                if (major == "") major=nums[1]
                if (minor == "") minor=nums[2]+0
                if (rel == "") rel=nums[3]+0
                if (major !~ /^[0-9]+$/) continue
                if (beta == "") {
                    if (tolower(title) ~ /public beta/) {
                        t=tolower(title); sub(/^.*public beta */,"",t)
                        beta=t+0
                    } else if (tolower(title) ~ /beta/) continue
                    else beta=255
                }
                key=major "." minor "." rel "." beta "." (value(path,"buildNum")+0)
                versions[path]=parts[1]
                if (versions[path] == "") versions[path]=major "." minor "." rel
                if (beta != 255) versions[path]=versions[path] "b" beta
                if (specific &&
                    matches(versions[path],channel) &&
                    ((index(channel,"b") > 0) == (beta != 255)) && newer(key,requestedkey)) {
                    requested=path; requestedkey=key
                }
                # Blackmagic uses 255 for final releases, not a beta number.
                if (beta == 255) {
                    if (newer(key,stablekey)) { stable=path; stablekey=key }
                } else if (tolower(title) ~ /public beta/ && newer(key,betakey)) {
                    candidate=path; betakey=key
                }
            }
            selected=stable
            if (channel == "beta") {
                if (candidate == "" || !newer(betakey,stablekey)) {
                    print "There is no current " name " public beta available." > "/dev/stderr"
                    if (stable != "") print "Latest stable version is " versions[stable] "." > "/dev/stderr"
                    exit 1
                }
                selected=candidate
            }
            # Explicit versions/patterns may select historical betas; only the
            # unversioned beta channel must be newer than the latest final.
            if (specific) selected=requested
            if (selected == "") {
                print "No Linux release of " name " matches " channel "." > "/dev/stderr"
                exit 1
            }
            parent=selected; sub(/,"urls","Linux",[0-9]+$/,"",parent)
            # The current API puts this flag on the parent download record.
            registration=value(selected,"requiresRegistration")
            if (registration == "") registration=value(parent,"requiresRegistration")
            # A missing flag is an API schema error, not permission to register.
            if (registration != "true" && registration != "false") exit 1
            print versions[selected]
            print value(selected,"downloadId")
            # Referer identifies the release; the POST endpoint uses downloadId.
            release=value(selected,"releaseId")
            if (release == "") release=value(selected,"downloadId")
            print release
            print registration
        }
    ' name="$BLACKMAGIC_PRODUCT_NAME"
}

blackmagic_catalog_entry()
{
    local json flat entry
    json="$(fetch_url "$BLACKMAGIC_DOWNLOADS_URL")" || return 1
    # JSON.sh tokenization needs the byte locale for some catalog Unicode text.
    flat="$(printf '%s' "$json" | LC_ALL=C epm --inscript --quiet tool json -b)" || return 1
    entry="$(printf '%s\n' "$flat" | blackmagic_select_entry)" || return 1
    BLACKMAGIC_VERSION="$(printf '%s\n' "$entry" | sed -n '1p')"
    BLACKMAGIC_DOWNLOAD_ID="$(printf '%s\n' "$entry" | sed -n '2p')"
    BLACKMAGIC_RELEASE_ID="$(printf '%s\n' "$entry" | sed -n '3p')"
    BLACKMAGIC_REGISTRATION="$(printf '%s\n' "$entry" | sed -n '4p')"
    [ -n "$BLACKMAGIC_DOWNLOAD_ID" ] && [ -n "$BLACKMAGIC_RELEASE_ID" ]
}

# All functions are defined before common.sh can call get_target_version.
get_target_version()
{
    blackmagic_catalog_entry || return 1
    echo "$BLACKMAGIC_VERSION"
}

get_blackmagic_pkgurl()
{
    local pkgurl

    blackmagic_catalog_entry || fatal "Can't find $BLACKMAGIC_PRODUCT_NAME ${BLACKMAGIC_CHANNEL:-stable} for Linux"
    info "Found $BLACKMAGIC_PRODUCT_NAME $BLACKMAGIC_VERSION"
    epm assure curl >&2 || fatal "curl is required to download $BLACKMAGIC_PRODUCT_NAME"
    cd_to_temp_dir

    # The product name comes from the short play script, never from remote JSON.
    # Use a reserved example domain and fictional 202-555 number rather than
    # user contact details or an address belonging to Epm or another project.
    case "$BLACKMAGIC_REGISTRATION" in
        true)
            BLACKMAGIC_REQUEST='{"platform":"Linux","policy":true,"product":"'"$BLACKMAGIC_PRODUCT_NAME"'","firstname":"Linux","lastname":"User","email":"user@example.org","phone":"202-555-0194","country":"us","state":"New York","city":"New York","street":"-"}'
            ;;
        false)
            BLACKMAGIC_REQUEST='{"platform":"Linux","policy":true,"product":{"name":"'"$BLACKMAGIC_PRODUCT_NAME"'"},"country":"us","downloadOnly":true,"origin":"www.blackmagicdesign.com"}'
            ;;
    esac

    BLACKMAGIC_HTTP_STATUS="$(curl --silent --show-error --max-time 60 \
        --output "$PKGDIR/blackmagic-response" --write-out '%{http_code}' \
        --header 'Accept: application/json, text/plain, */*' \
        --header 'Origin: https://www.blackmagicdesign.com' \
        --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64)' \
        --header 'Content-Type: application/json;charset=UTF-8' \
        --header "Referer: https://www.blackmagicdesign.com/support/download/$BLACKMAGIC_RELEASE_ID/Linux" \
        --header 'Accept-Language: en-US,en;q=0.9' \
        --data-raw "$BLACKMAGIC_REQUEST" --compressed \
        "$BLACKMAGIC_REGISTER_URL/$BLACKMAGIC_DOWNLOAD_ID")" || \
        fatal "Can't request $BLACKMAGIC_PRODUCT_NAME download URL"
    BLACKMAGIC_RESPONSE="$(cat "$PKGDIR/blackmagic-response")"
    [ "$BLACKMAGIC_HTTP_STATUS" = 200 ] || \
        fatal "Blackmagic Design refused download request (HTTP $BLACKMAGIC_HTTP_STATUS): $BLACKMAGIC_RESPONSE"
    pkgurl="$(printf '%s' "$BLACKMAGIC_RESPONSE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    case "$pkgurl" in
        http://*|https://*) ;;
        *) fatal "Blackmagic Design returned an invalid download URL: $BLACKMAGIC_RESPONSE" ;;
    esac

    printf '%s\n' "$pkgurl"
}

# Compute runtimes are host setup, not build requirements. Run only after
# installation through play; repacking must not modify the build host.
assure_blackmagic_gpu_dependencies()
{
    local gpu_info package
    epm assure lspci pciutils || fatal "pciutils is required to detect AMD GPUs"
    gpu_info="$(a='' lspci -nn)" || fatal "Can't detect PCI devices"
    # Match AMD display devices, not AMD audio devices or chipsets.
    printf '%s\n' "$gpu_info" | grep '\[03' | grep -q '\[1002:' || return 0

    info "AMD GPU detected: installing OpenCL and HIP runtimes for Resolve"
    for package in rocm-opencl-runtime hip-runtime-amd ; do
        epm assure "$package" || fatal "Can't install AMD dependency $package"
    done
}

. $(dirname $0)/common.sh
