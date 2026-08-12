import SwiftUI

public struct DSTextFieldView: View {
    private let label: String?
    private let placeholder: String
    private let systemImageName: String?
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    public init(
        _ placeholder: String,
        text: Binding<String>,
        label: String? = nil,
        systemImageName: String? = nil
    ) {
        self.placeholder = placeholder
        _text = text
        self.label = label
        self.systemImageName = systemImageName
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            if let label {
                Text(label)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextPrimary)
            }

            HStack(spacing: DSSpacing.small) {
                if let systemImageName {
                    Image(systemName: systemImageName)
                        .foregroundStyle(Color.dsTextSecondary)
                }

                TextField(placeholder, text: $text)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextPrimary)
                    .focused($isFocused)
            }
            .padding(.horizontal, DSSpacing.medium)
            .frame(minHeight: 60)
            .overlay {
                RoundedRectangle(cornerRadius: DSBorder.radius)
                    .strokeBorder(isFocused ? Color.dsAccent : .dsBorder, lineWidth: DSBorder.width)
            }
        }
    }
}
