import XCTest
@testable import BrowserSwitchMenuBarApp

final class InternetInfoTests: XCTestCase {
    func testDecodeMapsPrimaryFieldsFromServiceResponse() throws {
        let json = """
        {
          "YourFuckingIPAddress": "1.2.3.4",
          "YourFuckingLocation": "Salt Lake City, UT, United States",
          "YourFuckingISP": "Example ISP",
          "YourFuckingTorExit": false
        }
        """

        let info = try XCTUnwrap(InternetInfoDecoder.decode(from: Data(json.utf8)))

        XCTAssertEqual(info.ipAddress, "1.2.3.4")
        XCTAssertEqual(info.isp, "Example ISP")
        XCTAssertEqual(info.location, "Salt Lake City, UT, United States")
        XCTAssertNil(info.vpn)
        XCTAssertEqual(info.torExit, false)
    }

    func testDecodeFallsBackToCityAndCountryWhenLocationMissing() throws {
        let json = """
        {
          "YourFuckingIPAddress": "1.2.3.4",
          "YourFuckingISP": "Example ISP",
          "YourFuckingCity": "Portland",
          "YourFuckingCountry": "United States"
        }
        """

        let info = try XCTUnwrap(InternetInfoDecoder.decode(from: Data(json.utf8)))
        XCTAssertEqual(info.location, "Portland, United States")
    }

    func testMenuLinesOnlyHideIPWhenNoTorValue() {
        let info = InternetInfo(
            ipAddress: "1.2.3.4",
            isp: "Example ISP",
            location: "Portland, United States",
            vpn: true,
            torExit: nil
        )

        XCTAssertEqual(
            info.menuLines(),
            [
                .init(title: "IP: 1.2.3.4", isHiddenWithoutOptionKey: true),
                .init(title: "ISP: Example ISP", isHiddenWithoutOptionKey: false),
                .init(title: "Location: Portland, United States", isHiddenWithoutOptionKey: false)
            ]
        )
    }

    func testMenuLinesHideIPAndTorExitWithoutOptionKey() {
        let info = InternetInfo(
            ipAddress: "1.2.3.4",
            isp: "Example ISP",
            location: "Portland, United States",
            vpn: nil,
            torExit: true
        )

        XCTAssertEqual(
            info.menuLines(),
            [
                .init(title: "IP: 1.2.3.4", isHiddenWithoutOptionKey: true),
                .init(title: "ISP: Example ISP", isHiddenWithoutOptionKey: false),
                .init(title: "Location: Portland, United States", isHiddenWithoutOptionKey: false),
                .init(title: "Tor Exit: Yes", isHiddenWithoutOptionKey: true)
            ]
        )
    }
}
