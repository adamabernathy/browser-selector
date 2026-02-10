#!/usr/bin/env bash
# Browser Switch – install from source
# https://github.com/adamabernathy/browser-selector
#
# One-liner install (copy and paste into Terminal):
#
#   rm -rf /tmp/browser-selector-install && git clone https://github.com/adamabernathy/browser-selector /tmp/browser-selector-install && /tmp/browser-selector-install/scripts/install.sh && rm -rf /tmp/browser-selector-install
#
# Requirements: Xcode or Xcode Command Line Tools with Swift 5.9+

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

APP_NAME="Browser Switch"
INSTALL_DIR="${HOME}/Applications"

cd "${PROJECT_DIR}"

echo "Building ${APP_NAME}..."
./scripts/build-app.sh --release

mkdir -p "${INSTALL_DIR}"

if [ -d "${INSTALL_DIR}/${APP_NAME}.app" ]; then
    echo "Removing previous install..."
    rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
fi

cp -R "dist/${APP_NAME}.app" "${INSTALL_DIR}/${APP_NAME}.app"
echo "Installed to ${INSTALL_DIR}/${APP_NAME}.app"
