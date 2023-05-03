import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel = PodcastsViewModel()
    @Binding var podcast: Podcast
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .center) {
            podcastHeaderAndImageView
            favouriteButtonView
            descriptionTextView
        }
        Spacer()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .foregroundColor(.black)
    }

    private var podcastHeaderAndImageView: some View {
        VStack {
            podcastHeaderView
            if let data = podcast.thumbnailImageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 240, height: 240)
                    .cornerRadius(10)
            } else {
                Color.gray
                    .frame(width: 240, height: 240)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 8)
        .padding(.top, 15)
    }

    private var favouriteButtonView: some View {
        Button {
            podcast.isFavourite?.toggle()
            viewModel.updateFavouriteStatus(for: podcast.id, isFavourite: podcast.isFavourite ?? false)
        } label: {
            let isFavorite = podcast.isFavourite ?? false
            let favouriteText = isFavorite ? Constants.favouritedText : Constants.favouriteText
            Text(favouriteText)
                .frame(width: 100, height: 40)
                .bold()
                .foregroundColor(.white)
                .background(Color.pink)
                .cornerRadius(10)
        }
        .padding(.bottom, 10)
    }

    private var descriptionTextView: some View {
        Text(podcast.description)
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: Constants.backArrowSystemKey)
                Text(Constants.backNavigationText)
                    .bold()
            }
        })
    }

    private var podcastHeaderView: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(podcast.title)
                .bold()
                .foregroundColor(.black)
                .font(.system(size: 20))
            Text(podcast.publisher)
                .lineLimit(1)
                .italic()
                .foregroundColor(.secondary)
        }
    }
}

private struct Constants {
    static let backNavigationText = "Back"
    static let backArrowSystemKey = "chevron.left"
    static let favouritedText = "Favourited"
    static let favouriteText = "Favourite"
}
