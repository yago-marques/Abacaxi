import UIKit

public final class DSButton: UIButton {
    public enum Style {
        case primary
        case secondary
        case text
    }

    private let style: Style
    private let accessoryImageView = UIImageView(image: DSIcon.forward())

    public init(title: String, style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        configure(title: title)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override public var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.72 : 1
        }
    }

    private func configure(title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title.uppercased()
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: DSSpacing.medium,
            bottom: 0,
            trailing: DSSpacing.medium
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updatedAttributes = attributes
            updatedAttributes.font = DSTypography.button
            return updatedAttributes
        }
        contentHorizontalAlignment = .center
        layer.cornerRadius = DSBorder.radius
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true

        accessoryImageView.contentMode = .scaleAspectFit
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryImageView)

        NSLayoutConstraint.activate([
            accessoryImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.small),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 40),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 48)
        ])

        switch style {
        case .primary:
            configuration.baseBackgroundColor = DSColor.primary
            configuration.baseForegroundColor = .black
            accessoryImageView.tintColor = .black
        case .secondary:
            configuration.baseBackgroundColor = .clear
            configuration.baseForegroundColor = DSColor.primary
            configuration.background.strokeColor = DSColor.primary
            configuration.background.strokeWidth = DSBorder.width
            accessoryImageView.tintColor = DSColor.primary
        case .text:
            configuration.baseBackgroundColor = .clear
            configuration.baseForegroundColor = DSColor.textPrimary
            accessoryImageView.tintColor = DSColor.accent
        }

        self.configuration = configuration
    }
}

public final class DSUIKitToastView: UIView {
    private let progressView = UIProgressView(progressViewStyle: .default)

    private init(message: String, style: DSToastStyle) {
        super.init(frame: .zero)

        let iconView = UIImageView(image: UIImage(systemName: Self.iconName(for: style)))
        iconView.tintColor = DSColor.textPrimary
        iconView.contentMode = .scaleAspectFit

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = DSTypography.caption
        messageLabel.textColor = DSColor.textPrimary
        messageLabel.numberOfLines = 0

        let contentStack = UIStackView(arrangedSubviews: [iconView, messageLabel])
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = DSSpacing.small
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        progressView.progressTintColor = DSColor.textPrimary.withAlphaComponent(0.8)
        progressView.trackTintColor = .clear
        progressView.progress = 1
        progressView.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = Self.backgroundColor(for: style)
        layer.cornerRadius = DSBorder.radius
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        addSubview(progressView)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: DSSpacing.medium),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSSpacing.medium),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.medium),
            progressView.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: DSSpacing.small),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    public static func show(
        in view: UIView,
        message: String,
        style: DSToastStyle,
        duration: TimeInterval = 3,
        completion: (() -> Void)? = nil
    ) {
        let toast = DSUIKitToastView(message: message, style: style)
        view.addSubview(toast)

        let verticalConstraint: NSLayoutConstraint
        switch style {
        case .error:
            verticalConstraint = toast.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: DSSpacing.medium
            )
        case .success:
            verticalConstraint = toast.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -DSSpacing.medium
            )
        }

        NSLayoutConstraint.activate([
            verticalConstraint,
            toast.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            toast.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        view.layoutIfNeeded()

        let offset = style == .error ? -DSSpacing.xxLarge : DSSpacing.xxLarge
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: offset)
        UIView.animate(withDuration: 0.2) {
            toast.alpha = 1
            toast.transform = .identity
        }
        UIView.animate(withDuration: duration) {
            toast.progressView.setProgress(0, animated: false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.2, animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: offset)
            }, completion: { _ in
                toast.removeFromSuperview()
                completion?()
            })
        }
    }

    private static func backgroundColor(for style: DSToastStyle) -> UIColor {
        switch style {
        case .error: DSColor.error
        case .success: DSColor.accent
        }
    }

    private static func iconName(for style: DSToastStyle) -> String {
        switch style {
        case .error: "exclamationmark.triangle.fill"
        case .success: "checkmark.circle.fill"
        }
    }
}
