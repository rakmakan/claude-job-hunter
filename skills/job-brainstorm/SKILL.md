---
name: job-brainstorm
description: "Use when starting a job search, creating a job application profile, or when user says they want to find jobs, apply to jobs, or set up their job search preferences"
---

# Job Brainstorm — Interactive Spec Creation

Create a comprehensive job search spec through a structured Q&A session. This spec drives all downstream skills: job discovery, filtering, resume tailoring, and auto-applying.

## Trigger

- Manual: `/job-brainstorm`
- User says anything about starting a job search, wanting to apply to jobs, or setting up preferences

## Behavior

### Step 1: Read the user's resume

Before asking any questions, read `resume.tex` in the current working directory to pre-fill known information.

Use the Read tool to read `resume.tex`. Extract:
- Name (from `\Huge` or header section)
- Email (from `\faEnvelope` or `mailto:`)
- Phone (from `\faPhone`)
- LinkedIn URL (from `\faLinkedin`)
- GitHub URL (from `\faGithub`)
- Current title (from subtitle or first `\subsection*`)
- Skills list (from Technical Skills section)

If `resume.tex` is not found, tell the user:
> "I don't see a `resume.tex` in this directory. Please either place your LaTeX resume here, or use `templates/example-resume.tex` from this plugin as a starting point."

### Step 2: Confirm pre-filled info

Present what you extracted:

> "I've read your resume. Here's what I found:
> - **Name:** [extracted]
> - **Email:** [extracted]
> - **Phone:** [extracted]
> - **LinkedIn:** [extracted]
> - **GitHub:** [extracted]
> - **Current title:** [extracted]
>
> Is this correct? Anything to update?"

Wait for confirmation before proceeding.

### Step 3: Gather missing personal info

Ask ONE question at a time. Use multiple choice where possible. Skip fields already extracted from the resume.

**Address:**
> "What's your current mailing address? Job portals typically ask for this.
> Please provide: street address, city, province/state, postal/ZIP code, country."

**Portfolio (if not on resume):**
> "Do you have a portfolio or personal website URL? (Enter URL or 'none')"

### Step 4: Demographics & compliance

Explain why these are needed:
> "Job portals ask demographic questions for equal opportunity compliance. I'll store your answers so you don't have to re-enter them. All answers are optional — you can say 'prefer not to answer' for any."

Ask each ONE at a time:

**Work authorization** (ask this first — it's the most important):
> "What is your work authorization status?
> a) Citizen
> b) Permanent Resident
> c) Work Permit (specify type)
> d) Need Visa Sponsorship"

**Sponsorship:**
> "Will you now or in the future require visa sponsorship?
> a) Yes
> b) No"

**Gender identity:**
> "How do you identify? (This is for EEO forms on job portals)
> a) Male
> b) Female
> c) Non-binary
> d) Prefer not to answer
> e) Other (specify)"

**Race/ethnicity:**
> "What is your race/ethnicity? (For EEO compliance)
> a) Asian
> b) Black or African American
> c) Hispanic or Latino
> d) White
> e) Two or more races
> f) Native American or Alaska Native
> g) Native Hawaiian or Pacific Islander
> h) Prefer not to answer"

**Veteran status:**
> "Are you a protected veteran?
> a) Yes
> b) No
> c) Prefer not to answer"

**Disability status:**
> "Do you have a disability?
> a) Yes
> b) No
> c) Prefer not to answer"

**Sexual orientation** (some portals ask this):
> "What is your sexual orientation? (Some portals ask this for diversity reporting)
> a) Heterosexual
> b) LGBTQ+
> c) Prefer not to answer"

### Step 5: Job targeting

**Target roles:**
> "What job titles are you targeting? List all that apply.
> (e.g., Senior ML Engineer, Staff AI Engineer, Machine Learning Lead)"

**Target companies:**
> "Do you have specific companies in mind, or would you like me to discover companies for you?
> a) I have a list (provide company names)
> b) Discover companies for me based on my profile
> c) Both — I have some, but discover more too"

**Industries:**
> "Which industries are you interested in? (Select all that apply)
> a) Tech / Software
> b) Fintech / Financial Services
> c) Healthcare / Healthtech
> d) Pharma / Biotech
> e) AI / ML focused companies
> f) E-commerce / Retail
> g) Consulting
> h) Other (specify)"

**Locations:**
> "Where do you want to work? List cities, provinces, or countries.
> (e.g., Toronto ON, Vancouver BC, Remote - Canada)"

**Work mode:**
> "What work arrangement do you prefer?
> a) Remote only
> b) Hybrid
> c) Onsite
> d) Open to all"

**Salary:**
> "What's your target salary range and currency?
> (e.g., 150000-220000 CAD, or 'flexible')"

**Availability:**
> "What is your earliest start date?
> (e.g., 2026-05-01, or 'immediately', or '2 weeks notice')"

### Step 6: Resume context

**Key strengths:**
> "What are your top 3-5 strengths you want emphasized across all applications?
> (e.g., Agentic AI, LLM evaluation, production ML systems)"

**Downplay:**
> "Is there anything on your resume you'd prefer to de-emphasize?
> (e.g., an old role, a specific technology — or 'nothing')"

### Step 7: Application preferences

**Cover letter tone:**
> "What tone for cover letters?
> a) Formal/traditional
> b) Professional but conversational (recommended)
> c) Technical/engineering-focused"

**Relocate:**
> "Are you willing to relocate?
> a) Yes
> b) No
> c) Depends on the opportunity"

**Company size:**
> "What company sizes do you prefer? (Select all)
> a) Startup (< 50 employees)
> b) Mid-size (50-1000)
> c) Enterprise (1000+)
> d) No preference"

**Deal-breakers:**
> "Any deal-breakers? Industries, technologies, or practices you want to avoid?
> (e.g., defense, crypto, mandatory onsite — or 'none')"

### Step 8: Generate spec.json

After all questions are answered, compile everything into `spec.json` using the Write tool. Follow the schema in `schemas/spec-schema.json`.

Present a summary to the user:

> "Your job search spec is ready! Here's a summary:
> - **Targeting:** [N] role types across [N] companies in [locations]
> - **Work mode:** [remote/hybrid/onsite]
> - **Key strengths:** [list]
> - **Cover letter style:** [tone]
>
> Saved to `spec.json`. You can edit this file anytime to update your preferences.
>
> **Next steps:**
> - Run `/job-discover` to find matching jobs at your target companies
> - Or paste a job description to tailor your resume for a specific role"

### Rules

1. Ask ONE question per message. Never batch multiple questions.
2. Use multiple choice (a/b/c/d) whenever the answer set is bounded.
3. Pre-fill from resume — never ask for info you already extracted.
4. All demographic questions are optional — always include "prefer not to answer".
5. Never judge or comment on demographic answers.
6. If user says "skip" for any section, use reasonable defaults or null values.
7. Convert relative dates to absolute (e.g., "next month" → "2026-05-01").
8. Validate the final spec.json against `schemas/spec-schema.json` before saving.
