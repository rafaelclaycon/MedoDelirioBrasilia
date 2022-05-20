import SwiftUI

struct SoundRow: View {

    @State var title: String
    @State var author: String
    
    let gradiente = LinearGradient(gradient: Gradient(colors: [.darkGreen, .darkGreen, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradiente)
                .frame(height: 90)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.body)
                        .bold()
                    
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct SoundRow_Previews: PreviewProvider {

    static var previews: some View {
        SoundRow(title: "A gente vai cansando", author: "Soraya Thronicke")
    }

}
