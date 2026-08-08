class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-darwin-arm64"
      sha256 "42404dc57658367e9371f94037079dab4787096e5b262ca11ed06135146768f8"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-darwin-amd64"
      sha256 "d2680c99cee07313e8ee620206a9909bf7166f39c8a3ae146177859823514520"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-linux-arm64"
      sha256 "9523b14f93639e4fbf548be8c42846f227295d8e419a3498d4b06da8683259c2"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-linux-amd64"
      sha256 "5c566b95ea5f87fe53af0bfd3cea6fbd7ea5967221cff9a35196627112d1d01f"
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
      💾 Persistent Storage: Emails saved to ~/MailHog/mailhog-data directory
      
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
