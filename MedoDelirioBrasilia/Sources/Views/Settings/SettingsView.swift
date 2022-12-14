//
//  SettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct SettingsView: View {

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
                    .onChange(of: showExplicitSounds) { newValue in
                        UserSettings.setShowOffensiveSounds(to: newValue)
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
                VStack(alignment: .leading) {
                    Text("Criado por Rafael Claycon Schmitt")
                    
                    HStack(spacing: 25) {
                        Spacer()
                        
                        Button {
                            open(link: "https://twitter.com/claycon_")
                        } label: {
                            Image("twitter")
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                        .tint(.blue)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        
                        Button {
                            open(link: "https://toot.wales/@mitt_rafael")
                        } label: {
                            Image("mastodon")
                                .renderingMode(.template)
                                .foregroundColor(.purple)
                                .padding(.horizontal)
                        }
                        .tint(.purple)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        
                        Spacer()
                    }
                    .padding(.bottom, 3)
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
        .navigationTitle("Ajustes")
        .onAppear {
            networkRabbit.displayAskForMoneyView { shouldDisplay in
                showAskForMoneyView = shouldDisplay
            }
            networkRabbit.displayAskForMoneyView { shouldDisplay in
                showAskForMoneyView = shouldDisplay
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
