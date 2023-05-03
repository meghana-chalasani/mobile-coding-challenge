import Foundation

protocol PodcastFetcherProtocol {
    func fetchAllPodcasts(page: Int, completion: @escaping (Result<Podcasts, Error>) -> Void)
    func fetchPodcastImageData(for podcast: Podcast, completion: @escaping (Data?) -> Void)
}

class PodcastFetcher: PodcastFetcherProtocol {
    let baseURL: URL

    init(baseURL: URL = URL(string: Constants.baseURL)!) {
          self.baseURL = baseURL
    }

    func fetchAllPodcasts(page: Int, completion: @escaping (Result<Podcasts, Error>) -> Void) {
        let queryParams = [Constants.queryPageParam: String(page)]
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }

      if let url = components?.url {
          URLSession.shared.dataTask(with: url) { data, _, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }

              guard let data = data else {
                  print(Constants.noData)
                  return
              }

              do {
                  let decoder = JSONDecoder()
                  let podcasts = try decoder.decode(Podcasts.self, from: data)
                  completion(.success(podcasts))
              } catch {
                  completion(.failure(error))
              }
          }.resume()
      } else {
          print(Constants.invalidURL)
      }
    }

    func fetchPodcastImageData(for podcast: Podcast, completion: @escaping (Data?) -> Void) {
       if let url = URL(string: podcast.thumbnailURL) {
           URLSession.shared.dataTask(with: url) { data, _, _ in
               completion(data)
           }.resume()
       } else {
           completion(nil)
       }
    }
}

private struct Constants {
    static var baseURL = "https://listen-api-test.listennotes.com/api/v2/best_podcasts"
    static var queryPageParam = "page"
    static var noData = "No data received"
    static var invalidURL = "Invalid URL"
}
