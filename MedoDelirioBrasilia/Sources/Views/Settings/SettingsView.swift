//
//  SettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct SettingsView: View {

    @State private var showExplicitSounds: Bool = UserSettings().getShowExplicitContent()

    @State private var showChangeAppIcon: Bool = !UIDevice.isMac

    @State private var showAskForMoneyView: Bool = false
    @State private var toast: Toast?
    @State private var donors: [Donor]? = nil

    @State private var showEmailSheet: Bool = false

    private let apiClient: APIClientProtocol

    // MARK: - Environment

    @Environment(SettingsHelper.self) private var helper

    // MARK: - Initializer

    init(
        apiClient: APIClientProtocol
    ) {
        self.apiClient = apiClient
    }

    // MARK: - View Body

    var body: some View {
        if #available(iOS 26.0, *) {
            form
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(
                            destination: DiagnosticsView(
                                database: LocalDatabase.shared,
                                analyticsService: AnalyticsService()
                            )
                        ) {
                            Image(systemName: "stethoscope")
                        }
                    }

                    ToolbarSpacer(.fixed, placement: .topBarTrailing)

                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: HelpView()) {
                            Image(systemName: "questionmark")
                        }
                    }
                }
        } else {
            form
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: HelpView()) {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                }
        }
    }

    var form: some View {
        Form {
            Section {
                Toggle("Exibir conteúdo sensível", isOn: $showExplicitSounds)
                    .onChange(of: showExplicitSounds) {
                        UserSettings().setShowExplicitContent(to: showExplicitSounds)
                        helper.updateSoundsList = true
                    }
            } footer: {
                Text("Alguns conteúdos contam com muitos palavrões. Ao marcar essa opção, você concorda que tem mais de 18 anos e que deseja ver esses conteúdos.")
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

            Section("Problemas, sugestões e pedidos") {
                Button {
                    showEmailSheet = true
                } label: {
                    Label("Entrar em contato por e-mail", systemImage: "envelope")
                }
                .foregroundStyle(Color.blue)
            }

            if showAskForMoneyView || CommandLine.arguments.contains("-FORCE_SHOW_HELP_THE_APP") {
                HelpTheAppView(donors: donors, toast: $toast, apiClient: APIClient.shared)
            }

            Section("Contribua ou entenda como funciona") {
                Button {
                    Task {
                        OpenUtility.open(link: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")
                        await SettingsView.sendAnalytics(for: "didTapGitHubButton")
                    }
                } label: {
                    Label("Ver código fonte no GitHub", systemImage: "curlybraces")
                        .foregroundStyle(.purple)
                }
            }

            Section("Sobre") {
                Text("Versão \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)")
            }

            Section {
                AuthorCreditsView()
            }
        }
        .navigationTitle("Configurações")
        .onAppear {
            Task {
                await onViewAppeared()
            }
        }
        .sheet(isPresented: $showEmailSheet) {
            EmailAppPickerView(
                isBeingShown: $showEmailSheet,
                toast: $toast,
                subject: Shared.issueSuggestionEmailSubject,
                emailBody: Shared.issueSuggestionEmailBody
            )
        }
        .toast($toast)
    }

    // MARK: - Functions

    private func onViewAppeared() async {
        showAskForMoneyView = await apiClient.displayAskForMoneyView(appVersion: Versioneer.appVersion)
        let copy = await apiClient.getDonorNames()?.shuffled()
        self.donors = copy
    }

    private static func sendAnalytics(for action: String) async {
        await AnalyticsService().send(
            originatingScreen: "SettingsView",
            action: action
        )
    }
}

// MARK: - Preview

#Preview {
    SettingsView(apiClient: APIClient.shared)
}
