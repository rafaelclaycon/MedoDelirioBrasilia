import SwiftUI

struct IconImage: View {

    var icon: Icon
    
    var body: some View {
        Label {
            Text(icon.rawValue)
        } icon: {
            Image(uiImage: UIImage(named: icon.rawValue) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 50, maxHeight: 50)
                .cornerRadius(10)
                .padding()
        }
        .labelStyle(.iconOnly)
    }

}

struct IconImage_Previews: PreviewProvider {

    static var previews: some View {
        IconImage(icon: Icon.primary)
            .previewInterfaceOrientation(.portrait)
    }

}
