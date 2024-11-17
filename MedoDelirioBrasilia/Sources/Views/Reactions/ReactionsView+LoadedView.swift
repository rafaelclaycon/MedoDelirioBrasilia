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
                                    isPinned: true,
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
                                isPinned: false,
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

    struct Pin: View {

        @ScaledMetric private var padding: CGFloat = 5

        var body: some View {
            Image(systemName: "pin.fill")
                .rotationEffect(.degrees(45))
                .foregroundStyle(.white)
                .padding(.all, padding)
                .background {
                    Circle()
                        .fill(.yellow)
                        .shadow(radius: 2, x: 1, y: 1)
                }
        }
    }

    struct InteractibleReactionItem<Button: View>: View {

        let reaction: Reaction
        let isPinned: Bool
        let button: Button

        @ScaledMetric private var pinOffset: CGFloat = -7

        @Environment(\.push) var push

        var body: some View {
            ReactionItem(reaction: reaction)
                .overlay(alignment: .topLeading) {
                    Pin()
                        .offset(x: pinOffset, y: pinOffset)
                }
                .onTapGesture {
                    push(GeneralNavigationDestination.reactionDetail(reaction))
                }
                .contextMenu {
                    button
                }
                .contentShape(
                    .contextMenuPreview,
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
    }
}

// MARK: - Preview

#Preview("Pin") {
    ReactionsView.Pin()
        .padding()
}

#Preview("Pinned Reaction") {
    ReactionsView.InteractibleReactionItem(
        reaction: Reaction.enthusiasmMock,
        isPinned: true,
        button:
            Button {
                print("Tapped")
            } label: {
                Label("Desafixar", systemImage: "pin.slash")
            }
    )
    .padding()
}
