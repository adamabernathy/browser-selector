import Foundation

public enum BrowserRouterPolicy {
    /// Returns the bundle ID of the browser that should handle the given URL,
    /// based on the provided route list. Returns nil if no route matches.
    public static func targetBundleID(for url: URL, routes: [BrowserRoute]) -> String? {
        guard let host = url.host?.lowercased(), !host.isEmpty else { return nil }
        let path = url.path.lowercased()

        for route in routes where route.isEnabled {
            if patternMatches(host: host, path: path, pattern: route.pattern.lowercased()) {
                return route.browserBundleID
            }
        }
        return nil
    }

    // MARK: - Pattern matching

    private static func patternMatches(host: String, path: String, pattern: String) -> Bool {
        guard !pattern.isEmpty else { return false }

        let patternHost: String
        let patternPath: String?

        if let slashIdx = pattern.firstIndex(of: "/") {
            patternHost = String(pattern[..<slashIdx])
            patternPath = String(pattern[slashIdx...])
        } else {
            patternHost = pattern
            patternPath = nil
        }

        guard hostMatches(host, patternHost: patternHost) else { return false }
        if let patternPath { return path.hasPrefix(patternPath) }
        return true
    }

    private static func hostMatches(_ host: String, patternHost: String) -> Bool {
        if patternHost.hasPrefix("*.") {
            let suffix = String(patternHost.dropFirst(2))
            return host == suffix || host.hasSuffix(".\(suffix)")
        }
        return host == patternHost
    }
}
