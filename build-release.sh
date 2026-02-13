#!/bin/bash
set -e

VERSION=${1:-"2.0.3"}
OUTPUT_DIR="./release"

echo "Building MailHog v${VERSION} for multiple platforms..."

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Build for different platforms
echo "Building for macOS ARM64..."
GOOS=darwin GOARCH=arm64 go build -o "${OUTPUT_DIR}/MailHog-darwin-arm64" -ldflags "-X main.version=${VERSION}" .

echo "Building for macOS AMD64..."
GOOS=darwin GOARCH=amd64 go build -o "${OUTPUT_DIR}/MailHog-darwin-amd64" -ldflags "-X main.version=${VERSION}" .

echo "Building for Linux AMD64..."
GOOS=linux GOARCH=amd64 go build -o "${OUTPUT_DIR}/MailHog-linux-amd64" -ldflags "-X main.version=${VERSION}" .

echo "Building for Linux ARM64..."
GOOS=linux GOARCH=arm64 go build -o "${OUTPUT_DIR}/MailHog-linux-arm64" -ldflags "-X main.version=${VERSION}" .

echo "Building for Windows AMD64..."
GOOS=windows GOARCH=amd64 go build -o "${OUTPUT_DIR}/MailHog-windows-amd64.exe" -ldflags "-X main.version=${VERSION}" .

# Generate checksums
echo "Generating checksums..."
cd "${OUTPUT_DIR}"
sha256sum MailHog-* > checksums.txt

echo ""
echo "Build complete! Files in ${OUTPUT_DIR}:"
ls -lh
echo ""
echo "Checksums:"
cat checksums.txt
echo ""
echo "To create a GitHub release:"
echo "1. git tag v${VERSION}"
echo "2. git push origin v${VERSION}"
echo "3. Upload files from ${OUTPUT_DIR} to GitHub release"
