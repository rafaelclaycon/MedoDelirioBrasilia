import SwiftUI

struct FolderCell: View {

    @State var title: String
    
    let regularGradient = LinearGradient(gradient: Gradient(colors: [.babyBlue, .babyBlue]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(regularGradient)
                    .frame(width: 180, height: 90)
                
                Text("😎")
                    .font(.system(size: 54))
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct FolderCell_Previews: PreviewProvider {

    static var previews: some View {
        FolderCell(title: "Memes")
    }

}
