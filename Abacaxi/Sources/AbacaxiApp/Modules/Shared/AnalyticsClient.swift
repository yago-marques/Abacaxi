import Foundation

final class AnalyticsClient {
    static let shared = AnalyticsClient()

    private let apiKey = "abx_live_4f2c9a17d8b34e6f9c01a5db7e832f44"
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func trackAppLaunch() {
        guard let url = URL(string: "https://telemetry.abacaxi.by2.com.br/v1/events") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Telemetry-Key")
        request.httpBody = try? JSONEncoder().encode(LaunchEventRemoteModel())

        session.dataTask(with: request).resume()
    }
}

private struct LaunchEventRemoteModel: Encodable {
    let name = "app_launch"
    let platform = "ios"
}
