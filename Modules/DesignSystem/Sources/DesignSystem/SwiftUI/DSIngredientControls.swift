import SwiftUI

public struct DSListRow<Trailing: View>: View {
    private let title: String
    private let trailing: Trailing

    public init(title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: DSSpacing.small) {
            Text(title)
                .font(.dsButton)
                .textCase(.uppercase)
                .lineLimit(1)
            Spacer()
            trailing
        }
        .padding(.leading, DSSpacing.medium)
        .frame(minHeight: 48)
        .background(Color.dsSurface)
    }
}

public struct DSIconButton: View {
    private let systemImage: String
    private let action: () -> Void

    public init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.dsButton)
                .frame(width: 36, height: 36)
                .foregroundStyle(Color.black)
                .background(Color.dsAccent)
                // Visual stays 36pt; the tappable area honors the 44pt minimum target.
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public struct DSNavigationBackControl: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 52, height: 44)
                .foregroundStyle(Color.dsAccent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Voltar")
    }
}

public struct DSNavigationToolbar: ToolbarContent {
    private let title: String?
    private let showsBackButton: Bool
    private let onBack: () -> Void

    public init(
        title: String? = nil,
        showsBackButton: Bool = true,
        onBack: @escaping () -> Void = {}
    ) {
        self.title = title
        self.showsBackButton = showsBackButton
        self.onBack = onBack
    }

    @ToolbarContentBuilder public var body: some ToolbarContent {
        if showsBackButton {
            ToolbarItem(placement: .navigationBarLeading) {
                DSNavigationBackControl(action: onBack)
            }
        }

        if let title {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.dsTitle)
                    .foregroundStyle(Color.dsTextPrimary)
            }
        }
    }
}

public enum DSToastStyle: Equatable {
    case error
    case success

    fileprivate var backgroundColor: Color {
        switch self {
        case .error: .dsError
        case .success: .dsAccent
        }
    }

    fileprivate var alignment: Alignment {
        switch self {
        case .error: .top
        case .success: .bottom
        }
    }

    fileprivate var iconName: String {
        switch self {
        case .error: "exclamationmark.triangle.fill"
        case .success: "checkmark.circle.fill"
        }
    }
}

public struct DSToastRequest: Identifiable, Equatable {
    public let id: UUID
    public let message: String
    public let style: DSToastStyle

    public init(id: UUID = UUID(), message: String, style: DSToastStyle) {
        self.id = id
        self.message = message
        self.style = style
    }
}

public struct DSToast: View {
    private let message: String
    private let style: DSToastStyle
    private let progress: CGFloat

    public init(message: String, style: DSToastStyle, progress: CGFloat) {
        self.message = message
        self.style = style
        self.progress = progress
    }

    public var body: some View {
        VStack(spacing: DSSpacing.small) {
            HStack(spacing: DSSpacing.small) {
                Image(systemName: style.iconName)
                Text(message)
                    .font(.dsCaption.weight(.bold))
                Spacer()
            }

            Rectangle()
                .fill(Color.dsTextPrimary.opacity(0.8))
                .frame(maxWidth: .infinity, minHeight: 3, maxHeight: 3)
                .scaleEffect(x: safeProgress, y: 1, anchor: .leading)
                .clipped()
            .frame(height: 3)
        }
        .foregroundStyle(Color.dsTextPrimary)
        .padding(DSSpacing.medium)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSBorder.radius))
    }

    private var safeProgress: CGFloat {
        guard progress.isFinite else { return 0 }
        return min(max(progress, 0), 1)
    }
}

public extension View {
    func dsToast(
        request: DSToastRequest?,
        duration: TimeInterval = 3,
        onDismiss: @escaping (UUID) -> Void
    ) -> some View {
        modifier(
            DSToastModifier(
                request: request,
                duration: duration,
                onDismiss: onDismiss
            )
        )
    }
}

@MainActor
final class DSToastPresentation: ObservableObject {
    @Published private(set) var activeRequest: DSToastRequest?
    @Published private(set) var isVisible = false
    @Published private(set) var progress: CGFloat = 0

    private var dismissTask: Task<Void, Never>?

    func present(
        request: DSToastRequest?,
        duration: TimeInterval,
        onDismiss: @escaping (UUID) -> Void
    ) {
        guard let request else { return }

        dismissTask?.cancel()
        activeRequest = request
        progress = 0

        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = true
        }
        withAnimation(.linear(duration: duration)) {
            progress = 1
        }

        dismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.dismiss(requestID: request.id, onDismiss: onDismiss)
        }
    }

    func cancel() {
        dismissTask?.cancel()
        dismissTask = nil
    }

    func dismiss(requestID: UUID, onDismiss: @escaping (UUID) -> Void) {
        guard activeRequest?.id == requestID else { return }

        withAnimation(.easeIn(duration: 0.2)) {
            isVisible = false
        }
        activeRequest = nil
        dismissTask = nil
        onDismiss(requestID)
    }
}

private struct DSToastModifier: ViewModifier {
    let request: DSToastRequest?
    let duration: TimeInterval
    let onDismiss: (UUID) -> Void

    @StateObject private var presentation = DSToastPresentation()

    func body(content: Content) -> some View {
        content
            .overlay(alignment: presentation.activeRequest?.style.alignment ?? .top) {
                if presentation.isVisible, let request = presentation.activeRequest {
                    DSToast(message: request.message, style: request.style, progress: presentation.progress)
                        .padding(DSSpacing.medium)
                        .transition(
                            .move(edge: request.style == .error ? .top : .bottom)
                                .combined(with: .opacity)
                        )
                }
            }
            .onChange(of: request) { request in
                presentation.present(request: request, duration: duration, onDismiss: onDismiss)
            }
            .onAppear {
                presentation.present(request: request, duration: duration, onDismiss: onDismiss)
            }
            .onDisappear {
                presentation.cancel()
            }
    }
}

public struct DSQuantityBadge: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.dsCaption.weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(Color.black)
            .padding(.horizontal, DSSpacing.small)
            .frame(minHeight: 28)
            .background(Color.dsPrimary)
    }
}

public struct DSChoiceRow: View {
    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.medium) {
                Circle()
                    .strokeBorder(isSelected ? Color.dsPrimary : .dsAccent, lineWidth: DSBorder.width)
                    .background(Circle().fill(isSelected ? Color.dsPrimary : .clear).padding(5))
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.dsTitle)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.medium)
            .frame(minHeight: 52)
            .foregroundStyle(isSelected ? Color.dsPrimary : Color.dsTextPrimary)
            .overlay(Rectangle().strokeBorder(isSelected ? Color.dsPrimary : .dsBorder, lineWidth: DSBorder.width))
        }
        .buttonStyle(.plain)
    }
}

public struct DSProgressBar: View {
    private let progress: CGFloat

    public init(progress: CGFloat) {
        self.progress = progress
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.dsSurface)
                Rectangle()
                    .fill(Color.dsPrimary)
                    .frame(width: proxy.size.width * safeProgress)
            }
        }
        .frame(height: DSSpacing.small)
        .overlay(Rectangle().strokeBorder(Color.dsBorder, lineWidth: DSBorder.width))
    }

    private var safeProgress: CGFloat {
        guard progress.isFinite else { return 0 }
        return min(max(progress, 0), 1)
    }
}

public struct DSBottomSheet<Content: View>: View {
    private let title: String
    private let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        ZStack {
            Color.dsSurface
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                Capsule().fill(Color.dsBorder).frame(width: 40, height: 5).frame(maxWidth: .infinity)
                Text(title).font(.dsDisplay).textCase(.uppercase)
                content
            }
            .padding(DSSpacing.large)
        }
        .foregroundStyle(Color.dsTextPrimary)
        .presentationDetents([.height(390)])
        .presentationDragIndicator(.hidden)
    }
}
