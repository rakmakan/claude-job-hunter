---
name: job-filter
description: "Use when user wants to filter, rank, or curate discovered job listings, or after running /job-discover to score jobs against their profile and resume"
---

# Job Filter — Score & Curate Job Listings

Score each discovered job against the user's spec and resume, then present a ranked list for interactive approval.

## Trigger

- Manual: `/job-filter`
- After `/job-discover` completes, suggest this as next step

## Prerequisites

All three must exist in the working directory:
- `spec.json` (from Phase 1)
- `jobs-raw.json` (from Phase 2)
- `resume.tex` (user's master resume)

If any is missing, tell the user which file is needed and which skill to run.

## Behavior

### Step 1: Load all data

Read all three files using the Read tool:
- From `spec.json`: targeting preferences, deal-breakers, key strengths, locations, work mode
- From `jobs-raw.json`: all discovered jobs with descriptions
- From `resume.tex`: skills, experience, technologies, role history

### Step 2: Extract resume keywords

Parse `resume.tex` to build a keyword profile:
- **Technical skills** from the Technical Skills section (e.g., Python, PyTorch, Kubernetes, LLM)
- **Domain keywords** from experience bullets (e.g., fraud detection, NLP, MLOps, CI/CD)
- **Seniority indicators** from titles and years (e.g., Senior, Lead, 8+ years)
- **Tools/platforms** (e.g., AWS, Docker, MLflow, Grafana)

### Step 3: Score each job

For each job in `jobs-raw.json`, compute a fit score (0-100):

**Keyword Match (0-30 points):**
- Count how many of the JD's required/preferred skills appear in the resume
- Score = (matched_keywords / total_required_keywords) * 30
- Weight "required" keywords 2x vs "nice to have"

**Experience Level Fit (0-25 points):**
- Extract seniority from JD title (junior/mid/senior/staff/principal/lead)
- Compare against user's `current_title` and `years_experience` from spec
- Exact match = 25, one level off = 15, two levels off = 5, more = 0

**Location Match (0-20 points):**
- Job location matches spec locations = 20
- Job is remote and user wants remote = 20
- Job is hybrid and user wants hybrid = 15
- Partial match (same country, different city) = 10
- No match = 0

**Industry/Role Fit (0-15 points):**
- Job title contains target role keywords = 15
- Job title is related but not exact = 10
- Job is in target industry = 5 (additive with title match, cap at 15)

**Deal-Breaker Check (-100 points):**
- If JD mentions any of the user's deal-breakers → instant -100 (effectively filters out)

**Bonus (0-10 points):**
- Job posted within last 7 days = +5
- Company is in user's explicit company list = +5

### Step 4: Present ranked list

Sort jobs by score (descending). Present interactively in batches of 10:

> "Here are your top matches:
>
> | # | Score | Company | Title | Location | Top Matches | Gaps |
> |---|-------|---------|-------|----------|-------------|------|
> | 1 | 92 | Google | Sr ML Engineer | Toronto, Remote | PyTorch, LLM, K8s | Spark |
> | 2 | 87 | Shopify | Staff ML Eng | Toronto, Hybrid | Python, MLOps | Ruby |
> | ... | ... | ... | ... | ... | ... | ... |
>
> For each job, reply with:
> - **a** = approve (will tailor resume and apply)
> - **r** = reject (skip this job)
> - **b** = bookmark (save for later, don't apply now)
> - **d** = details (show full job description)
>
> Or reply **'approve all'** / **'reject below [score]'** for bulk actions."

Continue presenting batches until all jobs are reviewed.

### Step 5: Generate jobs-approved.json

Write `jobs-approved.json` with only approved jobs, adding scoring metadata:

```json
{
  "filtered_at": "YYYY-MM-DD",
  "jobs": [
    {
      "id": "from-jobs-raw",
      "company": "Company Name",
      "title": "Job Title",
      "url": "https://...",
      "description": "Full JD text",
      "location": "City, Province",
      "work_mode": "remote",
      "posted_date": "YYYY-MM-DD",
      "portal_type": "workday",
      "portal_url": "https://...",
      "raw_metadata": {},
      "fit_score": 92,
      "matching_keywords": ["PyTorch", "LLM", "Kubernetes", "Docker", "Python"],
      "gap_keywords": ["Spark"],
      "status": "approved"
    }
  ],
  "bookmarked": [
    { "...same structure...", "status": "bookmarked" }
  ],
  "rejected_count": 15,
  "total_discovered": 45
}
```

### Step 6: Summary

> "Filtering complete!
> - **Approved:** [N] jobs ready for resume tailoring
> - **Bookmarked:** [N] jobs saved for later
> - **Rejected:** [N] jobs filtered out
>
> Saved to `jobs-approved.json`.
>
> **Next steps:**
> - Run `/job-tailor` to create tailored resumes and cover letters for all approved jobs
> - Run `/job-accounts` to set up portal credentials before applying"

### Rules

1. Never modify `jobs-raw.json` — it's the source of truth from discovery.
2. Always show the user the full list before filtering — no silent rejections.
3. The scoring algorithm is transparent — show matching and gap keywords for each job.
4. If user asks for details on a job, show the full description before they decide.
5. Deal-breakers are absolute — never present a deal-breaker job as a match.
6. If all jobs score below 50, warn the user: "None of the discovered jobs are strong matches. Consider adjusting your target roles or companies in spec.json."
