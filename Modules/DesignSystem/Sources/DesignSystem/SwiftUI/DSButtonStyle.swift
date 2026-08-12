import SwiftUI

public struct DSButtonStyle: ButtonStyle {
    public enum Variant {
        case primary
        case secondary
        case text
    }

    private let variant: Variant

    public init(variant: Variant = .primary) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .font(.dsButton)
                .textCase(.uppercase)
            HStack {
                Spacer()
                Image(systemName: "play.fill")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundStyle(foregroundColor)
        .frame(maxWidth: variant == .text ? nil : .infinity)
        .frame(minHeight: 56)
        .padding(.horizontal, variant == .text ? 0 : DSSpacing.medium)
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(cornerRadius: DSBorder.radius)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: DSBorder.radius))
        .opacity(configuration.isPressed ? 0.72 : 1)
        .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }

    private var backgroundColor: Color {
        variant == .primary ? .dsPrimary : .clear
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: .black
        case .secondary: .dsPrimary
        case .text: .dsTextPrimary
        }
    }

    private var borderColor: Color {
        variant == .secondary ? .dsPrimary : .clear
    }

    private var borderWidth: CGFloat {
        variant == .secondary ? DSBorder.width : 0
    }
}

public extension ButtonStyle where Self == DSButtonStyle {
    static var dsPrimary: DSButtonStyle { DSButtonStyle() }
    static var dsSecondary: DSButtonStyle { DSButtonStyle(variant: .secondary) }
    static var dsText: DSButtonStyle { DSButtonStyle(variant: .text) }
}
