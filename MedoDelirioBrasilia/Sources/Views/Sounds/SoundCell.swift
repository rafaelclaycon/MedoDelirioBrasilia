//
//  SoundCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct SoundCell: View {

    @State var soundId: String
    @State var title: String
    @State var author: String
    @State var isNew: Bool
    @Binding var favorites: Set<String>
    @Binding var highlighted: Set<String>
    @Binding var nowPlaying: Set<String>
    
    enum Mode {
        case regular, favorite, highlighted
    }
    
    private var currentMode: Mode {
        guard highlighted.contains(soundId) == false else {
            return .highlighted
        }
        
        if favorites.contains(soundId) {
            return .favorite
        } else {
            return .regular
        }
    }
    
    private var cellFill: LinearGradient {
        switch currentMode {
        case .regular:
            return regularGradient
        case .favorite:
            return favoriteGradient
        case .highlighted:
            return highlightGradient
        }
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
    
    private var isPlaying: Bool {
        nowPlaying.contains(soundId)
    }
    
    private let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let favoriteGradient = LinearGradient(gradient: Gradient(colors: [.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let highlightGradient = LinearGradient(gradient: Gradient(colors: [.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cellFill)
                .frame(height: cellHeight)
                .opacity(isPlaying ? 0.7 : 1.0)
            
            if currentMode == .favorite, isPlaying == false {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(.yellow)
                            .padding(.trailing, 10)
                            .padding(.bottom)
                    }
                }
                .frame(height: cellHeight)
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
            
            if isNew, currentMode == .regular, isPlaying == false {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(.yellow)
                                .frame(width: 50, height: 20)
                                
                            Text("NOVO")
                                .foregroundColor(.black)
                                .font(.footnote)
                                .bold()
                                .opacity(0.7)
                        }
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                    }
                }
                .frame(height: cellHeight)
            }
            
            if isPlaying {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "stop.circle")
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                }
                .frame(height: cellHeight)
            }
        }
    }

}

struct SoundRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Regular
            SoundCell(soundId: "ABC", title: "A gente vai cansando", author: "Soraya Thronicke", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            //SoundCell(soundId: "ABC", title: "Funk do Xandão", author: "Roberto Jeferson", favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "Às vezes o ódio é a única emoção possível", author: "Soraya Thronicke", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "É simples assim, um manda e o outro obedece", author: "Soraya Thronicke", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "Você tá falando isso porque você é a putinha do Bozo", author: "Soraya Thronicke", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "A decisão não cabe a gente, cabe ao TSE", author: "Paulo Sérgio Nogueira", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            
            // With New tag
            SoundCell(soundId: "ABC", title: "A decisão não cabe a gente, cabe ao TSE", author: "Paulo Sérgio Nogueira", isNew: true, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            
            // Favorite
            SoundCell(soundId: "DEF", title: "A gente vai cansando", author: "Soraya Thronicke", isNew: false, favorites: .constant(Set<String>(arrayLiteral: "DEF")), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            SoundCell(soundId: "GHI", title: "Funk do Xandão", author: "Roberto Jeferson", isNew: false, favorites: .constant(Set<String>(arrayLiteral: "GHI")), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()))
            
            // Highlighted
            SoundCell(soundId: "JKL", title: "Bom dia", author: "Hamilton Mourão", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>(arrayLiteral: "JKL")), nowPlaying: .constant(Set<String>()))
        }
        .previewLayout(.fixed(width: 170, height: 100))
    }

}
