class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.6/MailHog-darwin-arm64"
      sha256 "7badcf40a58bb9171a96b2f7096ef759deb29f6ba4cfe0b33224aac95a0977b8"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.6/MailHog-darwin-amd64"
      sha256 "1d76086f97f074f93e7a389407a9395bec26880c569ec645abee4f182fe60b21"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.6/MailHog-linux-arm64"
      sha256 "604f4c7a139f143468812e463a6ad1afaf8543e37b44332ddc8c9ba22f0a9909"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.6/MailHog-linux-amd64"
      sha256 "4e0a86d88db64e882b3dee472869d2c6ecfe90e5786b50e2a025f6386bdd9ae9"
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
