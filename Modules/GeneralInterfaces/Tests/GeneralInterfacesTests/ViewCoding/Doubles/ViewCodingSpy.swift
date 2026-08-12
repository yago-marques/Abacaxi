@testable import GeneralInterfaces

final class ViewCodingSpy: ViewCoding {
    private(set) var calledMethods: [String] = []

    func setupView() {
        calledMethods.append(#function)
    }

    func setupHierarchy() {
        calledMethods.append(#function)
    }

    func setupConstraints() {
        calledMethods.append(#function)
    }
}
