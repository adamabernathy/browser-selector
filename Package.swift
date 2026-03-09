// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BrowserSwitchMenuBarApp",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BrowserSwitchMenuBarApp", targets: ["BrowserSwitchMenuBarApp"]),
        .executable(name: "BrowserSwitchRouter",     targets: ["BrowserSwitchRouter"]),
    ],
    targets: [
        .target(name: "BrowserSwitchCore"),
        .executableTarget(
            name: "BrowserSwitchMenuBarApp",
            dependencies: ["BrowserSwitchCore"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreServices"),
                .linkedFramework("Network")
            ]
        ),
        .executableTarget(
            name: "BrowserSwitchRouter",
            dependencies: ["BrowserSwitchCore"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreServices")
            ]
        ),
        .testTarget(
            name: "BrowserSwitchMenuBarAppTests",
            dependencies: ["BrowserSwitchMenuBarApp", "BrowserSwitchCore"]
        )
    ]
)
