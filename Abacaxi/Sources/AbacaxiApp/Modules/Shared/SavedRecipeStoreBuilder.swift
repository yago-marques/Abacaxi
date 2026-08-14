import CoreData
import Data
import Persistence

enum SavedRecipeStoreBuilder {
    static func make() -> CoreDataStore<SavedRecipePersistentModel, NSManagedObject> {
        store
    }

    private static let store = CoreDataStoreBuilder.make(
        container: makeContainer(),
        entityName: "SavedRecipe",
        idKeyPath: "id",
        map: map,
        toEntity: map
    )

    private static func makeContainer() -> NSPersistentContainer {
        let entity = NSEntityDescription()
        entity.name = "SavedRecipe"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            attribute("id", .stringAttributeType),
            attribute("title", .stringAttributeType),
            attribute("recipeDescription", .stringAttributeType),
            attribute("ingredientsData", .binaryDataAttributeType),
            attribute("stepsData", .binaryDataAttributeType),
            attribute("preparationTimeMinutes", .integer32AttributeType),
            attribute("servings", .integer32AttributeType),
            attribute("nutritionData", .binaryDataAttributeType, optional: true),
            attribute("imagePath", .stringAttributeType, optional: true),
            attribute("createdAt", .dateAttributeType)
        ]
        let model = NSManagedObjectModel()
        model.entities = [entity]
        let container = NSPersistentContainer(name: "SavedRecipes", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error { fatalError("Unable to load saved recipes: \(error)") }
        }
        return container
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }

    private static func map(_ model: SavedRecipePersistentModel, _ object: NSManagedObject) {
        object.setValue(model.id, forKey: "id")
        object.setValue(model.title, forKey: "title")
        object.setValue(model.recipeDescription, forKey: "recipeDescription")
        object.setValue(model.ingredientsData, forKey: "ingredientsData")
        object.setValue(model.stepsData, forKey: "stepsData")
        object.setValue(model.preparationTimeMinutes, forKey: "preparationTimeMinutes")
        object.setValue(model.servings, forKey: "servings")
        object.setValue(model.nutritionData, forKey: "nutritionData")
        object.setValue(model.imagePath, forKey: "imagePath")
        object.setValue(model.createdAt, forKey: "createdAt")
    }

    private static func map(_ object: NSManagedObject) -> SavedRecipePersistentModel {
        SavedRecipePersistentModel(
            id: object.value(forKey: "id") as? String ?? "",
            title: object.value(forKey: "title") as? String ?? "",
            recipeDescription: object.value(forKey: "recipeDescription") as? String ?? "",
            ingredientsData: object.value(forKey: "ingredientsData") as? Data ?? Data(),
            stepsData: object.value(forKey: "stepsData") as? Data ?? Data(),
            preparationTimeMinutes: object.value(forKey: "preparationTimeMinutes") as? Int ?? 0,
            servings: object.value(forKey: "servings") as? Int ?? 0,
            nutritionData: object.value(forKey: "nutritionData") as? Data,
            imagePath: object.value(forKey: "imagePath") as? String,
            createdAt: object.value(forKey: "createdAt") as? Date ?? Date()
        )
    }
}
