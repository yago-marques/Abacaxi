public struct AttemptsResponse: Equatable {
    public let remaining: Int
    public let limit: Int
    public let windowSeconds: Int

    public init(remaining: Int, limit: Int, windowSeconds: Int) {
        self.remaining = remaining
        self.limit = limit
        self.windowSeconds = windowSeconds
    }
}
