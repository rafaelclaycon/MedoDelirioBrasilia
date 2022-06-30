import SwiftUI

struct NotificationsSettingsView: View {

    @State var newSounds = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Novos sons", isOn: $newSounds)
                    .onChange(of: newSounds) { newValue in
                        //UserSettings.setEnableTrends(to: newValue)
                    }
                
                Toggle("Novas músicas", isOn: $newSounds)
                    .onChange(of: newSounds) { newValue in
                        //UserSettings.setEnableTrends(to: newValue)
                    }
                
                Toggle("Anúncios de novas funcionalidades", isOn: $newSounds)
                    .onChange(of: newSounds) { newValue in
                        //UserSettings.setEnableTrends(to: newValue)
                    }
                
                Toggle("Brincadeiras", isOn: $newSounds)
                    .onChange(of: newSounds) { newValue in
                        //UserSettings.setEnableTrends(to: newValue)
                    }
            } header: {
                Text("Escolha quais notificações deseja receber")
            } footer: {
                Text("Tentarei manter a frequência das notificações em 1 a 2 por semana para não encher o saco.")
            }
            
        }
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct NotificationsSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        NotificationsSettingsView()
    }

}
