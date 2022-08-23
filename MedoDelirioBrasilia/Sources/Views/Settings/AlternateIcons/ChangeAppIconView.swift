import SwiftUI

struct ChangeAppIconView: View {

    private var model = AppIcon()
    
    var body: some View {
        VStack {
            List(Icon.allCases) { icon in
                Button {
                    model.setAlternateAppIcon(icon: icon)
                } label: {
                    HStack(spacing: 15) {
                        IconImage(icon: icon)
                        Text(icon.marketingName)
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Ícone do app")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct ChangeAppIconView_Previews: PreviewProvider {

    static var previews: some View {
        ChangeAppIconView()
    }

}
