#!/usr/bin/env bash
# JD Auto-Detection Hook
# Scans user prompt for job description patterns.
# If 3+ patterns match, suggests using /job-tailor.

# Read user prompt from stdin
USER_PROMPT=$(cat)

# Define JD indicator patterns (case-insensitive)
PATTERNS=(
  "responsibilities"
  "requirements"
  "qualifications"
  "about the role"
  "what you.ll do"
  "what you.ll bring"
  "who you are"
  "nice to have"
  "must have"
  "minimum qualifications"
  "preferred qualifications"
  "about the team"
  "years of experience"
  "we are looking for"
  "you will"
  "the ideal candidate"
  "job description"
  "apply now"
  "equal opportunity"
)

# Count matches
MATCH_COUNT=0
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

for pattern in "${PATTERNS[@]}"; do
  if echo "$PROMPT_LOWER" | grep -qi "$pattern"; then
    MATCH_COUNT=$((MATCH_COUNT + 1))
  fi
done

# If 3+ patterns match, this is likely a job description
if [ "$MATCH_COUNT" -ge 3 ]; then
  # Output additional context for Claude
  CONTEXT="This message appears to contain a job description ($MATCH_COUNT JD indicators detected). Use the /job-tailor skill to tailor the user's resume and generate a cover letter for this position."

  printf '{\n  "hookSpecificOutput": {\n    "additionalContext": "%s"\n  }\n}\n' "$CONTEXT"
else
  # No JD detected — pass through silently
  printf '{\n  "hookSpecificOutput": {}\n}\n'
fi
