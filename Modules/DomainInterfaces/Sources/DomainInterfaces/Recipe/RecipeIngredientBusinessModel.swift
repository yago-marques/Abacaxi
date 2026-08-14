import Foundation

public struct RecipeIngredientBusinessModel: Equatable, Sendable {
    public enum Amount: Equatable, Sendable {
        case little
        case medium
        case much
    }

    public let name: String
    public let amount: Amount

    public init(name: String, amount: Amount) {
        self.name = name
        self.amount = amount
    }
}
