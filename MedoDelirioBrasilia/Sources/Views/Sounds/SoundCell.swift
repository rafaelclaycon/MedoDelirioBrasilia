import SwiftUI

struct SoundCell: View {

    @State var soundId: String
    @State var title: String
    @State var author: String
    @Binding var favorites: Set<String>
    
    private var isFavorite: Bool {
        favorites.contains(soundId)
    }
    
    private var titleFont: Font {
        if title.count <= 26 {
            return .body
        } else if (title.count >= 27 && title.count <= 40) && (author.count < 20) {
            return .callout
        } else {
            return .footnote
        }
    }
    
    private var authorFont: Font {
        if title.count <= 26 {
            return .subheadline
        } else if title.count >= 27 && title.count <= 40 {
            return .callout
        } else {
            return .footnote
        }
    }
    
    private let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let favoriteGradient = LinearGradient(gradient: Gradient(colors: [.red, .red, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isFavorite ? favoriteGradient : regularGradient)
                .frame(height: UIDevice.is4InchDevice ? 120 : 96)
            
            if isFavorite {
                HStack {
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(.yellow)
                        .offset(y: -22)
                }
                .padding(.trailing, 10)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .foregroundColor(.black)
                        .font(titleFont)
                        .bold()
                    
                    Text(author)
                        .font(UIDevice.is4InchDevice ? .footnote : authorFont)
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.leading, UIDevice.is4InchDevice ? 10 : 20)
        }
    }

}

struct SoundRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Regular
            SoundCell(soundId: "ABC", title: "A gente vai cansando", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            //SoundCell(soundId: "ABC", title: "Funk do Xand??o", author: "Roberto Jeferson", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "??s vezes o ??dio ?? a ??nica emo????o poss??vel", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "?? simples assim, um manda e o outro obedece", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "Voc?? t?? falando isso porque voc?? ?? a putinha do Bozo", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "A decis??o n??o cabe a gente, cabe ao TSE", author: "Paulo S??rgio Nogueira", favorites: .constant(Set<String>()))
            
            // Favorite
            SoundCell(soundId: "DEF", title: "A gente vai cansando", author: "Soraya Thronicke", favorites: .constant(Set<String>(arrayLiteral: "DEF")))
            SoundCell(soundId: "GHI", title: "Funk do Xand??o", author: "Roberto Jeferson", favorites: .constant(Set<String>(arrayLiteral: "GHI")))
        }
        .previewLayout(.fixed(width: 170, height: 100))
    }

}
