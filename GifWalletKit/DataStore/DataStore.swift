//
//  Created by Pierluigi Cifani on 28/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import CoreData
import Deferred

public class DataStore {

    private let persistentStore: NSPersistentContainer
    public var storeIsReady: Bool = false

    public init(kind: Kind = .sqlite, shouldLoadAsync: Bool = true) {
        guard
            let path = Bundle(for: DataStore.self).path(forResource: "Model", ofType: "momd"),
            let model = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError()
        }

        persistentStore = NSPersistentContainer(
            name: "GifModel",
            managedObjectModel: model
        )

        let description = NSPersistentStoreDescription(url: {
            let storeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return storeDirectory.appendingPathComponent("GifModel.sqlite")
        }())
        description.type = kind.coreDataRepresentation
        description.shouldAddStoreAsynchronously = shouldLoadAsync
        persistentStore.persistentStoreDescriptions = [description]
    }

    public func loadAndMigrateIfNeeded() -> Task<()> {
        guard !self.storeIsReady else {
            return Task(success: ())
        }
        
        let deferred = Deferred<TaskResult<()>>()
        persistentStore.loadPersistentStores { (description, error) in
            if let error = error {
                deferred.fill(with: TaskResult<()>(failure: error))
            } else {
                self.storeIsReady = true
                deferred.fill(with: TaskResult<()>(success: ()))
            }
        }
        return Task(deferred)
    }

    //MARK: GIF Creation
    public func createGIF(giphyID: String, title: String, subtitle: String, url: URL, tags: Set<String>) -> Task<()> {
        let deferred = Deferred<TaskResult<()>>()
        guard self.storeIsReady else {
            deferred.fill(with: TaskResult<()>(failure: DataStore.Error.dataStoreNotInitialized))
            return Task(deferred)
        }

        self.persistentStore.performBackgroundTask { (moc) in
            let managedGIF = self.fetchGIF(id: giphyID, moc: moc) ?? ManagedGIF(entity: ManagedGIF.entity(), insertInto: moc)
            managedGIF.title = title
            managedGIF.subtitle = subtitle
            managedGIF.remoteURL = url.absoluteString
            managedGIF.giphyID = giphyID
            managedGIF.creationDate = Date()

            let managedTags: [ManagedTag] = tags.map {
                if let managedTag = self.fetchTag(name: $0, moc: moc) {
                    return managedTag
                } else {
                    let managedTag = ManagedTag(entity: ManagedTag.entity(), insertInto: moc)
                    managedTag.name = $0
                    return managedTag
                }
            }

            managedTags.forEach {
                managedGIF.addToManagedTags($0)
            }

            do {
                try moc.save()
                deferred.fill(with: .init(success: ()))
            } catch let error {
                deferred.fill(with: .init(failure: error))
            }
        }
        return Task(deferred)
    }

    public func fetchGIF(id: String) throws -> ManagedGIF? {
        return self.fetchGIF(id: id, moc: self.persistentStore.viewContext)
    }

    public func fetchGIFs(withTag tag: String) throws -> Set<ManagedGIF> {
        return self.fetchTag(name: tag, moc: self.persistentStore.viewContext)?.gifs ?? []
    }

    public func fetchGIFsSortedByCreationDate() -> Task<[ManagedGIF]> {
        return self.fetchGIFsSortedByCreationDate(moc: self.persistentStore.viewContext)
    }

    //MARK: Private

    private func fetchGIFsSortedByCreationDate(moc: NSManagedObjectContext) -> Task<[ManagedGIF]> {
        assert(self.storeIsReady)
        let deferred = Deferred<TaskResult<[ManagedGIF]>>()

        let fetchRequest: NSFetchRequest<ManagedGIF> = ManagedGIF.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(ManagedGIF.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest, completionBlock: { (result) in
            guard let managedGIFs = result.finalResult else {
                let error: Swift.Error = result.operationError ?? Error.fetchFailed
                deferred.fill(with: TaskResult<[ManagedGIF]>.init(failure: error))
                return
            }
            deferred.fill(with: TaskResult<[ManagedGIF]>.init(success: managedGIFs))
        })

        do {
            try moc.execute(asyncFetchRequest)
        } catch let error {
            deferred.fill(with: TaskResult<[ManagedGIF]>.init(failure: error))
        }

        return Task(deferred)
    }

    private func fetchGIF(id: String, moc: NSManagedObjectContext) -> ManagedGIF? {
        assert(self.storeIsReady)
        let fetchRequest: NSFetchRequest<ManagedGIF> = ManagedGIF.fetchRequest()
        fetchRequest.predicate = NSPredicate(property: #keyPath(ManagedGIF.giphyID), value: id)
        let managedGIFs = try? moc.fetch(fetchRequest)
        return managedGIFs?.first
    }

    private func fetchTag(name: String, moc: NSManagedObjectContext) -> ManagedTag? {
        assert(self.storeIsReady)
        let fetchRequest: NSFetchRequest<ManagedTag> = ManagedTag.fetchRequest()
        fetchRequest.predicate = NSPredicate(property: #keyPath(ManagedTag.name), value: name)
        let managedTags = try? moc.fetch(fetchRequest)
        return managedTags?.first
    }
}

extension DataStore {

    public enum Kind {
        case sqlite
        case memory
    }

    public enum Error: Swift.Error {
        case fetchFailed
        case dataStoreNotInitialized
    }
}
extension DataStore.Kind {
    fileprivate var coreDataRepresentation: String {
        switch self {
        case .memory:
            return NSInMemoryStoreType
        case .sqlite:
            return NSSQLiteStoreType
        }
    }
}
