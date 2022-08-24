import SwiftUI

struct ChangeAppIconView: View {

    private var model = AppIcon()
    @State private var selectedIcon: String = .empty
    
    var body: some View {
        VStack {
            List(Icon.allCases) { icon in
                Button {
                    model.setAlternateAppIcon(icon: icon)
                    selectedIcon = icon.id
                } label: {
                    AppIconCell(icon: icon, selectedItem: $selectedIcon)
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Ícone do app")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedIcon = UIApplication.shared.alternateIconName ?? Icon.primary.id
        }
    }

}

struct ChangeAppIconView_Previews: PreviewProvider {

    static var previews: some View {
        ChangeAppIconView()
    }

}
