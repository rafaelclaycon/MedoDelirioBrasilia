import SwiftUI

struct SettingsCasingWithCloseView: View {

    @Binding var isBeingShown: Bool
    @Binding var updateSoundsList: Bool
    
    var body: some View {
        NavigationView {
            SettingsView(updateSoundsList: $updateSoundsList)
                .navigationTitle("Ajustes")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                    Button("Fechar") {
                        self.isBeingShown = false
                    }
                )
        }
    }

}

struct SettingsCasingWithCloseView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsCasingWithCloseView(isBeingShown: .constant(true), updateSoundsList: .constant(false))
    }

}
