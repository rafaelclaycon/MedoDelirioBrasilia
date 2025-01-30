//
//  WPSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/12/24.
//

import SwiftUI

struct WPSoundsView: View {

    @StateObject private var viewModel: MainSoundContainerViewModel
    @StateObject private var allSoundsViewModel: SoundListViewModel<[Sound]>

    init(
        viewModel: MainSoundContainerViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._allSoundsViewModel = StateObject(wrappedValue: SoundListViewModel<[Sound]>(
            data: viewModel.allSoundsPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: .constant(.regular)
        ))
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("sons")
                        .font(.system(size: 90))
                        .fontWeight(.light)

                    Spacer()
                }
                .padding()

                switch allSoundsViewModel.state {
                case .loading:
                    ProgressView()

                case .loaded(let sounds):
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(sounds) { sound in
                            WPSoundItem(
                                sound: sound
                            )
                            .padding(.horizontal, 10)
                            //                        .onTapGesture {
                            //                            viewModel.onSoundSelected(sound: sound)
                            //                        }
                        }
                    }

                case .error(let errorMessage):
                    Text("Erro: \(errorMessage)")
                }

                Spacer()
            }
        }
        .onAppear {
            print("WP SOUNDS VIEW - ON APPEAR")

            viewModel.reloadAllSounds()
            //viewModel.reloadFavorites()
            //favoritesViewModel.loadFavorites()
        }
    }
}

//#Preview {
//    WPSoundsView()
//}
