import SwiftUI

struct NotificationsSettingsView: View {

    @State private var enableNotifications = false
    @State private var episodeNotifications = false
    @State private var toast: Toast?
    @State private var subscriptionStatus: String?

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
                            Task {
                                let result = if episodeNotifications {
                                    await EpisodeNotificationSubscriber.subscribe()
                                } else {
                                    await EpisodeNotificationSubscriber.unsubscribe()
                                }

                                switch result {
                                case .success:
                                    subscriptionStatus = episodeNotifications
                                        ? "Inscrito com sucesso."
                                        : "Inscrição removida."
                                case .failure(let error):
                                    episodeNotifications = !episodeNotifications
                                    subscriptionStatus = "Erro: \(error.localizedDescription)"
                                    toast = Toast(
                                        message: "Não foi possível atualizar a inscrição. Tente novamente.",
                                        type: .warning
                                    )
                                }
                            }
                        }
                } header: {
                    Text("Escolha o que quer receber")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Receba uma notificação quando um novo episódio do podcast estiver disponível.")

                        if let subscriptionStatus {
                            Text(subscriptionStatus)
                                .foregroundStyle(
                                    subscriptionStatus.hasPrefix("Erro") ? .red : .secondary
                                )
                        }
                    }
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
        .topToast($toast)
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
