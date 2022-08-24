import SwiftUI

struct IconImage: View {

    var icon: Icon
    
    private let cornerRadius: CGFloat = 11.0
    
    var body: some View {
        Label {
            Text(icon.rawValue)
        } icon: {
            Image(uiImage: UIImage(named: icon.rawValue) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.vertical)
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
