import SwiftUI

struct SettingsView: View {

    @State private var showExplicitSounds: Bool = UserSettings.getShowOffensiveSounds()
    
    @State private var showChangeAppIcon: Bool = ProcessInfo.processInfo.isMacCatalystApp == false
    
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
                Text("Alguns conteúdos contam com muitos palavrões. Ao marcar essa opção, você concorda que tem mais de 18 anos e que deseja ver esses conteúdos.")
            }
            
            Section {
                NavigationLink(destination: HelpView()) {
                    Text("Ajuda")
                }
                
                /*NavigationLink(destination: NotificationsSettingsView()) {
                    Text("Notificações")
                }*/
                
                if showChangeAppIcon {
                    NavigationLink(destination: ChangeAppIconView(displayOffensiveIcons: showAskForMoneyView)) {
                        Text("Ícone do app")
                    }
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
                /*Section {
                    PodcastAuthorsView()
                        .padding(.vertical, 8)
                }*/
                
                Section {
                    BegForMoneyView()
                        .padding(.vertical)
                    
                    Button("Copiar chave Pix (e-mail)") {
                        UIPasteboard.general.string = pixKey
                        showPixKeyCopiedAlert = true
                    }
                    .alert(isPresented: $showPixKeyCopiedAlert) {
                        Alert(title: Text("Chave copiada com sucesso!"), dismissButton: .default(Text("OK")))
                    }
                } header: {
                    Text("Ajude o app")
                } footer: {
                    Text("Selecione E-mail como tipo de chave no app do seu banco. Evite qualquer opção que mencione QR Code.")
                }
            }
            
            Section("Sobre") {
                Button("Criado por @claycon_") {
                    guard let url = URL(string: "https://twitter.com/claycon_") else { return }
                    UIApplication.shared.open(url)
                }
                
                Text("Versão \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)")
            }
            
            Section("Contribua ou entenda como funciona") {
                Button("Ver código fonte no GitHub") {
                    let githubUrl = URL(string: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")!
                    UIApplication.shared.open(githubUrl)
                }
            }
            
            Section {
                NavigationLink(destination: DiagnosticsView()) {
                    Text("Diagnóstico")
                }
            }
        }
        .navigationTitle("Ajustes")
        .onAppear {
            networkRabbit.displayAskForMoneyView { result, _ in
                showAskForMoneyView = result
            }
        }
        .popover(isPresented: $showEmailClientConfirmationDialog) {
            EmailAppPickerView(isBeingShown: $showEmailClientConfirmationDialog, subject: Shared.issueSuggestionEmailSubject, emailBody: Shared.issueSuggestionEmailBody)
        }
    }

}

struct AboutView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsView()
    }

}
