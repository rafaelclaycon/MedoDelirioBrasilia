import SwiftUI

struct SettingsView: View {

    @State private var showExplicitSounds: Bool = UserSettings.getShowOffensiveSounds()
    
    @State private var showAskForMoneyView: Bool = false
    @State private var showPixKeyCopiedAlert: Bool = false
    
    @State private var showEmailAddressCopiedAlert: Bool = false
    
    let pixKey: String = "medodeliriosuporte@gmail.com"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let buildVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Exibir conteúdo sensível", isOn: $showExplicitSounds)
                        .onChange(of: showExplicitSounds) { newValue in
                            UserSettings.setShowOffensiveSounds(to: newValue)
                        }
                } footer: {
                    Text("Alguns conteúdos contam com muitos palavrões. Ao marcar essa opção, você concorda que tem mais de 18 anos e que deseja ver esse conteúdo.")
                }
                
                Section {
                    NavigationLink(destination: HelpView()) {
                        Text("Ajuda")
                    }
                    
                    NavigationLink(destination: TrendsSettingsView()) {
                        Text("Tendências")
                    }
                }
                
                if showAskForMoneyView {
                    Section {
                        BegForMoneyView()
                            .padding(.vertical)
                        
                        Button("Copiar chave Pix") {
                            UIPasteboard.general.string = pixKey
                            showPixKeyCopiedAlert = true
                        }
                        .alert(isPresented: $showPixKeyCopiedAlert) {
                            Alert(title: Text("Chave copiada com sucesso!"), dismissButton: .default(Text("OK")))
                        }
                    } header : {
                        Text("Esse app é uma homenagem ao trabalho de Cristiano Botafogo e Pedro Daltro")
                    } footer: {
                        Text("A chave é um endereço de e-mail, portanto, se o app do seu banco pedir o tipo de chave para transferir, selecione E-mail. Evite qualquer opção que mencione QR Code.")
                    }
                }
                
                Section("📬  Problemas, sugestões e pedidos") {
                    Button("Entrar em contato por e-mail (Mail)") {
                        guard let emailSubject = "Problema/sugestão no app iOS \(appVersion) Build \(buildVersionNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                            return
                        }
                        guard let emailMessage = "Para um problema, inclua passos para reproduzir e prints se possível.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                            return
                        }

                        let mailToString = "mailto:medodeliriosuporte@gmail.com?subject=\(emailSubject)&body=\(emailMessage)"

                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }

                        UIApplication.shared.open(mailToUrl)
                    }
                    
                    Button("Copiar endereço de e-mail (outros apps)") {
                        UIPasteboard.general.string = "medodeliriosuporte@gmail.com"
                        showEmailAddressCopiedAlert = true
                    }
                    .alert(isPresented: $showEmailAddressCopiedAlert) {
                        Alert(title: Text("Endereço copiado com sucesso!"), dismissButton: .default(Text("OK")))
                    }
                }
                
                Section("🧑‍💻  Contribua ou entenda como o app funciona") {
                    Button(action: {
                        let githubUrl = URL(string: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")!
                        UIApplication.shared.open(githubUrl)
                    }) {
                        Text("Ver código fonte no GitHub")
                    }
                }
                
                Section("Sobre") {
                    Button("Criado por @claycon_") {
                        guard let url = URL(string: "https://twitter.com/claycon_") else { return }
                        UIApplication.shared.open(url)
                    }
                    
                    Text("Versão \(appVersion) Build \(buildVersionNumber)")
                }
                
                Section("Diagnóstico") {
                    NavigationLink(destination: DiagnosticsView()) {
                        Text("Dados para nerds")
                    }
                }
            }
            .navigationTitle("Ajustes")
            .onAppear {
                networkRabbit.displayAskForMoneyView { result, _ in
                    showAskForMoneyView = result
                }
            }
        }
    }

}

struct AboutView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsView()
    }

}
