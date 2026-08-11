import Foundation

final class MockURLProtocol: URLProtocol {
    struct Stub {
        let statusCode: Int
        let data: Data?
        let delay: TimeInterval

        init(statusCode: Int = 200, data: Data? = nil, delay: TimeInterval = 0) {
            self.statusCode = statusCode
            self.data = data
            self.delay = delay
        }
    }

    static var handler: ((URLRequest) -> Stub)?
    static var lastRequest: URLRequest?

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private let lock = NSLock()
    private var isCancelled = false

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        MockURLProtocol.lastRequest = request
        guard let handler = MockURLProtocol.handler else {
            // A previous test's (already-cancelled) request can have its startLoading
            // dispatched late by the URL loading system, landing here after that test's
            // tearDown reset the handler. Fail it quietly instead of crashing the process.
            client?.urlProtocol(self, didFailWithError: URLError(.cancelled))
            return
        }
        let stub = handler(request)

        let respond = { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let cancelled = self.isCancelled
            self.lock.unlock()
            guard !cancelled else { return }

            guard let url = self.request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: stub.statusCode,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                return
            }
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = stub.data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }

        if stub.delay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + stub.delay, execute: respond)
        } else {
            respond()
        }
    }

    override func stopLoading() {
        lock.lock()
        isCancelled = true
        lock.unlock()
    }
}
