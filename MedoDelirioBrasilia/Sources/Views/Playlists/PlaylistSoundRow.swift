//
//  PlaylistSoundRow.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistSoundRow: View {
    
    @State var soundId: String
    @State var title: String
    @State var author: String
    @State var duration: Double
    @Binding var nowPlaying: Set<String>
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
        return nowPlaying.contains(soundId) ? .playing : .regular
    }
    
    private var background: Background {
        return .regular
    }
    
    private var backgroundOpacity: Double {
        return 0.7
    }
    
    private var cellFill: Color {
        return .green
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
                        RoundCheckbox(selected: .constant(false))
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
                        RoundCheckbox(selected: .constant(true))
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

struct PlaylistSoundRow_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistSoundRow(soundId: "ABC", title: "A gente vai cansando", author: "Soraya Thronicke", duration: 2, nowPlaying: .constant(Set<String>()))
    }
    
}
