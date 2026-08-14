import SwiftUI

public extension View {
    @ViewBuilder
    func applyIf<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func dsToolbar<Content: ToolbarContent>(
        @ToolbarContentBuilder content: () -> Content
    ) -> some View {
        self.toolbar(content: content)
    }
}
