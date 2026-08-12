import Foundation

struct ConsoleRequestLogger {
    private static let sensitiveHeaderNames = [
        "Authorization",
        "Cookie",
        "Set-Cookie",
        "X-API-Key"
    ]

    private let isEnabled: Bool
    private let write: (String) -> Void

    init(isEnabled: Bool, write: @escaping (String) -> Void = { print($0) }) {
        self.isEnabled = isEnabled
        self.write = write
    }

    func logRequest(_ request: URLRequest) {
        guard isEnabled else { return }
        var lines = ["→ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")"]
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            lines.append(contentsOf: Self.headerLines(headers))
        }
        if let body = request.httpBody {
            lines.append(contentsOf: Self.bodyLines(body))
        }
        write(Self.section("REQUEST", lines: lines))
    }

    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?) {
        guard isEnabled else { return }
        var lines: [String] = []
        if let response {
            lines.append("← \(response.statusCode) \(response.url?.absoluteString ?? "")")
            let headers = response.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                if let key = pair.key as? String, let value = pair.value as? String {
                    result[key] = value
                }
            }
            if !headers.isEmpty {
                lines.append(contentsOf: Self.headerLines(headers))
            }
        }
        if let error {
            lines.append("Error: \(error)")
        }
        if let data {
            lines.append(contentsOf: Self.bodyLines(data))
        }
        write(Self.section("RESPONSE", lines: lines))
    }

    static func prettyPrinted(_ data: Data) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: pretty, encoding: .utf8) {
            return string
        }
        return String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
    }

    private static func section(_ title: String, lines: [String]) -> String {
        let content = lines.map { "│ \($0)" }
        return (["┌── \(title)"] + content + ["└────────────────────────────────────────"]).joined(separator: "\n")
    }

    private static func headerLines(_ headers: [String: String]) -> [String] {
        let values = headers
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
            .map { "  \($0.key): \(redactedHeaderValue($0.value, for: $0.key))" }
        return ["Headers:"] + values
    }

    private static func bodyLines(_ data: Data) -> [String] {
        ["Body:"] + prettyPrinted(data).split(separator: "\n").map { "  \($0)" }
    }

    private static func redactedHeaderValue(_ value: String, for name: String) -> String {
        sensitiveHeaderNames.contains { $0.caseInsensitiveCompare(name) == .orderedSame }
            ? "<redacted>"
            : value
    }
}
