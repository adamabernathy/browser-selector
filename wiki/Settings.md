# Settings

Settings are accessed via **Settings...** in the menu (`Cmd+,`). This opens a native macOS settings window with two tabs.

## General

### Run on Startup

Registers or unregisters the app as a login item using `SMAppService.mainApp`.

The checkbox state reflects the current `SMAppService.Status`:

| Status | Checkbox state |
| --- | --- |
| `.enabled` | Checked |
| `.requiresApproval` | Indeterminate |
| `.notRegistered` | Unchecked |
| `.notFound` | Unchecked, disabled |

If registration or unregistration fails, an alert is shown with the error message.

After enabling, verify the entry in **System Settings → General → Login Items**.

## Browser Router

See [Browser Router](Browser-Router) for a full description of the feature.

### URL Bundles

Pre-configured groups of domain routes. Each bundle is shown with a checkbox — uncheck a bundle to disable all of its routes at once. Bundles cannot be deleted, only disabled.

Currently available bundles:

- **Google Workspace** — routes Docs, Sheets, Slides, Drive, Gmail, Calendar, Meet, Chat, and other Workspace domains to Chrome
- **Google Gemini** — routes `gemini.google.com` to Chrome

### Custom Routes

A table of user-defined rules. Each row maps a domain pattern to a browser.

| Column | Description |
| --- | --- |
| Route or Domain | Pattern to match (`work.com`, `*.work.com`, `work.com/path`) |
| Browser | Any installed browser, selected from a popup |
| Profile | Reserved for future browser profile support |

**Adding a route**: Click `+`. A new row appears with the cursor in the Route or Domain field. Type the pattern, press Tab, and choose a browser from the popup.

**Removing a route**: Select the row and click `−`.

**Editing a route**: Click the pattern field to edit it inline. Changes are saved immediately.

Routes are stored in `~/Library/Application Support/BrowserSwitch/routes.json`.

## Scan for New Browsers

**Scan for New Browsers** is available directly in the main menu (not in the Settings modal). It triggers a full rebuild of the menu, re-querying macOS for all installed browsers. Useful after installing or removing a browser without restarting the app.
