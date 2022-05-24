import SwiftUI

struct SettingsView: View {

    @State private var showPixKeyCopiedAlert: Bool = false
    @State private var showUnableToOpenPodcastsAppAlert: Bool = false
    @State private var showExplicitSounds: Bool = UserSettings.getShowOffensiveSounds()
    @State private var showExplicitSoundsConfirmationAlert: Bool = false
    
    let pixKey: String = "918bd609-04d1-4df6-8697-352b62462061"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let buildVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 40) {
                        Toggle("Exibir conteúdo sensível", isOn: $showExplicitSounds)
                            .padding(.horizontal)
                            .onChange(of: showExplicitSounds) { newValue in
                                showExplicitSoundsConfirmationAlert = newValue
                                UserSettings.setShowOffensiveSounds(to: newValue)
                            }
                            .alert(isPresented: $showExplicitSoundsConfirmationAlert) {
                                Alert(title: Text("Use Com Responsabilidade, Morô, Cara?"), message: Text("Alguns conteúdos contam com muitos palavrões, o que pode incomodar algumas pessoas.\n\nAo marcar essa opção, você concorda que tem mais de 18 anos e que deseja ver esse conteúdo."), dismissButton: .default(Text("OK")))
                            }
                            .padding(.bottom, -10)
                        
                        //Divider()
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**. Ouça no seu tocador de podcasts favorito.")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
//                            Button(action: {
//                                let podcastLinkOnApplePodcasts = "https://podcasts.apple.com/br/podcast/medo-e-del%C3%ADrio-em-bras%C3%ADlia/id1502134265"
//                                let podcastAppUrl = URL(string: podcastLinkOnApplePodcasts)!
//                                if UIApplication.shared.canOpenURL(podcastAppUrl) {
//                                    UIApplication.shared.open(podcastAppUrl)
//                                } else {
//                                    showUnableToOpenPodcastsAppAlert = true
//                                }
//                            }) {
//                                Text("Ver no Apple Podcasts")
//                                    .font(.callout)
//                            }
//                            .tint(.purple)
//                            .controlSize(.large)
//                            .buttonStyle(.bordered)
//                            .buttonBorderShape(.roundedRectangle)
//                            .padding(.top)
//                            .alert(isPresented: $showUnableToOpenPodcastsAppAlert) {
//                                Alert(title: Text("Não Pôde Abrir o App Podcasts"), message: Text("Por favor, procure pelo app Podcasts no seu iPhone para continuar."), dismissButton: .default(Text("OK")))
//                            }
                        }
                        
                        //Divider()
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("Dinheiro! Aqui aceitas Pix. Qualquer R$ 1 ajuda o desenvolvedor a manter isso aqui. 💵⬇️")
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
                        
                        VStack(spacing: 15) {
                            Text("Criado por @claycon_")
                            
                            Text("Versão \(appVersion) Build \(buildVersionNumber)")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Ajustes")
        }
    }

}

struct AboutView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsView()
    }

}
