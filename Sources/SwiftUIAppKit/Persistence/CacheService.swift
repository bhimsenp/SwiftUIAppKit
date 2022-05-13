import Foundation
import CoreData
import UIKit

public class CacheService {
    private let dateProvider: DateProvider
    public static let shared = CacheService()

    lazy var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle(for: CacheService.self).url(forResource: "Cache", withExtension: "momd")!
        let container = NSPersistentContainer(name: "Cache", managedObjectModel: NSManagedObjectModel(contentsOf: modelURL)!)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var currentContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()

    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }

    convenience init() {
        self.init(dateProvider: DateProvider())
    }

    public func setCache(withKey key: String, data: Data, expiryInMinutes: Int = 60) async {
        let context = currentContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cache")
        fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        do {
            let result = try context.fetch(fetchRequest)
            result.forEach { e in
                context.delete(e)
            }
            let entity = CacheEntity(entity: NSEntityDescription.entity(forEntityName: "Cache", in: context)!, insertInto: context)
            entity.key = key
            entity.data = data
            entity.expiresAt = dateProvider.currentDate().addingTimeInterval(TimeInterval(expiryInMinutes * 60))
            context.insert(entity)
        } catch {
            debugPrint(error)
        }
        saveContext(context)
    }

    public func setCache<T: Encodable>(withKey key: String, obj: T, expiryInMinutes: Int = 60) async {
        do {
            let data = try PropertyListEncoder().encode(obj)
            await setCache(withKey: key, data: data, expiryInMinutes: expiryInMinutes)
        } catch {
            debugPrint(error)
        }
    }

    public func getCached(forKey key: String) async -> Data? {
        let context = currentContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cache")
        fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        do {
            let result = try context.fetch(fetchRequest)
            if let cachedEntity = result.first, let data = cachedEntity.value(forKey: "data") as? Data {
                let date = cachedEntity.value(forKey: "expiresAt") as! Date
                if date < dateProvider.currentDate() {
                    context.delete(cachedEntity)
                    saveContext(context)
                    return nil
                }
                return data
            }
            return nil
        } catch {
            return nil
        }
    }

    public func getCached<T: Decodable>(for key: String) async -> T? {
        do {
            let data = await getCached(forKey: key)
            guard let decoded = data else {
                return nil
            }
            return try PropertyListDecoder().decode(T.self, from: decoded)
        } catch {
            return nil
        }
    }

    public func invalidateCache(withKey key: String, context: NSManagedObjectContext? = nil) async {
        let context = context ?? currentContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cache")
        fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        do {
            let result = try context.fetch(fetchRequest)
            for object in result {
                context.delete(object)
            }
            saveContext(context)
        } catch {
            debugPrint(error)
        }
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint(error)
            }
        }
    }
}

public class CacheEntity: NSManagedObject {
}

extension CacheEntity {
    @NSManaged public var key: String
    @NSManaged public var data: Data?
    @NSManaged public var expiresAt: Date
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<CacheEntity> {
        return NSFetchRequest<CacheEntity>(entityName: "Cache")
    }
    func isExpired(dateProvider: DateProvider) -> Bool { expiresAt < dateProvider.currentDate() }
}

class DateProvider {
    func currentDate() -> Date { Date() }
}
