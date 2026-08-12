import UIKit

public extension UIView {
    @discardableResult
    func addSubviews(_ views: UIView...) -> Self {
        views.forEach(addSubview)
        return self
    }

    @discardableResult
    func top(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> Self {
        topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }

    @discardableResult
    func bottom(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> Self {
        bottomAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }

    @discardableResult
    func leading(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) -> Self {
        leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }

    @discardableResult
    func trailing(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) -> Self {
        trailingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }

    @discardableResult
    func centerX(to anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) -> Self {
        centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }

    @discardableResult
    func centerY(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> Self {
        centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }

    @discardableResult
    func width(_ constant: CGFloat) -> Self {
        widthAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }

    @discardableResult
    func width(to anchor: NSLayoutDimension, multiplier: CGFloat = 1) -> Self {
        widthAnchor.constraint(equalTo: anchor, multiplier: multiplier).isActive = true
        return self
    }

    @discardableResult
    func width(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier: CGFloat = 1) -> Self {
        widthAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier).isActive = true
        return self
    }

    @discardableResult
    func height(_ constant: CGFloat) -> Self {
        heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }

    @discardableResult
    func height(to anchor: NSLayoutDimension, multiplier: CGFloat = 1) -> Self {
        heightAnchor.constraint(equalTo: anchor, multiplier: multiplier).isActive = true
        return self
    }
}
