import DesignSystem
import SwiftUI
import UIKit

struct SavedRecipesView: View {
    @StateObject private var viewModel: SavedRecipesViewModel

    private let onBack: () -> Void
    private let onCreateRecipe: () -> Void
    private let onSelectRecipe: (String) -> Void

    init(
        viewModel: SavedRecipesViewModel,
        onBack: @escaping () -> Void,
        onCreateRecipe: @escaping () -> Void,
        onSelectRecipe: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onCreateRecipe = onCreateRecipe
        self.onSelectRecipe = onSelectRecipe
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .tint(Color.dsAccent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                emptyState
            case let .content(recipes):
                recipeList(recipes)
            case .error:
                errorState
            }
        }
        .foregroundStyle(Color.dsTextPrimary)
        .background(Color.dsBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .dsToolbar {
            DSNavigationToolbar(title: L10n.MyRecipes.title, onBack: onBack)
        }
        .onAppear {
            viewModel.load()
        }
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.large) {
            Spacer()
            Image(systemName: "book.closed.fill")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Color.dsAccent)
            Text(L10n.MyRecipes.empty)
                .font(.dsBody)
                .foregroundStyle(Color.dsTextSecondary)
                .multilineTextAlignment(.center)
            Button(L10n.MyRecipes.create, action: onCreateRecipe)
                .buttonStyle(.dsPrimary)
            Spacer()
        }
        .padding(DSSpacing.large)
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.large) {
            Spacer()
            Text(L10n.MyRecipes.loadError)
                .font(.dsBody)
                .foregroundStyle(Color.dsTextSecondary)
                .multilineTextAlignment(.center)
            Button(L10n.MyRecipes.retry, action: viewModel.load)
                .buttonStyle(.dsSecondary)
            Spacer()
        }
        .padding(DSSpacing.large)
    }

    private func recipeList(_ recipes: [SavedRecipePresentationModel]) -> some View {
        VStack(spacing: DSSpacing.medium) {
            DSSearchField(
                L10n.MyRecipes.searchPlaceholder,
                text: $viewModel.searchText
            )
            Text(L10n.MyRecipes.personalizedDisclaimer)
                .font(.dsCaption)
                .foregroundStyle(Color.dsTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                LazyVStack(spacing: DSSpacing.medium) {
                    ForEach(viewModel.filteredRecipes(from: recipes)) { recipe in
                        Button {
                            onSelectRecipe(recipe.id)
                        } label: {
                            HStack(spacing: DSSpacing.medium) {
                                RecipeHistoryImage(url: recipe.imageURL)
                                Text(recipe.title)
                                    .font(.dsBody.weight(.bold))
                                    .textCase(.uppercase)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                            .padding(DSSpacing.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.dsSurface)
                            .clipShape(RoundedRectangle(cornerRadius: DSBorder.cardRadius))
                            .overlay {
                                RoundedRectangle(cornerRadius: DSBorder.cardRadius)
                                    .strokeBorder(Color.dsBorder, lineWidth: DSBorder.width)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, DSSpacing.large)
            }
        }
        .padding(.horizontal, DSSpacing.large)
        .padding(.top, DSSpacing.small)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}

private struct RecipeHistoryImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Color.dsAccent)
            }
        }
        .frame(width: 88, height: 88)
        .background(Color.dsSurface)
        .clipped()
    }
}
