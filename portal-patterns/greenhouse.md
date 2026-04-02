# Greenhouse Portal — Form Filling Patterns

## URL Detection
- `boards.greenhouse.io/*`
- `*.greenhouse.io`
- URL contains `greenhouse`

## Application Flow

Greenhouse is typically a single-page form:
1. **Personal Info** — Name, email, phone
2. **Resume Upload** — File upload
3. **Cover Letter** — File upload or text field
4. **LinkedIn Profile** — URL field
5. **Custom Questions** — Company-specific (0-10 questions)
6. **EEO/Demographic** — Optional section at bottom
7. **Submit**

### Navigation
No multi-step wizard. Single page with scroll. Submit button at bottom.

## Field Mapping

| Form Label | Spec Field | Notes |
|-----------|-----------|-------|
| First Name | `personal.name` (split) | |
| Last Name | `personal.name` (split) | |
| Email | `personal.email` | |
| Phone | `personal.phone` | |
| Resume | File upload | `resume-tailored.pdf` |
| Cover Letter | File upload or textarea | `cover-letter.pdf` or paste text |
| LinkedIn Profile | `personal.linkedin` | |
| Website | `personal.portfolio` | Optional |

### Custom Questions
Greenhouse custom questions vary widely. Common patterns:
- "Are you authorized to work in [country]?" → Map from `demographics.work_authorization`
- "Will you require sponsorship?" → Map from `demographics.sponsorship_needed`
- "How did you hear about this role?" → "Company website"
- "Salary expectations" → Map from `targeting.salary_range`
- Free-text questions → Ask user

### EEO Section
- Gender, race, veteran status dropdowns
- Map from `common_answers`
- All optional — select "Decline to self-identify" if user chose "prefer not to answer"

## Common Issues
1. **Simple forms**: Greenhouse is usually the easiest portal. Most applications take <2 minutes.
2. **Custom questions**: These are the main variable. If a question can't be mapped, ask user.
3. **No account needed**: Greenhouse typically doesn't require login — just fill and submit.
