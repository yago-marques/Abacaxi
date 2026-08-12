import DesignSystem
import Extensions
import GeneralInterfaces
import UIKit

public final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModelProtocol

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.state.title
        label.font = DSTypography.display
        label.textColor = DSColor.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dailyAttemptsLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.state.dailyAttemptsText
        label.font = DSTypography.button
        label.textColor = DSColor.accent
        label.textAlignment = .right
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dailyAttemptsPlaceholder: UIView = {
        let placeholder = UIView()
        placeholder.backgroundColor = DSColor.border
        placeholder.layer.cornerRadius = DSSpacing.small
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        return placeholder
    }()

    private lazy var topBar: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            dailyAttemptsPlaceholder,
            dailyAttemptsLabel
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var recipeCreationCard: DSCardView = {
        let state = viewModel.state
        return DSCardView(
            image: UIImage(named: "RecipeCreationCardImage"),
            mediaSize: .compact,
            showsChevron: true,
            title: state.recipeCreationCardTitle,
            description: state.recipeCreationCardSubtitle
        )
    }()

    public init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        dailyAttemptsPlaceholder.pulse(key: "homeDailyAttemptsPlaceholder")
        loadAttempts()
    }
}

extension HomeViewController: ViewCoding {
    public func setupView() {
        view.backgroundColor = DSColor.background
    }

    public func setupHierarchy() {
        view.addSubviews(
            topBar,
            recipeCreationCard
        )
    }

    public func setupConstraints() {
        topBar
            .top(to: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.xLarge)
            .leading(to: view.layoutMarginsGuide.leadingAnchor)
            .trailing(to: view.layoutMarginsGuide.trailingAnchor)

        dailyAttemptsPlaceholder
            .width(128)
            .height(DSSpacing.medium)

        recipeCreationCard
            .top(to: topBar.bottomAnchor, constant: DSSpacing.xLarge)
            .leading(to: view.layoutMarginsGuide.leadingAnchor)
            .trailing(to: view.layoutMarginsGuide.trailingAnchor)
    }

    private func loadAttempts() {
        Task { [weak self, viewModel] in
            await viewModel.load()
            self?.renderAttempts()
        }
    }

    private func renderAttempts() {
        topBar.transition(.crossDissolve) { [dailyAttemptsLabel, dailyAttemptsPlaceholder, viewModel] in
            dailyAttemptsLabel.text = viewModel.state.dailyAttemptsText
            dailyAttemptsPlaceholder.isHidden = true
            dailyAttemptsLabel.isHidden = false
        }
        dailyAttemptsPlaceholder.layer.removeAnimation(forKey: "homeDailyAttemptsPlaceholder")
    }
}
