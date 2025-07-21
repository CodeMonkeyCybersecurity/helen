# Font Files Required

Please add the following font files to this directory:

## Atkinson Hyperlegible
- AtkinsonHyperlegible-Regular.woff2
- AtkinsonHyperlegible-Regular.woff
- AtkinsonHyperlegible-Bold.woff2
- AtkinsonHyperlegible-Bold.woff

You can download Atkinson Hyperlegible from:
https://brailleinstitute.org/freefont

Convert TTF files to WOFF/WOFF2 using:
- https://cloudconvert.com/ttf-to-woff2
- https://cloudconvert.com/ttf-to-woff

Or use command line tools:
```bash
# Install woff2 tools
brew install woff2

# Convert TTF to WOFF2
woff2_compress AtkinsonHyperlegible-Regular.ttf
```