#!/bin/sh

# load common functions, compatible with local and installed script
# shellcheck disable=SC1091
. /usr/share/eterbuild/eterbuild
load_mod spec etersoft

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd "$SCRIPT_DIR" || exit 1

SPECNAME=eepm.spec
RELEASE_BRANCH=devel
BUILDER_API_URL=http://builder64.office.etersoft.ru:5503/api/rebuild
ENV_FILE="$SCRIPT_DIR/.env"

usage()
{
    cat <<EOF
Usage: $0 [-v|-r|-s|-n VERSION|--no-bump|--resume]
       $0 TAG

  -v          increment version (default)
  -r          increment release
  -s          increment subrelease
  -n VERSION  set version and reset release
  --no-bump   continue after rpmlog was run manually
  --resume    continue a release interrupted after rpmlog
  TAG         publish an existing tag to the public remotes
EOF
}

require_command()
{
    command -v "$1" >/dev/null 2>&1 || fatal "Required command '$1' is not installed."
}

require_remote()
{
    git remote get-url "$1" >/dev/null 2>&1 || fatal "Git remote '$1' is not configured."
    git ls-remote --heads "$1" >/dev/null 2>&1 || fatal "Git remote '$1' is not accessible."
}

load_builder_key()
{
    [ -r "$ENV_FILE" ] || fatal "Can't read $ENV_FILE."

    [ "$(sed -n '/^EPM_BUILDER_API_KEY=/p' "$ENV_FILE" | wc -l)" -eq 1 ] || fatal "$ENV_FILE must contain exactly one EPM_BUILDER_API_KEY entry."

    EPM_BUILDER_API_KEY=$(sed -n 's/^EPM_BUILDER_API_KEY=//p' "$ENV_FILE")

    [ -n "$EPM_BUILDER_API_KEY" ] || fatal "EPM_BUILDER_API_KEY is not set in $ENV_FILE."
}

check_release_ready()
{
    [ "$(git branch --show-current)" = "$RELEASE_BRANCH" ] || fatal "Release must be run from the $RELEASE_BRANCH branch."
    if ! git diff --quiet || ! git diff --cached --quiet ; then
        fatal "Tracked files contain uncommitted changes."
    fi

    for cmd in curl git gita rpmbs rpmlog rpmpub ssh ; do
        require_command "$cmd"
    done

    for remote in pub.github pub.gitlab gitery ; do
        require_remote "$remote"
    done

    gita ls >/dev/null 2>&1 || fatal "ALT task server is not accessible via gita."

    for host in epm-update epm-sisyphus ; do
        ssh -o BatchMode=yes -o ConnectTimeout=10 "epm@$host" true >/dev/null 2>&1 || fatal "Update host '$host' is not accessible."
    done
}

get_public_version()
(
    public_version=$(get_version "$1")
    base_version=$(echo "$public_version" | sed -e 's|\.[0-9]*$||')
    minor_version=$(echo "$base_version" | sed -e 's|.*\.||')

    [ "$((minor_version%2))" = 1 ] && public_version="$public_version-beta"
    echo "$public_version"
)

calculate_target()
(
    mode="$1"
    requested_version="$2"
    target_spec=$(mktemp) || fatal "Can't create temporary spec."

    trap 'rm -f "$target_spec"' EXIT HUP INT TERM
    cp "$SPECNAME" "$target_spec" || fatal "Can't copy $SPECNAME."

    case "$mode" in
        version)
            inc_version "$target_spec"
            set_release "$target_spec"
            ;;
        release)
            inc_release "$target_spec"
            ;;
        subrelease)
            inc_subrelease "$target_spec"
            ;;
        set-version)
            set_version "$target_spec" "$requested_version"
            set_release "$target_spec"
            ;;
        no-bump|resume)
            ;;
    esac

    printf '%s %s\n' "$(get_public_version "$target_spec")" \
        "$(get_version "$target_spec")-$(get_release "$target_spec")"
)

check_tag_is_new()
{
    [ -z "$(git tag -l "$1")" ] || fatal "Tag '$1' already exists locally."

    remote_tags=$(git ls-remote --tags "$2" "refs/tags/$1") || fatal "Can't inspect tags in $2."

    [ -z "$remote_tags" ] || fatal "Tag '$1' already exists in $2."
}

remote_tag_commit()
{
    git ls-remote --tags "$1" "refs/tags/$2" "refs/tags/$2^{}" | awk -v peeled="refs/tags/$2^{}" '$2 == peeled { print $1; found=1 } !found { commit=$1 } END { if (!found) print commit }'
}

verify_tag_points_to_head()
{
    tag_commit=$(git rev-list -n1 "$1" 2>/dev/null) || fatal "Can't resolve tag '$1'."
    [ "$tag_commit" = "$(git rev-parse HEAD)" ] || fatal "Tag '$1' does not point to HEAD."
}

fetch_release_tag()
{
    git rev-parse --verify "refs/tags/$1" >/dev/null 2>&1 && return
    docmd git fetch pub.github "refs/tags/$1:refs/tags/$1" || fatal "Can't fetch release tag '$1'."
}

create_release_tag()
{
    git tag -a "$1" -e -s -m "$(rpmlog -q --last-changelog | sed -e 's|^* ||')"
}

publish_tag_to_remote()
(
    local_commit=$(git rev-list -n1 "$2" 2>/dev/null) || fatal "Can't resolve tag '$2'."
    remote_commit=$(remote_tag_commit "$1" "$2")

    if [ -n "$remote_commit" ] ; then
        [ "$remote_commit" = "$local_commit" ] || fatal "Tag '$2' in $1 differs from the local tag."
        info "Tag '$2' is already published to $1."
        return
    fi

    git push "$1" "$2"
)

publish_tag()
{
    publish_tag_to_remote pub.github "$1" || return
    publish_tag_to_remote pub.gitlab "$1"
}

trigger_korinf_build()
{
    showcmd curl --fail-with-body --silent --show-error --config - \
        --request POST --header "Content-Type: application/json" \
        --data '{"package":"eepm","arch":"x86_64"}' "$BUILDER_API_URL"
    printf 'header = "X-API-Key: %s"\n' "$EPM_BUILDER_API_KEY" | \
        curl --fail-with-body --silent --show-error --config - \
            --request POST \
            --header "Content-Type: application/json" \
            --data '{"package":"eepm","arch":"x86_64"}' \
            "$BUILDER_API_URL"
}

publish_existing_tag()
{
    [ "$(git tag -l "$1")" = "$1" ] || fatal "Can't find tag '$1' in the repo."
    publish_tag "$1"
}

MODE=version
REQUESTED_VERSION=

case "$1" in
    "")
        ;;
    -v)
        [ "$#" -eq 1 ] || { usage >&2; exit 1; }
        ;;
    -r)
        [ "$#" -eq 1 ] || { usage >&2; exit 1; }
        MODE=release
        ;;
    -s)
        [ "$#" -eq 1 ] || { usage >&2; exit 1; }
        MODE=subrelease
        ;;
    -n)
        [ "$#" -eq 2 ] || { usage >&2; exit 1; }
        MODE=set-version
        REQUESTED_VERSION="$2"
        ;;
    --no-bump)
        [ "$#" -eq 1 ] || { usage >&2; exit 1; }
        MODE=no-bump
        ;;
    --resume)
        [ "$#" -eq 1 ] || { usage >&2; exit 1; }
        MODE=resume
        ;;
    -h|--help)
        usage
        exit
        ;;
    -*)
        usage >&2
        exit 1
        ;;
    *)
        [ "$#" -eq 1 ] || { usage >&2; exit 1; }
        publish_existing_tag "$1"
        exit
        ;;
esac

check_release_ready
load_builder_key

target=$(calculate_target "$MODE" "$REQUESTED_VERSION") || exit
version=${target%% *}
altversion=${target#* }

publish_public_tag=yes
case "$MODE" in
    release|subrelease)
        # A release-only rebuild keeps the existing upstream version tag.
        publish_public_tag=no
        ;;
    no-bump|resume)
        existing_tag_commit=$(git rev-list -n1 "$version" 2>/dev/null)
        if [ -n "$existing_tag_commit" ] && [ "$existing_tag_commit" != "$(git rev-parse HEAD)" ] ; then
            publish_public_tag=no
        fi
        ;;
esac

if [ "$MODE" != resume ] ; then
    if [ "$publish_public_tag" = yes ] ; then
        check_tag_is_new "$version" pub.github
        check_tag_is_new "$version" pub.gitlab
    fi
    check_tag_is_new "$altversion" gitery
fi

case "$MODE" in
    version|release|subrelease|set-version)
        previous_version=$(get_public_version "$SPECNAME")
        fetch_release_tag "$previous_version"
        case "$MODE" in
            version) docmd rpmlog -v -l "$previous_version" || exit ;;
            release) docmd rpmlog -r -l "$previous_version" || exit ;;
            subrelease) docmd rpmlog -s -l "$previous_version" || exit ;;
            set-version) docmd rpmlog -n "$REQUESTED_VERSION" -l "$previous_version" || exit ;;
        esac
        ;;
    no-bump)
        info "Using the version and changelog already prepared in $SPECNAME."
        ;;
    resume)
        info "Continuing release $altversion."
        ;;
esac

[ "$(get_public_version "$SPECNAME")" = "$version" ] || fatal "Prepared public version does not match $version."
[ "$(get_version "$SPECNAME")-$(get_release "$SPECNAME")" = "$altversion" ] || fatal "Prepared ALT version does not match $altversion."

head_subject=$(git log -1 --format=%s)
if [ "$MODE" = no-bump ] && [ "$head_subject" != "$altversion" ] ; then
    fatal "HEAD is not the rpmlog commit '$altversion'."
fi


if [ "$MODE" = resume ] && [ "$head_subject" != "$altversion" ] && [ "$head_subject" != "commit packed $version" ] ; then
    fatal "HEAD is neither the rpmlog nor the packed commit for $altversion."
fi


if [ "$MODE" = resume ] && [ "$head_subject" = "commit packed $version" ] ; then
    info "Packed files are already committed."
else
    docmd ./pack_in_onefile.sh || exit
    docmd git add packed || exit
    docmd git commit packed -m "commit packed $version" || exit
fi


if [ "$publish_public_tag" = yes ] ; then
    if [ "$(git tag -l "$version")" = "$version" ] ; then
        verify_tag_points_to_head "$version"
        info "Tag '$version' already exists locally."
    else
        docmd create_release_tag "$version" || exit
    fi
    docmd publish_tag "$version" || exit
fi
docmd gpush pub.github || exit

gitery_tag_commit=$(remote_tag_commit gitery "$altversion")

if [ -n "$gitery_tag_commit" ] && [ "$gitery_tag_commit" != "$(git rev-parse HEAD)" ] ; then
    fatal "Tag '$altversion' in gitery does not point to HEAD."
fi

docmd rpmpub /var/ftp/pub/Korinf/sources || exit
docmd trigger_korinf_build || exit

# Force rpmbs to create the Version-Release gear tag even though the public
# version-only tag already points to the same commit.
if [ -n "$gitery_tag_commit" ] ; then
    info "ALT task for '$altversion' was already submitted."
else
    docmd rpmbs gitery -u -f "$SPECNAME" || exit
fi

docmd ssh epm@epm-update /home/epm/bin/update.sh || exit
docmd ssh epm@epm-sisyphus /home/epm/bin/update.sh || exit
