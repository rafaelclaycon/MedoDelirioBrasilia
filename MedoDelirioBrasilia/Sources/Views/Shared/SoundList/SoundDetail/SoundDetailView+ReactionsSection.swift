//
//  SoundDetailView+ReactionsSection.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/11/24.
//

import SwiftUI

extension SoundDetailView {

    struct ReactionsSection: View {

        let state: LoadingState<[Reaction]>
        let openReactionAction: (Reaction) -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Reações Em Que Aparece")
                    .font(.title3)
                    .bold()
                    .padding(.leading, .spacing(.medium))

                switch state {
                case .loading:
                    PodiumPair.LoadingView()
                        .padding(.horizontal, .spacing(.small))

                case .loaded(let reactions):
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(reactions) { reaction in
                                ReactionItem(reaction: reaction)
                                    .frame(width: 180)
                                    .onTapGesture {
                                        openReactionAction(reaction)
                                    }
                            }
                        }
                        .padding(.horizontal, .spacing(.medium))
                    }

                case .error(_):
                    PodiumPair.LoadingErrorView(
                        retryAction: {}
                    )
                    .padding(.horizontal, .spacing(.small))
                }
            }
        }
    }
}
