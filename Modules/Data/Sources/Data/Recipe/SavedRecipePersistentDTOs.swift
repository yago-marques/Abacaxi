import DomainInterfaces

// As CodingKeys congelam o schema em disco no formato gravado pelas versões
// anteriores (chaves sintetizadas dos nomes das propriedades do domínio).
// Renomear propriedades do domínio não pode alterar estas chaves — dados já
// salvos nos dispositivos dependem delas.
struct RecipeIngredientPersistentDTO: Codable {
    let name: String
    let quantity: String

    enum CodingKeys: String, CodingKey {
        case name
        case quantity
    }
}

struct RecipeNutritionPersistentDTO: Codable {
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int

    enum CodingKeys: String, CodingKey {
        case calories
        case proteinGrams
        case carbsGrams
        case fatGrams
    }
}

extension RecipeIngredientPersistentDTO {
    init(_ businessModel: RecipeIngredientDetailBusinessModel) {
        self.init(name: businessModel.name, quantity: businessModel.quantity)
    }
}

extension RecipeNutritionPersistentDTO {
    init(_ businessModel: RecipeNutritionBusinessModel) {
        self.init(
            calories: businessModel.calories,
            proteinGrams: businessModel.proteinGrams,
            carbsGrams: businessModel.carbsGrams,
            fatGrams: businessModel.fatGrams
        )
    }
}

extension RecipeIngredientDetailBusinessModel {
    init(_ dto: RecipeIngredientPersistentDTO) {
        self.init(name: dto.name, quantity: dto.quantity)
    }
}

extension RecipeNutritionBusinessModel {
    init(_ dto: RecipeNutritionPersistentDTO) {
        self.init(
            calories: dto.calories,
            proteinGrams: dto.proteinGrams,
            carbsGrams: dto.carbsGrams,
            fatGrams: dto.fatGrams
        )
    }
}
