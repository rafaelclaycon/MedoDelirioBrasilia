//
//  SettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var helper: SettingsHelper
    
    @State private var showExplicitSounds: Bool = UserSettings.getShowOffensiveSounds()
    
    @State private var showChangeAppIcon: Bool = ProcessInfo.processInfo.isMacCatalystApp == false
    
    @State private var showAskForMoneyView: Bool = false
    @State private var showPixKeyCopiedAlert: Bool = false
    @State private var donorNames: String = ""
    
    @State private var showEmailClientConfirmationDialog: Bool = false
    
    private let pixKey: String = "medodeliriosuporte@gmail.com"
    
    var body: some View {
        Form {
            Section {
                Toggle("Exibir conteúdo explícito", isOn: $showExplicitSounds)
                    .onChange(of: showExplicitSounds) { showExplicitSounds in
                        UserSettings.setShowOffensiveSounds(to: showExplicitSounds)
                        helper.updateSoundsList = true
                    }
            } footer: {
                Text("Alguns conteúdos contam com muitos palavrões. Ao marcar essa opção, você concorda que tem mais de 18 anos e que deseja ver esses conteúdos.")
            }
            
            Section {
                NavigationLink(destination: HelpView()) {
                    Label {
                        Text("Ajuda")
                    } icon: {
                        Image(systemName: "questionmark")
                            .foregroundColor(.blue)
                    }

                }
            }
            
            Section {
                NavigationLink(destination: NotificationsSettingsView()) {
                    Label(title: {
                        Text("Notificações")
                    }, icon: {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.red)
                    })
                }
                
                if showChangeAppIcon {
                    NavigationLink(destination: ChangeAppIconView()) {
                        Label {
                            Text("Ícone do app")
                        } icon: {
                            Image(systemName: "app")
                                .foregroundColor(.orange)
                        }

                    }
                }
                
                NavigationLink(destination: PrivacySettingsView()) {
                    Label {
                        Text("Privacidade")
                    } icon: {
                        Image(systemName: "hand.raised")
                            .foregroundColor(.blue)
                    }

                }
            }
            
            Section("📬  Problemas, sugestões e pedidos") {
                Button("Entrar em contato por e-mail") {
                    showEmailClientConfirmationDialog = true
                }
            }
            
            if showAskForMoneyView || CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
                Section {
                    BegForMoneyView(donorNames: $donorNames)
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
                VStack(alignment: .leading) {
                    Text("Criado por Rafael Claycon Schmitt")
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            open(link: "https://burnthis.town/@rafael")
                        } label: {
                            HStack(spacing: 10) {
                                Image("mastodon")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                
                                Text("Seguir no Mastodon")
                                    .bold()
                            }
                            .foregroundColor(.purple)
                            .padding(.horizontal, 10)
                        }
                        .tint(.purple)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    
                    HStack {
                        Spacer()
                        
                        Button("Como abrir uma conta?") {
                            open(link: "https://jovemnerd.com.br/nerdbunker/mastodon-como-criar-conta/")
                        }
                        .tint(.blue)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Text("Versão \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)")
            }
            
            Section("Contribua ou entenda como funciona") {
                Button("Ver código fonte no GitHub") {
                    open(link: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")
                }
            }
            
            Section {
                NavigationLink(destination: DiagnosticsView()) {
                    Label {
                        Text("Diagnóstico")
                    } icon: {
                        Image(systemName: "stethoscope")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Configurações")
        .onAppear {
            networkRabbit.displayAskForMoneyView { shouldDisplay in
                showAskForMoneyView = shouldDisplay
            }
            networkRabbit.getPixDonorNames { names in
                donorNames = names
            }
        }
        .popover(isPresented: $showEmailClientConfirmationDialog) {
            EmailAppPickerView(isBeingShown: $showEmailClientConfirmationDialog, subject: Shared.issueSuggestionEmailSubject, emailBody: Shared.issueSuggestionEmailBody)
        }
    }
    
    private func open(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }

}

struct AboutView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsView()
    }

}
