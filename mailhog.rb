class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.10/MailHog-darwin-arm64"
      sha256 "fc156468a3eb2aad0e9429ef6523b33e115a8c2ef9aa27db20111d1ff337ff07"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.10/MailHog-darwin-amd64"
      sha256 "73b0995282220ae38a5bccfbde116c8ba702f95b3e60114a0b02350ffb6bc43a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.10/MailHog-linux-arm64"
      sha256 "1bacccd9e827d857211a8581572003cb072eaa00ee83dd6dba456a223e3102ec"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.10/MailHog-linux-amd64"
      sha256 "899d7efc22818b5800cc863f5cec6fc855abdfc69754dd0186b16582b03a9466"
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
