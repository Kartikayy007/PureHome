import Foundation
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let feedURL = URL(string: "https://hn.algolia.com/api/v1/search?query=climate%20environment&tags=story")!
    
    func fetchNews() async {
        isLoading = true
        errorMessage = nil
        do {
            var request = URLRequest(url: feedURL)
            request.setValue("Mozilla/5.0 (PureHome App)", forHTTPHeaderField: "User-Agent")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(HNResponse.self, from: data)
            
            self.articles = decoded.hits.compactMap { hit in
                guard let title = hit.title, !title.isEmpty else { return nil }
                return NewsArticle(
                    id: hit.objectID,
                    title: title,
                    description: "Published by \(hit.author ?? "Unknown Reporter") • \(hit.points ?? 0) upvotes",
                    link: hit.url.flatMap { URL(string: $0) },
                    pubDate: String((hit.created_at ?? "").prefix(10))
                )
            }
        } catch {
            self.errorMessage = "Failed to load environment news: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
