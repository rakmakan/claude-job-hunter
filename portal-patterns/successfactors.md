# SuccessFactors Portal — Form Filling Patterns

## URL Detection
- `*.successfactors.com`
- `*/career?company=*`
- `*/career/job-search*`
- URL contains `successfactors` or `sap.com/career`

## Application Flow

SuccessFactors typically has:
1. **Profile Creation/Login** — May require creating a profile first
2. **Personal Information** — Name, contact, address
3. **Work Experience** — Job history with descriptions
4. **Education** — Degrees, institutions
5. **Attachments** — Resume and cover letter upload
6. **Questionnaire** — Custom company questions
7. **Review & Submit**

### Navigation
- Steps shown in a progress bar at top
- "Next" or "Continue" button advances
- Some versions use "Save & Next"

## Field Mapping

Same as Workday for personal info and demographics. Key differences:

### Work Experience
- SuccessFactors often allows richer formatting in description fields
- Still use summarized paragraphs (4-5 lines), not bullets
- Date format may vary by company locale (DD/MM/YYYY vs MM/DD/YYYY)

### Attachments
- Look for "Upload Resume" or "Attach Resume" button
- Use `browser_file_upload` with resume-tailored.pdf
- Cover letter upload is often a separate field

### Country-Specific Fields
- SuccessFactors heavily localizes by country
- Canadian instances may ask for SIN (skip — tell user)
- Indian instances may ask for PAN number
- Always ask user for country-specific identifiers

## Common Issues
1. **Profile vs Application**: Some companies require creating a candidate profile BEFORE applying. Check if redirected to profile creation.
2. **Slow loading**: SuccessFactors pages can be slow. Use `browser_wait_for` between actions.
3. **Pop-up modals**: Cookie consent or notification modals may block form fields. Dismiss them first.
