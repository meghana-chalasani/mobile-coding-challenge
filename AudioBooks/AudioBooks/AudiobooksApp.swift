import SwiftUI

@main
struct AudiobooksApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            PodcastHomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
