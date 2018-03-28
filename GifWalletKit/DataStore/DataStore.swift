//
//  Created by Pierluigi Cifani on 28/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import CoreData
import Deferred

public class DataStore {

    private let persistentStore: NSPersistentContainer
    public var storeIsReady: Bool = false

    public init(kind: Kind = .sqlite) {
        guard
            let path = Bundle(for: DataStore.self).path(forResource: "Model", ofType: "momd"),
            let model = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError()
        }

        persistentStore = NSPersistentContainer(
            name: "GifModel",
            managedObjectModel: model
        )

        let description = NSPersistentStoreDescription()
        description.type = kind.coreDataRepresentation
        persistentStore.persistentStoreDescriptions = [description]
    }

    public func loadAndMigrateIfNeeded() -> Task<()> {
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
    func createGIF(giphyID: String, title: String, subtitle: String, url: URL, tags: Set<String>) -> Task<()> {
        let deferred = Deferred<TaskResult<()>>()
        guard self.storeIsReady else {
            deferred.fill(with: TaskResult<()>(failure: DataStore.Error.dataStoreNotInitialized))
            return Task(deferred)
        }

        self.persistentStore.performBackgroundTask { (moc) in
            let managedGIF = ManagedGIF(entity: ManagedGIF.entity(), insertInto: moc)
            managedGIF.title = title
            managedGIF.subtitle = subtitle
            managedGIF.remoteURL = url.absoluteString
            managedGIF.giphyID = giphyID
            managedGIF.creationDate = Date()

            do {
                try moc.save()
                deferred.fill(with: .init(success: ()))
            } catch let error {
                deferred.fill(with: .init(failure: error))
            }
        }
        return Task(deferred)
    }

    func fetchGIF(id: String) throws -> ManagedGIF? {
        guard self.storeIsReady else {
            throw DataStore.Error.dataStoreNotInitialized
        }

        let fetchRequest: NSFetchRequest<ManagedGIF> = ManagedGIF.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "giphyID == %@", id)
        let managedGIFs = try self.persistentStore.viewContext.fetch(fetchRequest)
        return managedGIFs.first
    }
}


extension DataStore {

    public enum Kind {
        case sqlite
        case memory
    }

    public enum Error: Swift.Error {
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
