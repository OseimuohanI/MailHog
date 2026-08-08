class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-darwin-arm64"
      sha256 "73083f994aafa7e125171ed28e69752337d3d9e02263d71afd5f0ab51a27fb89"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-darwin-amd64"
      sha256 "a62de24c37505cc8f754075ba95ff06ea35aacd73737ac9f4daa72c6d77ba7ec"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-linux-arm64"
      sha256 "0e8f0913d5da491182709bab4536d3d8aa26c655a52745006cee41729e72f2b4"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.11/MailHog-linux-amd64"
      sha256 "952b00c91d060ce181ec50a35d0bfa552a2f68b8ba603ac2cb507941e5d3faef"
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
