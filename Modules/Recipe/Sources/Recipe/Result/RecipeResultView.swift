import DesignSystem
import DomainInterfaces
import SwiftUI
import UIKit

struct RecipeResultView: View {
    let recipe: RecipeBusinessModel
    let context: RecipeResultContext

    @StateObject private var viewModel: RecipeResultViewModel
    @State private var toastRequest: DSToastRequest?
    @State private var isRemovalConfirmationPresented = false

    private let onGoHome: (() -> Void)?
    private let onBack: () -> Void
    private let onRecipeRemoved: () -> Void

    init(
        recipe: RecipeBusinessModel,
        context: RecipeResultContext,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol,
        onGoHome: (() -> Void)?,
        onBack: @escaping () -> Void,
        onRecipeRemoved: @escaping () -> Void
    ) {
        self.recipe = recipe
        self.context = context
        self.onGoHome = onGoHome
        self.onBack = onBack
        self.onRecipeRemoved = onRecipeRemoved
        _viewModel = StateObject(
            wrappedValue: RecipeResultViewModel(
                recipe: recipe,
                saveRecipeUseCase: saveRecipeUseCase,
                removeSavedRecipeUseCase: removeSavedRecipeUseCase
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.large) {
                image
                Text(recipe.title)
                    .font(.dsDisplay)
                Text(recipe.description)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                HStack {
                    Text(L10n.RecipeResult.prepTime(recipe.preparationTimeMinutes))
                    Spacer()
                    Text(L10n.RecipeResult.servings(recipe.servings))
                }
                .font(.dsButton)
                .foregroundStyle(Color.dsAccent)
                section(
                    L10n.RecipeResult.ingredients,
                    values: recipe.ingredients.map { "\($0.quantity) \($0.name)" }
                )
                section(
                    L10n.RecipeResult.preparation,
                    values: recipe.steps.enumerated().map { "\($0.offset + 1). \($0.element)" }
                )
                if let nutrition = recipe.nutrition {
                    section(
                        "\(L10n.RecipeResult.nutrition) · \(L10n.RecipeResult.nutritionEstimate)",
                        values: [
                            "\(nutrition.calories) kcal",
                            "P \(nutrition.proteinGrams)g",
                            "C \(nutrition.carbsGrams)g",
                            "G \(nutrition.fatGrams)g"
                        ]
                    )
                }
            }
            .padding(DSSpacing.large)
        }
        .safeAreaInset(edge: .bottom) {
            resultAction
            .padding(DSSpacing.large)
            .background(Color.dsBackground)
        }
        .foregroundStyle(Color.dsTextPrimary)
        .background(Color.dsBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .dsToolbar {
            if let onGoHome {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.RecipeResult.backHome, action: onGoHome)
                        .font(.dsButton)
                        .foregroundStyle(Color.dsAccent)
                }
            } else {
                DSNavigationToolbar(onBack: onBack)
            }
        }
        .dsToast(request: toastRequest, onDismiss: { _ in toastRequest = nil })
        .onChange(of: viewModel.didFailSaving) { didFailSaving in
            guard didFailSaving else { return }
            toastRequest = DSToastRequest(message: L10n.RecipeResult.saveError, style: .error)
        }
        .sheet(isPresented: $isRemovalConfirmationPresented) {
            removalConfirmationSheet
        }
    }

    @ViewBuilder private var image: some View {
        if let data = recipe.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()
        } else {
            Image(systemName: "fork.knife")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(Color.dsAccent)
                .frame(maxWidth: .infinity, minHeight: 180)
                .background(Color.dsSurface)
        }
    }

    private func section(_ title: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            Text(title)
                .font(.dsTitle)
            ForEach(values, id: \.self) {
                Text($0)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
            }
        }
    }

    @ViewBuilder private var resultAction: some View {
        switch context {
        case .generated:
            VStack(spacing: DSSpacing.small) {
                Text(L10n.RecipeResult.saveHint)
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
                Button(viewModel.saveTitle, action: viewModel.save)
                    .buttonStyle(.dsPrimary)
                    .disabled(viewModel.isSaving || viewModel.isSaved)
            }
            .padding(DSSpacing.small)
            .background(Color.dsBackground)
        case .saved:
            Button(L10n.RecipeResult.remove) {
                isRemovalConfirmationPresented = true
            }
            .buttonStyle(.dsDestructive)
            .padding(DSSpacing.small)
            .background(Color.dsBackground)
        }
    }

    private var removalConfirmationSheet: some View {
        DSBottomSheet(title: L10n.RecipeResult.removeConfirmationTitle) {
            Text(L10n.RecipeResult.removeConfirmationMessage)
                .font(.dsBody)
                .foregroundStyle(Color.dsTextSecondary)
            Spacer()
            Button(L10n.RecipeResult.cancel) {
                isRemovalConfirmationPresented = false
            }
            .buttonStyle(.dsSecondary)
            Button(L10n.RecipeResult.remove) {
                removeRecipe()
            }
            .buttonStyle(.dsDestructive)
        }
    }

    private func removeRecipe() {
        guard case let .saved(id) = context else { return }

        if viewModel.remove(id: id) {
            isRemovalConfirmationPresented = false
            onRecipeRemoved()
        } else {
            isRemovalConfirmationPresented = false
            toastRequest = DSToastRequest(message: L10n.RecipeResult.removeError, style: .error)
        }
    }
}
