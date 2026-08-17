import DomainInterfaces
import Foundation
import XCTest
@testable import Data

// Os fixtures reproduzem byte-a-byte o formato gravado em disco pelas versões
// anteriores, que encodavam os business models com chaves sintetizadas.
// Se estes testes quebrarem, receitas já salvas pelos usuários ficam ilegíveis.
final class SavedRecipePersistentDTOTests: XCTestCase {
    func test_decode_legacyIngredientsPayload_mapsToBusinessModels() throws {
        let legacyPayload = Data("""
        [{"name":"Arroz","quantity":"1 xícara"},{"name":"Feijão","quantity":"2 conchas"}]
        """.utf8)

        let decoded = try JSONDecoder().decode([RecipeIngredientPersistentDTO].self, from: legacyPayload)
        let ingredients = decoded.map(RecipeIngredientDetailBusinessModel.init)

        XCTAssertEqual(
            ingredients,
            [
                RecipeIngredientDetailBusinessModel(name: "Arroz", quantity: "1 xícara"),
                RecipeIngredientDetailBusinessModel(name: "Feijão", quantity: "2 conchas")
            ]
        )
    }

    func test_decode_legacyNutritionPayload_mapsToBusinessModel() throws {
        let legacyPayload = Data("""
        {"calories":450,"proteinGrams":12,"carbsGrams":60,"fatGrams":10}
        """.utf8)

        let decoded = try JSONDecoder().decode(RecipeNutritionPersistentDTO.self, from: legacyPayload)
        let nutrition = RecipeNutritionBusinessModel(decoded)

        XCTAssertEqual(
            nutrition,
            RecipeNutritionBusinessModel(calories: 450, proteinGrams: 12, carbsGrams: 60, fatGrams: 10)
        )
    }

    func test_encode_ingredientDTO_writesTheLegacyKeys() throws {
        let ingredient = RecipeIngredientDetailBusinessModel(name: "Arroz", quantity: "1 xícara")
        let dto = RecipeIngredientPersistentDTO(ingredient)

        let encoded = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])

        XCTAssertEqual(Set(json.keys), ["name", "quantity"])
        XCTAssertEqual(json["name"] as? String, "Arroz")
        XCTAssertEqual(json["quantity"] as? String, "1 xícara")
    }

    func test_encode_nutritionDTO_writesTheLegacyKeys() throws {
        let dto = RecipeNutritionPersistentDTO(
            RecipeNutritionBusinessModel(calories: 450, proteinGrams: 12, carbsGrams: 60, fatGrams: 10)
        )

        let encoded = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])

        XCTAssertEqual(Set(json.keys), ["calories", "proteinGrams", "carbsGrams", "fatGrams"])
        XCTAssertEqual(json["calories"] as? Int, 450)
        XCTAssertEqual(json["proteinGrams"] as? Int, 12)
        XCTAssertEqual(json["carbsGrams"] as? Int, 60)
        XCTAssertEqual(json["fatGrams"] as? Int, 10)
    }
}
