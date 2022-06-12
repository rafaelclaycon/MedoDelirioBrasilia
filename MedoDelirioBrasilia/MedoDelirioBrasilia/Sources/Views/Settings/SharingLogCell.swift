import SwiftUI

struct SharingLogCell: View {

    @State var destination: ShareDestination
    @State var contentType: ContentType
    @State var contentTitle: String
    @State var dateTime: String
    
    var symbolColor: Color {
        switch destination {
        case .whatsApp:
            return .green
        case .telegram:
            return .blue
        case .other:
            return .primary
        }
    }
    var typeToText: String {
        switch contentType {
        case .sound:
            return "Som"
        case .song:
            return "Música"
        }
    }
    var adjective: String {
        switch contentType {
        case .sound:
            return "compartilhado"
        case .song:
            return "compartilhada"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: "arrow.up.right")
                .resizable()
                .scaledToFit()
                .frame(height: 16)
                .foregroundColor(symbolColor)
                .padding(.leading, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(typeToText) \"\(contentTitle)\" \(adjective)")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(dateTime)
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
    }

}

struct SharingLogCell_Previews: PreviewProvider {

    static var previews: some View {
        SharingLogCell(destination: .whatsApp, contentType: .sound, contentTitle: "Adora falar rebuscado", dateTime: "11/06/2022 00:23")
    }

}
