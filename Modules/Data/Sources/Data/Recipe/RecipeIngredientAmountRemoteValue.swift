import DomainInterfaces

extension RecipeIngredientBusinessModel.Amount {
    var remoteValue: String {
        switch self {
        case .little: "pouco"
        case .medium: "medio"
        case .much: "muito"
        }
    }
}
