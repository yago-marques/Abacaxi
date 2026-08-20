@testable import PersistenceInterfaces

struct StubEntity: PersistentEntityProtocol, Sendable {
    let id: String
}

final class PersistentStoringStub: PersistentStoringProtocol {
    private var storage: [String: StubEntity] = [:]

    func save(_ entity: StubEntity) async throws {
        storage[entity.id] = entity
    }

    func fetch(id: String) async throws -> StubEntity? {
        storage[id]
    }

    func fetchAll() async throws -> [StubEntity] {
        Array(storage.values)
    }

    func delete(id: String) async throws {
        storage.removeValue(forKey: id)
    }
}
