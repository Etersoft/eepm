#!/bin/sh

PKGNAME=p4-plan-client
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="P4 Plan desktop client from the official site"
URL="https://www.perforce.com/downloads/hansoft-client"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Public package name in EPM is p4-plan-client, while upstream still mixes
# Helix Plan Client (portal/product title) and HelixPlan (internal app name).
export EPM_REPACK_SCRIPT=p4-plan-client
export EEPM_INTERNAL_PKGNAME='p4planclient p4-plan-client'

# The download page is a Salesforce portal. It does not expose a static .deb URL,
# so we have to reproduce a small part of its Aura workflow.
PORTAL_URL='https://portal.perforce.com/s/downloads?product=Helix%20Plan%20Client'
PORTAL_PAGEURI='/s/downloads?product=Helix%20Plan%20Client'
AURA_APP='siteforce:communityApp'
AURA_APP_LOADED='APPLICATION@markup://siteforce:communityApp'

epm assure curl || fatal 'curl is required'
cd_to_temp_dir

portal_post()
{
    local endpoint="$1"
    local descriptor="$2"
    local caller="$3"
    local params="$4"
    local output="$5"
    local message

    message='{"actions":[{"id":"1;a","descriptor":"'$descriptor'","callingDescriptor":"'$caller'","params":'$params',"version":null}]}'

    curl -fsSL --max-time 30 "$endpoint" \
        --data-urlencode "message=$message" \
        --data-urlencode "aura.context=$AURA_CONTEXT" \
        --data-urlencode "aura.pageURI=$PORTAL_PAGEURI" \
        --data-urlencode 'aura.token=null' \
        > "$output"
}

PORTAL_HTML="$PKGDIR/portal.html"
PRODUCT_JSON="$PKGDIR/product.json"
NODES_JSON="$PKGDIR/nodes.json"
DOWNLOAD_JSON="$PKGDIR/download.json"

# Raw HTML contains Aura bootstrap values only inside percent-encoded script URLs.
curl -fsSL --max-time 30 "$PORTAL_URL" > "$PORTAL_HTML" || fatal "Can't open $PORTAL_URL."

FWUID="$(sed -n 's|.*%22fwuid%22%3A%22\([^"%]*\)%22.*|\1|p' "$PORTAL_HTML" | head -n1)"
APP_LOADED="$(
      sed -n 's|.*%22APPLICATION%40markup%3A%2F%2Fsiteforce%3AcommunityApp%22%3A%22\([^"%]*\)%22.*|\1|p' "$PORTAL_HTML" \
    | head -n1
)"

[ -n "$FWUID" ] || fatal "Can't get Aura fwuid."
[ -n "$APP_LOADED" ] || fatal "Can't get Aura app token."

AURA_CONTEXT='{"mode":"PROD","fwuid":"'$FWUID'","app":"'$AURA_APP'","loaded":{"'$AURA_APP_LOADED'":"'$APP_LOADED'"},"dn":[],"globals":{},"uad":true}'

# Step 1: resolve the current product root folder in the portal file tree.
portal_post \
    'https://portal.perforce.com/s/sfsites/aura?r=1&c.dynamicDownload.getDownloadProductAndAllReleaeses=1' \
    'apex://productDownloadController/ACTION$getDownloadProductAndAllReleaeses' \
    'markup://c:dynamicDownload' \
    '{"productName":"Helix Plan Client"}' \
    "$PRODUCT_JSON" || fatal "Can't get product data."

ROOT_FOLDER_ID="$(get_json_value "$PRODUCT_JSON" '["actions",0,"returnValue","pDownload","s3Folder__c"]')"
[ -n "$ROOT_FOLDER_ID" ] || fatal "Can't get current download folder."

# Step 2: list files in that folder and find the current Linux .deb node.
NODE_DATA='{"captionField":"","checkable":true,"childObjectType":"","id":"Files/'$ROOT_FOLDER_ID'","key":"'$ROOT_FOLDER_ID'","nodeQuery":"","nodeType":"NodeType_Object","objectType":"Folder__c","objSelectedRecord":{"attributes":{"type":"NEILON__Folder__c"},"Id":"'$ROOT_FOLDER_ID'","Name":"Client"},"orderChildrenBy":"Name","showGroupByCharts":true,"showNewButton":false,"showResultObjectsInTree":true,"tncId":""}'
NODE_DATA_ESCAPED="$(printf '%s' "$NODE_DATA" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')"

portal_post \
    'https://portal.perforce.com/s/sfsites/aura?r=2&NEILON.apLightningTreeNode.getChildNodes=1' \
    'apex://NEILON.apLightningTreeNodeController/ACTION$getChildNodes' \
    'markup://NEILON:apLightningTreeNode' \
    '{"treeType":"Files","nodeData":"'"$NODE_DATA_ESCAPED"'","withoutSharing":true,"showItemsCount":false,"defaultWhereClauses":"{}"}' \
    "$NODES_JSON" || fatal "Can't get current Linux downloads."

DEB_INDEX="$(
    epm tool json -b < "$NODES_JSON" \
        | sed -n 's|^\["actions",0,"returnValue",\([0-9][0-9]*\),"title"\][[:space:]]*".*\.deb"$|\1|p' \
        | head -n1
)"
[ -n "$DEB_INDEX" ] || fatal "Can't find Linux .deb package."

RECORD_ID="$(get_json_value "$NODES_JSON" '["actions",0,"returnValue",'$DEB_INDEX',"userData","objSelectedRecord","Id"]')"
[ -n "$RECORD_ID" ] || fatal "Can't get Linux package record id."

VERSION="$(
    get_json_value "$NODES_JSON" '["actions",0,"returnValue",'$DEB_INDEX',"title"]' \
        | sed -n 's|^.*_\([0-9][0-9][0-9][0-9]\)_\([0-9][0-9][0-9][0-9]\)_x64\.deb$|\1.\2|p'
)"

# Step 3: ask the portal for a fresh signed S3 URL for that file.
portal_post \
    'https://portal.perforce.com/s/sfsites/aura?r=3&NEILON.edFileDetail.getFileDownloadInformation=1' \
    'apex://NEILON.edFileDetailController/ACTION$getFileDownloadInformation' \
    'markup://NEILON:edLightningFileDownload' \
    '{"recordId":"'$RECORD_ID'"}' \
    "$DOWNLOAD_JSON" || fatal "Can't get package download URL."

PKGURL="$(get_json_value "$DOWNLOAD_JSON" '["actions",0,"returnValue","fileDownloadURL"]')"
[ -n "$PKGURL" ] || fatal "Can't get package URL."

install_pkgurl
