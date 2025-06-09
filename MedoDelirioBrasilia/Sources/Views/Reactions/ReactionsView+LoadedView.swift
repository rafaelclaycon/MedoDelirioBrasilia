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
        let pinAction: (Reaction) -> Void
        let unpinAction: (Reaction) -> Void

        @State private var removedReaction: Reaction?
        @State private var showReactionRemovedAlert = false
        @State private var shouldDisplayPinBanner: Bool = false

        var body: some View {
            ScrollView {
                VStack {
                    if shouldDisplayPinBanner {
                        PinReactionsBanner(
                            isBeingShown: $shouldDisplayPinBanner
                        )
                        .layoutPriority(1)
                        .padding(.bottom)
                    }

                    if let pinnedReactions, pinnedReactions.count > 0 {
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
                                            unpinAction(reaction)
                                        } label: {
                                            Label("Desafixar", systemImage: "pin.slash")
                                        },
                                    reactionRemovedAction: {
                                        print("Reaction removed: \($0.title)")
                                        removedReaction = $0
                                        showReactionRemovedAlert = true
                                    }
                                )
                            }
                        }

                        Divider()
                            .padding(.vertical, 10)
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
                                        pinAction(reaction)
                                    } label: {
                                        Label("Fixar no Topo", systemImage: "pin")
                                    },
                                reactionRemovedAction: { _ in }
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
            .onAppear {
                shouldDisplayPinBanner = !AppPersistentMemory.shared.hasSeenPinReactionsBanner()
            }
            .alert(
                "A Reação \"\(removedReaction?.title ?? "")\" Foi Removida",
                isPresented: $showReactionRemovedAlert,
                actions: {
                    Button("Remover Fixação", action: {
                        guard let reaction = removedReaction else { return }
                        unpinAction(reaction)
                    })
                },
                message: { Text("Essa reação foi removida do servidor durante uma revisão. Pedimos desculpas pelo inconveniente.") }
            )
        }
    }

    struct InteractibleReactionItem<Button: View>: View {

        let reaction: Reaction
        let isPinned: Bool
        let button: Button
        let reactionRemovedAction: (Reaction) -> Void

        @Environment(\.push) var push

        var body: some View {
            ReactionItem(reaction: reaction)
                .onTapGesture {
                    if reaction.type == .pinnedRemoved {
                        reactionRemovedAction(reaction)
                    } else {
                        push(GeneralNavigationDestination.reactionDetail(reaction))
                    }
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

#Preview("Pinned Reaction") {
    ReactionsView.InteractibleReactionItem(
        reaction: Reaction.enthusiasmMock,
        isPinned: true,
        button:
            Button {
                print("Tapped")
            } label: {
                Label("Desafixar", systemImage: "pin.slash")
            },
        reactionRemovedAction: { _ in }
    )
    .padding()
}
