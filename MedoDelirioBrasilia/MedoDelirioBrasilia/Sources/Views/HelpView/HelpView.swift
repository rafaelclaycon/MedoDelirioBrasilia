import SwiftUI

struct HelpAboutView: View {

    var body: some View {
        VStack {
            ScrollView {                
                VStack(alignment: .center, spacing: 40) {
                    HStack(spacing: 15) {
                        Image(systemName: "questionmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                        
                        Text("Para compartilhar um som, toque e segure por 2 segundos.")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Ajuda")
    }

}

struct HelpAboutView_Previews: PreviewProvider {

    static var previews: some View {
        HelpAboutView()
    }

}
