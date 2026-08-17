import DomainInterfaces
import Foundation
import XCTest
@testable import Data

// Os fixtures reproduzem byte-a-byte o formato gravado em disco pelas versões
// anteriores, que encodavam os business models com chaves sintetizadas.
// Se estes testes quebrarem, receitas já salvas pelos usuários ficam ilegíveis.
final class SavedRecipePersistentDTOTests: XCTestCase {
    func test_decode_legacyIngredientsPayload_mapsToBusinessModels() throws {
        let sut = try makeDecodedIngredientsSUT()

        XCTAssertEqual(sut.map(RecipeIngredientDetailBusinessModel.init), expectedIngredients)
    }

    func test_decode_legacyNutritionPayload_mapsToBusinessModel() throws {
        let sut = try makeDecodedNutritionSUT()

        XCTAssertEqual(RecipeNutritionBusinessModel(sut), expectedNutrition)
    }

    func test_encode_ingredientDTO_writesTheLegacyKeys() throws {
        let sut = makeIngredientSUT()

        let json = try encodeToJSONObject(sut)

        XCTAssertEqual(Set(json.keys), ["name", "quantity"])
        XCTAssertEqual(json["name"] as? String, "Arroz")
        XCTAssertEqual(json["quantity"] as? String, "1 xícara")
    }

    func test_encode_nutritionDTO_writesTheLegacyKeys() throws {
        let sut = makeNutritionSUT()

        let json = try encodeToJSONObject(sut)

        XCTAssertEqual(Set(json.keys), ["calories", "proteinGrams", "carbsGrams", "fatGrams"])
        XCTAssertEqual(json["calories"] as? Int, 450)
        XCTAssertEqual(json["proteinGrams"] as? Int, 12)
        XCTAssertEqual(json["carbsGrams"] as? Int, 60)
        XCTAssertEqual(json["fatGrams"] as? Int, 10)
    }
}

private extension SavedRecipePersistentDTOTests {
    var legacyIngredientsPayload: Data {
        Data("""
        [{"name":"Arroz","quantity":"1 xícara"},{"name":"Feijão","quantity":"2 conchas"}]
        """.utf8)
    }

    var legacyNutritionPayload: Data {
        Data("""
        {"calories":450,"proteinGrams":12,"carbsGrams":60,"fatGrams":10}
        """.utf8)
    }

    var expectedIngredients: [RecipeIngredientDetailBusinessModel] {
        [
            RecipeIngredientDetailBusinessModel(name: "Arroz", quantity: "1 xícara"),
            RecipeIngredientDetailBusinessModel(name: "Feijão", quantity: "2 conchas")
        ]
    }

    var expectedNutrition: RecipeNutritionBusinessModel {
        RecipeNutritionBusinessModel(calories: 450, proteinGrams: 12, carbsGrams: 60, fatGrams: 10)
    }

    func makeDecodedIngredientsSUT() throws -> [RecipeIngredientPersistentDTO] {
        try JSONDecoder().decode([RecipeIngredientPersistentDTO].self, from: legacyIngredientsPayload)
    }

    func makeDecodedNutritionSUT() throws -> RecipeNutritionPersistentDTO {
        try JSONDecoder().decode(RecipeNutritionPersistentDTO.self, from: legacyNutritionPayload)
    }

    func makeIngredientSUT() -> RecipeIngredientPersistentDTO {
        RecipeIngredientPersistentDTO(expectedIngredients[0])
    }

    func makeNutritionSUT() -> RecipeNutritionPersistentDTO {
        RecipeNutritionPersistentDTO(expectedNutrition)
    }

    func encodeToJSONObject(_ value: some Encodable) throws -> [String: Any] {
        let encoded = try JSONEncoder().encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    }
}
