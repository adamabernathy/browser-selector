# Architecture

## Project Structure

Browser Switch is a Swift Package Manager project with three targets and no `.xcodeproj`. Xcode can open the folder directly.

```
Sources/
  BrowserSwitchCore/                   -- shared library (no UI)
    BrowserDiscovery.swift             -- browser deduplication and ordering
    BrowserRoute.swift                 -- route model (Codable)
    BrowserRouterPolicy.swift          -- URL-to-browser matching logic
    RouteStore.swift                   -- route persistence (JSON in Application Support)

  BrowserSwitchMenuBarApp/             -- main menu bar app
    main.swift                         -- app delegate, menu bar UI, all primary logic
    SettingsWindowController.swift     -- Settings modal (General + Browser Router tabs)
    InternetInfo.swift                 -- IP/ISP/location model and JSON decoding
    SystemVPNStatus.swift              -- VPN detection via scutil and netstat

  BrowserSwitchRouter/
    main.swift                         -- URL routing daemon (Apple Event handler)

Tests/BrowserSwitchMenuBarAppTests/
  BrowserDiscoveryTests.swift
  BrowserRouterPolicyTests.swift
  InternetInfoTests.swift
  SystemVPNStatusTests.swift

scripts/
  build-app.sh                         -- builds standalone .app bundle in dist/
  bump-version.sh                      -- increments the VERSION file
  install.sh                           -- clone-build-install one-liner
  setup-dev-router.sh                  -- creates a dev router bundle for swift run

Makefile                               -- build, test, run, release, install, clean, bump-*
```

## Targets

### BrowserSwitchCore

A library target shared by the main app and the router daemon. Contains no AppKit or UI code.

- **`BrowserRoute`** — `Codable` struct representing a single routing rule (pattern, target browser, group membership, enabled state).
- **`RouteStore`** — reads and writes `routes.json` in `~/Library/Application Support/BrowserSwitch/`. Pre-seeds with the Google Workspace and Gemini bundles on first run. Both the main app and the router call `reload()` to pick up changes written by the other process.
- **`BrowserRouterPolicy`** — stateless matching logic. Given a URL and a route array, returns the target browser bundle ID or `nil` (use fallback). Supports exact host, wildcard (`*.work.com`), and path-prefix (`work.com/path`) patterns.
- **`BrowserDiscovery`** — deduplication and ordering of discovered browser candidates.

### BrowserSwitchMenuBarApp

The menu bar UI process. Depends on `BrowserSwitchCore`.

- **`main.swift`** — app delegate, menu construction, browser switching, Caffeine, network monitoring, Browser Router enable/disable, debug logging.
- **`SettingsWindowController`** — `NSWindowController` with an `NSTabViewController` (toolbar style). General tab: Run on Startup. Browser Router tab: bundle group toggles + custom routes `NSTableView`.
- **`InternetInfo`** / **`SystemVPNStatus`** — network context shown in the menu.

### BrowserSwitchRouter

A background helper process bundled inside the main `.app` at `Contents/Resources/BrowserSwitchRouter.app`. Depends on `BrowserSwitchCore`.

Registers an Apple Event handler for `kAEGetURL`. On every incoming URL:
1. Calls `RouteStore.shared.reload()` to pick up any changes saved via Settings.
2. Calls `BrowserRouterPolicy.targetBundleID(for:routes:)`.
3. Opens the URL in the target browser (or fallback) using `/usr/bin/open -a`.

Writes a structured log to `/tmp/browser-switch-router.log`.

## Frameworks

- **AppKit** — all UI (no SwiftUI, no UIKit)
- **CoreServices** — `LSSetDefaultHandlerForURLScheme` for setting the default browser
- **IOKit** — `IOPMAssertionCreateWithName` for Caffeine mode
- **Network** — `NWPathMonitor` for connectivity change detection
- **ServiceManagement** — `SMAppService` for Run on Startup

No third-party dependencies.

## App Lifecycle

The main app sets `.accessory` activation policy (no Dock icon). On launch it:
1. Terminates any other running instances of itself.
2. Seeds `RouteStore.shared` (creating `routes.json` if it doesn't exist).
3. Builds the menu bar status item and menu.
4. Repairs the router fallback preference if the router is active but no fallback was saved.
5. Starts the network monitor and fetches initial internet info and VPN status.
6. Begins observing `NSApp.effectiveAppearance` for theme changes.

On quit it releases any Caffeine power assertion, terminates the router helper, and cancels the network monitor.

## Browser Router Lifecycle

The router is launched by the main app when Browser Router is enabled. It registers as a background-only app (`LSUIElement = true`) and stays alive until:
- The user disables Browser Router from the menu (main app calls `terminate()`).
- The main app quits.
- The user force-quits it.

The router is stored at `Contents/Resources/BrowserSwitchRouter.app` inside the main bundle. Its `Info.plist` declares `CFBundleURLTypes` for `http` and `https`, which is what allows Launch Services to register it as a browser.

## Route Persistence

Routes are stored in JSON at `~/Library/Application Support/BrowserSwitch/routes.json`. The main app writes via `RouteStore.shared.update/add/remove`. The router calls `RouteStore.shared.reload()` before each URL is routed, so changes take effect immediately without restarting either process.

The fallback browser (used when no route matches) is stored separately in `~/Library/Preferences/com.adamabernathy.browserswitch.plist` under the key `browserRouter.selectedDefaultBrowserBundleID`, written via `CFPreferencesSetAppValue` so it is readable by the router daemon from a different process.

## Dark Mode

All custom-drawn images use `NSImage(size:flipped:drawingHandler:)` so colors resolve at draw time. Only semantic `NSColor` values are used (`.labelColor`, `.windowBackgroundColor`, `.systemGreen`). The menu bar icon is an SF Symbol with `.isTemplate = true`. A KVO observation on `NSApp.effectiveAppearance` rebuilds the cached app identity icon on theme change.

## Menu Construction

`rebuildMenu(_:)` tears down and reconstructs all menu items on every `menuWillOpen`. This avoids stale state and keeps the code simple. Browser icons come from `NSWorkspace.shared.icon(forFile:)` at 16×16. The current default browser gets `.state = .on`.

## Concurrency Model

- Network requests and shell commands run on background queues.
- All UI updates dispatch back to `DispatchQueue.main.async`.
- Requests are guarded by in-flight boolean flags.
- Internet info is throttled to one request per 60 seconds. VPN status every 5 seconds.
- The router helper runs its own `NSRunLoop` (via `NSApplication.shared.run()`).
