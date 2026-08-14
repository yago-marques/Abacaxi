import DomainInterfaces
import Foundation

enum IngredientAmount: CaseIterable, Equatable {
    case little
    case medium
    case much

    var title: String {
        switch self {
        case .little: L10n.IngredientPicker.Amount.little
        case .medium: L10n.IngredientPicker.Amount.medium
        case .much: L10n.IngredientPicker.Amount.much
        }
    }
}

struct IngredientPresentationModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    var amount: IngredientAmount

    init(id: UUID = UUID(), name: String, amount: IngredientAmount = .medium) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.amount = amount
    }

    var normalizedName: String {
        name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}

extension IngredientPresentationModel {
    func toBusinessModel() -> RecipeIngredientBusinessModel {
        RecipeIngredientBusinessModel(
            name: name,
            amount: businessAmount
        )
    }

    private var businessAmount: RecipeIngredientBusinessModel.Amount {
        switch amount {
        case .little: .little
        case .medium: .medium
        case .much: .much
        }
    }
}
