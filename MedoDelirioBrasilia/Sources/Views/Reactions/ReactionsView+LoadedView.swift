//
//  ReactionsView+LoadedView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/11/24.
//

import SwiftUI

extension ReactionsView {

    struct LoadedView: View {

        let pinnedReactions: [Reaction]?
        let otherReactions: [Reaction]
        let columns: [GridItem]
        let pullToRefreshAction: () -> Void
        let pinAction: () -> Void
        let unpinAction: () -> Void

        var body: some View {
            ScrollView {
                VStack {
                    if let pinnedReactions {
                        LazyVGrid(
                            columns: columns,
                            spacing: UIDevice.isiPhone ? 12 : 20
                        ) {
                            ForEach(pinnedReactions) { reaction in
                                InteractibleReactionItem(
                                    reaction: reaction,
                                    button:
                                        Button {
                                            unpinAction()
                                        } label: {
                                            Label("Desafixar", systemImage: "pin.slash")
                                        }
                                )
                            }
                        }
                    }

                    LazyVGrid(
                        columns: columns,
                        spacing: UIDevice.isiPhone ? 12 : 20
                    ) {
                        ForEach(otherReactions) { reaction in
                            InteractibleReactionItem(
                                reaction: reaction,
                                button:
                                    Button {
                                        pinAction()
                                    } label: {
                                        Label("Fixar", systemImage: "pin")
                                    }
                            )
                        }
                    }
                }
                .padding()
                .navigationTitle("Reações")
            }
            .refreshable {
                pullToRefreshAction()
            }
        }
    }

    struct InteractibleReactionItem<Button: View>: View {

        let reaction: Reaction
        let button: Button

        @Environment(\.push) var push

        var body: some View {
            ReactionItem(reaction: reaction)
                .onTapGesture {
                    push(GeneralNavigationDestination.reactionDetail(reaction))
                }
                .contextMenu {
                    button
                }
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// MARK: - Preview

//#Preview {
//    ReactionsView.LoadedView(
//
//    )
//}
