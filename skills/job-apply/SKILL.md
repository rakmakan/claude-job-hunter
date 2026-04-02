---
name: job-apply
description: "Use when user wants to submit job applications, auto-apply to approved jobs, fill out job portal forms, or after running /job-tailor and /job-accounts to submit applications via Playwright"
---

# Job Apply — Auto-Fill & Submit Applications

Navigate to job portals via Playwright MCP, fill application forms using portal-specific patterns, upload tailored resumes and cover letters, and submit applications.

## Trigger

- Manual: `/job-apply`
- After `/job-tailor` and `/job-accounts` complete, suggest this as next step

## Prerequisites

All of these must exist:
- `spec.json` (from Phase 1)
- `jobs-approved.json` (from Phase 3)
- `accounts.json` (from Phase 5)
- Per-job: `applications/YYYY-MM-DD-company-role/resume-tailored.pdf` and `cover-letter.pdf` (from Phase 4)

Check each prerequisite. If any is missing:
> "Missing [file]. Run [/skill-name] first."

If resume PDFs are missing for some jobs:
> "Tailored resumes are missing for [N] jobs. Run `/job-tailor` first, or I can process only the jobs that have tailored resumes."

## Behavior

### Step 1: Load all data

Read using the Read tool:
- `spec.json` — personal info, demographics
- `jobs-approved.json` — job list with portal types and URLs
- `accounts.json` — portal credentials and common answers
- Read the portal pattern file for each portal type from the plugin's `portal-patterns/` directory

### Step 2: Present application plan

> "Ready to apply to [N] jobs:
>
> | # | Company | Role | Portal | Status |
> |---|---------|------|--------|--------|
> | 1 | RBC | Sr ML Eng | Workday | Ready |
> | 2 | Shopify | Staff ML | Greenhouse | Ready |
> | 3 | Google | Sr AI Eng | Custom | Manual login required |
>
> **Options:**
> a) Apply to all
> b) Select specific jobs by number
> c) Apply one at a time (I'll confirm between each)
>
> Which approach?"

Recommend option (c) for the first run so the user can monitor the process.

### Step 3: Per-job application

For each job to apply:

#### 3a: Navigate to the job

Use Playwright MCP `browser_navigate` to go to the job's application URL.

If the portal requires login:
- If `accounts.json` has credentials: navigate to login page, fill username/password using `browser_fill_form`, click login
- If credential mode is "prompt_each_time": ask user for credentials now
- If credential mode is "manual": tell user "Please log in to [portal] in the browser, then let me know when you're ready"

After login, navigate to the specific job application page.

#### 3b: Take initial snapshot

Use `browser_snapshot` to capture the form structure. Identify:
- What type of form this is (multi-step wizard vs single page)
- Which portal pattern file applies
- What fields are visible

#### 3c: Read portal pattern file

Based on the detected `portal_type`, read the corresponding pattern file:
- `workday` → read `portal-patterns/workday.md` from the plugin directory
- `successfactors` → read `portal-patterns/successfactors.md`
- `greenhouse` → read `portal-patterns/greenhouse.md`
- `lever` → read `portal-patterns/lever.md`
- `custom` → no pattern file; use best-effort snapshot analysis

Follow the field mapping and navigation instructions from the pattern file.

#### 3d: Fill the form

For each field on the form:

1. **Identify the field** from the snapshot (label text, field type, automation IDs)
2. **Map to data source** in this priority order:
   - `common_answers` in accounts.json (for demographics, address, etc.)
   - `spec.json` personal info
   - `resume.tex` content (for work history, education)
   - Portal pattern file recommendations (for "how did you hear", etc.)
3. **Fill the field** using the appropriate Playwright MCP tool:
   - Text inputs: `browser_fill_form` or `browser_type`
   - Dropdowns: `browser_select_option`
   - Checkboxes/radio buttons: `browser_click`
   - File uploads: `browser_file_upload`
4. **If field cannot be mapped**: follow Missing Info Protocol (below)

**Work experience sections (especially Workday):**
- Read resume.tex for each role
- Generate summarized descriptions (4-5 line paragraphs, NOT bullet points) as specified in the portal pattern file
- Add 25+ skills as specified in workday.md pattern
- Use dates from resume in the format the portal expects

**Resume and cover letter upload:**
- Upload `applications/YYYY-MM-DD-company-role/resume-tailored.pdf`
- Upload `applications/YYYY-MM-DD-company-role/cover-letter.pdf`
- Use `browser_file_upload` with the absolute file path

#### 3e: Handle multi-step wizards

For Workday and SuccessFactors:
- After filling all visible fields on a step, click "Next"/"Continue"
- Take a new snapshot after each step loads
- Repeat fill process for the new step
- Continue until reaching the review/submit page

#### 3f: Review before submit

Before clicking Submit:
1. Take a `browser_snapshot` of the review page
2. Present a summary to the user:

> "About to submit application to [Company] for [Role]. Review page shows:
> - Name: [filled]
> - Email: [filled]
> - Resume: [uploaded]
> - Cover letter: [uploaded]
> - [any notable fields]
>
> **Submit this application?** (yes/no)"

Wait for user confirmation. NEVER submit without explicit approval.

#### 3g: Submit and capture confirmation

After user approves:
1. Click the Submit button using `browser_click`
2. Wait for confirmation page using `browser_wait_for`
3. Take a screenshot using `browser_take_screenshot`
4. Save screenshot to `applications/YYYY-MM-DD-company-role/confirmation.png`

### Step 4: Missing Info Protocol

When a form field cannot be filled from any data source:

1. Take a `browser_take_screenshot` showing the problematic field
2. Ask the user:
> "The application for [Company] — [Role] has a field I can't fill:
> **Field:** [label text]
> **Type:** [text/dropdown/checkbox/etc.]
> **Options (if dropdown):** [list options if visible]
>
> What should I enter?"
3. Wait for user response
4. Fill the field with the user's answer
5. Ask: "Should I save this answer for future applications? (yes/no)"
6. If yes, add to `common_answers` in accounts.json

### Step 5: Handle errors

**CAPTCHA encountered:**
> "CAPTCHA detected on [Company]'s portal. Please solve it in the browser, then say 'done' to continue."

**Bot detection / access blocked:**
> "[Company] has blocked automated access. You'll need to apply manually at: [URL]"
Mark as `"needs_manual_review"` in the log.

**Session timeout:**
> "Session expired on [Company]'s portal. Re-logging in..."
Re-login and retry from where it left off.

**Form submission error:**
Take a screenshot, show the error to the user, and ask how to proceed.

### Step 6: Log results

After each application attempt, append to `applications-log.json`:

```json
{
  "applications": [
    {
      "company": "RBC",
      "role": "Senior ML Engineer",
      "job_id": "12345",
      "url": "https://...",
      "applied_at": "2026-04-01T14:30:00Z",
      "status": "submitted",
      "confirmation_screenshot": "applications/2026-04-01-rbc-senior-ml-engineer/confirmation.png",
      "notes": ""
    }
  ]
}
```

Status values: `"submitted"`, `"needs_manual_review"`, `"failed"`, `"skipped_by_user"`

### Step 7: Final summary

After all applications are processed:

> "Application session complete!
>
> | Company | Role | Status |
> |---------|------|--------|
> | RBC | Sr ML Eng | Submitted |
> | Shopify | Staff ML | Submitted |
> | Google | Sr AI Eng | Needs manual review (CAPTCHA) |
>
> **Submitted:** [N]
> **Needs manual review:** [N]
> **Failed:** [N]
>
> Full log saved to `applications-log.json`.
> Confirmation screenshots saved in each job's `applications/` subdirectory."

### Rules

1. **NEVER submit without user confirmation.** Always show the review page and ask.
2. **NEVER guess missing information.** Always ask the user.
3. **Wait 3-5 seconds between page actions** to avoid triggering rate limits.
4. **Take snapshots frequently** — before filling, after filling, at review, after submission.
5. **One application at a time** unless user explicitly chose "apply to all" and confirmed.
6. **Read the portal pattern file** for the detected portal type before filling any form.
7. **Log every attempt** — successful or not — to applications-log.json.
8. **If anything looks wrong** (unexpected page, error message, different form than expected), stop and ask the user before proceeding.
