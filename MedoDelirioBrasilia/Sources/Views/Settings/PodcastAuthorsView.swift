import SwiftUI

struct PodcastAuthorsView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**.")
                .multilineTextAlignment(.center)
            
            Text("Ouça no seu agregador de podcasts preferido e apoie o projeto.")
                .multilineTextAlignment(.center)
            
            HStack(spacing: 24) {
                Button {
                    guard let url = URL(string: "https://apoia.se/medoedelirio") else { return }
                    UIApplication.shared.open(url)
                } label: {
                    Text("APOIA.se")
                        .bold()
                        .padding(.horizontal, UIDevice.is4InchDevice ? 4 : 6)
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
                        .padding(.horizontal, UIDevice.is4InchDevice ? 6 : 6)
                }
                .tint(.green)
                .controlSize(.large)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
            
            Button {
                guard let url = URL(string: "https://loja.medoedelirioembrasilia.com.br") else { return }
                UIApplication.shared.open(url)
            } label: {
                HStack(spacing: 15) {
                    Image(systemName: "bag.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                        .foregroundColor(.blue)
                    
                    Text("Compre na loja oficial")
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 24)
            }
            .controlSize(.regular)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
        }
    }

}

struct PodcastAuthorsView_Previews: PreviewProvider {

    static var previews: some View {
        PodcastAuthorsView()
    }

}
