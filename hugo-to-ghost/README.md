# Hugo to Ghost Migration Tool

This tool converts Hugo content to Ghost's JSON import format.

## Usage

```bash
# Build the tool
go build -o hugo-to-ghost

# Run the migration
./hugo-to-ghost ../content ghost-export.json
```

## Features

- Converts Hugo markdown files to Ghost posts/pages
- Preserves metadata (title, date, tags, categories)
- Converts common Hugo shortcodes to HTML
- Distinguishes between blog posts and pages
- Handles draft status

## Import to Ghost

1. Run the migration tool to generate `ghost-export.json`
2. In Ghost Admin, go to Settings → Labs
3. Click "Import content" and upload the JSON file
4. Review imported content and adjust as needed

## Post-Migration Tasks

1. **Images**: Upload images to Ghost's content directory
2. **URLs**: Set up redirects for changed URL structures
3. **Shortcodes**: Review converted HTML and adjust styling
4. **Navigation**: Recreate menu structure in Ghost
5. **Theme**: Apply Ghost theme matching your design