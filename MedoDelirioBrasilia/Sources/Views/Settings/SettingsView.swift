//
//  SettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var helper: SettingsHelper
    
    @State private var showExplicitSounds: Bool = UserSettings.getShowExplicitContent()
    
    @State private var showChangeAppIcon: Bool = ProcessInfo.processInfo.isMacCatalystApp == false
    
    @State private var showAskForMoneyView: Bool = false
    @State private var showToastView: Bool = false
    @State private var donors: [Donor]? = nil
    
    @State private var showEmailClientConfirmationDialog: Bool = false
    @State private var didCopySupportAddressOnEmailPicker: Bool = false
    
    @State private var showLargeCreatorImage: Bool = false
    
    private let pixKey: String = "medodeliriosuporte@gmail.com"
    
    private var copyPixKeyButtonHorizontalPadding: CGFloat {
        20
    }
    
    private var helpTheAppFooterText: String {
        if #available(iOS 16.0, *) {
            return "Já doou antes? Inclua essa informação na mensagem do Pix para ganhar um selo especial aqui :)"
        } else {
            return ""
        }
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    Toggle("Exibir conteúdo explícito", isOn: $showExplicitSounds)
                        .onChange(of: showExplicitSounds) { showExplicitSounds in
                            UserSettings.setShowExplicitContent(to: showExplicitSounds)
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
                
                if showAskForMoneyView {
                    Section {
                        HelpTheAppView(donors: $donors, imageIsSelected: $showLargeCreatorImage)
                            .padding(donors != nil ? .top : .vertical)
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                UIPasteboard.general.string = pixKey
                                withAnimation {
                                    showToastView = true
                                }
                                TapticFeedback.success()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showToastView = false
                                    }
                                }
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "doc.on.doc")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                    
                                    Text("Copiar chave Pix (e-mail)")
                                        .bold()
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, copyPixKeyButtonHorizontalPadding)
                                .padding(.vertical, 8)
                            }
                            .tint(.green)
                            .controlSize(.regular)
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    } header: {
                        Text("Ajude o app")
                    } footer: {
                        Text(helpTheAppFooterText)
                    }
                }
                
                Section("Sobre") {
                    Menu {
                        Section {
                            Button {
                                open(link: "https://burnthis.town/@rafael")
                            } label: {
                                Label("Seguir no Mastodon", image: "mastodon")
                            }
                        }
                        
                        Section {
                            Button {
                                open(link: "https://jovemnerd.com.br/nerdbunker/mastodon-como-criar-conta/")
                            } label: {
                                Label("Como abrir uma conta no Mastodon?", systemImage: "arrow.up.right.square")
                            }
                        }
                    } label: {
                        Text("Criado por Rafael Claycon Schmitt")
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
                networkRabbit.getPixDonorNames { donors in
                    self.donors = donors
                }
            }
            .popover(isPresented: $showEmailClientConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $showEmailClientConfirmationDialog,
                                   didCopySupportAddress: $didCopySupportAddressOnEmailPicker,
                                   subject: Shared.issueSuggestionEmailSubject,
                                   emailBody: Shared.issueSuggestionEmailBody)
            }
            .onChange(of: showEmailClientConfirmationDialog) { showEmailClientConfirmationDialog in
                if showEmailClientConfirmationDialog == false {
                    if didCopySupportAddressOnEmailPicker {
                        withAnimation {
                            showToastView = true
                        }
                        TapticFeedback.success()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showToastView = false
                            }
                        }
                        
                        didCopySupportAddressOnEmailPicker = false
                    }
                }
            }
            
            if showLargeCreatorImage {
                LargeCreatorView(showLargeCreatorImage: $showLargeCreatorImage)
            }
            
            if showToastView {
                VStack {
                    Spacer()
                    
                    ToastView(text: didCopySupportAddressOnEmailPicker ? "E-mail de suporte copiado com sucesso." : "Chave copiada com sucesso!")
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                }
                .transition(.moveAndFade)
            }
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
