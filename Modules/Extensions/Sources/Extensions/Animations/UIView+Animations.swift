import UIKit

public enum UIViewAnimation {
    case quick
    case standard
    case slowEaseIn
    case spring

    fileprivate var duration: TimeInterval {
        switch self {
        case .quick:
            0.2
        case .standard, .spring:
            0.3
        case .slowEaseIn:
            0.7
        }
    }

    fileprivate var options: UIView.AnimationOptions {
        switch self {
        case .quick, .standard:
            [.beginFromCurrentState, .curveEaseInOut]
        case .slowEaseIn:
            [.beginFromCurrentState, .curveEaseIn]
        case .spring:
            [.beginFromCurrentState, .curveEaseOut]
        }
    }

    fileprivate var dampingRatio: CGFloat? {
        switch self {
        case .spring:
            0.75
        case .quick, .standard, .slowEaseIn:
            nil
        }
    }
}

public enum UIViewTransition {
    case crossDissolve
    case flipFromLeft
    case flipFromRight

    fileprivate var options: UIView.AnimationOptions {
        switch self {
        case .crossDissolve:
            [.beginFromCurrentState, .transitionCrossDissolve]
        case .flipFromLeft:
            [.beginFromCurrentState, .transitionFlipFromLeft]
        case .flipFromRight:
            [.beginFromCurrentState, .transitionFlipFromRight]
        }
    }

    fileprivate var duration: TimeInterval {
        switch self {
        case .crossDissolve:
            0.35
        case .flipFromLeft, .flipFromRight:
            0.5
        }
    }
}

public extension UIView {
    func animate(
        _ animation: UIViewAnimation = .standard,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let dampingRatio = animation.dampingRatio else {
            UIView.animate(
                withDuration: animation.duration,
                delay: 0,
                options: animation.options,
                animations: animations,
                completion: completion
            )
            return
        }

        UIView.animate(
            withDuration: animation.duration,
            delay: 0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: 0,
            options: animation.options,
            animations: animations,
            completion: completion
        )
    }

    func transition(
        _ transition: UIViewTransition = .crossDissolve,
        animations: @escaping @MainActor () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.transition(
            with: self,
            duration: transition.duration,
            options: transition.options,
            animations: animations,
            completion: completion
        )
    }

    func disappear(
        _ animation: UIViewAnimation = .quick,
        with transform: CGAffineTransform = .identity,
        completion: ((Bool) -> Void)? = nil
    ) {
        animate(animation, animations: {
            self.alpha = 0
            self.transform = transform
        }, completion: { finished in
            self.isHidden = true
            self.alpha = 1
            self.transform = .identity
            completion?(finished)
        })
    }

    func appear(
        _ animation: UIViewAnimation = .standard,
        from transform: CGAffineTransform = .identity,
        completion: ((Bool) -> Void)? = nil
    ) {
        isHidden = false
        alpha = 0
        self.transform = transform
        animate(animation, animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: completion)
    }

    func pulse(
        scale: CGFloat = 1.12,
        opacity: Float = 0.75,
        duration: TimeInterval = 0.9,
        key: String = "pulse"
    ) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = scale

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = opacity

        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(animation, forKey: key)
    }
}
