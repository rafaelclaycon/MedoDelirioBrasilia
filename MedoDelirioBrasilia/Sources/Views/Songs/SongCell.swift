//
//  SongCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/05/22.
//

import SwiftUI

struct SongCell: View {

    let song: Song
    
    @Binding var nowPlaying: Set<String>
    @Environment(\.sizeCategory) var sizeCategory
    @State private var timeRemaining: Double = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var isPlaying: Bool {
        nowPlaying.contains(song.id)
    }
    
    private var cellHeight: CGFloat {
        if sizeCategory > ContentSizeCategory.large {
            return 115
        } else {
            return 90
        }
    }
    
    private var durationForDisplay: String {
        if isPlaying {
            return timeRemaining.minuteSecondFormatted
        } else {
            return song.duration.minuteSecondFormatted
        }
    }
    
    private var isNew: Bool {
        return Date.isDateWithinLast7Days(song.dateAdded)
    }
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .foregroundColor(.black)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 10) {
                        Text("\(song.genreName ?? "") · \(durationForDisplay)")
                            .foregroundColor(.white)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                            .onReceive(timer) { time in
                                guard isPlaying else { return }
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                }
                            }

                        if isNew {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(.yellow)
                                    .frame(width: 50, height: 20)

                                Text("NOVA")
                                    .foregroundColor(.black)
                                    .font(.footnote)
                                    .bold()
                                    .opacity(0.7)
                            }
                        }
                    }
                }

                Spacer()

                if isPlaying {
                    Image(systemName: "stop.circle")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding(.trailing)
                }
            }
        }
        .frame(height: cellHeight)
        .padding(.leading, 20)
        .onAppear {
            if !isPlaying {
                timeRemaining = song.duration
            }
        }
        .onChange(of: isPlaying) { isPlaying in
            if !isPlaying {
                timeRemaining = song.duration
            }
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(gradient)
                    .opacity(isPlaying ? 0.7 : 1.0)

                if isPlaying {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(.green)
                                .animation(.linear(duration: 1), value: timeRemaining)

                            Spacer()
                                .frame(width: geometry.size.width * (timeRemaining / song.duration))
                        }
                        .mask {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SongCell(
        song: Song(
            id: "ABC",
            title: "Funk do Morto",
            genreId: "82BFAA10-C01A-4FE0-8366-1B1690D00A40",
            genreName: "Funk",
            duration: 60
        ),
        nowPlaying: .constant(Set<String>())
    )
    .padding(.horizontal)
}
