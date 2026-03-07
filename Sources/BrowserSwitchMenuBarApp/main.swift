import AppKit
import BrowserSwitchCore
import CoreServices
import IOKit.pwr_mgt
import Network
import ServiceManagement

final class BrowserSwitchMenuBarApp: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var browserMenuItems: [String: NSMenuItem] = [:]
    private var runOnStartupItem: NSMenuItem?
    private var modifierPollTimer: Timer?
    private var powerToolsSeparatorItem: NSMenuItem?
    private var desktopIconsToggleItem: NSMenuItem?
    private var stageManagerToggleItem: NSMenuItem?
    private var showPowerTools = false
    private var caffeineMenuItem: NSMenuItem?
    private var caffeineEnabled = false
    private var caffeineAssertionID: IOPMAssertionID = 0
    private lazy var appIdentityIcon: NSImage = makeAppIdentityIcon()
    private var internetInfo: InternetInfo?
    private var internetInfoRequestInFlight = false
    private var internetInfoLastRefresh: Date?
    private var optionHiddenInternetInfoItems: [NSMenuItem] = []
    private var systemVPNStatus: SystemVPNStatus = .unknown
    private var systemVPNStatusRequestInFlight = false
    private var systemVPNStatusLastRefresh: Date?
    private var networkMonitor: NWPathMonitor?
    private let networkMonitorQueue = DispatchQueue(label: "BrowserSwitchMenuBarApp.NetworkMonitor")
    private var appearanceObservation: NSKeyValueObservation?
    private let safariBundleID = "com.apple.Safari"
    private let routerBundleIdentifier = "com.adamabernathy.browserswitch.router"
    private let selectedDefaultBrowserBundleIDKey = "browserRouter.selectedDefaultBrowserBundleID"
    private let routerMenuOptionIdentifier = "__browser_router_option__"
    private let launchServicesPermissionError: OSStatus = -54
    private let defaultBrowserSetRetryDelay: TimeInterval = 0.8
    private let preferencesAppID = "com.adamabernathy.browserswitch" as CFString

    private var menuBarSymbolName: String {
        if #available(macOS 26, *) {
            return "circle.grid.2x2.topleft.checkmark.filled"
        } else {
            return "figure.curling"
        }
    }

    private let preferredBrowserOrder = ["com.apple.Safari", "com.google.Chrome"]
    private let internetInfoRefreshInterval: TimeInterval = 60
    private let systemVPNStatusRefreshInterval: TimeInterval = 5

    func applicationDidFinishLaunching(_ notification: Notification) {
        let runningInstances = NSRunningApplication.runningApplications(
            withBundleIdentifier: Bundle.main.bundleIdentifier ?? "")
            .filter { $0 != .current }
        for instance in runningInstances {
            instance.terminate()
        }

        NSApp.setActivationPolicy(.accessory)
        NSApp.applicationIconImage = appIdentityIcon

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: menuBarSymbolName,
                accessibilityDescription: "Browser Switch")
            button.image?.isTemplate = true
            button.toolTip = "Browser Switch"
        }

        statusItem.menu = buildMenu()
        repairRouterFallbackIfNeeded()
        startNetworkMonitor()
        refreshInternetInfoIfNeeded()
        refreshSystemVPNStatusIfNeeded(force: true)
        startObservingAppearanceChanges()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopCaffeineAssertion()
        networkMonitor?.cancel()
        networkMonitor = nil
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        rebuildMenu(menu)
        return menu
    }

    private func rebuildMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        browserMenuItems.removeAll()
        optionHiddenInternetInfoItems.removeAll()

        let routerItem = NSMenuItem(
            title: "Browser Router",
            action: #selector(selectBrowser(_:)),
            keyEquivalent: "")
        routerItem.target = self
        routerItem.image = browserRouterIcon(isEnabled: isBrowserRouterEnabled())
        routerItem.representedObject = routerMenuOptionIdentifier
        menu.addItem(routerItem)
        browserMenuItems[routerMenuOptionIdentifier] = routerItem

        for bundleID in discoverInstalledBrowsers() {
            let item = NSMenuItem(
                title: appDisplayName(bundleIdentifier: bundleID),
                action: #selector(selectBrowser(_:)),
                keyEquivalent: "")
            item.target = self
            item.image = appIcon(bundleIdentifier: bundleID)
            item.representedObject = bundleID
            menu.addItem(item)
            browserMenuItems[bundleID] = item
        }

        menu.addItem(.separator())

        let caffeineItem = NSMenuItem(
            title: caffeineEnabled ? "Caffeine" : "Caffeine",
            action: #selector(toggleCaffeine),
            keyEquivalent: "")
        caffeineItem.target = self
        menu.addItem(caffeineItem)
        self.caffeineMenuItem = caffeineItem

        let desktopIconsToggleItem = NSMenuItem(
            title: "Toggle Desktop Icons",
            action: #selector(toggleDesktopIcons),
            keyEquivalent: "")
        desktopIconsToggleItem.target = self
        menu.addItem(desktopIconsToggleItem)
        self.desktopIconsToggleItem = desktopIconsToggleItem
        
        menu.addItem(.separator())

        addInternetInfoItems(to: menu)

        let powerToolsSeparator = NSMenuItem.separator()
        menu.addItem(powerToolsSeparator)
        self.powerToolsSeparatorItem = powerToolsSeparator

        let stageManagerToggleItem = NSMenuItem(
            title: "Toggle Stage Manager",
            action: #selector(toggleStageManager),
            keyEquivalent: "")
        stageManagerToggleItem.target = self
        menu.addItem(stageManagerToggleItem)
        self.stageManagerToggleItem = stageManagerToggleItem

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
        let settingsMenu = NSMenu(title: "Settings")

        let runOnStartupItem = NSMenuItem(
            title: "Run on Startup",
            action: #selector(toggleRunOnStartup),
            keyEquivalent: "")
        runOnStartupItem.target = self
        settingsMenu.addItem(runOnStartupItem)
        self.runOnStartupItem = runOnStartupItem

        let scanItem = NSMenuItem(
            title: "Scan for New Browsers",
            action: #selector(scanForNewBrowsers),
            keyEquivalent: "")
        scanItem.target = self
        settingsMenu.addItem(scanItem)

        settingsItem.submenu = settingsMenu
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let aboutItem = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        refreshBrowserState()
        refreshRunOnStartupState()
        refreshCaffeineState()
        refreshPowerToolsState()
        applyPowerToolsVisibility()
    }

    private func appIcon(bundleIdentifier: String) -> NSImage? {
        guard let appURL = applicationURL(forBundleIdentifier: bundleIdentifier) else {
            return nil
        }

        let icon = NSWorkspace.shared.icon(forFile: appURL.path)
        icon.size = NSSize(width: 16, height: 16)
        return icon
    }

    private func browserRouterIcon(isEnabled: Bool) -> NSImage? {
        let symbolNames = isEnabled
            ? ["signpost.right.and.left.fill", "signpost.right.and.left"]
            : ["signpost.right.and.left", "signpost.right.and.left.fill"]

        for symbolName in symbolNames {
            guard let icon = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Browser Router") else {
                continue
            }
            icon.size = NSSize(width: 16, height: 16)
            icon.isTemplate = true
            return icon
        }

        return nil
    }

    private func appDisplayName(bundleIdentifier: String) -> String {
        guard
            let appURL = applicationURL(forBundleIdentifier: bundleIdentifier),
            let bundle = Bundle(url: appURL)
        else {
            return bundleIdentifier
        }

        if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, !displayName.isEmpty {
            return displayName
        }

        if let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String, !bundleName.isEmpty {
            return bundleName
        }

        return appURL.deletingPathExtension().lastPathComponent
    }

    @objc
    private func selectBrowser(_ sender: NSMenuItem) {
        guard let bundleIdentifier = sender.representedObject as? String else { return }
        if bundleIdentifier == routerMenuOptionIdentifier {
            toggleBrowserRouter()
            return
        }
        selectDefaultBrowser(bundleIdentifier: bundleIdentifier)
    }

    private func toggleBrowserRouter() {
        if isBrowserRouterEnabled() {
            if let selectedDefaultBrowser = resolvedSelectedDefaultBrowserBundleID() {
                terminateRouterIfRunning()
                setDefaultBrowser(bundleIdentifier: selectedDefaultBrowser)
            }
            return
        }

        enableBrowserRouter()
    }

    private func terminateRouterIfRunning() {
        NSRunningApplication
            .runningApplications(withBundleIdentifier: routerBundleIdentifier)
            .forEach { $0.terminate() }
    }

    private func launchRouterHelperIfNeeded(completion: @escaping () -> Void) {
        guard let resourceURL = Bundle.main.resourceURL else {
            showAlert(
                title: "Browser Router Unavailable",
                message: "Run ./scripts/build-app.sh to build the full app bundle required for Browser Router.")
            return
        }
        let routerAppURL = resourceURL.appendingPathComponent("BrowserSwitchRouter.app")
        guard FileManager.default.fileExists(atPath: routerAppURL.path) else {
            showAlert(
                title: "Browser Router Unavailable",
                message: "BrowserSwitchRouter.app was not found. Run ./scripts/build-app.sh to build the full app bundle.")
            return
        }

        let alreadyRunning = NSRunningApplication
            .runningApplications(withBundleIdentifier: routerBundleIdentifier)
            .contains { !$0.isTerminated }
        if alreadyRunning {
            completion()
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = false
        NSWorkspace.shared.openApplication(at: routerAppURL, configuration: config) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error {
                    self?.showAlert(
                        title: "Could Not Start Browser Router",
                        message: error.localizedDescription)
                } else {
                    completion()
                }
            }
        }
    }

    private func enableBrowserRouter() {
        let fallback = resolvedSelectedDefaultBrowserBundleID()
        debugLog("enableBrowserRouter fallback=\(fallback ?? "nil")")
        if let fallback {
            persistSelectedDefaultBrowserBundleID(fallback)
        }
        launchRouterHelperIfNeeded { [weak self] in
            guard let self else { return }
            self.setDefaultBrowser(bundleIdentifier: self.routerBundleIdentifier)
        }
    }

    private func selectDefaultBrowser(bundleIdentifier: String) {
        persistSelectedDefaultBrowserBundleID(bundleIdentifier)
        if isBrowserRouterEnabled() {
            refreshBrowserState()
            return
        }
        setDefaultBrowser(bundleIdentifier: bundleIdentifier)
    }

    private func setDefaultBrowser(bundleIdentifier: String) {
        applyDefaultBrowserHandlers(
            bundleIdentifier: bundleIdentifier,
            schemes: ["http", "https"],
            retryCount: 10)
    }

    private func applyDefaultBrowserHandlers(bundleIdentifier: String, schemes: [String], retryCount: Int) {
        var failedStatuses: [(scheme: String, status: OSStatus)] = []

        for scheme in schemes {
            let status = LSSetDefaultHandlerForURLScheme(scheme as CFString, bundleIdentifier as CFString)
            if status != noErr {
                failedStatuses.append((scheme: scheme, status: status))
            }
        }

        if failedStatuses.isEmpty {
            refreshBrowserState()
            return
        }

        let retryableFailures = failedStatuses.filter { $0.status == launchServicesPermissionError }
        if !retryableFailures.isEmpty && retryCount > 0 {
            let retrySchemes = retryableFailures.map(\.scheme)
            DispatchQueue.main.asyncAfter(deadline: .now() + defaultBrowserSetRetryDelay) { [weak self] in
                self?.applyDefaultBrowserHandlers(
                    bundleIdentifier: bundleIdentifier,
                    schemes: retrySchemes,
                    retryCount: retryCount - 1)
            }
            refreshBrowserState()
            return
        }

        if failedStatuses.allSatisfy({ $0.status == launchServicesPermissionError }) {
            refreshBrowserState()
            return
        }

        let details = failedStatuses
            .map { "\($0.scheme): \($0.status)" }
            .joined(separator: ", ")
        showAlert(
            title: "Could Not Set Default Browser",
            message: "Launch Services rejected the default browser update (\(details)).")
        refreshBrowserState()
    }

    @objc
    private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        
        // Create formatted credits with version info
        let creditsText = """
        Version \(versionString) (Build \(buildString))
        
        (C) 2026 Adam Abernathy, LLC
        """
        let copyright = NSAttributedString(string: creditsText)
        
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Browser Switch",
            .applicationIcon: appIdentityIcon,
            .credits: copyright
        ])
    }

    @objc
    private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc
    private func scanForNewBrowsers() {
        guard let menu = statusItem.menu else { return }
        rebuildMenu(menu)
    }

    @objc
    private func toggleDesktopIcons() {
        let shouldShowDesktopIcons = !desktopIconsAreVisible()
        let defaultsOK = runSystemCommand(
            executable: "/usr/bin/defaults",
            arguments: ["write", "com.apple.finder", "CreateDesktop", "-bool", shouldShowDesktopIcons ? "true" : "false"])
        let finderRestartOK = runSystemCommand(
            executable: "/usr/bin/killall",
            arguments: ["Finder"])

        if !defaultsOK || !finderRestartOK {
            showAlert(
                title: "Could Not Update Desktop Icons",
                message: "macOS did not accept one of the commands needed to update Finder.")
        }
        refreshPowerToolsState()
    }

    @objc
    private func toggleStageManager() {
        let shouldEnableStageManager = !stageManagerIsEnabled()
        let defaultsOK = runSystemCommand(
            executable: "/usr/bin/defaults",
            arguments: ["write", "com.apple.WindowManager", "GloballyEnabled", "-bool", shouldEnableStageManager ? "true" : "false"])
        let dockRestartOK = runSystemCommand(
            executable: "/usr/bin/killall",
            arguments: ["Dock"])

        if !defaultsOK || !dockRestartOK {
            showAlert(
                title: "Could Not Update Stage Manager",
                message: "macOS did not accept one of the commands needed to update Dock settings.")
        }
        refreshPowerToolsState()
    }

    @objc
    private func toggleRunOnStartup() {
        do {
            let service = SMAppService.mainApp
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            showAlert(
                title: "Could Not Update Startup Setting",
                message: error.localizedDescription)
        }

        refreshRunOnStartupState()
    }

    @objc
    private func toggleCaffeine() {
        caffeineEnabled.toggle()

        if caffeineEnabled {
            startCaffeineAssertion()
        } else {
            stopCaffeineAssertion()
        }

        refreshCaffeineState()
    }

    private func startCaffeineAssertion() {
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Browser Switch Caffeine Mode" as CFString,
            &caffeineAssertionID)

        if result != kIOReturnSuccess {
            caffeineEnabled = false
            showAlert(
                title: "Caffeine Mode Failed",
                message: "macOS did not allow the app to prevent sleep.")
        }
    }

    private func stopCaffeineAssertion() {
        if caffeineAssertionID != 0 {
            IOPMAssertionRelease(caffeineAssertionID)
            caffeineAssertionID = 0
        }
    }

    private func refreshCaffeineState() {
        guard let item = caffeineMenuItem else { return }

        item.title = caffeineEnabled ? "Caffeine" : "Caffeine"

        if caffeineEnabled {
            item.image = caffeineOnImage()
        } else {
            let image = NSImage(
                systemSymbolName: "cup.and.saucer.fill",
                accessibilityDescription: "Caffeine Off")
            image?.size = NSSize(width: 16, height: 16)
            item.image = image
        }
    }

    private func caffeineOnImage() -> NSImage? {
        guard let cupImage = NSImage(
            systemSymbolName: "cup.and.heat.waves.fill",
            accessibilityDescription: "Caffeine On")
        else {
            return nil
        }

        let cupSize = NSSize(width: 16, height: 16)
        let dotDiameter: CGFloat = 6
        let padding: CGFloat = 1
        let totalWidth = dotDiameter + padding + cupSize.width
        let compositeSize = NSSize(width: totalWidth, height: cupSize.height)

        let composite = NSImage(size: compositeSize, flipped: false) { drawRect in
            NSColor.systemGreen.setFill()
            let dotRect = NSRect(
                x: 0,
                y: (cupSize.height - dotDiameter) / 2,
                width: dotDiameter,
                height: dotDiameter)
            NSBezierPath(ovalIn: dotRect).fill()

            cupImage.draw(
                in: NSRect(x: dotDiameter + padding, y: 0, width: cupSize.width, height: cupSize.height),
                from: .zero,
                operation: .sourceOver,
                fraction: 1.0)
            return true
        }
        return composite
    }

    private func refreshBrowserState() {
        let routerEnabled = isBrowserRouterEnabled()
        let selectedDefaultBrowser = resolvedSelectedDefaultBrowserBundleID()

        for (bundleID, item) in browserMenuItems {
            if bundleID == routerMenuOptionIdentifier {
                item.state = routerEnabled ? .on : .off
                item.image = browserRouterIcon(isEnabled: routerEnabled)
                continue
            }

            item.state = bundleID == selectedDefaultBrowser ? .on : .off
        }
    }

    private func refreshRunOnStartupState() {
        guard let item = runOnStartupItem else { return }

        let status = SMAppService.mainApp.status
        item.isEnabled = true
        switch status {
        case .enabled:
            item.state = .on
        case .requiresApproval:
            item.state = .mixed
        case .notRegistered:
            item.state = .off
        case .notFound:
            item.state = .off
            item.isEnabled = false
        @unknown default:
            item.state = .off
        }
    }

    private func currentDefaultBrowserBundleID(excluding excludedBundleIDs: Set<String> = []) -> String? {
        for scheme in ["https", "http"] {
            guard
                let url = URL(string: "\(scheme)://example.com"),
                let appURL = NSWorkspace.shared.urlForApplication(toOpen: url),
                let bundleID = Bundle(url: appURL)?.bundleIdentifier,
                !excludedBundleIDs.contains(bundleID)
            else {
                continue
            }
            return bundleID
        }

        if !excludedBundleIDs.isEmpty {
            for scheme in ["https", "http"] {
                guard let url = URL(string: "\(scheme)://example.com") else { continue }
                for appURL in NSWorkspace.shared.urlsForApplications(toOpen: url) {
                    guard let bundleID = Bundle(url: appURL)?.bundleIdentifier else { continue }
                    if excludedBundleIDs.contains(bundleID) { continue }
                    return bundleID
                }
            }
        }

        return nil
    }

    private func repairRouterFallbackIfNeeded() {
        guard isBrowserRouterEnabled() else { return }
        let saved = CFPreferencesCopyAppValue(selectedDefaultBrowserBundleIDKey as CFString, preferencesAppID) as? String
        guard saved == nil || saved == routerBundleIdentifier else { return }
        if let fallback = currentDefaultBrowserBundleID(excluding: [routerBundleIdentifier]) {
            persistSelectedDefaultBrowserBundleID(fallback)
            debugLog("repairRouterFallback saved fallback=\(fallback)")
        }
    }

    private func isBrowserRouterEnabled() -> Bool {
        return currentDefaultBrowserBundleID() == routerBundleIdentifier
    }

    private func persistSelectedDefaultBrowserBundleID(_ bundleIdentifier: String) {
        let appURL = applicationURL(forBundleIdentifier: bundleIdentifier)
        debugLog("persist bundleID=\(bundleIdentifier) appURL=\(appURL?.path ?? "nil")")
        guard
            !bundleIdentifier.isEmpty,
            bundleIdentifier != routerBundleIdentifier,
            appURL != nil
        else {
            debugLog("persist REJECTED")
            return
        }
        CFPreferencesSetAppValue(selectedDefaultBrowserBundleIDKey as CFString, bundleIdentifier as CFString, preferencesAppID)
        CFPreferencesAppSynchronize(preferencesAppID)
        debugLog("persist WROTE \(bundleIdentifier)")
    }

    private func debugLog(_ message: String) {
        let logPath = "/tmp/browser-switch-router.log"
        let line = "[MAIN \(ISO8601DateFormatter().string(from: Date()))] \(message)\n"
        guard let data = line.data(using: .utf8) else { return }
        let url = URL(fileURLWithPath: logPath)
        if FileManager.default.fileExists(atPath: logPath),
           let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        } else {
            try? data.write(to: url)
        }
    }

    private func resolvedSelectedDefaultBrowserBundleID() -> String? {
        if
            let savedBundleID = CFPreferencesCopyAppValue(selectedDefaultBrowserBundleIDKey as CFString, preferencesAppID) as? String,
            savedBundleID != routerBundleIdentifier,
            applicationURL(forBundleIdentifier: savedBundleID) != nil
        {
            return savedBundleID
        }

        if let liveFallback = currentDefaultBrowserBundleID(excluding: [routerBundleIdentifier]) {
            return liveFallback
        }
        if applicationURL(forBundleIdentifier: safariBundleID) != nil {
            return safariBundleID
        }

        return nil
    }

    func menuWillOpen(_ menu: NSMenu) {
        showPowerTools = NSEvent.modifierFlags.contains(.option)
        startOptionTrackingTimer()
        applyPowerToolsVisibility()
        refreshInternetInfoIfNeeded()
        refreshSystemVPNStatusIfNeeded(force: false)
        rebuildMenu(menu)
    }

    func menuDidClose(_ menu: NSMenu) {
        stopOptionTrackingTimer()
        showPowerTools = false
        applyPowerToolsVisibility()
    }

    private func discoverInstalledBrowsers() -> [String] {
        let httpHandlers = Set(bundleIDsForApplicationsOpening(urlString: "http://example.com"))
        let httpsHandlers = Set(bundleIDsForApplicationsOpening(urlString: "https://example.com"))
        let ownBundleID = Bundle.main.bundleIdentifier ?? ""

        let candidateBundleIDs = httpHandlers
            .intersection(httpsHandlers)
            .filter { !$0.isEmpty && $0 != ownBundleID && $0 != routerBundleIdentifier }
            .filter { applicationURL(forBundleIdentifier: $0) != nil }

        return BrowserDiscovery.orderedBundleIDs(
            preferredOrder: preferredBrowserOrder,
            candidates: candidateBundleIDs.compactMap { browserCandidate(bundleIdentifier: $0) }
        )
    }

    private func browserCandidate(bundleIdentifier: String) -> BrowserCandidateInfo? {
        guard let appURL = applicationURL(forBundleIdentifier: bundleIdentifier) else {
            return nil
        }

        return BrowserCandidateInfo(
            bundleID: bundleIdentifier,
            appURL: appURL,
            displayName: appDisplayName(bundleIdentifier: bundleIdentifier)
        )
    }

    private func bundleIDsForApplicationsOpening(urlString: String) -> [String] {
        guard let url = URL(string: urlString) else {
            return []
        }

        return NSWorkspace.shared
            .urlsForApplications(toOpen: url)
            .compactMap { Bundle(url: $0)?.bundleIdentifier }
    }

    private func applicationURL(forBundleIdentifier bundleIdentifier: String) -> URL? {
        if let direct = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return direct
        }

        for urlString in ["https://example.com", "http://example.com"] {
            guard let probeURL = URL(string: urlString) else { continue }
            for candidate in NSWorkspace.shared.urlsForApplications(toOpen: probeURL) {
                guard let candidateBundleID = Bundle(url: candidate)?.bundleIdentifier else { continue }
                if candidateBundleID == bundleIdentifier {
                    return candidate
                }
            }
        }

        return nil
    }

    private func addInternetInfoItems(to menu: NSMenu) {
        if let vpnStatusItem = makeVPNStatusItem() {
            menu.addItem(vpnStatusItem)
        }

        guard let internetInfo else { return }

        for line in internetInfo.menuLines() {
            let item = NSMenuItem(title: line.title, action: nil, keyEquivalent: "")
            item.isEnabled = false
            if line.isHiddenWithoutOptionKey {
                optionHiddenInternetInfoItems.append(item)
            }
            menu.addItem(item)
        }
    }

    private func makeVPNStatusItem() -> NSMenuItem? {
        guard let resolvedVPNEnabled = systemVPNStatus.isConnected else { return nil }

        let item = NSMenuItem(
            title: resolvedVPNEnabled ? "VPN: On" : "VPN: Off",
            action: nil,
            keyEquivalent: "")
        item.isEnabled = false

        if resolvedVPNEnabled {
            item.image = vpnConnectedImage()
        }

        return item
    }

    private func vpnConnectedImage() -> NSImage? {
        guard let baseImage = NSImage(
            systemSymbolName: "checkmark.circle.fill",
            accessibilityDescription: "VPN enabled")
        else {
            return nil
        }

        baseImage.isTemplate = false

        let config = NSImage.SymbolConfiguration(paletteColors: [.systemGreen])
        let image = baseImage.withSymbolConfiguration(config) ?? baseImage
        image.size = NSSize(width: 14, height: 14)
        return image
    }

    private func refreshInternetInfoIfNeeded() {
        if internetInfoRequestInFlight { return }

        if let lastRefresh = internetInfoLastRefresh,
           Date().timeIntervalSince(lastRefresh) < internetInfoRefreshInterval {
            return
        }

        guard let url = URL(string: "https://wtfismyip.com/json") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 3

        internetInfoRequestInFlight = true

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }

            let latestInfo: InternetInfo?
            if let data, error == nil {
                latestInfo = InternetInfoDecoder.decode(from: data)
            } else {
                latestInfo = nil
            }

            DispatchQueue.main.async {
                self.internetInfoRequestInFlight = false
                self.internetInfoLastRefresh = Date()

                let didChange = self.internetInfo != latestInfo
                self.internetInfo = latestInfo

                if didChange, let menu = self.statusItem?.menu {
                    self.rebuildMenu(menu)
                }
            }
        }.resume()
    }

    private func startObservingAppearanceChanges() {
        appearanceObservation = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
            guard let self else { return }
            self.appIdentityIcon = self.makeAppIdentityIcon()
            NSApp.applicationIconImage = self.appIdentityIcon
        }
    }

    private func startNetworkMonitor() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.refreshInternetInfoIfNeeded()
                self.refreshSystemVPNStatusIfNeeded(force: false)
            }
        }
        monitor.start(queue: networkMonitorQueue)
        networkMonitor = monitor
    }

    private func refreshSystemVPNStatusIfNeeded(force: Bool) {
        if systemVPNStatusRequestInFlight { return }

        if
            !force,
            let lastRefresh = systemVPNStatusLastRefresh,
            Date().timeIntervalSince(lastRefresh) < systemVPNStatusRefreshInterval
        {
            return
        }

        systemVPNStatusRequestInFlight = true

        DispatchQueue.global(qos: .utility).async { [weak self] in
            let latestStatus = SystemVPNStatusDetector.detect()

            DispatchQueue.main.async {
                guard let self else { return }

                self.systemVPNStatusRequestInFlight = false
                self.systemVPNStatusLastRefresh = Date()

                let didChange = self.systemVPNStatus != latestStatus
                self.systemVPNStatus = latestStatus

                if didChange, let menu = self.statusItem?.menu {
                    self.rebuildMenu(menu)
                }
            }
        }
    }

    private func makeAppIdentityIcon() -> NSImage {
        let size = NSSize(width: 512, height: 512)
        let image = NSImage(size: size, flipped: false) { drawRect in
            let bgRect = NSRect(origin: .zero, size: size)
            NSColor.windowBackgroundColor.setFill()
            NSBezierPath(roundedRect: bgRect, xRadius: 96, yRadius: 96).fill()

            if let symbol = NSImage(
                systemSymbolName: self.menuBarSymbolName,
                accessibilityDescription: "Browser Switch")
            {
                let config = NSImage.SymbolConfiguration(pointSize: 300, weight: .medium)
                    .applying(NSImage.SymbolConfiguration(paletteColors: [.labelColor]))
                symbol.isTemplate = false
                symbol.withSymbolConfiguration(config)?
                    .draw(in: NSRect(x: 106, y: 106, width: 300, height: 300))
            }
            return true
        }
        return image
    }

    private func startOptionTrackingTimer() {
        stopOptionTrackingTimer()

        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.handleModifierChange(NSEvent.modifierFlags)
        }
        modifierPollTimer = timer
        RunLoop.current.add(timer, forMode: .eventTracking)
    }

    private func stopOptionTrackingTimer() {
        modifierPollTimer?.invalidate()
        modifierPollTimer = nil
    }

    private func handleModifierChange(_ flags: NSEvent.ModifierFlags) {
        let shouldShow = flags.contains(.option)
        guard shouldShow != showPowerTools else { return }

        showPowerTools = shouldShow
        applyPowerToolsVisibility()
        statusItem.menu?.update()
    }

    private func applyPowerToolsVisibility() {
        let hidden = !showPowerTools
        powerToolsSeparatorItem?.isHidden = hidden
        stageManagerToggleItem?.isHidden = hidden
        for item in optionHiddenInternetInfoItems {
            item.isHidden = hidden
        }
    }

    private func refreshPowerToolsState() {
        let desktopVisible = desktopIconsAreVisible()
        desktopIconsToggleItem?.title = desktopVisible ? "Hide Desktop Icons" : "Show Desktop Icons"
        desktopIconsToggleItem?.image = NSImage(
            systemSymbolName: desktopVisible ? "eye.slash" : "eye",
            accessibilityDescription: desktopVisible ? "Hide Desktop Icons" : "Show Desktop Icons")

        let stageEnabled = stageManagerIsEnabled()
        stageManagerToggleItem?.title = stageEnabled ? "Disable Stage Manager" : "Enable Stage Manager"
        stageManagerToggleItem?.image = NSImage(
            systemSymbolName: stageEnabled ? "rectangle.on.rectangle.slash" : "rectangle.on.rectangle",
            accessibilityDescription: stageEnabled ? "Disable Stage Manager" : "Enable Stage Manager")
    }

    private func desktopIconsAreVisible() -> Bool {
        preferenceBool(domain: "com.apple.finder", key: "CreateDesktop", defaultValue: true)
    }

    private func stageManagerIsEnabled() -> Bool {
        preferenceBool(domain: "com.apple.WindowManager", key: "GloballyEnabled", defaultValue: false)
    }

    private func preferenceBool(domain: String, key: String, defaultValue: Bool) -> Bool {
        guard let value = CFPreferencesCopyAppValue(key as CFString, domain as CFString) else {
            return defaultValue
        }
        if let number = value as? NSNumber {
            return number.boolValue
        }
        if let boolValue = value as? Bool {
            return boolValue
        }
        return defaultValue
    }

    private func runSystemCommand(executable: String, arguments: [String]) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func showAlert(title: String, message: String) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = BrowserSwitchMenuBarApp()
app.delegate = delegate
app.run()
