import Foundation
import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack {
            Text(Constants.errorTextMessage)
                .font(.title)
                .bold()
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {
                retryAction()
            }, label: {
                Text(Constants.retryButtonText)
                    .frame(width: 100, height: 40)
                    .bold()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .padding(.top)
        }
    }
}

private struct Constants {
    static let errorTextMessage = "An error occurred"
    static let retryButtonText = "Retry"
}
