import SwiftUI

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "f9f9fe")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView("Fetching Environmental News...")
                                .padding(40)
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(40)
                        } else {
                            ForEach(viewModel.articles) { article in
                                NewsCard(article: article)
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Environment News")
            .onAppear {
                Task {
                    await viewModel.fetchNews()
                }
            }
        }
    }
}

struct NewsCard: View {
    let article: NewsArticle
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: {
            if let link = article.link {
                openURL(link)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Text(article.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(article.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "40493d"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    Text(article.pubDate)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "arrow.up.forward.square")
                        .foregroundColor(Color(hex: "0d631b"))
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 40, x: 0, y: 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
