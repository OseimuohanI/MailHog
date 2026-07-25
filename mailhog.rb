class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-darwin-arm64"
      sha256 "766d229a76cc61df64128358c6c978f08f703ece37a6ae4429c04f6a633f873b"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-darwin-amd64"
      sha256 "6813c814cb5f08b78f1efaf6b6871904979510f489275d15248b7f1fab9a8b5f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-linux-arm64"
      sha256 "85bfc1119f7d7ee342f97058dbba02588d614cc6132746456eafa8de137c3fa2"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-linux-amd64"
      sha256 "e7762d0dbe5103baca2f72310ae929c29fc3f6b69740f12c961efb01a1857f89"
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
      💾 Persistent Storage: Emails saved to ./MailHog/mailhog-data directory
      
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
