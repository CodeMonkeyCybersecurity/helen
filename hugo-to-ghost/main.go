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

type HugoFrontmatter struct {
	Title       string   `yaml:"title"`
	Date        string   `yaml:"date"`
	Description string   `yaml:"description"`
	Draft       bool     `yaml:"draft"`
	Tags        []string `yaml:"tags"`
	Categories  []string `yaml:"categories"`
	Author      string   `yaml:"author"`
	Weight      int      `yaml:"weight"`
	Menu        interface{} `yaml:"menu"`
}

type GhostPost struct {
	ID              string   `json:"id"`
	UUID            string   `json:"uuid"`
	Title           string   `json:"title"`
	Slug            string   `json:"slug"`
	Mobiledoc       string   `json:"mobiledoc"`
	HTML            string   `json:"html"`
	Plaintext       string   `json:"plaintext"`
	FeatureImage    string   `json:"feature_image"`
	Featured        bool     `json:"featured"`
	Page            bool     `json:"page"`
	Status          string   `json:"status"`
	Locale          string   `json:"locale"`
	Visibility      string   `json:"visibility"`
	MetaTitle       string   `json:"meta_title"`
	MetaDescription string   `json:"meta_description"`
	CreatedAt       int64    `json:"created_at"`
	UpdatedAt       int64    `json:"updated_at"`
	PublishedAt     int64    `json:"published_at"`
	Tags            []string `json:"tags"`
}

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

type GhostTag struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Slug        string `json:"slug"`
	Description string `json:"description"`
}

type GhostUser struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Slug  string `json:"slug"`
	Email string `json:"email"`
	Bio   string `json:"bio"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: hugo-to-ghost <content-dir> <output-file>")
		os.Exit(1)
	}

	contentDir := os.Args[1]
	outputFile := os.Args[2]

	export := &GhostExport{}
	export.Meta.ExportedOn = time.Now().Unix() * 1000
	export.Meta.Version = "5.0.0"

	// Add default user
	export.Data.Users = append(export.Data.Users, GhostUser{
		ID:    "1",
		Name:  "Henry Oliver",
		Slug:  "henry-oliver",
		Email: "admin@cybermonkey.net.au",
		Bio:   "Code Monkey Cybersecurity",
	})

	// Track unique tags
	tagMap := make(map[string]bool)

	// Process all markdown files
	err := filepath.Walk(contentDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if filepath.Ext(path) == ".md" && !strings.Contains(path, "_index.md") {
			fmt.Printf("Processing: %s\n", path)
			post, tags := processMarkdownFile(path, contentDir)
			if post != nil {
				export.Data.Posts = append(export.Data.Posts, *post)
				
				// Collect tags
				for _, tag := range tags {
					tagMap[tag] = true
				}
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

	// Write JSON output
	jsonData, err := json.MarshalIndent(export, "", "  ")
	if err != nil {
		log.Fatal(err)
	}

	err = ioutil.WriteFile(outputFile, jsonData, 0644)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("\nExport complete! Created %s with %d posts and %d tags\n", 
		outputFile, len(export.Data.Posts), len(export.Data.Tags))
}

func processMarkdownFile(path string, contentDir string) (*GhostPost, []string) {
	content, err := ioutil.ReadFile(path)
	if err != nil {
		log.Printf("Error reading file %s: %v", path, err)
		return nil, nil
	}

	// Extract frontmatter and content
	parts := strings.SplitN(string(content), "---", 3)
	if len(parts) < 3 {
		log.Printf("No frontmatter found in %s", path)
		return nil, nil
	}

	var fm HugoFrontmatter
	err = yaml.Unmarshal([]byte(parts[1]), &fm)
	if err != nil {
		log.Printf("Error parsing frontmatter in %s: %v", path, err)
		return nil, nil
	}

	markdownContent := strings.TrimSpace(parts[2])

	// Convert Hugo shortcodes to HTML
	htmlContent := convertShortcodesToHTML(markdownContent)

	// Determine if this is a page or post
	isPage := !strings.Contains(path, "/blog/")

	// Parse date
	var publishedAt int64
	if fm.Date != "" {
		t, err := time.Parse("2006-01-02", fm.Date)
		if err != nil {
			t, err = time.Parse("2006-01-02T15:04:05Z07:00", fm.Date)
		}
		if err == nil {
			publishedAt = t.Unix() * 1000
		}
	}
	if publishedAt == 0 {
		publishedAt = time.Now().Unix() * 1000
	}

	// Generate slug from filepath
	relativePath := strings.TrimPrefix(path, contentDir)
	slug := generateSlug(relativePath)

	// Create Ghost post
	post := &GhostPost{
		ID:              generateID(),
		UUID:            generateUUID(),
		Title:           fm.Title,
		Slug:            slug,
		HTML:            htmlContent,
		Plaintext:       stripHTML(htmlContent),
		Page:            isPage,
		Status:          "published",
		Locale:          "en",
		Visibility:      "public",
		MetaTitle:       fm.Title,
		MetaDescription: fm.Description,
		CreatedAt:       publishedAt,
		UpdatedAt:       publishedAt,
		PublishedAt:     publishedAt,
	}

	if fm.Draft {
		post.Status = "draft"
	}

	// Combine tags and categories
	allTags := append(fm.Tags, fm.Categories...)
	
	return post, allTags
}

func convertShortcodesToHTML(content string) string {
	// Convert common Hugo shortcodes to HTML
	replacements := map[string]string{
		`{{< btn link="([^"]+)" text="([^"]+)" >}}`: `<a href="$1" class="button">$2</a>`,
		`{{< card title="([^"]+)" >}}([\s\S]*?){{< /card >}}`: `<div class="card"><h3>$1</h3>$2</div>`,
		`{{< grid >}}([\s\S]*?){{< /grid >}}`: `<div class="grid">$1</div>`,
		`{{< cta >}}([\s\S]*?){{< /cta >}}`: `<div class="cta">$1</div>`,
		`{{< section [^>]*>}}([\s\S]*?){{< /section >}}`: `<section>$1</section>`,
	}

	result := content
	for pattern, replacement := range replacements {
		re := regexp.MustCompile(pattern)
		result = re.ReplaceAllString(result, replacement)
	}

	return result
}

func stripHTML(html string) string {
	re := regexp.MustCompile(`<[^>]*>`)
	return re.ReplaceAllString(html, "")
}

func slugify(text string) string {
	slug := strings.ToLower(text)
	slug = regexp.MustCompile(`[^a-z0-9-]+`).ReplaceAllString(slug, "-")
	slug = strings.Trim(slug, "-")
	return slug
}

func generateSlug(path string) string {
	// Remove extension and convert path to slug
	slug := strings.TrimSuffix(filepath.Base(path), ".md")
	return slugify(slug)
}

func generateID() string {
	return fmt.Sprintf("%d", time.Now().UnixNano())
}

func generateUUID() string {
	// Simple UUID v4 generation
	b := make([]byte, 16)
	for i := range b {
		b[i] = byte(time.Now().UnixNano() & 0xff)
	}
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}