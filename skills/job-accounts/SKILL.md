---
name: job-accounts
description: "Use when user wants to set up or manage job portal accounts, store login credentials for Workday/Greenhouse/Lever/SuccessFactors portals, or before running /job-apply"
---

# Job Accounts — Portal Credential Management

Interactively collect and store job portal credentials so the auto-apply skill can log in and submit applications.

## Trigger

- Manual: `/job-accounts`
- Before `/job-apply` if `accounts.json` doesn't exist

## Prerequisites

- `jobs-approved.json` (from Phase 3) — to know which portals are needed
- `spec.json` (from Phase 1) — for pre-computing common form answers

If `jobs-approved.json` is missing:
> "No approved jobs found. Run `/job-discover` and `/job-filter` first."

## Behavior

### Step 1: Security warning

Always show this first:

> "**Security Notice:** Portal credentials will be stored in `accounts.json` as plaintext in your working directory. This file is automatically gitignored, but you are responsible for its security.
>
> **Options:**
> a) Store credentials in the file (convenient, less secure)
> b) I'll ask for credentials each time I need them (more secure, less convenient)
>
> Which do you prefer?"

If user chooses (b), skip credential storage and set a flag in accounts.json: `"credential_mode": "prompt_each_time"`.

### Step 2: Identify unique portals

Read `jobs-approved.json`. Group jobs by `portal_url` (the base career site, not individual job URLs). Deduplicate.

Present the portal list:

> "You have approved jobs across these portals:
>
> | # | Company | Portal Type | Portal URL |
> |---|---------|-------------|------------|
> | 1 | Google | custom | careers.google.com |
> | 2 | RBC | workday | rbc.wd3.myworkdayjobs.com |
> | 3 | Shopify | greenhouse | boards.greenhouse.io/shopify |
>
> Let's set up accounts for each."

### Step 3: Collect credentials per portal

For each unique portal, ask ONE at a time:

> "**[Company] ([Portal Type])** — [Portal URL]
>
> Do you have an account on this portal?
> a) Yes — I'll provide my credentials
> b) No — help me create one
> c) Skip — I'll handle this one manually"

**If yes:**
> "Please enter your username/email for [Company]'s portal:"
(Wait for response)
> "Please enter your password:"
(Wait for response)

**If no (help create account):**
1. Use Playwright MCP to navigate to the portal's registration page
2. Take a snapshot and guide the user: "I've opened the registration page. Please complete any CAPTCHAs or email verification in your browser. Let me know when you're done."
3. After registration, collect the credentials as above

**If skip:**
Mark as `"credential_mode": "manual"` for this portal.

### Step 4: Pre-compute common form answers

Read `spec.json` and build common answers that portals frequently ask:

```json
{
  "common_answers": {
    "full_name": "from spec.personal.name",
    "email": "from spec.personal.email",
    "phone": "from spec.personal.phone",
    "address_line1": "from spec.personal.address.street",
    "city": "from spec.personal.address.city",
    "state_province": "from spec.personal.address.province",
    "postal_code": "from spec.personal.address.postal",
    "country": "from spec.personal.address.country",
    "linkedin_url": "from spec.personal.linkedin",
    "work_authorization": "mapped from spec.demographics.work_authorization",
    "sponsorship_needed": "Yes/No from spec.demographics.sponsorship_needed",
    "veteran_status": "mapped from spec.demographics.veteran",
    "disability_status": "mapped from spec.demographics.disability",
    "gender": "mapped from spec.demographics.gender",
    "race_ethnicity": "mapped from spec.demographics.race_ethnicity",
    "how_did_you_hear": "Company website"
  }
}
```

### Step 5: Write accounts.json

Write `accounts.json` using the Write tool:

```json
{
  "credential_mode": "stored",
  "portals": [
    {
      "company": "RBC",
      "portal_type": "workday",
      "portal_url": "https://rbc.wd3.myworkdayjobs.com",
      "username": "user@email.com",
      "password": "user-provided-password",
      "status": "ready"
    },
    {
      "company": "Google",
      "portal_type": "custom",
      "portal_url": "https://careers.google.com",
      "username": "",
      "password": "",
      "status": "manual"
    }
  ],
  "common_answers": { "..." }
}
```

### Step 6: Ensure .gitignore

Check if `accounts.json` is in `.gitignore`. If not, append it:

```bash
echo "accounts.json" >> .gitignore
```

### Step 7: Summary

> "Portal accounts configured!
>
> | Portal | Status |
> |--------|--------|
> | RBC (Workday) | Ready |
> | Google (Custom) | Manual — you'll handle login |
> | Shopify (Greenhouse) | Ready |
>
> Saved to `accounts.json`.
>
> **Next step:** Run `/job-apply` to start submitting applications."

### Rules

1. NEVER display stored passwords back to the user after they enter them.
2. Always show the security warning before collecting any credentials.
3. If user chooses "prompt each time" mode, respect that in all downstream skills.
4. accounts.json must be gitignored — verify this before writing credentials.
5. One portal at a time — don't batch credential requests.
