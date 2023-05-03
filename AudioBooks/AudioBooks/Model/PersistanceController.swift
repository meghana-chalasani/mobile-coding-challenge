import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: Constants.containerName )
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: Constants.fileURL )
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("\(Constants.fatalError) \(error), \(error.userInfo)")
            }
        })
    }
}
private struct Constants {
   static let containerName = "PodcastModel"
   static let fileURL = "/dev/null"
    static let fatalError = "Unresolved error"
}
