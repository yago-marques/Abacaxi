public protocol ViewCoding: AnyObject {
    func setupView()
    func setupHierarchy()
    func setupConstraints()
}

public extension ViewCoding {
    func buildLayout() {
        setupView()
        setupHierarchy()
        setupConstraints()
    }
}
