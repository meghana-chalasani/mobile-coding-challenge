import Foundation
import CoreData

class PodcastsViewModel: ObservableObject {
    @Published var podcasts: [Podcast] = []
    private var apiFetcher: PodcastFetcherProtocol
    private let container: NSPersistentContainer
    @Published var hasMorePodcasts: Bool = false
    @Published var error: Error?

    init(apiFetcher: PodcastFetcherProtocol = PodcastFetcher(),
         container: NSPersistentContainer = PersistenceController.shared.container) {
       self.apiFetcher = apiFetcher
       self.container = container
       self.container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func savePodcastIdToFavourites(_ podcast: Podcast) {
       let favouritePodcast = FavouritePodcast(context: container.viewContext)
       favouritePodcast.id = podcast.id

       do {
           try container.viewContext.save()
       } catch {
           print("\(Constants.savingPodcastIDErrorTitle) \(error.localizedDescription)")
       }
    }

    private func removePodcastIdFromFavourites(_ podcast: Podcast) {
        let fetchRequest: NSFetchRequest<FavouritePodcast> = FavouritePodcast.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: Constants.podcastIDFormat, podcast.id)
        do {
            let podcastsToDelete = try container.viewContext.fetch(fetchRequest)
            for podcastToDelete in podcastsToDelete {
                container.viewContext.delete(podcastToDelete)
            }
            try container.viewContext.save()
        } catch {
            print("\(Constants.removingPodcastIDErrorTitle) \(error.localizedDescription)")
        }
    }

    func fetchInitialPodcasts() {
        self.podcasts = []
        fetchPodcasts(page: 1)
    }

    private func fetchPodcasts(page: Int) {
        DispatchQueue.global().async { [weak self] in
            self?.apiFetcher.fetchAllPodcasts(page: page) { result in
                switch result {
                case .success(let podcasts):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.hasMorePodcasts = podcasts.hasNext ?? false

                        let mappedPodcasts = podcasts.podcasts.prefix(10).map { podcast in
                            var tempPodcast = podcast
                            tempPodcast.description = self.htmlToString(html: tempPodcast.description)
                            tempPodcast.isFavourite = false
                            return tempPodcast
                        }
                        self.podcasts.append(contentsOf: mappedPodcasts)
                        updateFavorites()
                        updateImageData(podcasts: mappedPodcasts)
                        }
                case .failure(let error):
                    print("\(Constants.fetchingPodcastsErrorTitle) \(error)")
                    DispatchQueue.main.async {
                        self?.error = error
                    }
                }
            }
        }
    }

    private func updateImageData(podcasts: [Podcast]) {
        podcasts.forEach { podcast in
            self.apiFetcher.fetchPodcastImageData(for: podcast) { data in
                if let data = data {
        DispatchQueue.main.async {
            self.updatePodcastImageData(for: podcast, with: data)
                    }
                }
            }
        }
    }

    private func updatePodcastImageData(for podcast: Podcast, with data: Data) {
        guard let index = podcasts.firstIndex(where: { $0.uuid == podcast.uuid }) else { return }

        podcasts[index].thumbnailImageData = data
    }

    private func updateFavorites() {
        let fetchRequest: NSFetchRequest<FavouritePodcast> = FavouritePodcast.fetchRequest()
        do {
            let favouritePodcasts = try self.container.viewContext.fetch(fetchRequest)
            for (index, podcast) in self.podcasts.enumerated() {
                self.podcasts[index].isFavourite = favouritePodcasts.contains(where: { $0.id == podcast.id })
            }
        } catch {
            print("\(Constants.fetchingFavouritePodcastsErrorTitle) \(error.localizedDescription)")
        }
    }

    func fetchMorePodcastsIfNeeded(currentIndex: Int) {
        guard hasMorePodcasts, currentIndex >= 9 else { return }

        let pageNumber: Int = ((currentIndex + 1) / 10) + 1
        fetchPodcasts(page: pageNumber)
    }

    func updateFavouriteStatus(for id: String, isFavourite: Bool) {
       guard let index = podcasts.firstIndex(where: { $0.id == id }) else { return }

       self.podcasts[index].isFavourite = isFavourite
       if isFavourite {
           savePodcastIdToFavourites(podcasts[index])
       } else {
           removePodcastIdFromFavourites(podcasts[index])
       }
    }

    private func htmlToString(html: String) -> String {
        guard let data = html.data(using: .utf8),
              let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) else { return html }

        return attributedString.string
    }
}

extension FavouritePodcast {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouritePodcast> {
        return NSFetchRequest<FavouritePodcast>(entityName: Constants.entityName )
    }
}

private struct Constants {
    static let savingPodcastIDErrorTitle = "Error saving podcast id to CoreData:"
    static let podcastIDFormat = "id == %@"
    static let removingPodcastIDErrorTitle = "Error removing podcast id from CoreData:"
    static let fetchingFavouritePodcastsErrorTitle = "Error fetching favourite podcasts from CoreData:"
    static let fetchingPodcastsErrorTitle = "Error fetching podcasts:"
    static let entityName = "FavouritePodcast"
}
