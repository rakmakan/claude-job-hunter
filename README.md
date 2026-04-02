# Claude Job Hunter

A Claude Code plugin that automates the end-to-end job application workflow.

## What It Does

1. `/job-brainstorm` — Interactive Q&A to create your job search profile (spec.json)
2. `/job-discover` — Crawls career websites to find matching job listings
3. `/job-filter` — Scores and ranks jobs against your profile; you approve/reject
4. `/job-tailor` — Tailors your resume and generates cover letters per job (ATS-optimized)
5. `/job-accounts` — Manages job portal credentials (Workday, Greenhouse, etc.)
6. `/job-apply` — Auto-fills and submits applications via Playwright

Also auto-detects when you paste a job description and offers to tailor your resume.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) (CLI, Desktop, or IDE extension)
- LaTeX with XeLaTeX ([MacTeX](https://www.tug.org/mactex/) on macOS, [TexLive](https://www.tug.org/texlive/) on Linux)
- [SourceSansPro](https://fonts.google.com/specimen/Source+Sans+Pro) fonts (or update font paths in your resume.tex)

Playwright MCP is bundled with this plugin — no separate installation needed.

## Installation

### Option 1: Plugin Marketplace (when available)

```
/plugin install claude-job-hunter
```

### Option 2: Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/rakshitmakan/claude-job-hunter.git
   ```

2. Copy the skills to your Claude Code skills directory:
   ```bash
   cp -r claude-job-hunter/skills/* ~/.claude/skills/
   ```

3. Copy the hooks configuration. Add the contents of `hooks/hooks.json` to your Claude Code settings to enable JD auto-detection.

4. Place your `resume.tex` in your working directory.

## Quick Start

1. Navigate to a directory where you want to manage your job search:
   ```bash
   cd ~/job-search
   cp /path/to/your/resume.tex .
   ```

2. Run the brainstorming session:
   ```
   /job-brainstorm
   ```

3. Follow the pipeline: `/job-discover` -> `/job-filter` -> `/job-tailor` -> `/job-accounts` -> `/job-apply`

Or simply paste a job description to tailor your resume for a specific role.

## File Structure

After running through the pipeline, your directory will look like:

```
your-working-directory/
├── resume.tex                    # Your master resume (never modified)
├── spec.json                     # Your job search profile
├── jobs-raw.json                 # All discovered jobs
├── jobs-approved.json            # Your curated job list
├── accounts.json                 # Portal credentials (gitignored)
├── applications-log.json         # Application status tracker
└── applications/
    ├── 2026-04-01-google-sr-ml-engineer/
    │   ├── resume-tailored.tex
    │   ├── resume-tailored.pdf
    │   ├── cover-letter.tex
    │   ├── cover-letter.pdf
    │   ├── job-summary.md
    │   └── confirmation.png
    └── 2026-04-01-shopify-staff-ml/
        └── ...
```

## Supported Job Portals

| Portal | Auto-Fill | Notes |
|--------|-----------|-------|
| Workday | Full | Multi-step wizard, skills, experience summaries |
| SuccessFactors | Full | Multi-step, country-specific fields |
| Greenhouse | Full | Single-page, simple forms |
| Lever | Full | Single-page, simple forms |
| Custom | Best-effort | Snapshot-based field detection |

## Security

- `accounts.json` stores credentials in plaintext and is automatically gitignored
- You can choose "prompt each time" mode to avoid storing credentials
- Never commit `accounts.json` to version control
- The plugin never submits an application without your explicit confirmation

## Resume Tailoring Strategy

The plugin uses a **moderate** tailoring approach:
- Reorders bullet points to lead with relevant experience
- Rephrases to incorporate JD keywords naturally
- Adjusts summary/headline to match target role
- Comments out less relevant bullets (never deletes)
- **Never fabricates** experience, skills, or metrics

## License

MIT
