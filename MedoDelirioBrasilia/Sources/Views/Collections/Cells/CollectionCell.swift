import SwiftUI

struct CollectionCell: View {

    @State var title: String
    
    let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(regularGradient)
                .frame(width: 180)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .foregroundColor(.black)
                        .font(.body)
                        .bold()
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct CollectionCell_Previews: PreviewProvider {

    static var previews: some View {
        CollectionCell(title: "Clássicos")
    }

}
