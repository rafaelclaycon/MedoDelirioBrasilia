import SwiftUI

struct ProcessingView: View {

    @State var message: String
    @State var progressViewYOffset: CGFloat = -20
    @State var progressViewWidth: CGFloat = 200
    @State var messageYOffset: CGFloat = 33
    
    var body: some View {
        ZStack {
            ProgressView()
                .scaleEffect(2, anchor: .center)
                .frame(width: progressViewWidth, height: 140)
                .offset(x: 0, y: progressViewYOffset)
                .background(.regularMaterial)
                .cornerRadius(25)
            
            Text(message)
                .offset(x: 0, y: messageYOffset)
                .multilineTextAlignment(.center)
        }
    }

}

struct ProcessandoView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            //ProcessingView(message: Shared.ShareAsVideo.generatingVideoShortMessage).preferredColorScheme($0)
            ProcessingView(message: Shared.ShareAsVideo.generatingVideoLongMessage, progressViewYOffset: -27, progressViewWidth: 270, messageYOffset: 30).preferredColorScheme($0)
        }
        .previewLayout(.fixed(width: 375, height: 400))
    }

}
