#!/usr/bin/env bash
# Creates a minimal BrowserSwitchRouter.app in the SPM bin directory and
# registers it with Launch Services so the router feature works in dev builds.
set -euo pipefail

ROUTER_BUNDLE_ID="com.adamabernathy.browserswitch.router"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

BIN_PATH=$(swift build --show-bin-path 2>/dev/null)
ROUTER_BIN="${BIN_PATH}/BrowserSwitchRouter"
ROUTER_APP="${BIN_PATH}/BrowserSwitchRouter.app"

if [ ! -f "${ROUTER_BIN}" ]; then
    echo "error: BrowserSwitchRouter binary not found at ${ROUTER_BIN}" >&2
    exit 1
fi

mkdir -p "${ROUTER_APP}/Contents/MacOS"
cp "${ROUTER_BIN}" "${ROUTER_APP}/Contents/MacOS/BrowserSwitchRouter"
chmod +x "${ROUTER_APP}/Contents/MacOS/BrowserSwitchRouter"

cat > "${ROUTER_APP}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>   <string>BrowserSwitchRouter</string>
  <key>CFBundleIdentifier</key>   <string>${ROUTER_BUNDLE_ID}</string>
  <key>CFBundleName</key>         <string>BrowserSwitchRouter</string>
  <key>CFBundlePackageType</key>  <string>APPL</string>
  <key>CFBundleShortVersionString</key> <string>0.0.0-dev</string>
  <key>CFBundleVersion</key>      <string>dev</string>
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>     <string>Web URLs</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>http</string>
        <string>https</string>
      </array>
    </dict>
  </array>
  <key>LSMinimumSystemVersion</key> <string>14.0</string>
  <key>LSUIElement</key>            <true/>
  <key>NSHighResolutionCapable</key> <true/>
</dict>
</plist>
PLIST

if [ -f "${LSREGISTER}" ]; then
    "${LSREGISTER}" -f "${ROUTER_APP}"
fi

echo "Dev router bundle ready at: ${ROUTER_APP}"
