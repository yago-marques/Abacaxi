@testable import PersistenceInterfaces

struct StubEntity: PersistentEntity {
    let id: String
}

final class PersistentStoringStub: PersistentStoring {
    private var storage: [String: StubEntity] = [:]

    func save(_ entity: StubEntity) throws {
        storage[entity.id] = entity
    }

    func fetch(id: String) throws -> StubEntity? {
        storage[id]
    }

    func fetchAll() throws -> [StubEntity] {
        Array(storage.values)
    }

    func delete(id: String) throws {
        storage.removeValue(forKey: id)
    }
}
