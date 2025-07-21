#!/bin/sh -ex

cat << EOF >> $GITHUB_STEP_SUMMARY
## Job Summary
- Triggered By: $1
- Ref: $FORGEJO_REF
EOF

if [ "$1" = "pull_request" ]; then
  cat << EOF >> $GITHUB_STEP_SUMMARY
- PR #${FORGEJO_NUMBER}
- Title: `${FORGEJO_TITLE}`
- [URL]($FORGEJO_PR_URL)
EOF
fi