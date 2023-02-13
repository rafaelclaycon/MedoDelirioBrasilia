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
    @State var duration: Double
    @State var isNew: Bool
    @Binding var favorites: Set<String>
    @Binding var highlighted: Set<String>
    @Binding var nowPlaying: Set<String>
    @Binding var selectedItems: Set<String>
    @Binding var currentSoundsListMode: SoundsListMode
    @State private var timeRemaining: Double = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let unselectedForegroundColor: Color = .gray
    
    enum Background {
        case regular, favorite, highlighted
    }
    
    enum Mode {
        case regular, playing, upForSelection, selected
    }
    
    private var currentMode: Mode {
        if currentSoundsListMode == .selection {
            return selectedItems.contains(soundId) ? .selected : .upForSelection
        } else {
            return nowPlaying.contains(soundId) ? .playing : .regular
        }
    }
    
    private var background: Background {
        guard highlighted.contains(soundId) == false else {
            return .highlighted
        }
        if favorites.contains(soundId) {
            return .favorite
        } else {
            return .regular
        }
    }
    
    private var backgroundOpacity: Double {
        switch currentMode {
        case .regular:
            return 1.0
        case .playing:
            return 0.7
        case .upForSelection:
            return 0.7
        case .selected:
            return 1.0
        }
    }
    
    private var cellFill: LinearGradient {
        switch background {
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
        if (UIScreen.main.bounds.width <= 390) && (title.count > 20) {
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
    
    private var subtitle: String {
        if currentMode == .playing {
            if duration < 1.0 {
                return "< 1 s"
            }
            return timeRemaining.asString()
        } else {
            return author
        }
    }
    
    private let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let favoriteGradient = LinearGradient(gradient: Gradient(colors: [.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let highlightGradient = LinearGradient(gradient: Gradient(colors: [.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cellFill)
                .frame(height: cellHeight)
                .opacity(backgroundOpacity)
            
            if background == .favorite, currentMode == .regular {
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
                    
                    Text(subtitle)
                        .font(UIDevice.is4InchDevice ? .footnote : authorFont)
                        .foregroundColor(.white)
                        .lineLimit(authorNameLineLimit)
                        .onReceive(timer) { time in
                            guard currentMode == .playing else { return }
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                            }
                        }
                }
                
                Spacer()
            }
            .padding(.leading, UIDevice.is4InchDevice ? 10 : 20)
            
            if isNew, background == .regular, currentMode == .regular {
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
            
            if currentMode == .playing {
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
            
            if currentMode == .upForSelection {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoundCheckbox(selected: .constant(false), style: .default)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                }
                .frame(height: cellHeight)
            } else if currentMode == .selected {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoundCheckbox(selected: .constant(true), style: .default)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                }
                .frame(height: cellHeight)
            }
        }
        .onAppear {
            if currentMode != .playing {
                timeRemaining = duration
            }
        }
        .onChange(of: currentMode) { currentMode in
            if currentMode != .playing {
                timeRemaining = duration
            }
        }
    }

}

struct SoundRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Regular
            SoundCell(soundId: "ABC", title: "A gente vai cansando", author: "Soraya Thronicke", duration: 2, isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            //SoundCell(soundId: "ABC", title: "Funk do Xandão", author: "Roberto Jeferson", favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()))
            SoundCell(soundId: "ABC", title: "Às vezes o ódio é a única emoção possível", author: "Soraya Thronicke", duration: 2, isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            SoundCell(soundId: "ABC", title: "É simples assim, um manda e o outro obedece", author: "Soraya Thronicke", duration: 2, isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            SoundCell(soundId: "ABC", title: "Você tá falando isso porque você é a putinha do Bozo", author: "Soraya Thronicke", duration: 2, isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            SoundCell(soundId: "ABC", title: "A decisão não cabe a gente, cabe ao TSE", author: "Paulo Sérgio Nogueira", duration: 2, isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            
            // With New tag
            SoundCell(soundId: "ABC", title: "A decisão não cabe a gente, cabe ao TSE", author: "Paulo Sérgio Nogueira", duration: 2, isNew: true, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            
            // Favorite
            SoundCell(soundId: "DEF", title: "A gente vai cansando", author: "Soraya Thronicke", duration: 2, isNew: false, favorites: .constant(Set<String>(arrayLiteral: "DEF")), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            SoundCell(soundId: "GHI", title: "Funk do Xandão", author: "Roberto Jeferson", duration: 2, isNew: false, favorites: .constant(Set<String>(arrayLiteral: "GHI")), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
            
            // Highlighted
            SoundCell(soundId: "JKL", title: "Bom dia", author: "Hamilton Mourão", duration: 2, isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>(arrayLiteral: "JKL")), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular))
        }
        .previewLayout(.fixed(width: 170, height: 100))
    }

}
