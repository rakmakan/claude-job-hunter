# Lever Portal — Form Filling Patterns

## URL Detection
- `jobs.lever.co/*`
- `*.lever.co`
- URL contains `lever.co`

## Application Flow

Lever is similar to Greenhouse — typically single-page:
1. **Personal Info** — Name, email, phone, current company, LinkedIn
2. **Resume Upload** — File upload
3. **Cover Letter** — Optional file upload
4. **Additional Info** — URLs (LinkedIn, GitHub, portfolio)
5. **Custom Questions** — Company-specific
6. **EEO** — Optional
7. **Submit**

### Navigation
Single page. Submit button at bottom.

## Field Mapping

| Form Label | Spec Field | Notes |
|-----------|-----------|-------|
| Full Name | `personal.name` | Single field (not split) |
| Email | `personal.email` | |
| Phone | `personal.phone` | |
| Current Company | From resume — most recent employer | |
| Resume/CV | File upload | `resume-tailored.pdf` |
| Cover Letter | File upload | `cover-letter.pdf` |
| LinkedIn URL | `personal.linkedin` | |
| GitHub URL | `personal.github` | |
| Portfolio URL | `personal.portfolio` | |

### Custom Questions
- Similar to Greenhouse — varies by company
- Common: work authorization, sponsorship, start date, salary expectations
- Map what you can from spec, ask user for the rest

## Common Issues
1. **No account needed**: Like Greenhouse, Lever doesn't require login.
2. **Limited fields**: Lever forms tend to be short. Most applications take <2 minutes.
3. **File size limits**: Some Lever forms limit resume upload to 10MB. PDFs from LaTeX are typically <1MB.
