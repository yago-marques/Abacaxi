public protocol PersistentStoring {
    associatedtype Entity: PersistentEntity

    func save(_ entity: Entity) throws
    func fetch(id: Entity.ID) throws -> Entity?
    func fetchAll() throws -> [Entity]
    func delete(id: Entity.ID) throws
}
