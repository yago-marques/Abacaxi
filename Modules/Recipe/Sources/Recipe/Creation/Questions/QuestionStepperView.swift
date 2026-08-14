import DesignSystem
import Extensions
import SwiftUI

struct QuestionStepperView: View {
    @StateObject private var viewModel: QuestionStepperViewModel

    init(viewModel: QuestionStepperViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.large) {
            Text(L10n.QuestionStepper.progress(viewModel.currentIndex + 1, viewModel.totalQuestions))
                .font(.dsButton)
                .foregroundStyle(Color.dsAccent)
            DSProgressBar(progress: viewModel.progress)

            Text(viewModel.currentQuestion.text)
                .font(.dsDisplay)
                .foregroundStyle(Color.dsTextPrimary)

            VStack(spacing: DSSpacing.small) {
                ForEach(viewModel.currentQuestion.options, id: \.self) { option in
                    DSChoiceRow(title: option, isSelected: viewModel.selectedOption == option) {
                        viewModel.selectOption(option)
                    }
                }

                if viewModel.currentQuestion.allowsCustomAnswer {
                    DSChoiceRow(title: L10n.QuestionStepper.other, isSelected: viewModel.isCustomAnswerSelected) {
                        viewModel.selectCustomAnswer()
                    }
                    if viewModel.isCustomAnswerSelected {
                        TextField(L10n.QuestionStepper.Other.placeholder, text: $viewModel.customAnswer)
                            .font(.dsBody)
                            .foregroundStyle(Color.dsTextPrimary)
                            .padding(.horizontal, DSSpacing.medium)
                            .frame(minHeight: 52)
                            .overlay(Rectangle().strokeBorder(Color.dsPrimary, lineWidth: DSBorder.width))
                    }
                }
            }

            Spacer()

            Button(viewModel.isLastQuestion ? L10n.QuestionStepper.generate : L10n.QuestionStepper.next) {
                viewModel.continueStep()
            }
            .buttonStyle(.dsPrimary)
            .disabled(!viewModel.canContinue)
            .opacity(viewModel.canContinue ? 1 : 0.4)
        }
        .padding(DSSpacing.large)
        .background(Color.dsBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .dsToolbar {
            DSNavigationToolbar(onBack: viewModel.goBack)
        }
    }
}
