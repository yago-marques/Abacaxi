import Foundation

struct ConsoleRequestLogger {
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
            lines.append("  Headers: \(headers)")
        }
        if let body = request.httpBody {
            lines.append("  Body: \(Self.prettyPrinted(body))")
        }
        write(lines.joined(separator: "\n"))
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
                lines.append("  Headers: \(headers)")
            }
        }
        if let error {
            lines.append("  Error: \(error)")
        }
        if let data {
            lines.append("  Body: \(Self.prettyPrinted(data))")
        }
        write(lines.joined(separator: "\n"))
    }

    static func prettyPrinted(_ data: Data) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: pretty, encoding: .utf8) {
            return string
        }
        return String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
    }
}
