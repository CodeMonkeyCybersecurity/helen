#!/bin/bash

echo "Blog Post Migration Data"
echo "========================"
echo ""
echo "Copy these into Directus manually:"
echo ""

# Process each blog post
for file in content/blog/*.md; do
    # Skip index file
    if [[ "$file" == "content/blog/_index.md" ]]; then
        continue
    fi
    
    echo "---"
    echo "File: $file"
    
    # Extract front matter
    title=$(grep -m1 "^title:" "$file" | sed 's/title: *//; s/"//g')
    date=$(grep -m1 "^date:" "$file" | sed 's/date: *//')
    description=$(grep -m1 "^description:" "$file" | sed 's/description: *//; s/"//g')
    categories=$(grep "^categories:" "$file" | sed 's/categories: *//')
    tags=$(grep "^tags:" "$file" | sed 's/tags: *//')
    author=$(grep -m1 "^author:" "$file" | sed 's/author: *//; s/"//g')
    
    # Generate slug from filename
    slug=$(basename "$file" .md)
    
    echo "Title: $title"
    echo "Slug: $slug"
    echo "Date: $date"
    echo "Description: $description"
    echo "Categories: $categories"
    echo "Tags: $tags"
    echo "Author: ${author:-Code Monkey Cybersecurity}"
    echo ""
    
    # Extract content (everything after the second ---)
    echo "Content preview:"
    awk '/^---$/ {count++} count==2 {if (NR>1) print}' "$file" | head -5
    echo "..."
    echo ""
done