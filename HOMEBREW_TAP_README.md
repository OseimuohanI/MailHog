# Homebrew Tap for Custom MailHog

This is the Homebrew tap for the custom MailHog build with dark mode and persistent storage.

## Installation

```bash
brew tap OseimuohanI/mailhog
brew install mailhog
```

## Usage

```bash
mailhog
```

- SMTP Server: `localhost:1025`
- Web UI: `http://localhost:8025`
- Storage Directory: `./mailhog-data/`

## Features

- 🌙 **Dark Mode**: Toggle between light and dark themes in the web UI
- 💾 **Persistent Storage**: Emails are saved to `./mailhog-data` and persist across restarts
- 🎨 **Custom Branding**: Links point to this custom fork

## Building from Source

```bash
git clone https://github.com/OseimuohanI/MailHog.git
cd MailHog
go build -o MailHog .
./MailHog
```

## License

MIT License - See [LICENSE.md](https://github.com/OseimuohanI/MailHog/blob/main/LICENSE.md)
