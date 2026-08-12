import SwiftUI

public struct DSCard<Content: View>: View {
    public enum Theme {
        case dark
        case light
    }

    private let title: String
    private let description: String
    private let theme: Theme
    private let content: Content

    public init(
        title: String,
        description: String,
        theme: Theme = .dark,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.theme = theme
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            content
            Text(title)
                .font(.dsTitle)
                .textCase(.uppercase)
            Text(description)
                .font(.dsBody)
        }
        .foregroundStyle(theme == .dark ? Color.dsTextPrimary : Color.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.large)
        .background(theme == .dark ? Color.dsSurface : Color.dsSurfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: DSBorder.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DSBorder.cardRadius)
                .strokeBorder(Color.dsBorder, lineWidth: 1)
        }
    }
}
