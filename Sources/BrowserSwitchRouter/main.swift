import AppKit
import CoreServices
import BrowserSwitchCore

private let chromeBundleID = "com.google.Chrome"
private let mainAppBundleID = "com.adamabernathy.browserswitch"
private let selectedDefaultBrowserBundleIDKey = "browserRouter.selectedDefaultBrowserBundleID"
private let routerLogPath = "/tmp/browser-switch-router.log"

// MARK: - Duplicate instance guard

let runningInstances = NSRunningApplication.runningApplications(
    withBundleIdentifier: Bundle.main.bundleIdentifier ?? "")
    .filter { $0 != .current }
for instance in runningInstances {
    instance.terminate()
}

// MARK: - URL routing

private func resolvedFallbackBundleID() -> String? {
    guard
        let value = CFPreferencesCopyAppValue(
            selectedDefaultBrowserBundleIDKey as CFString,
            mainAppBundleID as CFString) as? String,
        !value.isEmpty
    else {
        return nil
    }
    return value
}

private func applicationURL(forBundleIdentifier bundleIdentifier: String) -> URL? {
    if let direct = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
        return direct
    }
    for urlString in ["https://example.com", "http://example.com"] {
        guard let probeURL = URL(string: urlString) else { continue }
        for candidate in NSWorkspace.shared.urlsForApplications(toOpen: probeURL) {
            guard let candidateBundleID = Bundle(url: candidate)?.bundleIdentifier else { continue }
            if candidateBundleID == bundleIdentifier { return candidate }
        }
    }
    return nil
}

@discardableResult
private func openURLViaSystemOpen(_ url: URL, applicationURL: URL) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = ["-a", applicationURL.path, url.absoluteString]
    do {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    } catch {
        return false
    }
}

private func openURL(_ url: URL, inBrowserWithBundleID bundleIdentifier: String) {
    guard let appURL = applicationURL(forBundleIdentifier: bundleIdentifier) else {
        logRouter("open skip url=\(url.absoluteString) bundle=\(bundleIdentifier) reason=not_found")
        return
    }

    if openURLViaSystemOpen(url, applicationURL: appURL) {
        logRouter("open success method=open-a url=\(url.absoluteString) bundle=\(bundleIdentifier)")
        return
    }

    let config = NSWorkspace.OpenConfiguration()
    config.activates = true
    NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { _, error in
        if let error {
            logRouter("open result method=nsworkspace url=\(url.absoluteString) bundle=\(bundleIdentifier) error=\(error.localizedDescription)")
        } else {
            logRouter("open success method=nsworkspace url=\(url.absoluteString) bundle=\(bundleIdentifier)")
        }
    }
}

private func routeURL(_ url: URL) {
    guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else { return }

    let fallbackBundleID = resolvedFallbackBundleID()
    let targetBundleID: String

    if BrowserRouterPolicy.shouldOpenInChrome(url) {
        if applicationURL(forBundleIdentifier: chromeBundleID) != nil {
            targetBundleID = chromeBundleID
        } else if let fallback = fallbackBundleID {
            targetBundleID = fallback
        } else {
            logRouter("route drop url=\(url.absoluteString) reason=no_chrome_no_fallback")
            return
        }
    } else if let fallback = fallbackBundleID {
        targetBundleID = fallback
    } else {
        logRouter("route drop url=\(url.absoluteString) reason=no_fallback")
        return
    }

    logRouter("route url=\(url.absoluteString) target=\(targetBundleID) fallback=\(fallbackBundleID ?? "-")")
    openURL(url, inBrowserWithBundleID: targetBundleID)
}

private func logRouter(_ message: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(message)\n"
    guard let data = line.data(using: .utf8) else { return }
    let url = URL(fileURLWithPath: routerLogPath)
    if FileManager.default.fileExists(atPath: routerLogPath) {
        if let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
    } else {
        try? data.write(to: url)
    }
}

// MARK: - Apple Event handler

final class RouterDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        logRouter("router started bundle=\(Bundle.main.bundleIdentifier ?? "-")")
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { routeURL(url) }
    }

    @objc
    func handleGetURLEvent(
        _ event: NSAppleEventDescriptor,
        withReplyEvent _: NSAppleEventDescriptor
    ) {
        guard
            let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let url = URL(string: urlString)
        else { return }
        routeURL(url)
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
}

let app = NSApplication.shared
let delegate = RouterDelegate()
app.delegate = delegate
app.run()
