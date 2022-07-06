import SwiftUI

struct PodcastAuthorsView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**. Ouça no seu agregador de podcasts preferido e apoie o projeto.")
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button {
                    guard let url = URL(string: "https://apoia.se/medoedelirio") else { return }
                    UIApplication.shared.open(url)
                } label: {
                    Text("APOIA.se")
                        .bold()
                        .padding(.horizontal)
                }
                .tint(.red)
                .controlSize(.large)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                
                Button {
                    guard let url = URL(string: "https://app.picpay.com/user/medoedelirioembrasilia") else { return }
                    UIApplication.shared.open(url)
                } label: {
                    Text("PicPay")
                        .bold()
                        .padding(.horizontal)
                }
                .tint(.green)
                .controlSize(.large)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
    }

}

struct PodcastAuthorsView_Previews: PreviewProvider {

    static var previews: some View {
        PodcastAuthorsView()
    }

}
