public protocol PersistentStoringProtocol {
    associatedtype Entity: PersistentEntityProtocol

    func save(_ entity: Entity) async throws
    func fetch(id: Entity.ID) async throws -> Entity?
    func fetchAll() async throws -> [Entity]
    func delete(id: Entity.ID) async throws
}
