class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.3/MailHog-darwin-arm64"
      sha256 "7da732ad9719d06c5b19375ffe684bb4670536b0d9e8de739b0539cd70d2a224"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.3/MailHog-darwin-amd64"
      sha256 "2c006d9c20b0c517fcb576bb5cae3430733a3b3d433dbdbf485f94287329a604"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.3/MailHog-linux-arm64"
      sha256 "252a3f1affbe50d019c5c09961d27b210e16a6afe939625a1452beb6fb96579e"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.3/MailHog-linux-amd64"
      sha256 "844627dbe3456f2b362eca2850111b7fe26fb1586edb33b7c2f6e0491f6346cc"
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
