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
    
    private var helpTheAppFooterText: String {
        if #available(iOS 16.0, *) {
            return "Doações recorrentes a partir de R$ 30 ganham um selo especial aqui."
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

//                if RetroView.ViewModel.shouldDisplayBanner() {
//                    Section {
//                        Button {
//                            print("Retro")
//                        } label: {
//                            Label("Retrospectiva 2023", systemImage: "airpodsmax")
//                        }
//                        .foregroundStyle(Color.green)
//                    }
//                }

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
                
                Section("Problemas, sugestões e pedidos") {
                    Button {
                        showEmailClientConfirmationDialog = true
                    } label: {
                        Label("Entrar em contato por e-mail", systemImage: "envelope")
                    }
                    .foregroundStyle(Color.blue)
                }
                
                if showAskForMoneyView || CommandLine.arguments.contains("-FORCE_SHOW_HELP_THE_APP") {
                    Section {
                        HelpTheAppView(donors: $donors, imageIsSelected: $showLargeCreatorImage)
                            .padding(donors != nil ? .top : .vertical)
                        
                        DonateButtons(showToastView: $showToastView)
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
                                OpenUtility.open(link: "https://burnthis.town/@rafael")
                            } label: {
                                Label(title: {
                                    Text("Seguir no Mastodon")
                                }, icon: {
                                    Image("mastodon")
                                        .renderingMode(.template)
                                        .foregroundColor(.primary)
                                })
                            }
                        }
                        
                        Section {
                            Button {
                                OpenUtility.open(link: "https://jovemnerd.com.br/nerdbunker/mastodon-como-criar-conta/")
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
                    Button {
                        OpenUtility.open(link: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")
                    } label: {
                        Label("Ver código fonte no GitHub", systemImage: "curlybraces")
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HelpView()) {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
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
                    
                    ToastView(
                        icon: "checkmark",
                        iconColor: .green,
                        text: didCopySupportAddressOnEmailPicker ? "E-mail de suporte copiado com sucesso." : "Chave copiada com sucesso!"
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                }
                .transition(.moveAndFade)
            }
        }
    }
}

extension SettingsView {

    struct DonateButtons: View {

        @Binding var showToastView: Bool

        private var copyPixKeyButtonHorizontalPadding: CGFloat {
            UIScreen.main.bounds.width > 400 ? 20 : 10
        }

        private let pixKey: String = "medodeliriosuporte@gmail.com"

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("DOAÇÃO RECORRENTE:")
                    .font(.footnote)
                    .bold()

                HStack {
                    Spacer()

                    Button {
                        OpenUtility.open(link: "https://apoia.se/app-medo-delirio-ios")
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "dollarsign.circle")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22)

                            Text("Ver campanha no Apoia.se")
                                .bold()
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, copyPixKeyButtonHorizontalPadding)
                        .padding(.vertical, 8)
                    }
                    .tint(.red)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)

                    Spacer()
                }
                
                Text("DOAÇÃO ÚNICA:")
                    .font(.footnote)
                    .bold()

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
                                .frame(width: 17)

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
            }
            .padding(.vertical, 10)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
