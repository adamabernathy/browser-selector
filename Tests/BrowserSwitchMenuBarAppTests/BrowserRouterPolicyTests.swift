import XCTest
@testable import BrowserSwitchCore

final class BrowserRouterPolicyTests: XCTestCase {

    // MARK: - Helpers

    private func target(_ urlString: String, routes: [BrowserRoute] = RouteStore.defaultRoutes) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return BrowserRouterPolicy.targetBundleID(for: url, routes: routes)
    }

    private let chrome = RouteStore.chromeBundleID

    // MARK: - Built-in Google Workspace routes

    func testGoogleDocsMatchesChrome() {
        XCTAssertEqual(target("https://docs.google.com/document/d/abc123/edit"), chrome)
    }

    func testGoogleSheetsMatchesChrome() {
        XCTAssertEqual(target("https://sheets.google.com/spreadsheets/d/abc123/edit"), chrome)
    }

    func testGoogleSlidesMatchesChrome() {
        XCTAssertEqual(target("https://slides.google.com/presentation/d/abc123/edit"), chrome)
    }

    func testGoogleDriveMatchesChrome() {
        XCTAssertEqual(target("https://drive.google.com/drive/my-drive"), chrome)
    }

    func testGmailMatchesChrome() {
        XCTAssertEqual(target("https://mail.google.com/mail/u/0/"), chrome)
    }

    func testGoogleCalendarMatchesChrome() {
        XCTAssertEqual(target("https://calendar.google.com/calendar/r"), chrome)
    }

    func testGoogleMeetMatchesChrome() {
        XCTAssertEqual(target("https://meet.google.com/abc-defg-hij"), chrome)
    }

    func testGoogleChatMatchesChrome() {
        XCTAssertEqual(target("https://chat.google.com/room/abc123"), chrome)
    }

    func testGoogleKeepMatchesChrome() {
        XCTAssertEqual(target("https://keep.google.com/"), chrome)
    }

    func testGoogleFormsMatchesChrome() {
        XCTAssertEqual(target("https://forms.google.com/forms/d/abc123/edit"), chrome)
    }

    func testGoogleAdminMatchesChrome() {
        XCTAssertEqual(target("https://admin.google.com/ac/home"), chrome)
    }

    func testGoogleWorkspaceMatchesChrome() {
        XCTAssertEqual(target("https://workspace.google.com/dashboard"), chrome)
    }

    func testDocsNewMatchesChrome() {
        XCTAssertEqual(target("https://docs.new"), chrome)
    }

    func testSheetsNewMatchesChrome() {
        XCTAssertEqual(target("https://sheets.new"), chrome)
    }

    func testSlidesNewMatchesChrome() {
        XCTAssertEqual(target("https://slides.new"), chrome)
    }

    func testFormsNewMatchesChrome() {
        XCTAssertEqual(target("https://forms.new"), chrome)
    }

    func testGeminiMatchesChrome() {
        XCTAssertEqual(target("https://gemini.google.com/app"), chrome)
    }

    // MARK: - Non-matching hosts return nil

    func testGoogleSearchReturnsNil() {
        XCTAssertNil(target("https://www.google.com/search?q=test"))
    }

    func testGoogleComReturnsNil() {
        XCTAssertNil(target("https://google.com"))
    }

    func testArbitraryHostReturnsNil() {
        XCTAssertNil(target("https://example.com"))
    }

    func testEmptyHostReturnsNil() {
        XCTAssertNil(target("https://"))
    }

    // MARK: - Wildcard patterns

    func testWildcardMatchesSubdomain() {
        let routes = [BrowserRoute(pattern: "*.work.com", browserBundleID: "com.apple.Safari")]
        XCTAssertEqual(target("https://app.work.com", routes: routes), "com.apple.Safari")
    }

    func testWildcardMatchesRootDomain() {
        let routes = [BrowserRoute(pattern: "*.work.com", browserBundleID: "com.apple.Safari")]
        XCTAssertEqual(target("https://work.com", routes: routes), "com.apple.Safari")
    }

    func testWildcardDoesNotMatchUnrelatedDomain() {
        let routes = [BrowserRoute(pattern: "*.work.com", browserBundleID: "com.apple.Safari")]
        XCTAssertNil(target("https://notwork.com", routes: routes))
    }

    // MARK: - Path patterns

    func testPathPatternMatchesPrefix() {
        let routes = [BrowserRoute(pattern: "example.com/app", browserBundleID: "com.apple.Safari")]
        XCTAssertEqual(target("https://example.com/app/dashboard", routes: routes), "com.apple.Safari")
    }

    func testPathPatternDoesNotMatchDifferentPath() {
        let routes = [BrowserRoute(pattern: "example.com/app", browserBundleID: "com.apple.Safari")]
        XCTAssertNil(target("https://example.com/other", routes: routes))
    }

    // MARK: - Disabled routes

    func testDisabledRouteIsSkipped() {
        let routes = [BrowserRoute(pattern: "docs.google.com", browserBundleID: chrome, isEnabled: false)]
        XCTAssertNil(target("https://docs.google.com/document/d/abc", routes: routes))
    }

    func testEnabledRouteIsMatched() {
        let routes = [BrowserRoute(pattern: "docs.google.com", browserBundleID: chrome, isEnabled: true)]
        XCTAssertEqual(target("https://docs.google.com/document/d/abc", routes: routes), chrome)
    }

    // MARK: - Empty pattern

    func testEmptyPatternDoesNotMatch() {
        let routes = [BrowserRoute(pattern: "", browserBundleID: chrome)]
        XCTAssertNil(target("https://example.com", routes: routes))
    }
}
