import Foundation

struct HNResponse: Codable {
    let hits: [HNHit]
}

struct HNHit: Codable {
    let objectID: String
    let title: String?
    let url: String?
    let created_at: String?
    let author: String?
    let points: Int?
}

struct NewsArticle: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let link: URL?
    let pubDate: String
}
