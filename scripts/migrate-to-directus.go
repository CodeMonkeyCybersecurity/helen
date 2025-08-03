package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v2"
)

type FrontMatter struct {
	Title       string   `yaml:"title"`
	Date        string   `yaml:"date"`
	Description string   `yaml:"description"`
	Tags        []string `yaml:"tags"`
	Categories  []string `yaml:"categories"`
	Draft       bool     `yaml:"draft"`
	Weight      int      `yaml:"weight"`
	Author      string   `yaml:"author"`
}

func main() {
	directusURL := os.Getenv("DIRECTUS_URL")
	if directusURL == "" {
		directusURL = "http://localhost:8055"
	}

	token := os.Getenv("DIRECTUS_TOKEN")
	if token == "" {
		fmt.Println("Error: DIRECTUS_TOKEN environment variable not set")
		os.Exit(1)
	}

	// Migrate posts
	fmt.Println("Migrating posts...")
	migrateContent("content/posts", "posts", directusURL, token)

	// Migrate docs as pages
	fmt.Println("Migrating documentation pages...")
	migrateContent("content/docs", "pages", directusURL, token)

	fmt.Println("\nMigration complete!")
}

func migrateContent(contentDir, collection string, directusURL, token string) {
	err := filepath.Walk(contentDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip directories and non-markdown files
		if info.IsDir() || !strings.HasSuffix(path, ".md") {
			return nil
		}

		fmt.Printf("Processing: %s\n", path)

		// Read file
		content, err := os.ReadFile(path)
		if err != nil {
			fmt.Printf("Error reading %s: %v\n", path, err)
			return nil
		}

		// Parse front matter and content
		parts := bytes.SplitN(content, []byte("---"), 3)
		if len(parts) < 3 {
			fmt.Printf("No front matter found in %s\n", path)
			return nil
		}

		var fm FrontMatter
		if err := yaml.Unmarshal(parts[1], &fm); err != nil {
			fmt.Printf("Error parsing front matter in %s: %v\n", path, err)
			return nil
		}

		// Get content body
		body := string(parts[2])

		// Create Directus item
		item := map[string]interface{}{
			"title":       fm.Title,
			"slug":        generateSlug(fm.Title),
			"content":     body,
			"description": fm.Description,
			"status":      "published",
			"date_created": fm.Date,
		}

		if fm.Draft {
			item["status"] = "draft"
		}

		if collection == "posts" {
			item["tags"] = fm.Tags
			item["categories"] = fm.Categories
			item["author"] = fm.Author
		}

		if collection == "pages" && fm.Weight > 0 {
			item["sort"] = fm.Weight
		}

		// Send to Directus
		if err := createDirectusItem(directusURL, token, collection, item); err != nil {
			fmt.Printf("Error creating item in Directus: %v\n", err)
		} else {
			fmt.Printf("✓ Migrated: %s\n", fm.Title)
		}

		return nil
	})

	if err != nil {
		fmt.Printf("Error walking directory: %v\n", err)
	}
}

func createDirectusItem(directusURL, token, collection string, item map[string]interface{}) error {
	url := fmt.Sprintf("%s/items/%s", directusURL, collection)
	
	jsonData, err := json.Marshal(item)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("directus returned status %d: %s", resp.StatusCode, body)
	}

	return nil
}

func generateSlug(title string) string {
	slug := strings.ToLower(title)
	slug = strings.ReplaceAll(slug, " ", "-")
	slug = strings.ReplaceAll(slug, "'", "")
	slug = strings.ReplaceAll(slug, "\"", "")
	slug = strings.ReplaceAll(slug, "&", "and")
	slug = strings.ReplaceAll(slug, "?", "")
	slug = strings.ReplaceAll(slug, "!", "")
	slug = strings.ReplaceAll(slug, ".", "")
	slug = strings.ReplaceAll(slug, ",", "")
	slug = strings.ReplaceAll(slug, ":", "")
	slug = strings.ReplaceAll(slug, ";", "")
	return slug
}