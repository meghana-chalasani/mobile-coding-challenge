import Foundation
import UIKit

struct Podcasts: Decodable {
    let hasNext: Bool?
    let podcasts: [Podcast]

    enum CodingKeys: String, CodingKey {
        case hasNext = "has_next"
        case podcasts
    }
}

struct Podcast: Decodable, Identifiable {
    let uuid: UUID = UUID()
    let id: String
    let thumbnailURL: String
    let title: String
    let publisher: String
    var description: String
    var thumbnailImageData: Data?
    var isFavourite: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case thumbnailURL = "thumbnail"
        case title
        case publisher
        case description
        case thumbnailImageData
        case isFavourite
    }
}
