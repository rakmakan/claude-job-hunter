# Workday Portal — Form Filling Patterns

## URL Detection
- `*.myworkdayjobs.com`
- `*.wd1.myworkdayjobs.com` through `*.wd12.myworkdayjobs.com`
- URL contains `/workday/` or `/wday/`

## Application Flow

Workday uses a multi-step wizard. Typical steps:

1. **My Information** — Name, email, address, phone
2. **My Experience** — Work history, education
3. **Application Questions** — Custom questions per company
4. **Voluntary Disclosures** — EEO, veteran status, disability
5. **Self-Identify** — Gender, race, ethnicity
6. **Review & Submit** — Final review page

### Navigation
- Click "Next" or "Continue" button to advance
- Use `browser_click` on the primary action button
- Look for `[data-automation-id="bottom-navigation-next-button"]` or button text "Next"
- Some Workday instances use "Save and Continue"

## Field Mapping

### My Information
| Form Label | Spec Field | Notes |
|-----------|-----------|-------|
| First Name | `personal.name` (split) | Split on first space |
| Last Name | `personal.name` (split) | Everything after first space |
| Email | `personal.email` | |
| Phone | `personal.phone` | May need country code prefix |
| Address Line 1 | `personal.address.street` | |
| City | `personal.address.city` | |
| State/Province | `personal.address.province` | Dropdown — use `browser_select_option` |
| Postal Code | `personal.address.postal` | |
| Country | `personal.address.country` | Dropdown |

### My Experience (Work History)

**Critical: Workday expects summarized descriptions, NOT bullet points.**

For each role from resume.tex, generate a 4-5 line summary paragraph:
- Combine the most impactful 3-4 bullets into flowing prose
- Focus on: scope, impact, technologies used, and team leadership
- Example: "Led a team of 2 engineers to architect and deploy a production ML pipeline serving 40 applications across 15 languages. Reduced deployment time by 95% through CI/CD automation. Built distributed training infrastructure for transformer models, achieving 95% reduction in training time."

| Form Label | Source | Notes |
|-----------|--------|-------|
| Job Title | From resume `\subsection*` | |
| Company | From resume `\subtext` | |
| Start Date | From resume date range | Format: MM/YYYY |
| End Date | From resume date range | "Present" for current role |
| Description | Generated summary | 4-5 lines, paragraph form |

### Skills Section

**Critical: Add 25+ relevant skills.**

Combine skills from:
1. Resume Technical Skills section (all listed skills)
2. JD required skills that the user has
3. JD preferred skills that the user has
4. Domain-specific skills from experience (e.g., "Fraud Detection", "Regulatory Compliance")

Enter skills one at a time. In Workday's skill input:
1. Type the skill name in the search box
2. Wait for autocomplete dropdown
3. Click the matching suggestion using `browser_click`
4. If no autocomplete match, type the full skill and press Enter

### Resume Upload
- Look for file upload input: `[data-automation-id="file-upload-input-ref"]`
- Use `browser_file_upload` with the path to `resume-tailored.pdf`
- Some instances also have a "Cover Letter" upload — upload `cover-letter.pdf`

### Voluntary Disclosures
Map from `common_answers` in accounts.json. These are always optional.
- Use `browser_select_option` for dropdowns
- Use `browser_click` for radio buttons

### Source/Referral
- "How did you hear about us?" → Select "Company Website" unless spec says otherwise
- Use `browser_select_option` or `browser_click` depending on field type

## Common Issues

1. **Session timeout**: Workday sessions expire after ~30 minutes. If a form times out, re-login and restart.
2. **Duplicate application detection**: Workday may block if already applied. Check for "You have already applied" message.
3. **Country-specific fields**: Some Workday instances add country-specific fields (e.g., SIN for Canada, SSN for US). Ask user for these — never guess.
4. **CAPTCHA on login**: Pause and ask user to complete manually.
