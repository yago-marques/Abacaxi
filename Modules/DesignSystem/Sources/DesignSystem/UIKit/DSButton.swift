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

    public override var isHighlighted: Bool {
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
