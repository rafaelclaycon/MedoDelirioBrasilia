import SwiftUI

struct SoundRow: View {
    
    @State var title: String
    @State var author: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.body)
                    .bold()
                
                Text(author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

}

struct SoundRow_Previews: PreviewProvider {

    static var previews: some View {
        SoundRow(title: "A gente vai cansando", author: "Soraya Thronicke")
    }

}
