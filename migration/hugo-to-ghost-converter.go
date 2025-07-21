package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"gopkg.in/yaml.v2"
)

// HugoFrontMatter represents the front matter in Hugo markdown files
type HugoFrontMatter struct {
	Title       string   `yaml:"title"`
	Date        string   `yaml:"date"`
	Author      string   `yaml:"author"`
	Draft       bool     `yaml:"draft"`
	Tags        []string `yaml:"tags"`
	Categories  []string `yaml:"categories"`
	Description string   `yaml:"description"`
	Weight      int      `yaml:"weight"`
	Offering    bool     `yaml:"offering"`
	Type        string   `yaml:"type"`
	Layout      string   `yaml:"layout"`
}

// GhostPost represents a Ghost post/page structure
type GhostPost struct {
	Title               string    `json:"title"`
	Slug                string    `json:"slug"`
	Mobiledoc           string    `json:"mobiledoc"`
	HTML                string    `json:"html"`
	FeatureImage        string    `json:"feature_image,omitempty"`
	Featured            bool      `json:"featured"`
	Type                string    `json:"type"` // "post" or "page"
	Status              string    `json:"status"` // "published" or "draft"
	Visibility          string    `json:"visibility"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`
	PublishedAt         *time.Time `json:"published_at,omitempty"`
	CustomExcerpt       string    `json:"custom_excerpt,omitempty"`
	CodeinjectionHead   string    `json:"codeinjection_head,omitempty"`
	CodeinjectionFoot   string    `json:"codeinjection_foot,omitempty"`
	OgImage             string    `json:"og_image,omitempty"`
	OgTitle             string    `json:"og_title,omitempty"`
	OgDescription       string    `json:"og_description,omitempty"`
	TwitterImage        string    `json:"twitter_image,omitempty"`
	TwitterTitle        string    `json:"twitter_title,omitempty"`
	TwitterDescription  string    `json:"twitter_description,omitempty"`
	MetaTitle           string    `json:"meta_title,omitempty"`
	MetaDescription     string    `json:"meta_description,omitempty"`
	Authors             []string  `json:"authors"`
	Tags                []string  `json:"tags"`
}

// GhostExport represents the complete Ghost export format
type GhostExport struct {
	Meta struct {
		ExportedOn int64  `json:"exported_on"`
		Version    string `json:"version"`
	} `json:"meta"`
	Data struct {
		Posts []GhostPost `json:"posts"`
		Tags  []GhostTag  `json:"tags"`
		Users []GhostUser `json:"users"`
	} `json:"data"`
}

// GhostTag represents a Ghost tag
type GhostTag struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Slug        string `json:"slug"`
	Description string `json:"description,omitempty"`
}

// GhostUser represents a Ghost user
type GhostUser struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Slug  string `json:"slug"`
	Email string `json:"email"`
	Bio   string `json:"bio,omitempty"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: go run hugo-to-ghost-converter.go <hugo-content-dir> <output-file.json>")
		os.Exit(1)
	}

	hugoDir := os.Args[1]
	outputFile := os.Args[2]

	export := &GhostExport{}
	export.Meta.ExportedOn = time.Now().Unix() * 1000
	export.Meta.Version = "5.0.0"

	// Add default author
	export.Data.Users = []GhostUser{
		{
			ID:    "1",
			Name:  "Henry Oliver",
			Slug:  "henry-oliver",
			Email: "main@cybermonkey.net.au",
			Bio:   "Code Monkey Cybersecurity Founder",
		},
	}

	// Track unique tags
	tagMap := make(map[string]bool)

	// Walk through Hugo content directory
	err := filepath.Walk(hugoDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Only process .md files
		if filepath.Ext(path) != ".md" {
			return nil
		}

		// Skip _index.md files for now (they're section indexes)
		if strings.HasSuffix(path, "_index.md") {
			return nil
		}

		post, tags := convertHugoToGhost(path, hugoDir)
		if post != nil {
			export.Data.Posts = append(export.Data.Posts, *post)
			
			// Collect unique tags
			for _, tag := range tags {
				tagMap[tag] = true
			}
		}

		return nil
	})

	if err != nil {
		log.Fatal(err)
	}

	// Create tag objects
	tagID := 1
	for tagName := range tagMap {
		export.Data.Tags = append(export.Data.Tags, GhostTag{
			ID:   fmt.Sprintf("%d", tagID),
			Name: tagName,
			Slug: slugify(tagName),
		})
		tagID++
	}

	// Marshal to JSON
	output, err := json.MarshalIndent(export, "", "  ")
	if err != nil {
		log.Fatal(err)
	}

	// Write to file
	err = ioutil.WriteFile(outputFile, output, 0644)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Successfully converted %d posts/pages\n", len(export.Data.Posts))
	fmt.Printf("Output written to: %s\n", outputFile)
}

func convertHugoToGhost(filePath, baseDir string) (*GhostPost, []string) {
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Printf("Error reading file %s: %v", filePath, err)
		return nil, nil
	}

	// Extract front matter and content
	parts := regexp.MustCompile(`(?s)^---\n(.*?)\n---\n(.*)$`).FindStringSubmatch(string(content))
	if len(parts) != 3 {
		log.Printf("No front matter found in %s", filePath)
		return nil, nil
	}

	// Parse front matter
	var fm HugoFrontMatter
	err = yaml.Unmarshal([]byte(parts[1]), &fm)
	if err != nil {
		log.Printf("Error parsing front matter in %s: %v", filePath, err)
		return nil, nil
	}

	// Get the content body
	bodyContent := strings.TrimSpace(parts[2])

	// Convert markdown to HTML (simplified - Ghost can handle markdown)
	htmlContent := markdownToHTML(bodyContent)

	// Create Ghost post
	post := &GhostPost{
		Title:           fm.Title,
		Slug:            generateSlug(filePath, baseDir),
		HTML:            htmlContent,
		Status:          "published",
		Visibility:      "public",
		Authors:         []string{"1"}, // Default author ID
		MetaDescription: fm.Description,
		CustomExcerpt:   fm.Description,
	}

	// Set type based on directory
	if strings.Contains(filePath, "/blog/") {
		post.Type = "post"
	} else {
		post.Type = "page"
	}

	// Handle draft status
	if fm.Draft {
		post.Status = "draft"
	}

	// Parse and set dates
	if fm.Date != "" {
		parsedDate, err := time.Parse("2006-01-02", fm.Date)
		if err == nil {
			post.CreatedAt = parsedDate
			post.UpdatedAt = parsedDate
			if !fm.Draft {
				post.PublishedAt = &parsedDate
			}
		}
	} else {
		now := time.Now()
		post.CreatedAt = now
		post.UpdatedAt = now
		if !fm.Draft {
			post.PublishedAt = &now
		}
	}

	// Create Mobiledoc format (Ghost's native format)
	post.Mobiledoc = createMobiledoc(bodyContent)

	// Combine tags and categories
	allTags := append(fm.Tags, fm.Categories...)
	post.Tags = allTags

	return post, allTags
}

func generateSlug(filePath, baseDir string) string {
	// Remove base directory and .md extension
	relPath := strings.TrimPrefix(filePath, baseDir)
	relPath = strings.TrimPrefix(relPath, "/")
	relPath = strings.TrimSuffix(relPath, ".md")
	
	// Convert path to slug
	slug := strings.ReplaceAll(relPath, "/", "-")
	slug = strings.ReplaceAll(slug, "_", "-")
	
	return slug
}

func slugify(s string) string {
	// Convert to lowercase and replace spaces with hyphens
	s = strings.ToLower(s)
	s = strings.ReplaceAll(s, " ", "-")
	s = strings.ReplaceAll(s, "_", "-")
	
	// Remove non-alphanumeric characters (except hyphens)
	reg := regexp.MustCompile(`[^a-z0-9-]+`)
	s = reg.ReplaceAllString(s, "")
	
	// Remove multiple consecutive hyphens
	reg = regexp.MustCompile(`-+`)
	s = reg.ReplaceAllString(s, "-")
	
	// Trim hyphens from start and end
	s = strings.Trim(s, "-")
	
	return s
}

func markdownToHTML(markdown string) string {
	// This is a simplified conversion
	// In production, you'd use a proper markdown parser
	// Ghost can handle markdown directly, so we'll keep it simple
	
	// Convert headers
	html := regexp.MustCompile(`(?m)^### (.+)$`).ReplaceAllString(markdown, "<h3>$1</h3>")
	html = regexp.MustCompile(`(?m)^## (.+)$`).ReplaceAllString(html, "<h2>$1</h2>")
	html = regexp.MustCompile(`(?m)^# (.+)$`).ReplaceAllString(html, "<h1>$1</h1>")
	
	// Convert bold
	html = regexp.MustCompile(`\*\*(.+?)\*\*`).ReplaceAllString(html, "<strong>$1</strong>")
	
	// Convert italic
	html = regexp.MustCompile(`\*(.+?)\*`).ReplaceAllString(html, "<em>$1</em>")
	
	// Convert links
	html = regexp.MustCompile(`\[(.+?)\]\((.+?)\)`).ReplaceAllString(html, `<a href="$2">$1</a>`)
	
	// Convert paragraphs
	paragraphs := strings.Split(html, "\n\n")
	for i, p := range paragraphs {
		p = strings.TrimSpace(p)
		if p != "" && !strings.HasPrefix(p, "<") {
			paragraphs[i] = "<p>" + p + "</p>"
		}
	}
	html = strings.Join(paragraphs, "\n\n")
	
	return html
}

func createMobiledoc(markdown string) string {
	// Create a simple Mobiledoc structure with markdown card
	mobiledoc := map[string]interface{}{
		"version": "0.3.1",
		"atoms":   []interface{}{},
		"cards": []interface{}{
			[]interface{}{
				"markdown",
				map[string]interface{}{
					"markdown": markdown,
				},
			},
		},
		"markups": []interface{}{},
		"sections": []interface{}{
			[]interface{}{10, 0},
		},
	}
	
	jsonBytes, _ := json.Marshal(mobiledoc)
	return string(jsonBytes)
}