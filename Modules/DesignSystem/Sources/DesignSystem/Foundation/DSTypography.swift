import SwiftUI
import UIKit

public enum DSTypography {
    public static var hero: UIFont { scaled(.largeTitle, size: 44, weight: .heavy) }
    public static var display: UIFont { scaled(.title1, size: 28, weight: .heavy) }
    public static var title: UIFont { scaled(.title2, size: 22, weight: .bold) }
    public static var button: UIFont { scaled(.body, size: 17, weight: .bold) }
    public static var body: UIFont { UIFont.preferredFont(forTextStyle: .body) }
    public static var caption: UIFont { UIFont.preferredFont(forTextStyle: .caption1) }

    private static func scaled(_ textStyle: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        UIFontMetrics(forTextStyle: textStyle).scaledFont(for: .systemFont(ofSize: size, weight: weight))
    }
}

public extension Font {
    static var dsHero: Font { Font(DSTypography.hero) }
    static var dsDisplay: Font { Font(DSTypography.display) }
    static var dsTitle: Font { Font(DSTypography.title) }
    static var dsButton: Font { Font(DSTypography.button) }
    static var dsBody: Font { .body }
    static var dsCaption: Font { .caption }
}
