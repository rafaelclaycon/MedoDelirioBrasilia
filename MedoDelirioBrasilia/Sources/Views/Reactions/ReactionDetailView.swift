//
//  ReactionDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ReactionDetailView: View {

    @StateObject var viewModel: ReactionDetailViewModel
    
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                VStack {
                    HStack(spacing: 10) {
                        ProgressView()

                        Text("Carregando sons...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)

            case .loaded(_):
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
                    ),
                    headerView: AnyView(
                        ReactionDetailHeader(
                            title: viewModel.reaction.title,
                            subtitle: viewModel.subtitle,
                            imageUrl: viewModel.reaction.image
                        )
                        .frame(height: 250)
                        .padding(.bottom, 6)
                    )
                )

            case .error(let errorString):
                VStack {
                    Text("Erro ao carregar os sons dessa Reação. :(\n\n\(errorString)")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .toolbar {
            toolbarControls()
                .foregroundStyle(.white)
                .opacity(viewModel.sounds.isEmpty ? 0.5 : 1.0)
                .disabled(viewModel.sounds.isEmpty)
        }
        .oneTimeTask {
            await viewModel.loadSounds()
        }
        .edgesIgnoringSafeArea(.top)
    }

    @ViewBuilder func toolbarControls() -> some View {
        HStack(spacing: 15) {
            Button {
//                if viewModel.isPlayingPlaylist {
//                    viewModel.stopPlaying()
//                } else {
//                    viewModel.playAllSoundsOneAfterTheOther()
//                }
            } label: {
                Image(systemName: "play.fill")
            }
            .disabled(viewModel.sounds.isEmpty)

            Menu {
                Section {
                    Button {
                        // viewModel.startSelecting()
                    } label: {
                        // Label(currentSoundsListMode == .selection ? "Cancelar Seleção" : "Selecionar", systemImage: currentSoundsListMode == .selection ? "xmark.circle" : "checkmark.circle")
                        Label("Selecionar", systemImage: "checkmark.circle")
                    }
                }

                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        ForEach(ReactionSoundSortOption.allCases, id: \.self) { option in
                            Text(option.description).tag(option)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
//            .onChange(of: viewModel.soundSortOption) {
//                viewModel.sortSounds(by: SoundSortOption(rawValue: $0) ?? .dateAddedDescending)
//                UserSettings.setSoundSortOption(to: $0)
//            }
        }
    }
}

#Preview {
    ReactionDetailView(viewModel: .init(reaction: .acidMock))
}
