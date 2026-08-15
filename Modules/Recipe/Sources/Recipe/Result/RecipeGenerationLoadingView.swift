import DesignSystem
import SwiftUI

struct RecipeGenerationLoadingView: View {
    @State private var isAnimating = false
    @State private var phraseIndex = 0

    var body: some View {
        VStack(spacing: DSSpacing.large) {
            Image("OnboardingPineapple", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .scaleEffect(isAnimating ? 1.08 : 0.92)
            Text(phrases[phraseIndex])
                .font(.dsTitle)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
            Text(L10n.RecipeResult.Loading.hint)
                .font(.dsCaption)
                .foregroundStyle(Color.dsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(Color.dsTextPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dsBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2.4))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.35)) {
                    phraseIndex = (phraseIndex + 1) % phrases.count
                }
            }
        }
    }

    private var phrases: [String] {
        [
            L10n.RecipeResult.Loading.analyzing,
            L10n.RecipeResult.Loading.combining,
            L10n.RecipeResult.Loading.finishing
        ]
    }
}
