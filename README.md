# Browser Switch (macOS Menu Bar App)

[![Build](https://github.com/adamabernathy/default-browser/actions/workflows/ci.yml/badge.svg)](https://github.com/adamabernathy/default-browser/actions/workflows/ci.yml)

Browser Switch is a macOS menu bar app that changes your default browser in one click — and optionally routes URLs to different browsers automatically based on domain rules.

If you bounce between Safari, Chrome, Firefox, Arc, Edge, or a test browser during the day, Browser Switch keeps that switch in the menu bar instead of sending you into System Settings.

> [!IMPORTANT]
> Browser Switch targets macOS 14+ (Sonoma and newer).

## Current Status ✅

- Active macOS menu bar app for daily use
- Core browser switching working (`http` and `https`)
- Browser Router: rule-based URL routing to any installed browser
- Built-in Google Workspace, Gemini, and ChatGPT bundle routes
- Settings modal with General (including Scan for New Browsers) and Browser Router tabs
- Built as a native AppKit app (no SwiftUI)
- CI, tests, and release packaging workflows are in the repo

## Screenshot 📸

![Browser Switch menu screenshot](docs/images/screenshot-1.png)

## Why Use It 🚀

- Switch browsers in one click without leaving your workflow
- Route work URLs to Chrome and everything else to Safari automatically
- Keep work, personal, and testing browser contexts easy to manage
- Stay in the menu bar with minimal UI and no Dock icon
- See the current default browser at a glance

## Key Features ✨

- **One-click browser switching** from the menu bar
- **Browser Router** — rule-based URL routing to any installed browser
  - Built-in Google Workspace & Gemini bundle (routes to Chrome automatically)
  - Custom routes with wildcard (`*.work.com`) and path prefix (`work.com/path`) patterns
  - Route any domain to any installed browser
  - Configurable via the Settings modal
- **Dynamic browser discovery** (Safari and Chrome prioritized)
- **Settings modal** (`Cmd+,`) with General and Browser Router tabs
- Network and VPN context shown in the menu
- Caffeine mode to keep the display awake
- Hide/show desktop icons for screen sharing
- Quick Stage Manager toggle (hold Option)
- Run on Startup (configured in Settings)
- About panel and standard quit behavior

## Getting Started 🛠️

### Install from Source (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/adamabernathy/default-browser/main/scripts/install.sh | bash
```

This builds a release app and installs `Browser Switch.app` into `~/Applications`.

> [!NOTE]
> This is a menu bar app. It runs without a Dock icon during normal use, so look for the app's icon in the macOS menu bar after launch.

### Run from a Local Checkout

#### Requirements

- macOS 14 (Sonoma) or later
- Xcode or Xcode Command Line Tools (Swift toolchain)

#### Common commands

```bash
make build       # Debug build
make test        # Run all tests
make run         # Build and launch via swift run
make release     # Build release .app bundle in dist/
make open        # Build release and launch it
make install     # Install to ~/Applications
make clean       # Remove .build and dist/
```

> [!TIP]
> Use `make open` for the full experience including Browser Router. `make run` wires up a dev router bundle automatically, but some system-level behaviors only work from the packaged `.app`.

## Browser Router

Browser Router is a background helper that intercepts every link click on your Mac and sends it to the right browser based on your rules.

Enable it from the menu bar (click **Browser Router**). When active, all links route through the helper:

- URLs matching a rule go to the configured browser
- Everything else goes to your chosen fallback browser

**Built-in URL bundles** (pre-configured, toggleable; only shown in Settings if the target app is installed):
- Google Workspace (Docs, Sheets, Slides, Drive, Gmail, Calendar, Meet, Chat, and more) → Chrome
- Google Gemini → Chrome
- ChatGPT (`chatgpt.com`) → ChatGPT Mac app (disabled by default)

**Custom routes** support:
- Exact host: `work.com`
- Wildcard subdomain: `*.work.com`
- Path prefix: `work.com/app/dashboard`

Configure routes in **Settings... → Browser Router** (`Cmd+,`).

> [!NOTE]
> Browser Router requires the full `.app` bundle (`make open` or `make install`). It is not available when running via `swift run` alone.

## Tips 💡

- Hold `Option` while the menu is open to reveal power tools and additional network details.
- Use Caffeine mode before demos or long screen shares to prevent the display from sleeping.
- Hide desktop icons before presenting to reduce visual clutter.
- Toggle Stage Manager from the same menu (hold Option) for a cleaner layout.
- Keep Browser Switch in `~/Applications` for a per-user install without `sudo`.
- Routes are stored in `~/Library/Application Support/BrowserSwitch/routes.json` and can be backed up or shared.

### Uninstall

```bash
rm -rf ~/Applications/Browser\ Switch.app
rm -rf ~/Library/Application\ Support/BrowserSwitch
```

## Documentation 📚

For technical details, architecture, CI, and implementation notes, see the wiki pages in `wiki/`:

- [Wiki Home](wiki/Home.md)
- [Installation](wiki/Installation.md)
- [Menu Bar Interface](wiki/Menu-Bar-Interface.md)
- [Browser Router](wiki/Browser-Router.md)
- [Settings](wiki/Settings.md)
- [Option-Key Power Tools](wiki/Option-Key-Power-Tools.md)
- [Network and VPN Context](wiki/Network-and-VPN-Context.md)
- [Browser Discovery](wiki/Browser-Discovery.md)
- [Architecture](wiki/Architecture.md)
- [CI and Releases](wiki/CI-and-Releases.md)

## License

Licensed under the MIT License. See `LICENSE`.
