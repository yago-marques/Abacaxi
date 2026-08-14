import DesignSystem
import DomainInterfaces
import Extensions
import SwiftUI

struct IngredientPickerView: View {
    @StateObject private var viewModel: IngredientPickerViewModel
    @State private var isLoadingPresented = false
    @State private var pendingFeedback: IngredientPickerFeedback?
    @State private var toastRequest: DSToastRequest?
    private let onBack: () -> Void
    private let onQuestionsLoaded: ([RecipeIngredientBusinessModel], [RecipeQuestionPresentationModel]) -> Void

    init(
        viewModel: IngredientPickerViewModel,
        onBack: @escaping () -> Void = {},
        onQuestionsLoaded: @escaping ([RecipeIngredientBusinessModel], [RecipeQuestionPresentationModel]) -> Void = { _, _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onQuestionsLoaded = onQuestionsLoaded
    }

    var body: some View {
        ZStack {
            content

            if isLoadingPresented {
                RecipeQuestionsLoadingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isLoadingPresented)
        .navigationBarBackButtonHidden()
        .applyIf(!isLoadingPresented) { view in
            view.dsToolbar {
                DSNavigationToolbar(onBack: onBack)
            }
        }
        .dsToast(
            request: toastRequest,
            onDismiss: dismissToast
        )
        .onChange(of: viewModel.feedback?.id) { _ in
            routeFeedback(viewModel.feedback)
        }
        .onChange(of: isLoadingPresented) { isLoading in
            guard !isLoading, let pendingFeedback else { return }
            self.pendingFeedback = nil
            presentToast(for: pendingFeedback)
        }
        .sheet(item: $viewModel.ingredientBeingEdited) { ingredient in
            QuantitySheet(ingredient: ingredient, viewModel: viewModel)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            Text(L10n.IngredientPicker.title)
                .font(.dsHero)
                .textCase(.uppercase)
                .overlay(alignment: .bottomLeading) {
                    Rectangle().fill(Color.dsPrimary).frame(width: 44, height: 5).offset(y: 12)
                }
                .padding(.bottom, DSSpacing.medium)

            ScrollView {
                LazyVStack(spacing: DSSpacing.small) {
                    ForEach(viewModel.ingredients) { ingredient in
                        DSListRow(title: ingredient.name) {
                            HStack(spacing: DSSpacing.small) {
                                Button { viewModel.beginEditing(ingredient) } label: {
                                    DSQuantityBadge(ingredient.amount.title)
                                }
                                .buttonStyle(.plain)
                                DSIconButton(systemImage: "xmark") {
                                    viewModel.removeIngredient(id: ingredient.id)
                                }
                            }
                        }
                        .onTapGesture { viewModel.beginEditing(ingredient) }
                    }
                }
            }

            HStack(spacing: 0) {
                TextField(
                    "",
                    text: $viewModel.draftText,
                    prompt: Text(L10n.IngredientPicker.Input.placeholder)
                        .foregroundColor(Color.dsTextSecondary)
                )
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextPrimary)
                    .padding(.horizontal, DSSpacing.medium)
                    .frame(minHeight: 48)
                    .overlay(Rectangle().strokeBorder(Color.dsBorder, lineWidth: DSBorder.width))
                Button(action: viewModel.addIngredient) {
                    Label(L10n.IngredientPicker.add, systemImage: "plus")
                        .font(.dsCaption.weight(.bold))
                        .textCase(.uppercase)
                        .padding(.horizontal, DSSpacing.small)
                        .frame(minHeight: 48)
                        .foregroundStyle(Color.black)
                        .background(Color.dsPrimary)
                }
            }

            Text(L10n.IngredientPicker.minimumIngredients)
                .font(.dsCaption)
                .foregroundStyle(Color.dsTextSecondary)
                .opacity(viewModel.canContinue ? 0 : 1)
                .accessibilityHidden(viewModel.canContinue)

            Button(L10n.IngredientPicker.continue) {
                fetchQuestions()
            }
                .buttonStyle(.dsPrimary)
                .disabled(!viewModel.canContinue || isLoadingPresented)
                .opacity(viewModel.canContinue ? 1 : 0.4)
        }
        .padding(DSSpacing.large)
        .foregroundStyle(Color.dsTextPrimary)
        .background(Color.dsBackground.ignoresSafeArea())
    }

    private func fetchQuestions() {
        Task {
            let startedAt = Date()
            isLoadingPresented = true
            let questions = await viewModel.fetchQuestions()

            let elapsed = Date().timeIntervalSince(startedAt)
            let remainingDuration = max(0, 2 - elapsed)
            if remainingDuration > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingDuration * 1_000_000_000))
            }

            isLoadingPresented = false
            if let questions {
                onQuestionsLoaded(viewModel.ingredients.map { $0.toBusinessModel() }, questions)
            }
        }
    }

    private func routeFeedback(_ feedback: IngredientPickerFeedback?) {
        guard let feedback else { return }

        if isLoadingPresented {
            pendingFeedback = feedback
        } else {
            presentToast(for: feedback)
        }
    }

    private func presentToast(for feedback: IngredientPickerFeedback) {
        toastRequest = DSToastRequest(message: toastMessage(for: feedback), style: .error)
    }

    private func dismissToast(requestID: UUID) {
        guard toastRequest?.id == requestID else { return }

        toastRequest = nil
        viewModel.dismissFeedback()
    }

    private func toastMessage(for feedback: IngredientPickerFeedback) -> String {
        switch feedback.kind {
        case .duplicate:
            return L10n.IngredientPicker.duplicateToast
        case .invalidIngredients:
            return L10n.IngredientPicker.invalidIngredientsToast
        case .rateLimited:
            return L10n.IngredientPicker.rateLimitedToast
        case .temporarilyUnavailable:
            return L10n.IngredientPicker.temporarilyUnavailableToast
        case .requestFailed:
            return L10n.IngredientPicker.requestFailedToast
        }
    }

}

private struct QuantitySheet: View {
    let ingredient: IngredientPresentationModel
    @ObservedObject var viewModel: IngredientPickerViewModel
    @State private var selectedAmount: IngredientAmount

    init(ingredient: IngredientPresentationModel, viewModel: IngredientPickerViewModel) {
        self.ingredient = ingredient
        self.viewModel = viewModel
        _selectedAmount = State(initialValue: ingredient.amount)
    }

    var body: some View {
        DSBottomSheet(title: L10n.IngredientPicker.quantity) {
            ForEach(IngredientAmount.allCases, id: \.self) { amount in
                DSChoiceRow(title: amount.title, isSelected: amount == selectedAmount) {
                    selectedAmount = amount
                }
            }
            Button(L10n.IngredientPicker.confirm) { viewModel.updateAmount(selectedAmount) }
                .buttonStyle(.dsPrimary)
        }
    }
}
