#!/bin/sh -ex

cat << EOF >> $GITHUB_STEP_SUMMARY
## Job Summary
- Triggered By: $1
- Ref: [\`$FORGEJO_REF\`](https://git.eden-emu.dev/eden-emu/eden/commit/$FORGEJO_REF)
EOF

if [ "$1" = "pull_request" ]; then
  cat << EOF >> $GITHUB_STEP_SUMMARY
- PR #[${FORGEJO_NUMBER}]($FORGEJO_PR_URL)
- Title: $FORGEJO_TITLE
EOF
fi