---
name: job-tailor
description: "Use when user wants to tailor their resume for a job, create a cover letter, optimize resume for ATS, or when a job description is pasted and detected by the JD auto-detection hook"
---

# Job Tailor — Resume & Cover Letter Tailoring

Tailor the user's master resume and generate a research-informed cover letter for each approved job. Compiles both to PDF using XeLaTeX.

## Trigger

- Manual: `/job-tailor` (processes all approved jobs from `jobs-approved.json`)
- Auto-trigger: when JD is pasted and detected by the `jd-detector` hook
- Manual with argument: `/job-tailor [paste JD here]` for a single ad-hoc job

## Prerequisites

- `resume.tex` in the working directory (the master resume — never modified)
- `spec.json` (from Phase 1) — for personal info and preferences
- For batch mode: `jobs-approved.json` (from Phase 3)
- LaTeX installation with XeLaTeX available via command line

Check LaTeX availability:
```bash
which xelatex
```
If not found, tell user: "XeLaTeX is required to compile resumes. Install MacTeX (macOS) or TexLive (Linux)."

## Behavior

### Mode Detection

**Batch mode** (when `jobs-approved.json` exists and no JD argument):
- Process each approved job sequentially
- Create a subdirectory per job

**Single mode** (when JD is pasted directly or provided as argument):
- Extract company name and role from the JD
- Process just that one job
- Still creates a subdirectory

### Per-Job Processing

#### Step 1: Create output directory

```
applications/YYYY-MM-DD-{company-slug}-{role-slug}/
```

Slugify: lowercase, replace spaces with hyphens, remove special characters.
Example: `applications/2026-04-01-google-senior-ml-engineer/`

Use Bash to create: `mkdir -p applications/YYYY-MM-DD-company-role/`

#### Step 2: Research the company

Use WebSearch to gather:
1. "[Company] culture values" — understand their values and tone
2. "[Company] engineering blog" — understand their tech stack emphasis
3. "[Company] recent news" — find recent achievements or initiatives to reference in cover letter
4. "[Company] glassdoor reviews" — understand work environment

Compile a brief internal research note (not saved, just used for tailoring decisions).

#### Step 3: Tailor the resume (Moderate strategy)

Read `resume.tex` using the Read tool. Create a tailored copy following these rules:

**Summary/headline adjustments:**
- Update the headline (e.g., "Senior AI/ML Engineer" → "Senior Machine Learning Engineer") to match the JD's title language
- Rephrase the summary paragraph to lead with the most relevant experience for THIS role
- Incorporate 2-3 key JD keywords naturally into the summary

**Experience bullet reordering:**
- Within each role, reorder bullets so the most relevant ones (matching JD requirements) come first
- Comment out (`% `) bullets that are least relevant IF the resume exceeds 2 pages. Never comment out more than 30% of bullets per role.
- Never comment out entire roles — they show career progression

**Keyword optimization (ATS compliance):**
- Identify keywords from the JD that exist in the resume under different phrasing
- Replace with JD's exact phrasing where natural (e.g., "ML pipelines" → "machine learning pipelines" if that's what the JD says)
- Add missing high-priority keywords to the Technical Skills section if the user genuinely has that skill (check against `spec.json` key_strengths)
- Ensure keywords appear in BOTH the skills section AND experience bullets (ATS scanners check both)

**ATS best practices (apply to every tailored resume):**
- No tables in the skills section for ATS parsing (convert to comma-separated if needed)
- No images, icons, or graphics that ATS can't read (LaTeX text commands are fine)
- Use standard section headings: "Experience", "Education", "Technical Skills"
- Include the exact job title from the JD somewhere in the resume
- Spell out acronyms at least once (e.g., "Natural Language Processing (NLP)")

**What NEVER to do:**
- Never fabricate experience, projects, or metrics
- Never add skills the user doesn't have
- Never change dates, companies, or titles of past roles
- Never remove the Education section
- Never change contact information

Write the tailored LaTeX to `applications/YYYY-MM-DD-company-role/resume-tailored.tex` using the Write tool.

#### Step 4: Compile resume PDF

```bash
cd applications/YYYY-MM-DD-company-role && xelatex -interaction=nonstopmode resume-tailored.tex
```

Run twice if needed for proper cross-references. Check that `resume-tailored.pdf` was created:
```bash
ls -la applications/YYYY-MM-DD-company-role/resume-tailored.pdf
```

If compilation fails, read the `.log` file to diagnose. Common issues:
- Missing fonts: suggest user install SourceSansPro or update `\setmainfont` in their resume.tex
- Missing packages: suggest `tlmgr install [package]`

#### Step 5: Research cover letter tone

Based on Step 2 research:
- **Startup/tech company** → more casual, emphasize passion and impact
- **Enterprise/finance** → more formal, emphasize reliability and compliance experience
- **Company with strong mission** → connect personal motivation to their mission
- Override with `spec.json` `cover_letter_tone` preference if it conflicts

Use WebSearch: "how to write cover letter for [company name]" or "[company name] application tips"

#### Step 6: Generate cover letter

Write a cover letter in LaTeX format. The cover letter must:

**Structure:**
1. Header matching resume style (same fonts, contact info layout)
2. Date and recipient (use "Dear Hiring Team at [Company]," if no specific name)
3. Opening paragraph: hook with specific relevant achievement → state the role you're applying for
4. Body paragraph 1: map your strongest experience to their top 2-3 requirements
5. Body paragraph 2: demonstrate knowledge of their company (from research) and why you're drawn to it
6. Closing paragraph: call to action, availability, enthusiasm
7. Signature

**Rules:**
- 250-400 words total (not counting header/signature)
- Reference specific JD requirements and match them to specific resume achievements
- Include at least one reference to something company-specific (from research)
- Never use generic phrases like "I am writing to express my interest" — start with impact
- Match the user's `cover_letter_tone` from spec
- Do not repeat the resume — the cover letter tells the story behind the bullets

Write to `applications/YYYY-MM-DD-company-role/cover-letter.tex` using the Write tool.

**Cover letter LaTeX template structure:**

```latex
\documentclass[a4paper,10pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{fontspec}
\usepackage{hyperref}
\hypersetup{colorlinks=true,urlcolor=black}

% Match resume fonts if available
\setmainfont[
BoldFont=SourceSansPro-Semibold.otf,
ItalicFont=SourceSansPro-RegularIt.otf
]{SourceSansPro-Regular.otf}

\pagestyle{empty}

\begin{document}

% Header — match resume header style
\begin{center}
{\Huge [Name]} \\
\vspace{0.1cm}
[Phone] | [Email] | [LinkedIn] | [GitHub]
\end{center}

\vspace{0.5cm}

\noindent [Date] \\[0.3cm]
\noindent Dear Hiring Team at [Company], \\[0.3cm]

\noindent [Opening paragraph — lead with impact, state the role] \\[0.3cm]

\noindent [Body paragraph 1 — match experience to requirements] \\[0.3cm]

\noindent [Body paragraph 2 — company-specific connection] \\[0.3cm]

\noindent [Closing — call to action] \\[0.3cm]

\noindent Best regards, \\
[Name]

\end{document}
```

#### Step 7: Compile cover letter PDF

```bash
cd applications/YYYY-MM-DD-company-role && xelatex -interaction=nonstopmode cover-letter.tex
```

Verify `cover-letter.pdf` was created.

#### Step 8: Write job summary

Write `applications/YYYY-MM-DD-company-role/job-summary.md`:

```markdown
# [Company] — [Role Title]

**Applied:** YYYY-MM-DD
**URL:** [job listing URL]
**Fit Score:** [score from filtering, or "N/A" for ad-hoc]

## Why This Is a Fit
- [2-3 bullet points on alignment]

## Keywords Targeted
[comma-separated list of keywords optimized for]

## Gaps Noted
[comma-separated list of JD requirements not strongly on resume]

## Company Research Notes
- Culture: [brief note]
- Recent news: [brief note]
- Tech emphasis: [brief note]
```

#### Step 9: Report to user

After each job (or after all jobs in batch mode):

> "Tailored resume and cover letter ready for [Company] — [Role]:
> - `applications/YYYY-MM-DD-company-role/resume-tailored.pdf`
> - `applications/YYYY-MM-DD-company-role/cover-letter.pdf`
> - `applications/YYYY-MM-DD-company-role/job-summary.md`
>
> **Keywords optimized:** [list]
> **Changes made:** [brief: reordered X bullets, added Y keywords, adjusted summary]"

In batch mode, show a final summary table:

> | Company | Role | Status | Directory |
> |---------|------|--------|-----------|
> | Google | Sr ML Eng | Done | applications/2026-04-01-google-.../ |
> | Shopify | Staff ML | Done | applications/2026-04-01-shopify-.../ |

### Rules

1. NEVER modify `resume.tex` — always write to `resume-tailored.tex` in the job subdirectory.
2. Never fabricate experience or skills. Reorder and rephrase only.
3. Every cover letter must reference something specific from company research — no generic letters.
4. If XeLaTeX is not available, write the `.tex` files and tell user to compile manually.
5. ATS optimization is mandatory — apply the ATS best practices to every resume.
6. Comment out irrelevant bullets with `% ` prefix so they can be restored.
