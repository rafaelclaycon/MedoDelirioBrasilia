//
//  ReactionItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI
import Kingfisher

struct ReactionItem: View {

    let reaction: Reaction

    @State private var isLoading: Bool = true

    // MARK: - Computed Properties

    private var cellHeight: CGFloat {
        UIDevice.isiPhone ? 100 : 120
    }

    private var reduceTextSize: Bool {
        UIDevice.isSmallDevice && reaction.title.count > 8
    }

    // MARK: - View Body

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.4))
            .frame(height: cellHeight)
            .background {
                KFImage(URL(string: reaction.image))
                    .placeholder {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(2)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                                .foregroundColor(.gray)
                        }
                    }
                    .onSuccess { _ in isLoading = false }
                    .onFailure { _ in isLoading = false }
                    .resizable()
                    .scaledToFill()
                    .frame(height: cellHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .overlay {
                Text(reaction.title)
                    .foregroundColor(.white)
                    .font(reduceTextSize ? .title2 : .title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 4, y: 4)
            }
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct ReactionCell_Previews: PreviewProvider {

    static let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    static var previews: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .listRowSeparatorLeading, spacing: 14) {
                    ForEach(Reaction.allMocks) {
                        ReactionItem(reaction: $0)
                    }
                }
                .padding()
                .navigationTitle("Reações")
            }
        }
    }
}
