#!/usr/bin/env bash
set -euo pipefail
export TOKEN="$1"
export ME="$2"
export OWNER='Ascend'
export REPO='AscendNPU-IR-Dev'

if [ "$ME" == "" ]; then
  echo "Usage: $0 <ACCESS_TOKEN> <USER_NAME>"
  exit 1
fi

BASE_URL="https://api.gitcode.com/api/v5"
WEB_BASE_URL="https://gitcode.com"

IGNORE_RE='^(compile|compile#openlibing|/compile|/merge|/lgtm|/approve)([[:space:]]|$)'

api_get() {
    local url="$1"
    curl -fsS "$url"
}

get_all_prs() {
    local page=1

    while true; do
        local data count

        data=$(api_get "${BASE_URL}/repos/${OWNER}/${REPO}/pulls?access_token=${TOKEN}&state=all&page=${page}&per_page=100")
        count=$(echo "$data" | jq 'length')

        echo "$data" | jq -r '.[].number'

        [[ "$count" -lt 100 ]] && break
        ((page++))
    done
}

get_comments_of_pr() {
    local pr="$1"
    local page=1
    local pr_url="${WEB_BASE_URL}/${OWNER}/${REPO}/pull/${pr}"

    while true; do
        local data count

        data=$(api_get "${BASE_URL}/repos/${OWNER}/${REPO}/pulls/${pr}/comments?access_token=${TOKEN}&page=${page}&per_page=100")
        count=$(echo "$data" | jq 'length')

        echo "$data" | jq \
            --arg me "$ME" \
            --argjson pr "$pr" \
            --arg pr_url "$pr_url" \
            --arg ignore_re "$IGNORE_RE" '
            .[]
            | select(.user.login == $me)
            | (.body // "" | ascii_downcase | gsub("^\\s+|\\s+$"; "")) as $body_norm
            | select(($body_norm | test($ignore_re; "i")) | not)
            | {
                pr: $pr,
                comment_id: .id,
                discussion_id: .discussion_id,
                created_at: .created_at,
                updated_at: .updated_at,
                comment_type: .comment_type,
                file: (.diff_file // .position.new_path // .position.old_path // null),
                body: .body,

                pr_url: $pr_url,

                comment_url: (
                    .html_url
                    // .target.html_url
                    // .url
                    // ($pr_url + "#note_" + (.id | tostring))
                )
            }
        '

        [[ "$count" -lt 100 ]] && break
        ((page++))
    done
}

while read -r pr; do
    echo "Processing PR #${pr}..." >&2
    get_comments_of_pr "$pr"
done < <(get_all_prs)

