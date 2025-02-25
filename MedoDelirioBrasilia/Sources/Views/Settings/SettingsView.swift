//
//  SettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct SettingsView: View {

    enum ToastType {
        case email, pix
    }

    @EnvironmentObject var helper: SettingsHelper

    @State private var showExplicitSounds: Bool = UserSettings().getShowExplicitContent()

    @State private var showChangeAppIcon: Bool = ProcessInfo.processInfo.isMacCatalystApp == false

    @State private var showAskForMoneyView: Bool = false
    @State private var showToastView: Bool = false
    @State private var toastType: ToastType = .pix
    @State private var donors: [Donor]? = nil

    @State private var showEmailClientConfirmationDialog: Bool = false

    @State private var showLargeCreatorImage: Bool = false

    private let authorSocials: [SocialMediaLink] = [
        .init(name: "Bluesky", imageName: "bluesky", link: "https://bsky.app/profile/rafaelschmitt.bsky.social"),
        .init(name: "Mastodon", imageName: "mastodon", link: "https://burnthis.town/@rafael")
    ]

    var body: some View {
        ZStack {
            Form {
                Section {
                    Toggle("Exibir conteúdo sensível", isOn: $showExplicitSounds)
                        .onChange(of: showExplicitSounds) { showExplicitSounds in
                            UserSettings().setShowExplicitContent(to: showExplicitSounds)
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
                        
                        DonateButtons(
                            showToastView: $showToastView,
                            toastType: $toastType
                        )
                    } header: {
                        Text("Ajude o app")
                    } footer: {
                        Text("Doações recorrentes a partir de R$ 30 ganham um selo especial aqui.")
                    }
                }
                
                Section("Sobre") {
                    Menu {
                        Section("Blogue") {
                            Button {
                                OpenUtility.open(link: "https://from-rafael-with-code.ghost.io/")
                                SettingsView.sendAnalytics(for: "didTapBlogLink")
                            } label: {
                                Label("From Rafael with Code", systemImage: "book")
                            }
                        }

                        Section("Seguir no") {
                            ForEach(authorSocials) { social in
                                Button {
                                    OpenUtility.open(link: social.link)
                                    SettingsView.sendAnalytics(for: "didTapSocialLink(\(social.name))")
                                } label: {
                                    Label(title: {
                                        Text(social.name)
                                    }, icon: {
                                        Image(social.imageName)
                                            .renderingMode(.template)
                                            .foregroundColor(.primary)
                                    })
                                }
                            }
                        }

                        Section {
                            Button {
                                OpenUtility.open(link: "https://jovemnerd.com.br/noticias/ciencia-e-tecnologia/mastodon-como-criar-conta")
                                SettingsView.sendAnalytics(for: "didTapHowToCreateMastodonAccountOption")
                            } label: {
                                Label("O que é e como criar uma conta no Mastodon", systemImage: "arrow.up.right.square")
                            }
                        }
                    } label: {
                        Text("Criado por Rafael Schmitt")
                    }
                    
                    Text("Versão \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)")
                }
                
                Section("Contribua ou entenda como funciona") {
                    Button {
                        OpenUtility.open(link: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")
                        SettingsView.sendAnalytics(for: "didTapGitHubButton")
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
                NetworkRabbit.shared.displayAskForMoneyView { shouldDisplay in
                    showAskForMoneyView = shouldDisplay
                }
                NetworkRabbit.shared.getPixDonorNames { donors in
                    let copy = donors?.shuffled()
                    self.donors = copy
                }
            }
            .sheet(isPresented: $showEmailClientConfirmationDialog) {
                EmailAppPickerView(
                    isBeingShown: $showEmailClientConfirmationDialog,
                    subject: Shared.issueSuggestionEmailSubject,
                    emailBody: Shared.issueSuggestionEmailBody,
                    afterCopyAddressAction: {
                        toastType = .email
                        withAnimation {
                            showToastView = true
                        }
                        TapticFeedback.success()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showToastView = false
                            }
                        }
                    }
                )
            }

            if showLargeCreatorImage {
                LargeCreatorView(showLargeCreatorImage: $showLargeCreatorImage)
            }

            if showToastView {
                VStack {
                    Spacer()
                    
                    ToastView(
                        icon: toastType == .email ? "checkmark" : "heart",
                        iconColor: toastType == .email ? .green : .red,
                        text: toastType == .email ? "E-mail copiado com sucesso." : randomThankYouString()
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                }
                .transition(.moveAndFade)
            }
        }
    }

    private func randomThankYouString() -> String {
        let ending = [
            "Obrigado!",
            "Tem que manter isso, viu?",
            "Alegria!",
            "Éééé!",
            "Vamos apoiar o circo!",
            "Olha-Que-Legal!",
            "Ai, que delícia!",
            "Maravilhoso!",
            "Vamo, comunistada!",
            "Bora!"
        ].randomElement() ?? ""
        return "Chave copiada. \(ending)"
    }

    private static func sendAnalytics(for action: String) {
        Analytics().send(
            originatingScreen: "SettingsView",
            action: action
        )
    }
}

extension SettingsView {

    struct DonateButtons: View {

        @Binding var showToastView: Bool
        @Binding var toastType: ToastType

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
                        sendAnalytics(for: "didTapApoiaseButton")
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
                        toastType = .pix
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

                        sendAnalytics(for: "didCopyPixKey")
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

#Preview {
    SettingsView()
}
