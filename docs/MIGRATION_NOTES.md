# Content Migration Notes

## Old Structure → New Structure

### Services (was offerings/)
- `/offerings/delphi/*` → `/services/delphi/`
- `/offerings/phishing-simulation/*` → `/services/phishing-training/`
- `/offerings/persephone/*` → `/services/persephone/`

### Company (was about-us/)
- `/about-us/governance/policies/*` → `/company/policies/`
- `/about-us/team/*` → `/company/team/`
- `/about-us/contact/*` → `/company/contact/`

### Guides (was resources/guides/)
- `/resources/guides/*` → `/guides/`

### Documentation (was resources/documentation/)
- Keep in `/docs/` as per Hugo convention

## URL Redirects Needed
Add these to your web server configuration:
- `/about-us/*` → `/company/*`
- `/offerings/*` → `/services/*`
- `/resources/guides/*` → `/guides/*`

## Benefits
- Maximum 3 levels deep (e.g., /services/delphi/sign-up)
- Clearer navigation structure
- Better SEO with shorter URLs
- Easier to maintain