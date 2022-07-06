import SwiftUI

struct PodcastAuthorsView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**. Ouça no seu agregador de podcasts preferido e apoie o projeto.")
                .multilineTextAlignment(.center)
            
            HStack {
                Button() {
                    
                }
            }
        }
    }

}

struct PodcastAuthorsView_Previews: PreviewProvider {

    static var previews: some View {
        PodcastAuthorsView()
    }

}
