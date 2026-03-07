import Foundation

public struct BrowserRoute: Codable, Equatable {
    public var id: UUID
    public var pattern: String
    public var browserBundleID: String
    public var profile: String?
    public var isBuiltIn: Bool
    public var bundleGroupName: String?
    public var isEnabled: Bool

    public init(
        id: UUID = UUID(),
        pattern: String,
        browserBundleID: String,
        profile: String? = nil,
        isBuiltIn: Bool = false,
        bundleGroupName: String? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.pattern = pattern
        self.browserBundleID = browserBundleID
        self.profile = profile
        self.isBuiltIn = isBuiltIn
        self.bundleGroupName = bundleGroupName
        self.isEnabled = isEnabled
    }
}
