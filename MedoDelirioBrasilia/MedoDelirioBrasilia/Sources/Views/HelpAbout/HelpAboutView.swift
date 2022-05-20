import SwiftUI

struct HelpAboutView: View {

    @State var showPixKeyCopiedAlert: Bool = false
    @State var showUnableToOpenPodcastsAppAlert: Bool = false
    
    let cpf: String = "02066428060"

    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            HStack(spacing: 15) {
                Image(systemName: "questionmark.circle")
                    .font(.largeTitle)
                    .foregroundColor(.darkGreen)
                
                Text("Para compartilhar um som, toque e segure por 2 segundos.")
            }
            
            VStack(alignment: .center, spacing: 5) {
                Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**. Ouça no seu tocador de podcasts favorito.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Ouça no Apple Podcasts") {
                    let podcastLinkOnApplePodcasts = "https://podcasts.apple.com/br/podcast/medo-e-del%C3%ADrio-em-bras%C3%ADlia/id1502134265"
                    let podcastAppUrl = URL(string: podcastLinkOnApplePodcasts)!
                    if UIApplication.shared.canOpenURL(podcastAppUrl) {
                        UIApplication.shared.open(podcastAppUrl)
                    } else {
                        showUnableToOpenPodcastsAppAlert = true
                    }
                }
                .tint(.purple)
                .controlSize(.large)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .padding(.top)
                .alert(isPresented: $showUnableToOpenPodcastsAppAlert) {
                    Alert(title: Text("Não Pôde Abrir o App Podcasts"), message: Text("Por favor, procure pelo app Podcasts no seu iPhone para continuar."), dismissButton: .default(Text("OK")))
                }
            }
            
            VStack(alignment: .center, spacing: 5) {
                Text("Ô, cara, aproveita que tá aqui e paga uma 🍺 para o desenvolvedor por Pix, morô, cara.".uppercased())
                    .font(.callout)
                    .bold()
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(cpf) {
                    UIPasteboard.general.string = cpf
                    
                    showPixKeyCopiedAlert = true
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .padding(.top)
                .alert(isPresented: $showPixKeyCopiedAlert) {
                    Alert(title: Text("Chave copiada com sucesso!"), dismissButton: .default(Text("OK")))
                }
            }
            
            Spacer()
            
            Text("Criado por @claycon_")
        }
        .padding()
        .navigationTitle("Ajuda e Sobre")
    }

}

struct HelpAboutView_Previews: PreviewProvider {

    static var previews: some View {
        HelpAboutView()
    }

}
