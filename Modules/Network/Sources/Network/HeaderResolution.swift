import NetworkInterfaces

enum HeaderResolution {
    static func resolve(requestHeaders: HTTPHeaders, defaults: HTTPHeaders, hasBody: Bool) -> HTTPHeaders {
        var merged = defaults.merging(requestHeaders)
        if hasBody, merged["Content-Type"] == nil {
            merged["Content-Type"] = "application/json"
        }
        return merged
    }
}
