import SwiftUI

struct NotificationsSettingsView: View {

    @State var enableNotifications = false
    
    @State var enrollOnGeneralChannel = false
    @State var enrollOnNewEpisodesChannel = false
    
    var body: some View {
        Form {
//            Section {
//                Toggle("Novos sons", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings.setEnableTrends(to: newValue)
//                    }
//
//                Toggle("Novas músicas", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings.setEnableTrends(to: newValue)
//                    }
//
//                Toggle("Anúncios de novas funcionalidades", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings.setEnableTrends(to: newValue)
//                    }
//
//                Toggle("Brincadeiras", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings.setEnableTrends(to: newValue)
//                    }
//            } header: {
//                Text("Escolha quais notificações deseja receber")
//            } footer: {
//                Text("Tentarei manter a frequência das notificações em 1 a 2 por semana para não encher o saco.")
//            }
            
            Section {
                NotificationSymbolPlusText()
                    .padding()
                
                Toggle("Habilitar Notificações", isOn: $enableNotifications)
                    .onChange(of: enableNotifications) { newValue in
                        if newValue == true {
                            NotificationAide.registerForRemoteNotifications() { _ in
                                enableNotifications = UserSettings.getUserAllowedNotifications()
                            }
                        } else {
                            UserSettings.setUserAllowedNotifications(to: newValue)
                        }
                    }
            }
            
            Section {
                Toggle("Geral (novos sons, tendências, novos recursos)", isOn: $enrollOnGeneralChannel)
//                    .onChange(of: enableNotifications) { newValue in
//                        if newValue == true {
//                            NotificationAide.registerForRemoteNotifications() { _ in
//                                enableNotifications = UserSettings.getUserAllowedNotifications()
//                            }
//                        } else {
//                            UserSettings.setUserAllowedNotifications(to: newValue)
//                        }
//                    }
                
                Toggle("Novos Episódios (Beta)", isOn: $enrollOnNewEpisodesChannel)
            } header: {
                Text("Canais")
            }
            
            Section {
                Button("Mostrar permissões do app no sistema") {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            } header: {
                EmptyView()
            } footer: {
                Text("Use a opção acima para verificar se você não bloqueou o app de mandar notificações a nível de sistema.")
            }
            
//            if CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
//                Section {
//                    Button("Habilitar re-tentativa de envio do token de notificação para o servidor") {
//                        AppPersistentMemory.setShouldRetrySendingDevicePushToken(to: true)
//                    }
//                } header: {
//                    Text("Apenas para testes")
//                } footer: {
//                    Text("Use o botão acima caso você tenha desinstalado o app, reinstalado, concordado novamente em receber notificações e não recebeu mais.\n\nDepois disso, toque em Ajustes no topo da tela para voltar para a tela de Ajustes e re-abra essa tela (Notificações) para que a re-tentativa seja feita.")
//                }
//            }
        }
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            enableNotifications = UserSettings.getUserAllowedNotifications()
        }
    }

}

struct NotificationsSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        NotificationsSettingsView()
    }

}
