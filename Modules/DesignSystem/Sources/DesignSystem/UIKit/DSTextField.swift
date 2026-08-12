import UIKit

public final class DSTextField: UITextField {
    private let horizontalInset: CGFloat = DSSpacing.medium

    public init(placeholder: String, systemImageName: String? = nil) {
        super.init(frame: .zero)
        configure(placeholder: placeholder, systemImageName: systemImageName)
    }

    required init?(coder: NSCoder) {
        nil
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateBorderColor()
        return result
    }

    public override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateBorderColor()
        return result
    }

    private var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }

    private func configure(placeholder: String, systemImageName: String?) {
        self.placeholder = placeholder
        font = DSTypography.body
        textColor = DSColor.textPrimary
        tintColor = DSColor.accent
        backgroundColor = .clear
        layer.cornerRadius = DSBorder.radius
        layer.borderWidth = DSBorder.width
        layer.borderColor = DSColor.border.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true

        if let systemImageName {
            let iconView = UIImageView(image: UIImage(systemName: systemImageName))
            iconView.tintColor = DSColor.textSecondary
            iconView.contentMode = .center
            iconView.frame.size = CGSize(width: 48, height: 48)
            leftView = iconView
            leftViewMode = .always
        }

        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: DSColor.textSecondary]
        )
    }

    private func updateBorderColor() {
        layer.borderColor = (isFirstResponder ? DSColor.accent : DSColor.border).cgColor
    }
}
