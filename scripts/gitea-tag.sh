#!/bin/bash

function github_output {
    var_name="$1"
    shift
    var_value="$*"
    echo "::set-output name=$var_name::$var_value"
}

gitea_version=$(
curl -s https://api.github.com/repos/go-gitea/gitea/releases/latest \
    | jq -r .tag_name | tr -d 'v'
)

github_output version $gitea_version

if [ "${GITHUB_REF}" == "refs/heads/main" -a "${GITHUB_EVENT_NAME}" != "pull_request" ]; then
    # We are in a regular commit on main and should publish the image with the gitea version and latest.
    tags=$(echo "$gitea_version" | sed \
        -e 's/\(\(\([0-9]\+\)\.[0-9]\+\)\.[0-9]\+\)/\1,\2,\3,/' \
        -e 's/\([^,]\+\),/quay.io\/redhatgov\/gitea:\1,/g' \
        -e 's/$/quay.io\/redhatgov\/gitea:latest/')
    github_output tags "$tags"
else
    # We are in some branch other than main, or a pull request, and should just use the name of the branch
    branch=$(echo "$GITHUB_REF" | cut -d/ -f3- | tr '/' '_')
    github_output tags "quay.io/redhatgov/gitea:$branch"
fi
