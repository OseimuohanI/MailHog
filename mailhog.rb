class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.8/MailHog-darwin-arm64"
      sha256 "6dcaad8cbb534207dc106c3b239bb6e1a0fd25c0b325a4a01355364019495cf7"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.8/MailHog-darwin-amd64"
      sha256 "1fd196e42d9853d87df74c16825d72fbf985f166e65e6943c44398a9cfdff5d8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.8/MailHog-linux-arm64"
      sha256 "7a9d5ae9df38a099fc1f92d3a7878ee15b76881794802e0ba0c63900e8d8fd51"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.8/MailHog-linux-amd64"
      sha256 "9af1041b2c14d4911ae5db55a780bad23822777f3452ff87dcc3e8d5bd7c9ed5"
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
