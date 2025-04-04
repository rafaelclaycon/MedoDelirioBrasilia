//
//  SoundItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct SoundItem: View {

    let sound: Sound
    var showNewTag: Bool = true

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
            return selectedItems.contains(sound.id) ? .selected : .upForSelection
        } else {
            return nowPlaying.contains(sound.id) ? .playing : .regular
        }
    }
    
    private var background: Background {
        guard highlighted.contains(sound.id) == false else {
            return .highlighted
        }
        if favorites.contains(sound.id) {
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
        if sound.title.count <= 26 {
            return .body
        } else if (sound.title.count >= 27 && sound.title.count <= 40) && (sound.authorName?.count ?? 0 < 20) {
            return .callout
        } else {
            return .footnote
        }
    }
    
    private var authorFont: Font {
        if sound.title.count <= 26 {
            return .subheadline
        } else if sound.title.count >= 27 && sound.title.count <= 40 {
            return .callout
        } else {
            return .footnote
        }
    }
    
    private var authorNameLineLimit: Int {
        if (UIScreen.main.bounds.width <= 390) && (sound.title.count > 20) {
            return 1
        } else {
            return 2
        }
    }
    
    private var itemHeight: CGFloat {
        if UIDevice.isiPhone {
            return 100
        } else {
            return UIDevice.isiPadMini ? 116 : 100
        }
    }
    
    private var subtitle: String {
        if currentMode == .playing {
            if sound.duration < 1.0 {
                return "< 1 s"
            }
            return timeRemaining.minuteSecondFormatted
        } else {
            return sound.authorName ?? ""
        }
    }
    
    private var isNew: Bool {
        guard showNewTag else { return false }
        return Date.isDateWithinLast7Days(sound.dateAdded)
    }
    
    private let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let favoriteGradient = LinearGradient(gradient: Gradient(colors: [.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let highlightGradient = LinearGradient(gradient: Gradient(colors: [.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cellFill)
                .frame(height: itemHeight)
                .opacity(backgroundOpacity)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(sound.title)
                        .foregroundColor(.black)
                        .font(titleFont)
                        .bold()
                    
                    Text(subtitle)
                        .font(UIDevice.isNarrowestWidth ? .footnote : authorFont)
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
            .padding(.leading, UIDevice.isNarrowestWidth ? 10 : 20)

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
                .frame(height: itemHeight)
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
                .frame(height: itemHeight)
            }
            
            if currentMode == .upForSelection {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoundCheckbox(selected: .constant(false))
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                }
                .frame(height: itemHeight)
            } else if currentMode == .selected {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoundCheckbox(selected: .constant(true))
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                }
                .frame(height: itemHeight)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if background == .favorite, currentMode == .regular {
                Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundColor(.yellow)
                .padding(.trailing, 10)
                .padding(.bottom)
                .shadow(color: .red, radius: 8)
            }
        }
        .onAppear {
            if currentMode != .playing {
                timeRemaining = sound.duration
            }
        }
        .onChange(of: currentMode) { currentMode in
            if currentMode != .playing {
                timeRemaining = sound.duration
            }
        }
    }

}

// MARK: - Previews

#Preview("Regular") {
    VStack(spacing: 15) {
        HStack(spacing: 15) {
            SoundItem(
                sound: Sound(
                    id: "ABC",
                    title: "A gente vai cansando",
                    authorName: "Filósofo da CEAGESP",
                    dateAdded: .now - 1_000_000, // 11.6 days
                    duration: 2
                ),
                favorites: .constant(Set<String>()),
                highlighted: .constant(Set<String>()),
                nowPlaying: .constant(Set<String>()),
                selectedItems: .constant(Set<String>()),
                currentSoundsListMode: .constant(.regular)
            )

            SoundItem(
                sound: Sound(
                    id: "DEF",
                    title: "Às vezes o ódio é a única emoção possível",
                    authorName: "Soraya Thronicke",
                    dateAdded: .now - 1_000_000, // 11.6 days
                    duration: 2
                ),
                favorites: .constant(Set<String>()),
                highlighted: .constant(Set<String>()),
                nowPlaying: .constant(Set<String>()),
                selectedItems: .constant(Set<String>()),
                currentSoundsListMode: .constant(.regular)
            )
        }

        SoundItem(
            sound: Sound(
                id: "DEF",
                title: "É simples assim, um manda e o outro obedece",
                authorName: "Soraya Thronicke",
                dateAdded: .now - 1_000_000, // 11.6 days
                duration: 2
            ),
            favorites: .constant(Set<String>()),
            highlighted: .constant(Set<String>()),
            nowPlaying: .constant(Set<String>()),
            selectedItems: .constant(Set<String>()),
            currentSoundsListMode: .constant(.regular)
        )
    }
    .padding()
}

#Preview("Favorite") {
    VStack(spacing: 15) {
        HStack(spacing: 15) {
            SoundItem(
                sound: Sound(
                    id: "ABC",
                    title: "A gente vai cansando",
                    authorName: "Filósofo da CEAGESP",
                    duration: 2
                ),
                favorites: .constant(Set<String>(arrayLiteral: "ABC")),
                highlighted: .constant(Set<String>()),
                nowPlaying: .constant(Set<String>()),
                selectedItems: .constant(Set<String>()),
                currentSoundsListMode: .constant(.regular)
            )

            SoundItem(
                sound: Sound(
                    id: "DEF",
                    title: "A gente vai cansando",
                    authorName: "Soraya Thronicke",
                    duration: 2
                ),
                favorites: .constant(Set<String>(arrayLiteral: "DEF")),
                highlighted: .constant(Set<String>()),
                nowPlaying: .constant(Set<String>()),
                selectedItems: .constant(Set<String>()),
                currentSoundsListMode: .constant(.regular)
            )
        }

        SoundItem(
            sound: Sound(
                id: "DEF",
                title: "A gente vai cansando",
                authorName: "Soraya Thronicke",
                duration: 2
            ),
            favorites: .constant(Set<String>(arrayLiteral: "DEF")),
            highlighted: .constant(Set<String>()),
            nowPlaying: .constant(Set<String>()),
            selectedItems: .constant(Set<String>()),
            currentSoundsListMode: .constant(.regular)
        )
    }
    .padding()
}

#Preview("Playing") {
    VStack(spacing: 15) {
        HStack(spacing: 15) {
            SoundItem(
                sound: Sound(
                    id: "ABC",
                    title: "A gente vai cansando",
                    authorName: "Filósofo da CEAGESP",
                    duration: 2
                ),
                favorites: .constant(Set<String>(arrayLiteral: "ABC")),
                highlighted: .constant(Set<String>()),
                nowPlaying: .constant(Set<String>(arrayLiteral: "ABC")),
                selectedItems: .constant(Set<String>()),
                currentSoundsListMode: .constant(.regular)
            )

            SoundItem(
                sound: Sound(
                    id: "DEF",
                    title: "A gente vai cansando",
                    authorName: "Soraya Thronicke",
                    duration: 2
                ),
                favorites: .constant(Set<String>()),
                highlighted: .constant(Set<String>()),
                nowPlaying: .constant(Set<String>(arrayLiteral: "DEF")),
                selectedItems: .constant(Set<String>()),
                currentSoundsListMode: .constant(.regular)
            )
        }

        SoundItem(
            sound: Sound(
                id: "DEF",
                title: "A gente vai cansando",
                authorName: "Soraya Thronicke",
                duration: 2
            ),
            favorites: .constant(Set<String>()),
            highlighted: .constant(Set<String>()),
            nowPlaying: .constant(Set<String>(arrayLiteral: "DEF")),
            selectedItems: .constant(Set<String>()),
            currentSoundsListMode: .constant(.regular)
        )
    }
    .padding()
}

#Preview("New Tag") {
    SoundItem(sound: Sound(id: "ABC", title: "A decisão não cabe a gente, cabe ao TSE", authorName: "Paulo Sérgio Nogueira", duration: 2), favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular)
    )
    .padding()
}

#Preview("Highlighted") {
    SoundItem(sound: Sound(id: "JKL", title: "Bom dia", authorName: "Hamilton Mourão", duration: 2), favorites: .constant(Set<String>()), highlighted: .constant(Set<String>(arrayLiteral: "JKL")), nowPlaying: .constant(Set<String>()), selectedItems: .constant(Set<String>()), currentSoundsListMode: .constant(.regular)
    )
    .padding()
}
