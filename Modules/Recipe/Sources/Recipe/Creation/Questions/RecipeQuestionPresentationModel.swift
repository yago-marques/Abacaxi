import DomainInterfaces

struct RecipeQuestionPresentationModel: Identifiable, Equatable {
    let id: String
    let text: String
    let options: [String]
    let allowsCustomAnswer: Bool
}

extension RecipeQuestionPresentationModel {
    init(_ businessModel: RecipeQuestionBusinessModel) {
        id = businessModel.id
        text = businessModel.text
        options = businessModel.options
        allowsCustomAnswer = businessModel.allowsCustomAnswer
    }
}
