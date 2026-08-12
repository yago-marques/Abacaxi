import SwiftUI
import UIKit

public enum DSColor {
    public static let background = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1)
    public static let surface = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
    public static let surfaceLight = UIColor(red: 0.96, green: 0.95, blue: 0.91, alpha: 1)
    public static let primary = UIColor(red: 1, green: 0.78, blue: 0.24, alpha: 1)
    public static let accent = UIColor(red: 0.25, green: 0.68, blue: 0.45, alpha: 1)
    public static let brown = UIColor(red: 0.42, green: 0.26, blue: 0.16, alpha: 1)
    public static let textPrimary = UIColor(red: 0.96, green: 0.95, blue: 0.91, alpha: 1)
    public static let textSecondary = UIColor(red: 0.73, green: 0.72, blue: 0.69, alpha: 1)
    public static let border = UIColor(red: 0.36, green: 0.36, blue: 0.35, alpha: 1)
}

public enum DSTheme {
    public static func apply() {
        UIView.appearance().tintColor = DSColor.accent

        let navigationBar = UINavigationBarAppearance()
        navigationBar.configureWithOpaqueBackground()
        navigationBar.backgroundColor = DSColor.background
        navigationBar.titleTextAttributes = [.foregroundColor: DSColor.textPrimary]
        navigationBar.largeTitleTextAttributes = [.foregroundColor: DSColor.textPrimary]

        UINavigationBar.appearance().standardAppearance = navigationBar
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBar
        UINavigationBar.appearance().compactAppearance = navigationBar
    }
}

public extension Color {
    static let dsBackground = Color(uiColor: DSColor.background)
    static let dsSurface = Color(uiColor: DSColor.surface)
    static let dsSurfaceLight = Color(uiColor: DSColor.surfaceLight)
    static let dsPrimary = Color(uiColor: DSColor.primary)
    static let dsAccent = Color(uiColor: DSColor.accent)
    static let dsBrown = Color(uiColor: DSColor.brown)
    static let dsTextPrimary = Color(uiColor: DSColor.textPrimary)
    static let dsTextSecondary = Color(uiColor: DSColor.textSecondary)
    static let dsBorder = Color(uiColor: DSColor.border)
}
