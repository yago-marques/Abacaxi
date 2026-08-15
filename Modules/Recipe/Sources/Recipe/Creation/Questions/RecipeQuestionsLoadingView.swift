import DesignSystem
import SwiftUI

struct RecipeQuestionsLoadingView: View {
    @State private var messageIndex = 0
    @State private var isLogoPulsing = false

    private let messages = [
        L10n.IngredientPicker.Loading.analyzing,
        L10n.IngredientPicker.Loading.preparing
    ]

    var body: some View {
        VStack(spacing: DSSpacing.large) {
            Image("OnboardingPineapple", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 230, height: 230)
                .scaleEffect(isLogoPulsing ? 1.1 : 0.92)
                .opacity(isLogoPulsing ? 1 : 0.75)

            Text(messages[messageIndex])
                .font(.dsTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.dsTextPrimary)
                .id(messageIndex)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .padding(DSSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dsBackground.ignoresSafeArea())
        .task {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isLogoPulsing = true
            }
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                messageIndex = 1
            }
        }
    }
}
