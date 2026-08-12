import SwiftUI
import UIKit

public enum DSTypography {
    public static let hero = UIFont.systemFont(ofSize: 44, weight: .heavy)
    public static let display = UIFont.systemFont(ofSize: 28, weight: .heavy)
    public static let title = UIFont.systemFont(ofSize: 22, weight: .bold)
    public static let button = UIFont.systemFont(ofSize: 17, weight: .bold)
    public static let body = UIFont.preferredFont(forTextStyle: .body)
    public static let caption = UIFont.preferredFont(forTextStyle: .caption1)
}

public extension Font {
    static let dsHero = Font.system(size: 44, weight: .heavy)
    static let dsDisplay = Font.system(size: 28, weight: .heavy)
    static let dsTitle = Font.system(size: 22, weight: .bold)
    static let dsButton = Font.system(size: 17, weight: .bold)
    static let dsBody = Font.body
    static let dsCaption = Font.caption
}
