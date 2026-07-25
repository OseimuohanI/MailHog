class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-darwin-arm64"
      sha256 "17b5ee20a0265ac25a24cfff9f52910e4b689d137350ea3a6bcf9fec76c88113"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-darwin-amd64"
      sha256 "5301ff43299fd592250140b63ab1d857d56b798a433a93259ca8e9b79bfae5cf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-linux-arm64"
      sha256 "876d12d3ea6cb4d69cc8924a164c690b6298c9425db36e4a820d2f0c1c51ab4c"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.7/MailHog-linux-amd64"
      sha256 "eac4f8ba40ed61649b8c0f1472a9ea0e972d92f7ba9fec2017283f7c4443d7a8"
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
