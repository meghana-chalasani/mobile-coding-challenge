import SwiftUI

struct PodcastHomeView: View {
    @ObservedObject var viewModel = PodcastsViewModel()
    @State private var hasAppeared = false

    var body: some View {
        NavigationView {
            if viewModel.error != nil {
                errorView
            } else {
                Group {
                    if viewModel.podcasts.isEmpty {
                        skeletonView
                    } else {
                        podcastScrollView
                        .refreshable {
                            viewModel.fetchInitialPodcasts()
                        }
                    }
                }
            .navigationBarItems(leading: headingText)
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let error = viewModel.error {
            ErrorView(error: error) {
                viewModel.fetchInitialPodcasts()
            }
        }
    }

    private var skeletonView: some View {
        SkeletonView()
        .onAppear {
            if !hasAppeared {
                viewModel.fetchInitialPodcasts()
                hasAppeared = true
            }
        }
    }

    private var podcastScrollView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(Array(viewModel.podcasts.enumerated()), id: \.element.uuid) { (index, podcast) in
                    HStack {
                        NavigationLink(destination: PodcastDetailView(viewModel: viewModel,
                                                                      podcast: $viewModel.podcasts[index])) {
                            PodcastRowImageView(podcast: podcast)
                                .padding(.trailing, 5)
                            VStack(alignment: .leading, spacing: 10) {
                                PodcastRowTitleView(podcast: podcast)
                                if let isFavorite = podcast.isFavourite, isFavorite {
                                    Text(Constants.favouriteText)
                                        .foregroundColor(.pink)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    .onAppear {
                        if (index + 1) % 10 == 0 && (index + 1) == viewModel.podcasts.count {
                            viewModel.fetchMorePodcastsIfNeeded(currentIndex: index)
                        }
                    }
                    Divider()
                }
            }
            .padding(.leading, 25)
        }
    }

    private var headingText: some View {
        Text(Constants.headingText)
            .font(.system(size: 20))
            .bold()
            .padding(.leading, 5)
    }
}

private struct Constants {
    static let headingText = "Podcasts"
    static let favouriteText = "Favourited"
}
