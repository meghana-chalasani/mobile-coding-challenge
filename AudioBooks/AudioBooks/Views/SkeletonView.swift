import Foundation
import SwiftUI

struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<7) { _ in
                HStack {
                    imageView
                    titleAndPublisherView
                }
                Divider()
            }
        Spacer()
        }
        .padding([.leading, .bottom], 25)
        .padding(.top)
    }

    private var titleAndPublisherView: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 150, height: 15)
                .foregroundColor(Color(.lightGray))
                .padding(.bottom, 10)
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 100, height: 15)
                .foregroundColor(Color(.lightGray))
                .padding(.bottom)
        }
    }

    private var imageView: some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(width: 80, height: 80)
            .foregroundColor(Color(.lightGray))
            .padding(.trailing)
    }
}
