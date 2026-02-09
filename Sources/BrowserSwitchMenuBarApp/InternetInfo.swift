import Foundation

struct InternetInfoMenuLine: Equatable {
    let title: String
    let isHiddenWithoutOptionKey: Bool
}

struct InternetInfo: Equatable {
    let ipAddress: String?
    let isp: String?
    let location: String?
    let vpn: Bool?
    let torExit: Bool?

    func menuLines() -> [InternetInfoMenuLine] {
        var lines: [InternetInfoMenuLine] = []

        if let ipAddress {
            lines.append(
                InternetInfoMenuLine(
                    title: "IP: \(ipAddress)",
                    isHiddenWithoutOptionKey: true
                )
            )
        }
        if let isp {
            lines.append(
                InternetInfoMenuLine(
                    title: "ISP: \(isp)",
                    isHiddenWithoutOptionKey: false
                )
            )
        }
        if let location {
            lines.append(
                InternetInfoMenuLine(
                    title: "Location: \(location)",
                    isHiddenWithoutOptionKey: false
                )
            )
        }

        if let torExit {
            lines.append(
                InternetInfoMenuLine(
                    title: "Tor Exit: \(torExit ? "Yes" : "No")",
                    isHiddenWithoutOptionKey: true
                )
            )
        }

        return lines
    }
}

enum InternetInfoDecoder {
    static func decode(from data: Data) -> InternetInfo? {
        guard let payload = try? JSONDecoder().decode(WTFIsMyIPPayload.self, from: data) else {
            return nil
        }

        let directLocation = payload.location?.nonEmptyTrimmed
        let fallbackLocationParts = [payload.city?.nonEmptyTrimmed, payload.country?.nonEmptyTrimmed]
            .compactMap { $0 }
        let fallbackLocation = fallbackLocationParts.isEmpty ? nil : fallbackLocationParts.joined(separator: ", ")

        return InternetInfo(
            ipAddress: payload.ipAddress?.nonEmptyTrimmed,
            isp: payload.isp?.nonEmptyTrimmed,
            location: directLocation ?? fallbackLocation,
            vpn: payload.vpn,
            torExit: payload.torExit
        )
    }
}

private struct WTFIsMyIPPayload: Decodable {
    let ipAddress: String?
    let location: String?
    let isp: String?
    let city: String?
    let country: String?
    let vpn: Bool?
    let torExit: Bool?

    enum CodingKeys: String, CodingKey {
        case ipAddress = "YourFuckingIPAddress"
        case location = "YourFuckingLocation"
        case isp = "YourFuckingISP"
        case city = "YourFuckingCity"
        case country = "YourFuckingCountry"
        case vpn = "YourFuckingVPN"
        case torExit = "YourFuckingTorExit"
    }
}

private extension String {
    var nonEmptyTrimmed: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
