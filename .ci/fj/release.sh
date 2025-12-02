#!/bin/sh -e

# shellcheck disable=SC1091

ROOTDIR="$PWD"
. "$ROOTDIR"/.ci/common/project.sh

RELEASE_JSON=".ci/release.json"
GH_HOST=$(jq -r --arg id "tag" '.[] | select(.["build-id"] == $id) | .host' $RELEASE_JSON)
GH_REPO=$(jq -r --arg id "tag" '.[] | select(.["build-id"] == $id) | .repository' $RELEASE_JSON)

DEFAULT_JSON=".ci/default.json"
FJ_HOST=$(jq -r ".[0].host" $DEFAULT_JSON)
FJ_REPO=$(jq -r ".[0].repository" $DEFAULT_JSON)

sed -i "s|$GH_HOST/$GH_REPO|$FJ_HOST/$FJ_REPO|g" changelog.md
git clone https://git.crueter.xyz/scripts/fj.git

fj/fj.sh -k "$FJ_TOKEN" -r "$FJ_REPO" -u "$FJ_HOST" release -t "$FORGEJO_REF" \
	create -b changelog.md -n "$PROJECT_PRETTYNAME $FORGEJO_REF" -d > url

cat url

fj/fj.sh -k "$FJ_TOKEN" -r "$FJ_REPO" -u "$FJ_HOST" release -t "$FORGEJO_REF" \
	upload -g artifacts/*
