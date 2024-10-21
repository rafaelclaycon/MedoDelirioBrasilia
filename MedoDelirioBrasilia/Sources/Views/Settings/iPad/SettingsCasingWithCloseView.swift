import SwiftUI

struct SettingsCasingWithCloseView: View {

    @Binding var isBeingShown: Bool
    @EnvironmentObject var helper: SettingsHelper
    
    var body: some View {
        NavigationView {
            SettingsView()
                .navigationTitle("Configurações")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                    Button("Fechar") {
                        self.isBeingShown = false
                    }
                )
                .environmentObject(helper)
        }
    }

}

struct SettingsCasingWithCloseView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsCasingWithCloseView(isBeingShown: .constant(true))
    }

}
