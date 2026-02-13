#!/bin/bash
set -e

# Script to set up Homebrew tap repository with proper checksums
# Usage: ./setup-homebrew-tap.sh <version> <checksums-file>

VERSION=${1:-"2.0.3"}
CHECKSUMS_FILE=${2:-"./release/checksums.txt"}

if [ ! -f "$CHECKSUMS_FILE" ]; then
    echo "Error: Checksums file not found: $CHECKSUMS_FILE"
    echo "Usage: $0 <version> <checksums-file>"
    exit 1
fi

echo "Setting up Homebrew tap for MailHog v${VERSION}..."

# Extract checksums
DARWIN_ARM64_SHA=$(grep "MailHog-darwin-arm64" "$CHECKSUMS_FILE" | awk '{print $1}')
DARWIN_AMD64_SHA=$(grep "MailHog-darwin-amd64" "$CHECKSUMS_FILE" | awk '{print $1}')
LINUX_ARM64_SHA=$(grep "MailHog-linux-arm64" "$CHECKSUMS_FILE" | awk '{print $1}')
LINUX_AMD64_SHA=$(grep "MailHog-linux-amd64" "$CHECKSUMS_FILE" | awk '{print $1}')

echo "Checksums found:"
echo "  macOS ARM64:  $DARWIN_ARM64_SHA"
echo "  macOS AMD64:  $DARWIN_AMD64_SHA"
echo "  Linux ARM64:  $LINUX_ARM64_SHA"
echo "  Linux AMD64:  $LINUX_AMD64_SHA"
echo ""

# Create the formula file
FORMULA_FILE="mailhog.rb"

cat > "$FORMULA_FILE" << EOF
class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "${VERSION}"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v${VERSION}/MailHog-darwin-arm64"
      sha256 "${DARWIN_ARM64_SHA}"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v${VERSION}/MailHog-darwin-amd64"
      sha256 "${DARWIN_AMD64_SHA}"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v${VERSION}/MailHog-linux-arm64"
      sha256 "${LINUX_ARM64_SHA}"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v${VERSION}/MailHog-linux-amd64"
      sha256 "${LINUX_AMD64_SHA}"
    end
  end

  def install
    bin.install "MailHog-darwin-arm64" => "MailHog" if OS.mac? && Hardware::CPU.arm?
    bin.install "MailHog-darwin-amd64" => "MailHog" if OS.mac? && Hardware::CPU.intel?
    bin.install "MailHog-linux-arm64" => "MailHog" if OS.linux? && Hardware::CPU.arm?
    bin.install "MailHog-linux-amd64" => "MailHog" if OS.linux? && Hardware::CPU.intel?
  end

  def caveats
    <<~EOS
      MailHog has been installed with custom features:
      
      🌙 Dark Mode: Toggle in the web UI (top-right corner)
      💾 Persistent Storage: Emails saved to ./mailhog-data directory
      
      To start MailHog:
        mailhog
      
      SMTP server will run on: localhost:1025
      Web interface will run on: http://localhost:8025
      
      To run MailHog as a background service:
        brew services start mailhog
    EOS
  end

  service do
    run [opt_bin/"MailHog"]
    keep_alive true
    log_path var/"log/mailhog.log"
    error_log_path var/"log/mailhog.log"
  end

  test do
    system "#{bin}/MailHog", "--version"
  end
end
EOF

echo "✅ Formula file created: $FORMULA_FILE"
echo ""
echo "Next steps:"
echo "1. Create tap repository: gh repo create homebrew-mailhog --public"
echo "2. Move to tap directory: cd ../homebrew-mailhog"
echo "3. Copy formula: cp ../MailHog-1.0.1/mailhog.rb ."
echo "4. Copy README: cp ../MailHog-1.0.1/HOMEBREW_TAP_README.md README.md"
echo "5. Commit and push:"
echo "   git add mailhog.rb README.md"
echo "   git commit -m 'Add MailHog v${VERSION} formula'"
echo "   git push origin main"
echo ""
echo "Test installation:"
echo "  brew tap OseimuohanI/mailhog"
echo "  brew install mailhog"
