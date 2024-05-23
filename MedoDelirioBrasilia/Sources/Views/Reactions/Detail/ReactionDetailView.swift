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

    // MARK: - Computed Properties

    private var toolbarControlsOpacity: CGFloat {
        guard let sounds = viewModel.sounds else { return 1.0 }
        return sounds.isEmpty ? 0.5 : 1.0
    }

    private var soundArrayIsEmpty: Bool {
        guard let sounds = viewModel.sounds else { return true }
        return sounds.isEmpty
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            SoundList(
                viewModel: .init(
                    data: viewModel.soundsPublisher,
                    menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
                    currentSoundsListMode: .constant(.regular)
                ),
                stopShowingFloatingSelector: .constant(nil),
                headerView: AnyView(
                    ReactionDetailHeader(
                        title: viewModel.reaction.title,
                        subtitle: viewModel.subtitle,
                        imageUrl: viewModel.reaction.image
                    )
                    .frame(height: 250)
                    .padding(.bottom, 6)
                ),
                loadingView: AnyView(
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
                ),
                emptyStateView: AnyView(
                    VStack(spacing: 40) {
                        Spacer()

                        Image(systemName: "questionmark.square.dashed")
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
                ),
                errorView: AnyView(
                    VStack(spacing: 40) {
                        Text("☹️")
                            .font(.system(size: 86))

                        VStack(spacing: 40) {
                            Text("Erro ao Carregar os Sons Dessa Reação")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)

                            Text("<Error message here>") // errorString
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
            .disabled(soundArrayIsEmpty)

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
