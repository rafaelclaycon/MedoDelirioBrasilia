import SwiftUI

struct ColorSelectionCell: View {

    @State var color: Color
    @Binding var selectedColor: String
    
    var isSelected: Bool {
        return selectedColor == color.name ?? ""
    }
    
    private let borderCircle: CGFloat = 44
    private let innerCircle: CGFloat = 37
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .strokeBorder(color, lineWidth: 2)
                    .frame(width: borderCircle, height: borderCircle)
                    .saturation(1.5)
            }
            
            Circle()
                .fill(color)
                .frame(width: innerCircle, height: innerCircle)
        }
        .frame(width: borderCircle, height: borderCircle)
        .onTapGesture {
            selectedColor = color.name ?? "pastelBabyBlue"
        }
    }

}

struct ColorSelectionCell_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ColorSelectionCell(color: .pastelBabyBlue, selectedColor: .constant("pastelBabyBlue"))
            ColorSelectionCell(color: .pastelBabyBlue, selectedColor: .constant("pastelBrightGreen"))
        }
        .previewLayout(.fixed(width: 100, height: 100))
    }

}
