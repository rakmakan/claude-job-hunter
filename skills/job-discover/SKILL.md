---
name: job-discover
description: "Use when user wants to find job listings, search for open positions, discover jobs at target companies, or after running /job-brainstorm to search career sites"
---

# Job Discover — Find Open Positions at Target Companies

Crawl career websites of target companies using Playwright MCP and WebSearch to build a comprehensive list of matching job listings.

## Trigger

- Manual: `/job-discover`
- After `/job-brainstorm` completes, suggest this as next step

## Prerequisites

`spec.json` must exist in the working directory. If not found:
> "No `spec.json` found. Run `/job-brainstorm` first to set up your job search preferences."

## Behavior

### Step 1: Load spec and plan discovery

Read `spec.json` using the Read tool. Extract:
- `targeting.companies` — list of specific companies
- `targeting.discover_companies` — whether to discover additional companies
- `targeting.roles` — target role titles
- `targeting.locations` — target locations
- `targeting.industries` — target industries
- `targeting.work_mode` — remote/hybrid/onsite preference

If `discover_companies` is true or the companies list includes a "discover" instruction:
- Use WebSearch to find companies matching the user's industries + locations
- Search queries like: "[industry] companies hiring [role] in [location]"
- Present discovered companies to user for approval before crawling
- Ask: "I found these companies. Which should I include? (Select by number, 'all', or 'none')"

### Step 2: Find career pages

For each target company:
1. Use WebSearch: "[company name] careers page" or "[company name] jobs"
2. Identify the career site URL
3. Detect portal type from URL patterns:
   - `*.myworkdayjobs.com` or `*/workday/` → `workday`
   - `*.greenhouse.io` or `boards.greenhouse.io/*` → `greenhouse`
   - `*.lever.co` or `jobs.lever.co/*` → `lever`
   - `*.successfactors.com` or `*/career?company=*` → `successfactors`
   - Anything else → `custom`

### Step 3: Crawl each career site

For each company, use Playwright MCP tools:

1. **Navigate** to the career page using `browser_navigate`
2. **Take snapshot** using `browser_snapshot` to understand page structure
3. **Search for roles** — look for search/filter inputs:
   - Fill search box with each target role title using `browser_fill_form` or `browser_type`
   - Apply location filters if available using `browser_click` or `browser_select_option`
   - Apply work mode filters (remote/hybrid) if available
4. **Extract job listings** — from the results page:
   - Use `browser_snapshot` to read job cards/links
   - For each listing, extract: title, URL, location, posted date
   - Click into each job to get the full description using `browser_click` then `browser_snapshot`
5. **Handle pagination** — if there are multiple pages:
   - Click "Next" or page numbers to load more results
   - Continue until all relevant results are captured or 50 jobs per company (whichever comes first)

### Step 4: Build jobs-raw.json

Compile all discovered jobs into `jobs-raw.json` using the Write tool:

```json
{
  "discovered_at": "YYYY-MM-DD",
  "jobs": [
    {
      "id": "unique-id-from-portal-or-generated",
      "company": "Company Name",
      "title": "Job Title",
      "url": "https://full-url-to-job-listing",
      "description": "Full job description text",
      "location": "City, Province/State",
      "work_mode": "remote|hybrid|onsite|unknown",
      "posted_date": "YYYY-MM-DD or null if not available",
      "portal_type": "workday|successfactors|greenhouse|lever|custom",
      "portal_url": "https://base-career-site-url",
      "raw_metadata": {}
    }
  ]
}
```

### Step 5: Present summary to user

> "Job discovery complete! Here's what I found:
>
> | Company | Jobs Found | Portal Type |
> |---------|-----------|-------------|
> | [company] | [count] | [type] |
> | ... | ... | ... |
>
> **Total: [N] jobs across [N] companies**
>
> Saved to `jobs-raw.json`.
>
> **Next step:** Run `/job-filter` to score and curate this list against your profile."

### Error Handling

- If a career site blocks Playwright (CAPTCHA, bot detection):
  - Tell user: "[Company] career site has bot protection. Please open [URL] in your browser and I'll try a different approach."
  - Fall back to WebSearch: search for "[company] [role] job listing site:linkedin.com OR site:indeed.com"
  - Extract what's available from search results
- If a career site has no search functionality:
  - Browse available listings and filter by title keywords manually
- If no jobs match the role titles:
  - Report: "No matching roles found at [Company]. They may not be hiring for these positions currently."

### Rate Limiting

Wait 2-3 seconds between page navigations to avoid triggering rate limits. Do not crawl more than 50 jobs per company in a single run.

### Rules

1. Never apply to any jobs during discovery — this is read-only crawling.
2. Always detect and record the portal type — it's critical for Phase 6 (auto-apply).
3. Capture the FULL job description text, not just a summary.
4. If the user's company list is very long (>20), suggest batching: "You have [N] companies. Want me to discover jobs for all at once, or batch them?"
5. If `discover_companies` is true, always get user approval on the discovered company list before crawling.
