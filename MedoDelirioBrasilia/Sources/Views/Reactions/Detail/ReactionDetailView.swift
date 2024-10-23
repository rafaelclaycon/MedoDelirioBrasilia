//
//  ReactionDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ReactionDetailView: View {

    @StateObject var viewModel: ReactionDetailViewModel
    @StateObject private var soundListViewModel: SoundListViewModel<[Sound]>

    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    // MARK: - Computed Properties

    private var toolbarControlsOpacity: CGFloat {
        guard let sounds = viewModel.sounds else { return 1.0 }
        return sounds.isEmpty ? 0.5 : 1.0
    }

    private var soundArrayIsEmpty: Bool {
        guard let sounds = viewModel.sounds else { return true }
        return sounds.isEmpty
    }

    // MARK: - Initializer

    init(
        reaction: Reaction,
        currentSoundsListMode: Binding<SoundsListMode>
    ) {
        let viewModel = ReactionDetailViewModel(reaction: reaction)

        self._viewModel = StateObject(wrappedValue: viewModel)

        let soundListViewModel = SoundListViewModel<[Sound]>(
            data: viewModel.soundsPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: currentSoundsListMode
        )

        self._soundListViewModel = StateObject(wrappedValue: soundListViewModel)
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            SoundList(
                viewModel: soundListViewModel,
                soundSearchTextIsEmpty: .constant(nil),
                dataLoadingDidFail: viewModel.dataLoadingDidFail,
                headerView: {
                    ReactionDetailHeader(
                        title: viewModel.reaction.title,
                        subtitle: viewModel.subtitle,
                        imageUrl: viewModel.reaction.image
                    )
                    .frame(height: 250)
                    .padding(.bottom, 6)
                },
                loadingView:
                    VStack(spacing: 40) {
                        Spacer()

                        HStack(spacing: 10) {
                            ProgressView()

                            Text("Carregando sons...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)

                        Spacer()
                    }
                ,
                emptyStateView:
                    VStack(spacing: 40) {
                        Spacer()

                        Image(systemName: "pc")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundStyle(.gray)

                        Text("Essa Reação está vazia. Parece que você chegou muito cedo.")
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)

                        Button {
                            Task {
                                await viewModel.loadSounds()
                            }
                        } label: {
                            Label("Recarregar", systemImage: "arrow.clockwise")
                        }
                        .padding(.bottom)

                        Spacer()
                    }
                    .padding(.horizontal, 30)
                ,
                errorView:
                    VStack(spacing: 40) {
                        Text("☹️")
                            .font(.system(size: 86))

                        VStack(spacing: 40) {
                            Text("Erro ao Carregar os Sons Dessa Reação")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)

                            Text(viewModel.errorMessage)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.gray)

                            Button {
                                Task {
                                    await viewModel.loadSounds()
                                }
                            } label: {
                                Label("Tentar Novamente", systemImage: "arrow.clockwise")
                            }
                        }
                        .padding(.horizontal, 30)

                        Spacer()
                    }
            )
            .environmentObject(TrendsHelper())
        }
        .toolbar {
            toolbarControls()
                .foregroundStyle(.white)
                .opacity(toolbarControlsOpacity)
                .disabled(soundArrayIsEmpty)
        }
        .oneTimeTask {
            await viewModel.loadSounds()
        }
        .onAppear {
            Analytics.send(
                originatingScreen: "ReactionDetailView",
                action: "didViewReaction(\(viewModel.reaction.title))"
            )
        }
        .edgesIgnoringSafeArea(.top)
    }

    @ViewBuilder func toolbarControls() -> some View {
        HStack(spacing: 15) {
            Button {
                soundListViewModel.playStopPlaylist()
            } label: {
                Image(systemName: soundListViewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
            }
            .disabled(soundArrayIsEmpty)

            Menu {
                Section {
                    Button {
                        soundListViewModel.startSelecting()
                    } label: {
                        Label(
                            soundListViewModel.currentSoundsListMode.wrappedValue == .selection ? "Cancelar Seleção" : "Selecionar",
                            systemImage: soundListViewModel.currentSoundsListMode.wrappedValue == .selection ? "xmark.circle" : "checkmark.circle"
                        )
                    }
                }

                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        ForEach(ReactionSoundSortOption.allCases, id: \.self) { option in
                            Text(option.description).tag(option.rawValue)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .onChange(of: viewModel.soundSortOption) {
                viewModel.sortSounds(by: $0)
            }
        }
    }
}

#Preview {
    ReactionDetailView(
        reaction: .acidMock,
        currentSoundsListMode: .constant(.regular)
    )
}
