import SwiftUI

struct ChangeAppIconView: View {

    var model = AppIcon()
    @State var displayOffensiveIcons: Bool
    @State private var selectedIcon: String = .empty
    
    private var icons: [Icon] {
        if displayOffensiveIcons {
            return Icon.allCases
        } else {
            return Icon.allCases.filter({ $0.isOffensive == false })
        }
    }
    
    var body: some View {
        VStack {
            List(icons) { icon in
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
        ChangeAppIconView(displayOffensiveIcons: true)
    }

}
