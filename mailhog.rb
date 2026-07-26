class Mailhog < Formula
  desc "Web and API based SMTP testing tool with dark mode and persistent storage"
  homepage "https://github.com/OseimuohanI/MailHog"
  version "2.0.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.9/MailHog-darwin-arm64"
      sha256 "819aaa7f1f359dbd509a0fbe072be5cc1e97624a7b9ac7d4b39a26b7fd1c5cbf"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.9/MailHog-darwin-amd64"
      sha256 "b53476a3d37f144e5cb383ad65a45d83fa5dc8fd1138895560daec6db87b3488"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.9/MailHog-linux-arm64"
      sha256 "a682b4ef7f1ff02a763879f3662f5abc71d8d8c45277ea1b8afd6efc2e8fb1f4"
    else
      url "https://github.com/OseimuohanI/MailHog/releases/download/v2.0.9/MailHog-linux-amd64"
      sha256 "9d21220ae8afda6c9e500a4e7983318fb9aa232e3a4f4781bdd1dd286f90c04f"
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
