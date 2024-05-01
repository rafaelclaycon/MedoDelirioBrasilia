//
//  ReactionDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ReactionDetailView: View {

    @StateObject var viewModel: ReactionDetailViewModel

    var body: some View {
        VStack {
            SoundList(
                viewModel: .init(
                    data: viewModel.soundsPublisher,
                    menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
                    currentSoundsListMode: .constant(.regular)
                ),
                stopShowingFloatingSelector: .constant(nil),
                emptyStateView: AnyView(
                    Text("Nenhum som a ser exibido. Isso é esquisito.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                )
            )
        }
        .navigationTitle(Text(viewModel.reactionTitle))
        .onAppear {
            viewModel.loadSounds()
        }
    }
}

#Preview {
    ReactionDetailView(viewModel: .init(reactionTitle: "entusiasmo"))
}

// https://images.unsplash.com/photo-1489710437720-ebb67ec84dd2?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
