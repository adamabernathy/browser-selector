# Browser Router

Browser Router is a background helper app (`BrowserSwitchRouter.app`) that intercepts every link click on your Mac and forwards it to the correct browser based on configurable domain rules.

## How It Works

When Browser Router is enabled, it registers itself as the system's default browser. Every time you click a link — in Mail, Slack, a terminal, or anywhere else — the OS sends the URL to the router instead of directly to a browser. The router looks up the URL against your rules and opens the appropriate browser.

```
Link click → OS → BrowserSwitchRouter → rule match? → target browser
                                                ↓ no match
                                          fallback browser
```

The fallback browser is whatever you had set as your default before enabling Browser Router.

## Enabling and Disabling

Click **Browser Router** at the top of the menu. When active, the item shows a checkmark and a filled icon. Click it again to disable — the router process is terminated and your previous default browser is restored.

## URL Bundles

URL Bundles are pre-configured sets of routes. They can be toggled on or off as a group in **Settings... → Browser Router** but cannot be deleted.

| Bundle | Routes to | Patterns |
| --- | --- | --- |
| Google Workspace | Chrome | Docs, Sheets, Slides, Drive, Gmail, Calendar, Meet, Chat, Jamboard, Sites, Keep, Forms, Admin, Workspace, and `.new` shortcuts |
| Google Gemini | Chrome | `gemini.google.com` |

## Custom Routes

Custom routes let you send any domain or URL pattern to any installed browser.

### Pattern syntax

| Pattern | Matches |
| --- | --- |
| `work.com` | Exactly `work.com` |
| `*.work.com` | `work.com` and any subdomain (`app.work.com`, `mail.work.com`, …) |
| `work.com/app` | `work.com` with a path that starts with `/app` |

Patterns are case-insensitive. Matching is checked in order — the first matching route wins.

### Managing routes

Open **Settings... → Browser Router** (`Cmd+,`):

- Click **+** to add a new route. Type the pattern in the Route or Domain column and select a browser from the Browser popup.
- Select a row and click **−** to remove it.
- Click a pattern cell to edit it inline.
- The Profile column is reserved for future browser profile support.

## Route Storage

Routes are stored as JSON at:

```
~/Library/Application Support/BrowserSwitch/routes.json
```

The file is written atomically on every change. Both the main app and the router daemon read from this file, so changes take effect immediately without restarting either process.

## Fallback Browser

When no route matches a URL, the router opens it in your fallback browser — the browser you had set as default before enabling Browser Router. This is saved automatically when you enable the router and persisted in:

```
~/Library/Preferences/com.adamabernathy.browserswitch.plist
```

Key: `browserRouter.selectedDefaultBrowserBundleID`

## Logging

The router writes a log to `/tmp/browser-switch-router.log` while running. Each line includes an ISO 8601 timestamp and a structured message:

```
[2026-03-07T17:00:00Z] router started bundle=com.adamabernathy.browserswitch.router
[2026-03-07T17:00:05Z] route url=https://docs.google.com target=com.google.Chrome fallback=com.apple.Safari
[2026-03-07T17:00:10Z] route url=https://yahoo.com target=com.apple.Safari fallback=com.apple.Safari
```

## Development Builds

Browser Router requires the full `.app` bundle structure (`make open` or `make install`). When running via `make run`, the build system creates a minimal `BrowserSwitchRouter.app` in the SPM bin directory and registers it with Launch Services automatically so the feature works during development.

> [!NOTE]
> `make run` calls `scripts/setup-dev-router.sh` which creates the dev bundle and runs `lsregister`. This happens automatically — no manual steps required.
