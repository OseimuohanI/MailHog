# Complete Guide: Creating a Homebrew Tap for Custom MailHog

This guide walks you through creating a professional Homebrew tap for your custom MailHog build.

## Overview

You'll create:
1. A GitHub release with multi-platform binaries
2. A Homebrew tap repository (`homebrew-mailhog`)
3. A formula that users can install with `brew install`

## Prerequisites

- GitHub CLI (`gh`) installed: `brew install gh`
- Authenticated with GitHub: `gh auth login`
- All your changes committed and pushed to `OseimuohanI/MailHog`

## Step 1: Build Release Binaries

```bash
# Build binaries for all platforms
./build-release.sh 2.0.0

# This creates:
# - release/MailHog-darwin-arm64 (macOS Apple Silicon)
# - release/MailHog-darwin-amd64 (macOS Intel)
# - release/MailHog-linux-amd64
# - release/MailHog-linux-arm64
# - release/MailHog-windows-amd64.exe
# - release/checksums.txt
```

## Step 2: Create GitHub Release (Option A: Manual)

```bash
# Commit and push all your changes
git add .
git commit -m "Release v2.0.0 with dark mode and persistent storage"
git push origin main

# Create and push tag
git tag -a v2.0.0 -m "Release v2.0.0: Dark mode, persistent storage, custom branding"
git push origin v2.0.0

# Create release with binaries
gh release create v2.0.0 \
  release/MailHog-darwin-arm64 \
  release/MailHog-darwin-amd64 \
  release/MailHog-linux-amd64 \
  release/MailHog-linux-arm64 \
  release/MailHog-windows-amd64.exe \
  release/checksums.txt \
  --title "MailHog v2.0.0 - Custom Build" \
  --notes "## Features

- 🌙 **Dark Mode**: Toggle between light and dark themes
- 💾 **Persistent Storage**: Emails saved to \`./mailhog-data\` across restarts
- 🎨 **Custom Branding**: Links to this fork

## Installation

### Homebrew (macOS/Linux)
\`\`\`bash
brew tap OseimuohanI/mailhog
brew install mailhog
\`\`\`

### Manual Installation
1. Download the binary for your platform
2. Make it executable: \`chmod +x MailHog-*\`
3. Run: \`./MailHog-*\`

## Usage
- SMTP Server: \`localhost:1025\`
- Web UI: \`http://localhost:8025\`
- Storage: \`./mailhog-data/\`"
```

## Step 2: Create GitHub Release (Option B: Automatic)

Just push the tag - GitHub Actions will automatically build and release:

```bash
# Commit changes
git add .
git commit -m "Release v2.0.0 with dark mode and persistent storage"
git push origin main

# Push tag - this triggers the GitHub Actions workflow
git tag v2.0.0
git push origin v2.0.0

# Wait for GitHub Actions to complete (check: https://github.com/OseimuohanI/MailHog/actions)
# Then download checksums.txt from the release
```

## Step 3: Create Homebrew Tap Repository

```bash
# Navigate to parent directory
cd ..

# Create tap repository
gh repo create homebrew-mailhog --public --description "Homebrew tap for custom MailHog with dark mode and persistent storage"

# Clone it
git clone https://github.com/OseimuohanI/homebrew-mailhog.git
cd homebrew-mailhog
```

## Step 4: Generate and Add Formula

```bash
# Go back to MailHog directory
cd ../MailHog-1.0.1

# Generate formula with checksums from your release
./setup-homebrew-tap.sh 2.0.0 release/checksums.txt

# This creates mailhog.rb with proper checksums

# Copy files to tap repository
cp mailhog.rb ../homebrew-mailhog/
cp HOMEBREW_TAP_README.md ../homebrew-mailhog/README.md
```

## Step 5: Publish the Tap

```bash
cd ../homebrew-mailhog

# Add and commit
git add mailhog.rb README.md
git commit -m "Add MailHog v2.0.0 formula with dark mode and persistent storage"
git push origin main
```

## Step 6: Test Installation

```bash
# Uninstall official version if installed
brew uninstall mailhog

# Tap your repository
brew tap OseimuohanI/mailhog

# Install your custom version
brew install mailhog

# Test it
mailhog

# Visit http://localhost:8025 and verify:
# - Dark mode toggle works (sun/moon icon top-right)
# - Persistent storage (./mailhog-data directory created)
# - GitHub link points to your fork
```

## Updating the Formula (Future Releases)

When you make new releases:

```bash
# 1. Build new version
cd MailHog-1.0.1
./build-release.sh 2.1.0

# 2. Create GitHub release
git tag v2.1.0
git push origin v2.1.0
gh release create v2.1.0 release/* --title "v2.1.0" --notes "Release notes here"

# 3. Update formula
./setup-homebrew-tap.sh 2.1.0 release/checksums.txt

# 4. Update tap
cp mailhog.rb ../homebrew-mailhog/
cd ../homebrew-mailhog
git add mailhog.rb
git commit -m "Update to v2.1.0"
git push

# 5. Users upgrade with
brew update
brew upgrade mailhog
```

## Troubleshooting

### "Formula not found"
```bash
brew untap OseimuohanI/mailhog
brew tap OseimuohanI/mailhog
```

### "SHA256 mismatch"
- Regenerate checksums: `cd release && sha256sum MailHog-* > checksums.txt`
- Run setup script again: `./setup-homebrew-tap.sh 2.0.0 release/checksums.txt`
- Update tap repository

### Test locally before publishing
```bash
brew install --build-from-source ./mailhog.rb
```

## Summary

Users can now install with:
```bash
brew tap OseimuohanI/mailhog
brew install mailhog
```

And they'll get your custom version with dark mode and persistent storage! 🎉
