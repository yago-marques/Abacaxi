@testable import PersistenceInterfaces

struct StubEntity: PersistentEntityProtocol {
    let id: String
}

final class PersistentStoringStub: PersistentStoringProtocol {
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
