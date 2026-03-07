import Foundation

public enum BrowserRouterPolicy {
    /// Hosts whose URLs should always open in Chrome when Browser Router is enabled.
    /// Includes Google Workspace collaboration and productivity apps.
    private static let chromeHosts: Set<String> = [
        // Google Workspace apps
        "docs.google.com",
        "sheets.google.com",
        "slides.google.com",
        "drive.google.com",
        "mail.google.com",
        "calendar.google.com",
        "meet.google.com",
        "chat.google.com",
        "jamboard.google.com",
        "sites.google.com",
        "keep.google.com",
        "forms.google.com",
        "admin.google.com",
        "workspace.google.com",
        // New-document shortcuts
        "docs.new",
        "sheets.new",
        "slides.new",
        "forms.new",
    ]

    public static func shouldOpenInChrome(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased(), !host.isEmpty else {
            return false
        }

        for chromeHost in chromeHosts {
            if host == chromeHost || host.hasSuffix(".\(chromeHost)") {
                return true
            }
        }

        return false
    }
}
