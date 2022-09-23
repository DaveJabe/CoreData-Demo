//
//  CoreDataManager.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/1/22.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    // MARK: - Properties
    
    // This closure is implemented by the ViewModel, and ensures the ViewController's tableView is reloaded any time there are changes to the data
    var dataWasFetched: ((Result<[Group], Error>) -> Void)?
    
    var toDosWereFetched: ((Result<[ToDo], Error>) -> Void)?
    
    // Singleton instance
    static let shared = CoreDataManager()
    
    private var importContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
    
    // private var importContext: NS
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataKey.containerName)
        
        container.loadPersistentStores { _, error in
            guard error == nil else {
                print(CoreDataError.loadPersistentStoresError,"\(String(describing: error))")
                return
            }
        }
        return container
    }()
    
    private lazy var controller: NSFetchedResultsController<Group> = {
        let controller = NSFetchedResultsController<Group>(fetchRequest: Group.fetchRequest(),
                                                           managedObjectContext: container.viewContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        return controller
    }()
    
    // MARK: - Init
    
    override init() {
        super.init()
        controller.delegate = self
        container.viewContext.automaticallyMergesChangesFromParent = true
        importContext = container.newBackgroundContext()
        // importContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
// MARK: - Methods
    
    func saveContext() {
        let context = container.viewContext
        
        do {
            try context.save()
        }
        catch(let error) {
            print(CoreDataError.saveContextError, error.localizedDescription)
        }
    }
    
    func removeEntity(entity: NSManagedObject) {
        container.viewContext.delete(entity)
        saveContext()
    }
    
    // MARK: - ToDo Methods
    
    func fetchToDoDataFromAPI(completion: @escaping (Error?) -> Void) {
        
        importContext.perform {  [weak self] in
            
            if Thread.isMainThread {
                print("we on the main thread")
            }
            else {
                print("we not on the main thread")
            }
            
            APIHandler.shared.fetchData(urlString: URLString.toDoUrl) { (result: Result<Data, Error>) in
                guard let self = self else {
                    return
                }
                switch result {
                    
                case .success(let data):
                    do {
                        let decoder = JSONDecoder(context: self.importContext)
                        
                        let request = ToDo.fetchRequest()
                        
                        let toDos = try self.importContext.fetch(request)
                    
                        let newToDos = try decoder.decode([ToDo].self, from: data)
                        
                        for newToDo in newToDos {
                            if toDos.contains(where: { $0.id == newToDo.id }) {
                                self.importContext.delete(newToDo) // deleting duplicates
                            }
                        }
                        
                        try? self.importContext.save() // saving changes
                        
                        completion(nil)
                    }
                    catch(let decodingError) {
                        completion(decodingError)
                    }
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }
    
    func fetchToDoData() {
        
        // Using this instead of container.performBackgroundTask
        importContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            if Thread.isMainThread {
                print("we on the main thread")
            }
            else {
                print("we not on the main thread")
            }
            
            do {
                let request = ToDo.fetchRequest()
                let toDos = try self.importContext.fetch(request)
                self.toDosWereFetched?(.success(toDos))
            }
            catch(let error) {
                self.toDosWereFetched?(.failure(error))
            }
        }
    }
    
    func deleteAllToDoData(completion: @escaping (Error?) -> Void) {
        container.performBackgroundTask { context in
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: ToDo.fetchRequest())
            
            do {
                try context.execute(deleteRequest)
                completion(nil)
            }
            catch(let error) {
                completion(error.localizedDescription)
            }
        }
    }
    
    func updateToDoItem(_ toDo: ToDo, newTitle: String, newCompletionStatus: Bool) {
        toDo.title = newTitle
        toDo.completed = newCompletionStatus
        do {
            try importContext.save()
        }
        catch(let error) {
            print(error)
        }
    }
    
    func removeToDoItem(_ toDo: ToDo) {
        importContext.delete(toDo)
        do {
            try importContext.save()
        }
        catch(let error) {
            print(error)
        }
    }
    
    
    // MARK: - Group/Person Methods
    
    func fetchData() {
        do {
            try controller.performFetch()
            guard let groups = controller.fetchedObjects else {
                dataWasFetched?(.failure(CoreDataError.fetchObjectsError))
                return
            }
            dataWasFetched?(.success(groups))
        }
        catch(let error) {
            dataWasFetched?(.failure(error))
        }
    }
    
    func updatePerson(_ entity: NSManagedObject, name: String, address: String) {
        entity.setValue(name, forKey: CoreDataKey.personName)
        entity.setValue(address, forKey: CoreDataKey.personAddress)
        saveContext()
    }
    
    // MARK: Group methods
    
    func insertNewGroup(name: String) {
        
        let context = container.viewContext
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = context
        
        privateContext.performAndWait {
            let newGroup = Group(context: context)
            newGroup.name = name
            
            try? context.save()
        }
    }
    
    // MARK: Person methods
    
    func insertNewPerson(name: String, address: String, groupID: NSManagedObjectID) {
        
        let context = container.viewContext
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType) // Creating private, concurrent context to add item from background thread
        privateContext.parent = context // Making the viewContext the parent of the privateContext to automatically merge changes from background context to main context
        
        privateContext.performAndWait {
            
            // We can't just pass in the group from a separate context because that would crash our app; instead, we access it from this background context via its objectID (NSManagedObjectID)
            guard let groupInThisContext = context.object(with: groupID) as? Group else {
                print(CoreDataError.invalidObjectID)
                return
            }
            
            if Thread.isMainThread {
                print("on main thread") // even though we're in a private context (queue), we're still on the main thread
            }
            else {
                print("off main thread")
            }
            
            let newPerson = Person(context: context)
            newPerson.name = name
            newPerson.address = address
            newPerson.group = groupInThisContext
            
            try? context.save()
        }
    }
    
    
    /* Initially, this func didn't work because the private context and view context were completely unaware of each other.
     To get it to work, I just had to set viewContext.automaticallyMergesChangesFromParent = true                     */
    func insertNewPerson2(name: String, address: String, groupID: NSManagedObjectID) {
        
        // creates an ephemeral (temporary) private context to execute background tasks
        container.performBackgroundTask { context in
            guard let groupInThisContext = context.object(with: groupID) as? Group else {
                return
            }
            
            if Thread.isMainThread {
                print("on main thread")
            }
            else {
                print("off main thread") // this will print because we're on a background queue
            }
            
            let newPerson = Person(context: context)
            newPerson.name = name
            newPerson.address = address
            newPerson.group = groupInThisContext
            
            try? context.save()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CoreDataManager: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let groups = controller.fetchedObjects as? [Group] else {
            dataWasFetched?(.failure(CoreDataError.fetchObjectsError))
            return
        }
        dataWasFetched?(.success(groups))
    }
}
