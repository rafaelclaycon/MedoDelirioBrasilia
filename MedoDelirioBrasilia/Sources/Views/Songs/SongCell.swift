//
//  SongCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/05/22.
//

import SwiftUI

struct SongCell: View {

    @State var songId: String
    @State var title: String
    @State var genre: MusicGenre
    @State var duration: String
    @State var isNew: Bool
    @Binding var nowPlaying: Set<String>
    @Environment(\.sizeCategory) var sizeCategory
    
    var isPlaying: Bool {
        nowPlaying.contains(songId)
    }
    
    private var cellHeight: CGFloat {
        if sizeCategory > ContentSizeCategory.large {
            return 115
        } else {
            return 90
        }
    }
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
                .frame(height: cellHeight)
                .opacity(isPlaying ? 0.7 : 1.0)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .foregroundColor(.black)
                            .bold()
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 10) {
                            Text("\(genre.name) · \(duration)")
                                .foregroundColor(.white)
                                .font(.callout)
                                .multilineTextAlignment(.leading)
                            
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
            .padding(.leading, 20)
        }
    }

}

struct SongCell_Previews: PreviewProvider {

    static var previews: some View {
        SongCell(songId: "ABC", title: "Funk do Morto", genre: .funk, duration: "01:00", isNew: false, nowPlaying: .constant(Set<String>()))
            .padding(.horizontal)
            .previewLayout(.fixed(width: 414, height: 100))
    }

}
