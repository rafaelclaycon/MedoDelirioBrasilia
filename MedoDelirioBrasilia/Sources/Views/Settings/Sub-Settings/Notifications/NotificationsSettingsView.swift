import SwiftUI

struct NotificationsSettingsView: View {

    @State var enableNotifications = false
    
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
            } header: {
                EmptyView()
            } footer: {
                Text("Caso não consiga ativar a opção acima, toque no botão abaixo para habilitar as notificações do app nos Ajustes do sistema.")
            }
            
            Section {
                Button("Mostrar Permissões do App nos Ajustes") {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
        }
        .navigationTitle("Notificações")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
