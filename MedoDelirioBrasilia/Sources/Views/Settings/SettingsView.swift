//
//  SettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct SettingsView: View {

    @State private var path = NavigationPath()

    @State private var showExplicitSounds: Bool = UserSettings().getShowExplicitContent()

    @State private var showChangeAppIcon: Bool = !UIDevice.isMac

    @State private var showAskForMoneyView: Bool = false
    @State private var toast: Toast?
    @State private var donors: [Donor]? = nil

    private let apiClient: APIClientProtocol

    // MARK: - Environment

    @Environment(SettingsHelper.self) private var helper
    @Environment(\.dismiss) var dismiss

    // MARK: - Initializer

    init(
        apiClient: APIClientProtocol
    ) {
        self.apiClient = apiClient
    }

    // MARK: - View Body

    var body: some View {
        NavigationStack(path: $path) {
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
                    NavigationLink(value: SettingsDestination.notificationSettings) {
                        Label {
                            Text("Notificações")
                                .foregroundStyle(.primary)
                        } icon: {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.red)
                        }
                    }

                    if showChangeAppIcon {
                        NavigationLink(value: SettingsDestination.changeAppIcon) {
                            Label {
                                Text("Ícone do app")
                            } icon: {
                                Image(systemName: "app")
                                    .foregroundColor(.orange)
                            }
                        }
                    }

                    NavigationLink(value: SettingsDestination.privacySettings) {
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
                        Task {
                            await Mailman.openDefaultEmailApp(
                                subject: Shared.issueSuggestionEmailSubject,
                                body: Shared.issueSuggestionEmailBody
                            )
                        }
                    } label: {
                        Label("Entrar em contato por e-mail", systemImage: "envelope")
                    }
                    .foregroundStyle(Color.blue)
                }

                if showAskForMoneyView || CommandLine.arguments.contains("-FORCE_SHOW_HELP_THE_APP") {
                    HelpTheAppView(donors: donors, toast: $toast, apiClient: APIClient.shared)
                }

                Section("Sobre") {
                    Text("Versão \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)")

                    HStack(spacing: .spacing(.small)) {
                        Button("Ver código fonte") {
                            Task {
                                OpenUtility.open(link: "https://github.com/rafaelclaycon/MedoDelirioBrasilia")
                                await SettingsView.sendAnalytics(for: "didTapGitHubButton")
                            }
                        }
                        .tint(.purple)
                        .buttonStyle(.bordered)

                        Button("Diagnóstico") {
                            path.append(SettingsDestination.diagnostics)
                        }
                        .tint(.orange)
                        .buttonStyle(.bordered)
                    }
                }

                Section {
                    AuthorCreditsView()
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await onViewAppeared()
                }
            }
            .toast($toast)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(SettingsDestination.help)
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .changeAppIcon:
                    ChangeAppIconView()

                case .diagnostics:
                    DiagnosticsView(
                        database: LocalDatabase.shared,
                        analyticsService: AnalyticsService()
                    )

                case .help:
                    HelpView()

                case .notificationSettings:
                    NotificationsSettingsView()
                    
                case .privacySettings:
                    PrivacySettingsView()
                }
            }
        }
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

enum SettingsDestination: Hashable {

    case changeAppIcon
    case diagnostics
    case help
    case notificationSettings
    case privacySettings
}

// MARK: - Preview

#Preview {
    SettingsView(apiClient: APIClient.shared)
}
