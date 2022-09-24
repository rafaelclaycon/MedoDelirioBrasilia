import SwiftUI

struct SettingsCasingWithCloseView: View {

    @Binding var isBeingShown: Bool
    
    var body: some View {
        NavigationView {
            SettingsView()
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
        SettingsCasingWithCloseView(isBeingShown: .constant(true))
    }

}
