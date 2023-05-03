import SwiftUI

struct PodcastRowTitleView: View {
    let podcast: Podcast

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(podcast.title)
                .multilineTextAlignment(.leading)
                .bold()
                .foregroundColor(.black)

            Text(podcast.publisher)
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .italic()
                .foregroundColor(.secondary)
        }
    }
}

struct PodcastRowImageView: View {
    let podcast: Podcast

    var body: some View {
        Group {
            if let data = podcast.thumbnailImageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Color.gray
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
        }
    }
}
