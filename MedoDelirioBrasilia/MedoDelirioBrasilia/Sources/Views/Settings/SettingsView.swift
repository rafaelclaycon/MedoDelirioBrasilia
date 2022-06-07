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
                        
                        /*NavigationLink {
                            TrendsSettingsView()
                        } label: {
                            HStack {
                                Text("Ajustes das Tendências")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.forward")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 4)
                        
                        NavigationLink {
                            DiagnosticsView()
                        } label: {
                            HStack {
                                Text("Diagnóstico")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.forward")
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()*/
                        
                        Text("Esse app é uma homenagem ao brilhante trabalho de **Cristiano Botafogo** e **Pedro Daltro** no podcast **Medo e Delírio em Brasília**. Ouça no seu agregador de podcasts favorito.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("**Ô, CARA, APROVEITA QUE TÁ AQUI E PAGA UMA 🍺 PARA O DESENVOLVEDOR POR PIX, MORÔ, CARA.**")
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
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("Gostou do que viu?")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                guard let emailSubject = "Bora fechar negócio".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                                    return
                                }
                                guard let emailMessage = "Por favor, inclua um resumo do projeto, prazos e o investimento planejado.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                                    return
                                }
                                
                                let mailToString = "mailto:medodeliriosuporte@gmail.com?subject=\(emailSubject)&body=\(emailMessage)"
                                
                                guard let mailToUrl = URL(string: mailToString) else {
                                    return
                                }
                                
                                UIApplication.shared.open(mailToUrl)
                            }) {
                                Text("Contrate-me para fazer o seu app iOS")
                            }
                            .tint(.accentColor)
                            .controlSize(.large)
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .padding(.top)
                        }
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("Encontrou um problema ou gostaria de fazer uma sugestão?")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                guard let emailSubject = "Problema/sugestão no app iOS \(appVersion) Build \(buildVersionNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                                    return
                                }
                                guard let emailMessage = "Inclua passos e prints se possível.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                                    return
                                }
                                
                                let mailToString = "mailto:medodeliriosuporte@gmail.com?subject=\(emailSubject)&body=\(emailMessage)"
                                
                                guard let mailToUrl = URL(string: mailToString) else {
                                    return
                                }
                                
                                UIApplication.shared.open(mailToUrl)
                            }) {
                                Text("Conte-nos por e-mail")
                            }
                            .tint(.pink)
                            .controlSize(.large)
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .padding(.top)
                            
                            Text("medodeliriosuporte@gmail.com".uppercased())
                                .font(.footnote)
                                .bold()
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                                .padding(.horizontal)
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
                            .tint(.blue)
                            .controlSize(.large)
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .padding(.top)
                        }
                        
                        VStack(spacing: 15) {
                            Text("Criado por @claycon_")
                                .onTapGesture {
                                    UIPasteboard.general.string = pixKey
                                    showPixKeyCopiedAlert = true
                                }
                                .alert(isPresented: $showPixKeyCopiedAlert) {
                                    Alert(title: Text("Chave Pix Copiada com Sucesso"), message: Text("Qualquer R$ 1 me ajuda a manter isso aqui."), dismissButton: .default(Text("OK")))
                                }
                            
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
