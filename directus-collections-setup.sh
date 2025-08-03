#!/bin/bash

# Get token
TOKEN=$(cat /tmp/directus_token.txt)

# Create contact_submissions collection
curl -X POST http://localhost:8055/collections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "collection": "contact_submissions",
    "meta": {
      "collection": "contact_submissions",
      "icon": "mail",
      "note": "Contact form submissions from the website",
      "display_template": "{{name}} - {{created_on}}",
      "hidden": false,
      "singleton": false,
      "archive_field": "status",
      "archive_value": "archived",
      "sort_field": "created_on"
    },
    "fields": [
      {
        "field": "id",
        "type": "integer",
        "meta": {
          "hidden": true,
          "interface": "input",
          "readonly": true
        },
        "schema": {
          "is_primary_key": true,
          "has_auto_increment": true
        }
      },
      {
        "field": "name",
        "type": "string",
        "meta": {
          "interface": "input",
          "required": true
        }
      },
      {
        "field": "email",
        "type": "string",
        "meta": {
          "interface": "input",
          "required": true,
          "options": {
            "inputType": "email"
          }
        }
      },
      {
        "field": "phone",
        "type": "string",
        "meta": {
          "interface": "input"
        }
      },
      {
        "field": "company",
        "type": "string",
        "meta": {
          "interface": "input"
        }
      },
      {
        "field": "service_interest",
        "type": "string",
        "meta": {
          "interface": "select-dropdown",
          "options": {
            "choices": [
              {"text": "Delphi Notify XDR/SIEM", "value": "delphi-notify"},
              {"text": "Security Training", "value": "security-training"},
              {"text": "Security Assessment", "value": "security-assessment"},
              {"text": "Managed Security", "value": "managed-security"},
              {"text": "Other", "value": "other"}
            ]
          }
        }
      },
      {
        "field": "message",
        "type": "text",
        "meta": {
          "interface": "input-multiline",
          "required": true
        }
      },
      {
        "field": "newsletter",
        "type": "boolean",
        "meta": {
          "interface": "boolean"
        },
        "schema": {
          "default_value": false
        }
      },
      {
        "field": "source_page",
        "type": "string",
        "meta": {
          "interface": "input",
          "readonly": true
        }
      },
      {
        "field": "status",
        "type": "string",
        "meta": {
          "interface": "select-dropdown",
          "options": {
            "choices": [
              {"text": "New", "value": "new"},
              {"text": "Contacted", "value": "contacted"},
              {"text": "Converted", "value": "converted"},
              {"text": "Archived", "value": "archived"}
            ]
          }
        },
        "schema": {
          "default_value": "new"
        }
      },
      {
        "field": "created_on",
        "type": "timestamp",
        "meta": {
          "interface": "datetime",
          "special": ["date-created"],
          "readonly": true
        }
      },
      {
        "field": "notes",
        "type": "text",
        "meta": {
          "interface": "input-multiline",
          "note": "Internal notes about this contact"
        }
      }
    ]
  }'

echo -e "\n\nContact submissions collection created!"

# Create blog_posts collection
curl -X POST http://localhost:8055/collections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "collection": "blog_posts",
    "meta": {
      "collection": "blog_posts",
      "icon": "article",
      "note": "Blog posts for the website",
      "display_template": "{{title}}",
      "hidden": false,
      "singleton": false,
      "archive_field": "status",
      "archive_value": "archived",
      "sort_field": "date_published"
    },
    "fields": [
      {
        "field": "id",
        "type": "uuid",
        "meta": {
          "hidden": true,
          "interface": "input",
          "readonly": true,
          "special": ["uuid"]
        },
        "schema": {
          "is_primary_key": true
        }
      },
      {
        "field": "title",
        "type": "string",
        "meta": {
          "interface": "input",
          "required": true
        }
      },
      {
        "field": "slug",
        "type": "string",
        "meta": {
          "interface": "input",
          "required": true,
          "note": "URL-friendly version of the title"
        }
      },
      {
        "field": "description",
        "type": "text",
        "meta": {
          "interface": "input-multiline",
          "note": "Brief description for SEO"
        }
      },
      {
        "field": "content",
        "type": "text",
        "meta": {
          "interface": "input-rich-text-md",
          "options": {
            "toolbar": ["bold", "italic", "link", "heading", "blockquote", "code", "bulletList", "orderedList", "image"]
          }
        }
      },
      {
        "field": "featured_image",
        "type": "uuid",
        "meta": {
          "interface": "file-image",
          "special": ["file"]
        }
      },
      {
        "field": "author",
        "type": "string",
        "meta": {
          "interface": "input",
          "options": {
            "placeholder": "Author name"
          }
        }
      },
      {
        "field": "categories",
        "type": "json",
        "meta": {
          "interface": "tags",
          "options": {
            "placeholder": "Add categories..."
          }
        }
      },
      {
        "field": "tags",
        "type": "json",
        "meta": {
          "interface": "tags",
          "options": {
            "placeholder": "Add tags..."
          }
        }
      },
      {
        "field": "status",
        "type": "string",
        "meta": {
          "interface": "select-dropdown",
          "options": {
            "choices": [
              {"text": "Draft", "value": "draft"},
              {"text": "Published", "value": "published"},
              {"text": "Archived", "value": "archived"}
            ]
          }
        },
        "schema": {
          "default_value": "draft"
        }
      },
      {
        "field": "date_published",
        "type": "timestamp",
        "meta": {
          "interface": "datetime"
        }
      },
      {
        "field": "date_created",
        "type": "timestamp",
        "meta": {
          "interface": "datetime",
          "special": ["date-created"],
          "readonly": true
        }
      },
      {
        "field": "date_updated",
        "type": "timestamp",
        "meta": {
          "interface": "datetime",
          "special": ["date-updated"],
          "readonly": true
        }
      }
    ]
  }'

echo -e "\n\nBlog posts collection created!"
echo "Collections are ready!"