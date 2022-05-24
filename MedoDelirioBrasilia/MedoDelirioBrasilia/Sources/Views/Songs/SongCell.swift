import SwiftUI

struct SongCell: View {

    @State var title: String
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.darkGreen, .darkGreen, .darkGreen, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
                .frame(height: 90)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.body) // title.count > 26 ? .callout : 
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(height: 90)
                    
                    Spacer()
                    
//                    Image(systemName: "play.fill")
//                        .foregroundColor(.white)
                }
            }
            .padding(.leading, 20)
        }
    }

}

struct SongCell_Previews: PreviewProvider {

    static var previews: some View {
        SongCell(title: "Test")
    }

}
