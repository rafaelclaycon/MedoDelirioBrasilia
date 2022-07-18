import SwiftUI

struct SettingsView: View {

    @State private var showExplicitSounds: Bool = UserSettings.getShowOffensiveSounds()
    
    @State private var showAskForMoneyView: Bool = false
    @State private var showPixKeyCopiedAlert: Bool = false
    
    @State private var showEmailClientConfirmationDialog: Bool = false
    
    let pixKey: String = "medodeliriosuporte@gmail.com"
    
    var body: some View {
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
            
            Section("📬  Problemas, sugestões e pedidos") {
                Button("Entrar em contato por e-mail") {
                    showEmailClientConfirmationDialog = true
                }
            }
            
            if showAskForMoneyView || CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
                Section {
                    PodcastAuthorsView()
                        .padding(.vertical, 8)
                }
                
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
                } header: {
                    Text("Ajude o app")
                } footer: {
                    Text("A chave é um endereço de e-mail, portanto, se o app do seu banco pedir o tipo de chave para fazer o Pix, selecione E-mail. Evite qualquer opção que mencione QR Code.")
                }
            }
            
            Section("🧑‍💻  Contribua ou entenda como o app funciona") {
                Button("Ver código fonte no GitHub") {
                    let githubUrl = URL(string: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")!
                    UIApplication.shared.open(githubUrl)
                }
            }
            
            Section("Sobre") {
                Button("Criado por @claycon_") {
                    guard let url = URL(string: "https://twitter.com/claycon_") else { return }
                    UIApplication.shared.open(url)
                }
                
                Text("Versão \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)")
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
        .confirmationDialog(Shared.pickAMailApp, isPresented: $showEmailClientConfirmationDialog, titleVisibility: .visible) {
            Mailman.getMailClientOptions(subject: Shared.issueSuggestionEmailSubject, body: Shared.issueSuggestionEmailBody)
        }
    }

}

struct AboutView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsView()
    }

}
