import Foundation

enum SystemVPNStatus: Equatable {
    case connected(serviceNames: [String])
    case disconnected
    case unknown

    var isConnected: Bool? {
        switch self {
        case .connected:
            return true
        case .disconnected:
            return false
        case .unknown:
            return nil
        }
    }
}

enum SystemVPNStatusDetector {
    static func detect() -> SystemVPNStatus {
        let scutilStatus = readNCListStatus()
        if case .connected = scutilStatus {
            return scutilStatus
        }

        let utunInterfaces = readUTUNRouteInterfaces()
        if !utunInterfaces.isEmpty {
            return .connected(serviceNames: utunInterfaces.sorted())
        }

        if case .disconnected = scutilStatus {
            return .disconnected
        }

        return .unknown
    }

    static func readNCListStatus() -> SystemVPNStatus {
        guard let output = runCommand(executable: "/usr/sbin/scutil", arguments: ["--nc", "list"]) else {
            return .unknown
        }
        return parseNCListOutput(output)
    }

    static func readUTUNRouteInterfaces() -> [String] {
        guard let output = runCommand(executable: "/usr/sbin/netstat", arguments: ["-rn", "-f", "inet"]) else {
            return []
        }
        return parseNetstatUTUNInterfaces(output)
    }

    static func runCommand(executable: String, arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0 else {
            return nil
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: outputData, encoding: .utf8)
    }

    static func parseNCListOutput(_ output: String) -> SystemVPNStatus {
        let lines = output.components(separatedBy: .newlines)
        var connectedServices: [String] = []
        var sawServiceState = false

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }

            guard
                let openingParen = trimmedLine.firstIndex(of: "("),
                let closingParen = trimmedLine[openingParen...].firstIndex(of: ")")
            else {
                continue
            }

            let stateStart = trimmedLine.index(after: openingParen)
            let state = trimmedLine[stateStart..<closingParen]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            sawServiceState = true

            let nameStart = trimmedLine.index(after: closingParen)
            let serviceName = trimmedLine[nameStart...]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if state == "connected" {
                connectedServices.append(serviceName)
            }
        }

        if !connectedServices.isEmpty {
            return .connected(serviceNames: connectedServices)
        }

        if sawServiceState || output.contains("Available network connection services") {
            return .disconnected
        }

        return .unknown
    }

    static func parseNetstatUTUNInterfaces(_ output: String) -> [String] {
        var interfaces = Set<String>()
        let lines = output.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            guard !trimmed.hasPrefix("Routing tables") else { continue }
            guard !trimmed.hasPrefix("Internet") else { continue }
            guard !trimmed.hasPrefix("Destination") else { continue }

            let parts = trimmed.split(whereSeparator: \.isWhitespace)
            guard parts.count >= 4 else { continue }

            let destination = String(parts[0])
            let flags = String(parts[2])
            let netif = String(parts[3])

            guard netif.hasPrefix("utun") else { continue }
            guard flags.contains("U") else { continue }

            if destination == "default" || destination == "0/1" || destination == "128/1" || destination == "128.0/1" {
                interfaces.insert(netif)
                continue
            }

            if destination.contains("/") || destination.contains(".") {
                interfaces.insert(netif)
            }
        }

        return interfaces.sorted()
    }
}
