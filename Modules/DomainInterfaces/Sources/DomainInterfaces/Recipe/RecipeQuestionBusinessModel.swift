import Foundation

public struct RecipeQuestionBusinessModel: Equatable, Sendable {
    public let id: String
    public let text: String
    public let options: [String]
    public let allowsCustomAnswer: Bool

    public init(id: String, text: String, options: [String], allowsCustomAnswer: Bool) {
        self.id = id
        self.text = text
        self.options = options
        self.allowsCustomAnswer = allowsCustomAnswer
    }
}
