import SwiftUI

struct NotificationsSettingsView: View {

    @State var enableNotifications = false
    
    var body: some View {
        Form {
//            Section {
//                Toggle("Novos sons", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings().setEnableTrends(to: newValue)
//                    }
//
//                Toggle("Novas músicas", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings().setEnableTrends(to: newValue)
//                    }
//
//                Toggle("Anúncios de novas funcionalidades", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings().setEnableTrends(to: newValue)
//                    }
//
//                Toggle("Brincadeiras", isOn: $newSounds)
//                    .onChange(of: newSounds) { newValue in
//                        //UserSettings().setEnableTrends(to: newValue)
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
                Text("Caso a opção acima não esteja surtindo efeito, toque no botão abaixo para habilitar as notificações do app nos Ajustes do sistema.")
            }
            
            Section {
                Button("Mostrar permissões do app no sistema") {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
        }
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            enableNotifications = UserSettings().getUserAllowedNotifications()
        }
    }
}

#Preview {
    NotificationsSettingsView()
}
