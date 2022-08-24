import SwiftUI

struct AppIconCell: View {

    @State var icon: Icon
    @Binding var selectedItem: String
    @Environment(\.colorScheme) var colorScheme
    var isSelected: Bool {
        selectedItem == icon.id
    }
    
    private let circleSize: CGFloat = 24.0
    
    var body: some View {
        HStack(spacing: 25) {
            IconImage(icon: icon)
            Text(icon.marketingName)
            Spacer()
            
            if isSelected {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: circleSize, height: circleSize)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .font(.callout)
                        .frame(width: circleSize, height: circleSize)
                }
            }
        }
    }

}

struct AppIconCell_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AppIconCell(icon: Icon.primary, selectedItem: .constant(Icon.primary.id))
            AppIconCell(icon: Icon.teuCu, selectedItem: .constant(Icon.primary.id))
        }
        .previewLayout(.fixed(width: 350, height: 100))
    }

}
