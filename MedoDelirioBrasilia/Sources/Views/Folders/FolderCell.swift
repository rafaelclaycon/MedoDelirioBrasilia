import SwiftUI

struct FolderCell: View {

    @State var symbol: String
    @State var title: String
    @State var backgroundColor: Color
    @State var backgroundOpacity: Double = 1.0
    @State var height: CGFloat = 90
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(backgroundColor)
                    .frame(height: height)
                    .opacity(backgroundOpacity)
                
                Text(symbol)
                    .font(.system(size: 54))
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.leading, 15)
        }
    }

}

struct FolderCell_Previews: PreviewProvider {

    static var previews: some View {
        FolderCell(symbol: "😎", title: "Memes", backgroundColor: .pastelBabyBlue)
    }

}