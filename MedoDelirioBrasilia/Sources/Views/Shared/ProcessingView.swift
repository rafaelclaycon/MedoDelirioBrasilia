import SwiftUI

struct ProcessingView: View {

    @Binding var message: String
    
    var body: some View {
        ZStack {
            ProgressView()
                .scaleEffect(2, anchor: .center)
                .frame(width: 200, height: 140)
                .offset(x: 0, y: -20)
                .background(.regularMaterial)
                .cornerRadius(25)
            
            Text(message)
                .offset(x: 0, y: 33)
        }
    }

}

struct ProcessandoView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            ProcessingView(message: .constant("Inspecting link...")).preferredColorScheme($0)
        }
        .previewLayout(.fixed(width: 375, height: 400))
    }

}
