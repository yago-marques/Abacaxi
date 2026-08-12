import DesignSystem
import Extensions
import GeneralInterfaces
import UIKit

public final class OnboardingViewController: UIViewController {
    private let viewModel: OnboardingViewModelProtocol

    private lazy var brandImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "OnboardingLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var pineappleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "OnboardingPineapple"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var headlineLabel: UILabel = {
        let text = L10n.Onboarding.headline
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: DSTypography.hero,
                .foregroundColor: DSColor.textPrimary
            ]
        )
        attributedText.addAttribute(
            .foregroundColor,
            value: DSColor.accent,
            range: (text as NSString).range(of: "?")
        )

        let label = UILabel()
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var startButton: DSButton = {
        let button = DSButton(title: L10n.Onboarding.start)
        button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        return button
    }()

    public init(viewModel: OnboardingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        viewModel.start()
    }

    @objc
    private func didTapStartButton() {
        viewModel.didTapStart()
    }
}

extension OnboardingViewController: ViewCoding {
    public func setupView() {
        view.backgroundColor = DSColor.background
    }

    public func setupHierarchy() {
        view.addSubviews(
            brandImageView,
            pineappleImageView,
            headlineLabel,
            startButton
        )
    }

    public func setupConstraints() {
        brandImageView
            .top(to: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.small)
            .centerX(to: view.centerXAnchor)
            .width(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.80)
            .height(76)

        pineappleImageView
            .top(to: brandImageView.bottomAnchor, constant: DSSpacing.xLarge)
            .centerX(to: view.centerXAnchor)
            .width(to: view.widthAnchor, multiplier: 0.82)
            .height(to: pineappleImageView.widthAnchor)

        headlineLabel
            .top(to: pineappleImageView.bottomAnchor, constant: DSSpacing.large)
            .leading(to: view.layoutMarginsGuide.leadingAnchor)
            .trailing(to: view.layoutMarginsGuide.trailingAnchor)

        startButton
            .leading(to: view.layoutMarginsGuide.leadingAnchor)
            .trailing(to: view.layoutMarginsGuide.trailingAnchor)
            .bottom(to: view.safeAreaLayoutGuide.bottomAnchor, constant: -DSSpacing.large)
    }
}
