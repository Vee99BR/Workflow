#!/bin/sh -ex

cat << EOF >> $GITHUB_STEP_SUMMARY
## Job Summary
- Triggered By: $1
- Ref: [\`$FORGEJO_REF\`](https://git.eden-emu.dev/eden-emu/eden/commit/$FORGEJO_REF)
EOF

if [ "$1" = "pull_request" ]; then
echo "- PR #[${FORGEJO_NUMBER}]($FORGEJO_PR_URL)" >> $GITHUB_STEP_SUMMARY
echo -n "- Title: " >> $GITHUB_STEP_SUMMARY
eval echo $FORGEJO_TITLE >> $GITHUB_STEP_SUMMARY
eval echo "$FORGEJO_BODY" >> $GITHUB_STEP_SUMMARY
fi