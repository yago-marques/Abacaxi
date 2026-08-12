import UIKit

public final class DSCardView: UIView {
    public enum Theme {
        case dark
        case light
    }

    public enum MediaSize {
        case compact
        case regular

        fileprivate var height: CGFloat {
            switch self {
            case .compact:
                180
            case .regular:
                280
            }
        }
    }

    private let imageView: UIImageView?
    private let forwardIndicatorImageView: UIImageView?
    private let mediaSize: MediaSize
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    public init(
        image: UIImage? = nil,
        mediaSize: MediaSize = .regular,
        showsChevron: Bool = false,
        title: String,
        description: String,
        theme: Theme = .dark
    ) {
        imageView = image.map(UIImageView.init(image:))
        forwardIndicatorImageView = showsChevron ? UIImageView(image: DSIcon.forward()) : nil
        self.mediaSize = mediaSize
        super.init(frame: .zero)
        configure(title: title, description: description, theme: theme)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func configure(title: String, description: String, theme: Theme) {
        let isDark = theme == .dark
        backgroundColor = isDark ? DSColor.surface : DSColor.surfaceLight
        layer.cornerRadius = DSBorder.cardRadius
        layer.borderWidth = 1
        layer.borderColor = DSColor.border.cgColor
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title.uppercased()
        titleLabel.font = DSTypography.title
        titleLabel.textColor = isDark ? DSColor.textPrimary : .black
        titleLabel.numberOfLines = 0

        descriptionLabel.text = description
        descriptionLabel.font = DSTypography.body
        descriptionLabel.textColor = isDark ? DSColor.textSecondary : .darkGray
        descriptionLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = DSSpacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        if let imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: mediaSize.height),
                stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: DSSpacing.large)
            ])
        } else {
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: DSSpacing.large).isActive = true
        }

        if let forwardIndicatorImageView {
            forwardIndicatorImageView.accessibilityIdentifier = "dsCardForwardIndicator"
            forwardIndicatorImageView.contentMode = .scaleAspectFit
            forwardIndicatorImageView.tintColor = isDark ? DSColor.accent : DSColor.primary
            forwardIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(forwardIndicatorImageView)

            NSLayoutConstraint.activate([
                forwardIndicatorImageView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -DSSpacing.large
                ),
                forwardIndicatorImageView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -DSSpacing.large
                ),
                forwardIndicatorImageView.widthAnchor.constraint(equalToConstant: 24),
                forwardIndicatorImageView.heightAnchor.constraint(equalToConstant: 32),
                stackView.trailingAnchor.constraint(
                    equalTo: forwardIndicatorImageView.leadingAnchor,
                    constant: -DSSpacing.medium
                )
            ])
        } else {
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.large).isActive = true
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSSpacing.large),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DSSpacing.large)
        ])
    }
}
