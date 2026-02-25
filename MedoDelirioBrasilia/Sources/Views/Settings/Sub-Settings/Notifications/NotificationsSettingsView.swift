import SwiftUI

struct NotificationsSettingsView: View {

    @State private var enableNotifications = false
    @State private var episodeNotifications = false

    var body: some View {
        Form {
            Section {
                Toggle("Habilitar Notificações", isOn: $enableNotifications)
                    .onChange(of: enableNotifications) {
                        if enableNotifications {
                            Task {
                                await NotificationAide.registerForRemoteNotifications()
                                enableNotifications = UserSettings().getUserAllowedNotifications()
                            }
                        } else {
                            UserSettings().setUserAllowedNotifications(to: false)
                        }
                    }
            } header: {
                EmptyView()
            } footer: {
                Text("Caso a opção acima não esteja surtindo efeito, toque no botão no fim dessa tela para habilitar as notificações do app nos Ajustes do sistema.")
            }

            if FeatureFlag.isEnabled(.episodeNotifications), enableNotifications {
                Section {
                    Toggle("Avisos", isOn: .constant(true))
                        .disabled(true)

                    Toggle("Novos Episódios", isOn: $episodeNotifications)
                        .onChange(of: episodeNotifications) {
                            UserSettings().setEnableEpisodeNotifications(to: episodeNotifications)
                            Task {
                                do {
                                    if episodeNotifications {
                                        try await APIClient.shared.subscribeToChannel("new_episodes")
                                    } else {
                                        try await APIClient.shared.unsubscribeFromChannel("new_episodes")
                                    }
                                } catch {
                                    print("Channel subscription update failed: \(error.localizedDescription)")
                                }
                            }
                        }
                } header: {
                    Text("Escolha o que quer receber")
                } footer: {
                    Text("Receba uma notificação quando um novo episódio do podcast estiver disponível.")
                }
            }

            Section {
                Button("Mostrar permissões do app no sistema") {
                    let bundleId = Bundle.main.bundleIdentifier ?? ""
                    if let url = URL(string: "settings-navigation://com.apple.Settings.Apps/\(bundleId)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            enableNotifications = UserSettings().getUserAllowedNotifications()
            episodeNotifications = UserSettings().getEnableEpisodeNotifications()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}
