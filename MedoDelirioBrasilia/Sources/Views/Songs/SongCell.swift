import SwiftUI

struct SongCell: View {

    @State var songId: String
    @State var title: String
    @Binding var nowPlaying: Set<String>
    var isPlaying: Bool {
        nowPlaying.contains(songId)
    }
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
                .frame(height: 90)
                .opacity(isPlaying ? 0.7 : 1.0)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(title)
                        .foregroundColor(.black)
                        .font(.body)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(height: 90)
                    
                    Spacer()
                    
                    if isPlaying {
                        Image(systemName: "stop.circle")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .padding(.trailing)
                    }
                }
            }
            .padding(.leading, 20)
        }
    }

}

struct SongCell_Previews: PreviewProvider {

    static var previews: some View {
        SongCell(songId: "ABC", title: "Test", nowPlaying: .constant(Set<String>()))
    }

}
