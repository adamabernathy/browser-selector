import XCTest
@testable import BrowserSwitchCore

final class BrowserRouterPolicyTests: XCTestCase {

    // MARK: - docs.new shortcut

    func testDocsNewHostMatches() {
        let url = URL(string: "https://docs.new")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testDocsNewSubdomainMatches() {
        let url = URL(string: "https://foo.docs.new/path")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    // MARK: - New-document shortcuts

    func testSheetsNewMatches() {
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(URL(string: "https://sheets.new")!))
    }

    func testSlidesNewMatches() {
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(URL(string: "https://slides.new")!))
    }

    func testFormsNewMatches() {
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(URL(string: "https://forms.new")!))
    }

    // MARK: - Google Workspace apps

    func testGoogleDocsMatches() {
        let url = URL(string: "https://docs.google.com/document/d/abc123/edit")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleSheetsMatches() {
        let url = URL(string: "https://sheets.google.com/spreadsheets/d/abc123/edit")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleSlidesMatches() {
        let url = URL(string: "https://slides.google.com/presentation/d/abc123/edit")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleDriveMatches() {
        let url = URL(string: "https://drive.google.com/drive/my-drive")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGmailMatches() {
        let url = URL(string: "https://mail.google.com/mail/u/0/")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleCalendarMatches() {
        let url = URL(string: "https://calendar.google.com/calendar/r")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleMeetMatches() {
        let url = URL(string: "https://meet.google.com/abc-defg-hij")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleChatMatches() {
        let url = URL(string: "https://chat.google.com/room/abc123")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testJamboardMatches() {
        let url = URL(string: "https://jamboard.google.com/d/abc123/viewer")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleSitesMatches() {
        let url = URL(string: "https://sites.google.com/view/mysite")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleKeepMatches() {
        let url = URL(string: "https://keep.google.com/")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleFormsMatches() {
        let url = URL(string: "https://forms.google.com/forms/d/abc123/edit")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleAdminMatches() {
        let url = URL(string: "https://admin.google.com/ac/home")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleWorkspaceMatches() {
        let url = URL(string: "https://workspace.google.com/dashboard")!
        XCTAssertTrue(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    // MARK: - Non-matching hosts

    func testGoogleSearchDoesNotMatch() {
        let url = URL(string: "https://www.google.com/search?q=test")!
        XCTAssertFalse(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testGoogleComDoesNotMatch() {
        let url = URL(string: "https://google.com")!
        XCTAssertFalse(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testNonGoogleHostDoesNotMatch() {
        let url = URL(string: "https://example.com")!
        XCTAssertFalse(BrowserRouterPolicy.shouldOpenInChrome(url))
    }

    func testEmptyHostDoesNotMatch() {
        let url = URL(string: "https://")!
        XCTAssertFalse(BrowserRouterPolicy.shouldOpenInChrome(url))
    }
}
