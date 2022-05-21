import SwiftUI

struct HelpAboutView: View {

    @State var showPixKeyCopiedAlert: Bool = false
    @State var showUnableToOpenPodcastsAppAlert: Bool = false
    
    let pixKey: String = "918bd609-04d1-4df6-8697-352b62462061"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? String()
    let buildVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? String()

    var body: some View {
        VStack {
            ScrollView {
                Text("\(soundData.count) sons")
                    .padding(.bottom)
                
                VStack(alignment: .center, spacing: 40) {
                    HStack(spacing: 15) {
                        Image(systemName: "questionmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                        
                        Text("Para compartilhar um som, toque e segure por 2 segundos.")
                    }
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**. Ouça no seu tocador de podcasts favorito.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            let podcastLinkOnApplePodcasts = "https://podcasts.apple.com/br/podcast/medo-e-del%C3%ADrio-em-bras%C3%ADlia/id1502134265"
                            let podcastAppUrl = URL(string: podcastLinkOnApplePodcasts)!
                            if UIApplication.shared.canOpenURL(podcastAppUrl) {
                                UIApplication.shared.open(podcastAppUrl)
                            } else {
                                showUnableToOpenPodcastsAppAlert = true
                            }
                        }) {
                            Text("Ver no Apple Podcasts")
                                .font(.callout)
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
                        Text("Ô, cara, aproveita que tá aqui e paga uma 🍺 por Pix pro desenvolvedor, morô, cara:".uppercased())
                            .font(.callout)
                            .bold()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            UIPasteboard.general.string = pixKey
                            showPixKeyCopiedAlert = true
                        }) {
                            Text(pixKey)
                                .font(.footnote)
                                .bold()
                        }
                        .tint(.blue)
                        .controlSize(.large)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        .padding(.top)
                        .alert(isPresented: $showPixKeyCopiedAlert) {
                            Alert(title: Text("Chave copiada com sucesso!"), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("🧑‍💻 Quer contribuir ou entender como o app funciona? Acesse o código fonte:")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            let githubUrl = URL(string: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")!
                            UIApplication.shared.open(githubUrl)
                        }) {
                            Text("Ver projeto no GitHub")
                        }
                        .tint(.gray)
                        .controlSize(.large)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .padding(.top)
                    }
                    
                    Spacer()
                }
            }
            
            VStack(spacing: 15) {
                Text("Criado por @claycon_")
                
                Text("Versão \(appVersion) Build \(buildVersionNumber)")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
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
