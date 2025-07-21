package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: migrate-images <ghost-export.json> <hugo-static-dir>")
		os.Exit(1)
	}

	exportFile := os.Args[1]
	staticDir := os.Args[2]

	// Read the export file
	content, err := ioutil.ReadFile(exportFile)
	if err != nil {
		log.Fatal(err)
	}

	// Find all image references
	imagePattern := regexp.MustCompile(`"(/images/[^"]+)"`)
	matches := imagePattern.FindAllStringSubmatch(string(content), -1)

	fmt.Println("Found image references:")
	imageMap := make(map[string]bool)
	for _, match := range matches {
		imageMap[match[1]] = true
	}

	for image := range imageMap {
		fmt.Printf("  %s\n", image)
		
		// Check if image exists in static directory
		srcPath := filepath.Join(staticDir, strings.TrimPrefix(image, "/"))
		if _, err := os.Stat(srcPath); os.IsNotExist(err) {
			fmt.Printf("    WARNING: Image not found at %s\n", srcPath)
		} else {
			fmt.Printf("    ✓ Found at %s\n", srcPath)
		}
	}

	fmt.Printf("\nTotal unique images: %d\n", len(imageMap))
	
	// Generate copy commands
	fmt.Println("\nCopy commands for Ghost:")
	fmt.Println("# Create Ghost images directory if needed")
	fmt.Println("mkdir -p /path/to/ghost/content/images")
	fmt.Println("\n# Copy images")
	for image := range imageMap {
		srcPath := filepath.Join(staticDir, strings.TrimPrefix(image, "/"))
		fmt.Printf("cp \"%s\" \"/path/to/ghost/content%s\"\n", srcPath, image)
	}
}