import SwiftUI

struct ChangeAppIconView: View {

    private var model = AppIcon()
    
    var body: some View {
        VStack {
            ScrollView {
                List(Icon.allCases) { icon in
                    Button {
                        model.setAlternateAppIcon(icon: icon)
                    } label: {
                        //IconImage(icon: icon)
                        Text("JJ")
                    }
                }
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
