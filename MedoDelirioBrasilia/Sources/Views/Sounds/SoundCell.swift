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
    
    private var authorNameLineLimit: Int {
        if (UIScreen.main.bounds.width < 380) && (title.count > 20) {
            return 1
        } else {
            return 2
        }
    }
    
    private var cellHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIDevice.is4InchDevice ? 120 : 96
        } else {
            return UIDevice.isiPadMini ? 116 : 96
        }
    }
    
    private let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let favoriteGradient = LinearGradient(gradient: Gradient(colors: [.red, .red, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isFavorite ? favoriteGradient : regularGradient)
                .frame(height: cellHeight)
            
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
                        .lineLimit(authorNameLineLimit)
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
            //SoundCell(soundId: "ABC", title: "Funk do Xandão", author: "Roberto Jeferson", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "Às vezes o ódio é a única emoção possível", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "É simples assim, um manda e o outro obedece", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "Você tá falando isso porque você é a putinha do Bozo", author: "Soraya Thronicke", favorites: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "A decisão não cabe a gente, cabe ao TSE", author: "Paulo Sérgio Nogueira", favorites: .constant(Set<String>()))
            
            // Favorite
            SoundCell(soundId: "DEF", title: "A gente vai cansando", author: "Soraya Thronicke", favorites: .constant(Set<String>(arrayLiteral: "DEF")))
            SoundCell(soundId: "GHI", title: "Funk do Xandão", author: "Roberto Jeferson", favorites: .constant(Set<String>(arrayLiteral: "GHI")))
        }
        .previewLayout(.fixed(width: 170, height: 100))
    }

}
