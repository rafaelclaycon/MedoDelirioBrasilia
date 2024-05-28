//
//  ReactionCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI
import Kingfisher

struct ReactionCell: View {

    let reaction: Reaction

    private var cellHeight: CGFloat {
        UIDevice.isiPhone ? 100 : 120
    }

    private var reduceTextSize: Bool {
        UIDevice.isSmallDevice && reaction.title.count > 8
    }

    var body: some View {
        HStack {
            Spacer()

            Text(reaction.title)
                .foregroundColor(.white)
                .font(reduceTextSize ? .title2 : .title)
                .bold()
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 4, y: 4)

            Spacer()
        }
        .frame(height: cellHeight)
        .background {
            HStack {
                KFImage(URL(string: reaction.image))
                    .placeholder {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: cellHeight)
            .overlay(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct ReactionCell_Previews: PreviewProvider {

    static let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    static var previews: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .listRowSeparatorLeading, spacing: 14) {
                    ForEach(Reaction.allMocks) {
                        ReactionCell(reaction: $0)
                    }
                }
                .padding()
                .navigationTitle("Reações")
            }
        }
    }
}
