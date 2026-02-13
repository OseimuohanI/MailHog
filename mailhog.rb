class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.0/MailHog-darwin-arm64"
      sha256 "b2925e51d0747cf947dc58d15700bad94dd7909320d072ee7081eb2e22879054"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.0/MailHog-darwin-amd64"
      sha256 "e4b98f32a3443fb93ca3c736441c17e64d9d253a1330355b38549ecfbfb03b52"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.0/MailHog-linux-arm64"
      sha256 "12344bb9ca95d724e2a1e483e19a494aeb9f50f0fdad789103c5f8c15ae0a1da"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.0/MailHog-linux-amd64"
      sha256 "ef9e380600477ad82fad5add43117f286ede7a09ea5f51c37e789e00ef2b78b1"
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
