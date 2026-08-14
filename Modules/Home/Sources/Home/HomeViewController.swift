import DesignSystem
import Extensions
import GeneralInterfaces
import UIKit

final class HomeViewController: UIViewController {
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
        let card = DSCardView(
            image: UIImage(named: "RecipeCreationCardImage"),
            mediaSize: .compact,
            showsChevron: true,
            title: state.recipeCreationCardTitle,
            description: state.recipeCreationCardSubtitle
        )
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRecipeCreation)))
        card.isUserInteractionEnabled = true
        return card
    }()

    private lazy var savedRecipesCard: DSCardView = {
        let state = viewModel.state
        let card = DSCardView(
            image: UIImage(named: "FavoriteRecipesIcon"),
            mediaSize: .compact,
            showsChevron: true,
            title: state.savedRecipesCardTitle,
            description: state.savedRecipesCardSubtitle
        )
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapSavedRecipes)))
        card.isUserInteractionEnabled = true
        card.isHidden = true
        return card
    }()

    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recipeCreationCard, savedRecipesCard])
        stackView.axis = .vertical
        stackView.spacing = DSSpacing.medium
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var cardsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadAttempts()
    }

}

extension HomeViewController: ViewCoding {
    func setupView() {
        view.backgroundColor = DSColor.background
    }

    func setupHierarchy() {
        view.addSubviews(
            topBar,
            cardsScrollView
        )
        cardsScrollView.addSubview(cardsStackView)
    }

    func setupConstraints() {
        topBar
            .top(to: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.xLarge)
            .leading(to: view.layoutMarginsGuide.leadingAnchor)
            .trailing(to: view.layoutMarginsGuide.trailingAnchor)

        dailyAttemptsPlaceholder
            .width(128)
            .height(DSSpacing.medium)

        cardsScrollView
            .top(to: topBar.bottomAnchor, constant: DSSpacing.xLarge)
            .leading(to: view.leadingAnchor)
            .trailing(to: view.trailingAnchor)
            .bottom(to: view.safeAreaLayoutGuide.bottomAnchor)

        cardsStackView
            .top(to: cardsScrollView.contentLayoutGuide.topAnchor)
            .leading(to: cardsScrollView.frameLayoutGuide.leadingAnchor, constant: DSSpacing.large)
            .trailing(to: cardsScrollView.frameLayoutGuide.trailingAnchor, constant: -DSSpacing.large)
            .bottom(to: cardsScrollView.contentLayoutGuide.bottomAnchor, constant: -DSSpacing.large)
    }

    private func loadAttempts() {
        showAttemptsPlaceholderIfNeeded()
        Task { [weak self, viewModel] in
            await viewModel.load()
            self?.renderAttempts()
        }
    }

    private func showAttemptsPlaceholderIfNeeded() {
        guard dailyAttemptsLabel.isHidden else { return }
        dailyAttemptsPlaceholder.isHidden = false
        dailyAttemptsPlaceholder.pulse(key: "homeDailyAttemptsPlaceholder")
    }

    private func renderAttempts() {
        renderSavedRecipesCard()
        guard dailyAttemptsLabel.isHidden else {
            topBar.transition(.crossDissolve) { [weak self] in
                self?.dailyAttemptsLabel.text = self?.viewModel.state.dailyAttemptsText
            }
            return
        }

        dailyAttemptsPlaceholder.layer.removeAnimation(forKey: "homeDailyAttemptsPlaceholder")
        dailyAttemptsPlaceholder.disappear(.quick, with: CGAffineTransform(scaleX: 0.92, y: 0.92)) { [weak self] _ in
            guard let self else { return }
            dailyAttemptsLabel.text = viewModel.state.dailyAttemptsText
            dailyAttemptsLabel.appear(.spring, from: CGAffineTransform(translationX: 0, y: DSSpacing.small))
        }
    }

    private func renderSavedRecipesCard() {
        guard viewModel.state.showsSavedRecipesShortcut else {
            savedRecipesCard.isHidden = true
            return
        }
        guard savedRecipesCard.isHidden else { return }

        savedRecipesCard.appear(
            .spring,
            from: CGAffineTransform(translationX: 0, y: DSSpacing.medium)
                .scaledBy(x: 0.96, y: 0.96)
        )
    }

    @objc private func didTapRecipeCreation() {
        viewModel.didTapRecipeCreation()
    }

    @objc private func didTapSavedRecipes() { viewModel.didTapSavedRecipes() }
}
