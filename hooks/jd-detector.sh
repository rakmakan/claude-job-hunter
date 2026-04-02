#!/usr/bin/env bash
# JD Auto-Detection Hook
# Scans user prompt for job description patterns.
# If 3+ patterns match, suggests using /job-tailor.

set -o pipefail

# Read JSON input from stdin
INPUT=$(cat 2>/dev/null) || INPUT=""

# If empty input, exit silently
if [ -z "$INPUT" ]; then
  echo '{"hookSpecificOutput":{}}'
  exit 0
fi

# Extract prompt field from JSON
USER_PROMPT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('prompt', d.get('message', '')))
except:
    print('')
" 2>/dev/null) || USER_PROMPT=""

# If we couldn't extract a prompt, exit silently
if [ -z "$USER_PROMPT" ]; then
  echo '{"hookSpecificOutput":{}}'
  exit 0
fi

# Count JD pattern matches
MATCH_COUNT=0
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

for pattern in "responsibilities" "requirements" "qualifications" "about the role" \
  "what you.ll do" "what you.ll bring" "who you are" "nice to have" "must have" \
  "minimum qualifications" "preferred qualifications" "about the team" \
  "years of experience" "we are looking for" "the ideal candidate" \
  "job description" "apply now" "equal opportunity"; do
  if echo "$PROMPT_LOWER" | grep -qi "$pattern" 2>/dev/null; then
    MATCH_COUNT=$((MATCH_COUNT + 1))
  fi
done

# If 3+ patterns match, this is likely a job description
if [ "$MATCH_COUNT" -ge 3 ]; then
  echo "{\"hookSpecificOutput\":{\"additionalContext\":\"This message appears to contain a job description ($MATCH_COUNT JD indicators detected). Use the /job-tailor skill to tailor the user's resume and generate a cover letter for this position.\"}}"
else
  echo '{"hookSpecificOutput":{}}'
fi

exit 0
