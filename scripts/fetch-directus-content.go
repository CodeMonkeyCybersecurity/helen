package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
)

type DirectusResponse struct {
	Data []map[string]interface{} `json:"data"`
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

	// Collections to fetch
	collections := []string{
		"posts",
		"pages",
		"resources",
		"team_members",
		"services",
		"training_content",
		"case_studies",
		"email_templates",
		"newsletter_subscribers",
	}

	// Create data directory
	dataDir := "data"
	if err := os.MkdirAll(dataDir, 0755); err != nil {
		fmt.Printf("Error creating data directory: %v\n", err)
		os.Exit(1)
	}

	// Fetch each collection
	for _, collection := range collections {
		fmt.Printf("Fetching %s...\n", collection)
		
		// Build URL with relations expanded
		url := fmt.Sprintf("%s/items/%s?limit=-1&fields=*.*", directusURL, collection)
		
		// Create request
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			fmt.Printf("Error creating request for %s: %v\n", collection, err)
			continue
		}
		
		// Add authentication
		req.Header.Add("Authorization", "Bearer "+token)
		
		// Make request
		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			fmt.Printf("Error fetching %s: %v\n", collection, err)
			continue
		}
		defer resp.Body.Close()
		
		// Read response
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			fmt.Printf("Error reading response for %s: %v\n", collection, err)
			continue
		}
		
		// Parse JSON to ensure it's valid
		var data DirectusResponse
		if err := json.Unmarshal(body, &data); err != nil {
			fmt.Printf("Error parsing JSON for %s: %v\n", collection, err)
			continue
		}
		
		// Write to file
		filename := filepath.Join(dataDir, collection+".json")
		if err := os.WriteFile(filename, body, 0644); err != nil {
			fmt.Printf("Error writing file for %s: %v\n", collection, err)
			continue
		}
		
		fmt.Printf("✓ Saved %d items to %s\n", len(data.Data), filename)
	}
	
	fmt.Println("\nContent fetch complete!")
}