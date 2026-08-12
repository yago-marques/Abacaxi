import DesignSystem
import Extensions
import GeneralInterfaces
import UIKit

public final class LauncherViewController: UIViewController {
    private let viewModel: LauncherViewModelProtocol
    private static let logoInitialScale: CGFloat = 0.72

    public var didFinishExpansion: (() -> Void)?

    private var isExpanding = false

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "OnboardingLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(scaleX: Self.logoInitialScale, y: Self.logoInitialScale)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    public init(viewModel: LauncherViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        viewModel.checkDeviceID()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogoEntrance()
    }

    public func closeLauncher() {
        guard !isExpanding else { return }
        isExpanding = true

        logoImageView.layer.removeAnimation(forKey: "pulse")

        view.animate(
            .slowEaseIn,
            animations: {
                self.logoImageView.alpha = 0
                self.logoImageView.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
            },
            completion: { _ in
                self.didFinishExpansion?()
            }
        )
    }

    private func animateLogoEntrance() {
        view.animate(
            .spring,
            animations: {
                self.logoImageView.alpha = 1
                self.logoImageView.transform = .identity
            },
            completion: { [weak self] _ in
                self?.logoImageView.pulse(scale: 1.035, opacity: 0.9)
            }
        )
    }
}

extension LauncherViewController: ViewCoding {
    public func setupView() {
        view.backgroundColor = DSColor.background
    }

    public func setupHierarchy() {
        view.addSubview(logoImageView)
    }

    public func setupConstraints() {
        logoImageView
            .centerX(to: view.centerXAnchor)
            .centerY(to: view.centerYAnchor)
            .width(to: view.widthAnchor, multiplier: 0.78)
            .height(to: logoImageView.widthAnchor, multiplier: 0.56)
    }
}
