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
