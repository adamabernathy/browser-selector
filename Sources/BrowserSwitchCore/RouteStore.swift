import Foundation

public final class RouteStore {
    public static let shared = RouteStore()

    public private(set) var routes: [BrowserRoute] = []

    private let fileURL: URL

    public init() {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        let dir = appSupport.appendingPathComponent("BrowserSwitch")
        fileURL = dir.appendingPathComponent("routes.json")
        load()
    }

    public func reload() {
        load()
    }

    private func load() {
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([BrowserRoute].self, from: data) {
            routes = decoded
        } else {
            routes = RouteStore.defaultRoutes
            save()
        }
    }

    @discardableResult
    public func save() -> Bool {
        let dir = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(routes)
            try data.write(to: fileURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    public func add(_ route: BrowserRoute) {
        routes.append(route)
        save()
    }

    public func remove(id: UUID) {
        routes.removeAll { $0.id == id && !$0.isBuiltIn }
        save()
    }

    public func update(_ route: BrowserRoute) {
        guard let index = routes.firstIndex(where: { $0.id == route.id }) else { return }
        routes[index] = route
        save()
    }

    public func setGroupEnabled(_ groupName: String, enabled: Bool) {
        for i in routes.indices where routes[i].bundleGroupName == groupName {
            routes[i].isEnabled = enabled
        }
        save()
    }

    public var sortedRoutes: [BrowserRoute] {
        let builtIns = routes.filter(\.isBuiltIn)
            .sorted { $0.pattern.localizedCaseInsensitiveCompare($1.pattern) == .orderedAscending }
        let custom = routes.filter { !$0.isBuiltIn }
            .sorted { $0.pattern.localizedCaseInsensitiveCompare($1.pattern) == .orderedAscending }
        return builtIns + custom
    }

    public var bundleGroups: [(name: String, routes: [BrowserRoute])] {
        var groups: [String: [BrowserRoute]] = [:]
        for route in routes where route.isBuiltIn {
            let key = route.bundleGroupName ?? ""
            groups[key, default: []].append(route)
        }
        return groups.map { (name: $0.key, routes: $0.value) }
            .sorted { $0.name < $1.name }
    }
}

// MARK: - Default routes

extension RouteStore {
    public static let googleWorkspaceBundleGroupName = "Google Workspace"
    public static let geminiBundleGroupName = "Google Gemini"
    public static let chromeBundleID = "com.google.Chrome"

    public static let defaultRoutes: [BrowserRoute] = googleWorkspaceRoutes + geminiRoutes

    private static let googleWorkspaceHosts = [
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
        "docs.new",
        "sheets.new",
        "slides.new",
        "forms.new",
    ]

    public static let googleWorkspaceRoutes: [BrowserRoute] = googleWorkspaceHosts.map {
        BrowserRoute(
            pattern: $0,
            browserBundleID: chromeBundleID,
            isBuiltIn: true,
            bundleGroupName: googleWorkspaceBundleGroupName
        )
    }

    public static let geminiRoutes: [BrowserRoute] = [
        BrowserRoute(
            pattern: "gemini.google.com",
            browserBundleID: chromeBundleID,
            isBuiltIn: true,
            bundleGroupName: geminiBundleGroupName
        )
    ]
}
