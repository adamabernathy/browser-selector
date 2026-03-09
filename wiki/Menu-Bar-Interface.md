# Menu Bar Interface

Browser Switch lives entirely in the macOS menu bar. There is no main window and no Dock icon.

## Status Item

The menu bar icon is an SF Symbol rendered as a template image. macOS automatically inverts it for light and dark mode. On macOS 26 (Tahoe) and later the symbol is `circle.grid.2x2.topleft.checkmark.filled`; on earlier versions it falls back to `figure.curling`.

Clicking the icon opens the main menu. The menu is rebuilt from scratch every time it opens so the browser list, VPN status, and internet info are always current.

## Menu Layout

From top to bottom:

1. **Browser Router** — enables or disables the URL routing helper. When active, shows a checkmark and a filled icon. See [Browser Router](Browser-Router).

2. **Browser list** — every installed browser that handles both `http` and `https`. Safari and Chrome are pinned to the top; remaining browsers are sorted alphabetically. A checkmark indicates the current macOS default. Clicking a browser sets it as the default for both schemes immediately. When Browser Router is active, clicking a browser sets it as the router's fallback target without disabling routing.

3. **Separator**

4. **Internet Connection Details** — section header (non-clickable).

5. **Network info** — VPN status, ISP, and location are shown as disabled (non-clickable) menu items. IP address and Tor exit status are hidden by default and revealed by holding Option. See [Network and VPN Context](Network-and-VPN-Context) and [Option-Key Power Tools](Option-Key-Power-Tools).

6. **Toggle Stage Manager** — hidden by default, revealed by holding Option. See [Option-Key Power Tools](Option-Key-Power-Tools).

7. **Separator**

8. **Helpful Functions** — section header (non-clickable).

9. **Caffeine** — prevents the display from sleeping. When active, shows a checkmark and changes the icon to a steaming cup. Uses an `IOPMAssertion` of type `PreventUserIdleDisplaySleep`. The assertion is released on quit or when toggled off.

10. **Toggle Desktop Icons** — shows or hides Finder desktop icons by writing `CreateDesktop` to `com.apple.finder` preferences and restarting Finder.

11. **Separator**

12. **Settings...** (`Cmd+,`) — opens the Settings modal with General and Browser Router tabs. See [Settings](Settings).

13. **Separator**

14. **About** — opens the standard macOS About panel with the app identity icon, version, build number, and copyright.

15. **Separator**

16. **Quit** (`Cmd+Q`) — terminates the app, releasing any power assertions and cancelling network monitors. If Browser Router is active, the router process is terminated automatically on quit.
