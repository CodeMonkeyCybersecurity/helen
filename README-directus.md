# Directus CMS Integration for Code Monkey Cybersecurity

This setup adds Directus CMS with media handling and Mailcow email integration to your Hugo static site.

## Features

- **Media Management**: Automatic image resizing, PDF handling, video support
- **Email Integration**: Transactional emails via Mailcow
- **Content API**: RESTful API for dynamic content
- **Automatic Builds**: Hugo rebuilds on content changes
- **Responsive Images**: Automatic WebP conversion and multiple sizes
- **Form Handling**: Contact forms with email notifications

## Quick Start

1. **Copy environment file and configure**:
   ```bash
   cp .env.directus .env
   # Edit .env with your settings
   ```

2. **Start Directus and related services**:
   ```bash
   docker-compose -f docker-compose.directus.yml up -d
   ```

3. **Access Directus admin**:
   - URL: http://localhost:8055
   - Login with credentials from .env file

4. **Configure Directus collections**:
   - The system will auto-create basic collections on first run
   - Add custom fields as needed

## Directory Structure

```
directus/
├── extensions/
│   ├── endpoints/      # Custom API endpoints
│   │   └── email-handler.js
│   └── hooks/         # Event hooks
│       └── trigger-hugo-build.js
├── uploads/           # Media files (Docker volume)
└── database/          # PostgreSQL data (Docker volume)

layouts/
├── shortcodes/        # Hugo shortcodes
│   ├── directus-image.html
│   ├── directus-pdf.html
│   ├── directus-video.html
│   └── contact-form.html
└── partials/
    └── directus-gallery.html
```

## Usage Examples

### Display Responsive Images

```markdown
{{< directus-image id="abc-123-uuid" alt="Security diagram" >}}
```

### Embed PDFs

```markdown
{{< directus-pdf id="xyz-789-uuid" title="Download Security Checklist" >}}
```

### Video Player

```markdown
{{< directus-video id="video-uuid" poster="poster-uuid" >}}

<!-- Or YouTube/Vimeo -->
{{< directus-video youtube="dQw4w9WgXcQ" >}}
```

### Contact Form

```markdown
{{< contact-form >}}
```

### Image Gallery

In your content front matter:
```yaml
gallery:
  - id: image1-uuid
    title: "First image"
  - id: image2-uuid
    title: "Second image"
```

Then in your template:
```html
{{ partial "directus-gallery" .Params.gallery }}
```

## API Endpoints

### Public Form Submission
```
POST /api/custom/email-handler/contact-form
POST /api/custom/email-handler/newsletter-subscribe
```

### Webhook for Hugo Builds
```
POST http://hugo-builder:9000/hooks/directus-webhook
```

## Email Configuration

1. **Set Mailcow credentials in .env**:
   ```
   MAILCOW_HOST=mail.cybermonkey.net.au
   MAILCOW_USER=noreply@cybermonkey.net.au
   MAILCOW_PASSWORD=your-app-password
   ```

2. **Create app-specific password in Mailcow**:
   - Login to Mailcow
   - Go to User Settings
   - Create new app password
   - Use this password in .env

## Security Notes

- Change all default passwords in .env
- Use HTTPS in production (update nginx.conf)
- Restrict Directus admin access by IP if needed
- Regular backups of PostgreSQL database
- Monitor file upload sizes and types

## Troubleshooting

### Images not loading
- Check Docker volume permissions
- Verify Nginx can access directus_uploads volume

### Emails not sending
- Verify Mailcow credentials
- Check Directus logs: `docker logs directus-cms`
- Test SMTP connection from Directus container

### Hugo not rebuilding
- Check webhook configuration
- Verify hugo-builder container is running
- Check logs: `docker logs hugo-builder`

## Production Deployment

1. **Update .env for production**
2. **Configure SSL certificates**
3. **Set up proper backup strategy**
4. **Configure firewall rules**
5. **Set up monitoring for all services**