//
//  ReactionDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ReactionDetailView: View {

    @State var viewModel: ReactionDetailViewModel
    @State private var soundListViewModel: ContentGridViewModel

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
        currentListMode: Binding<ContentListMode>,
        toast: Binding<Toast?>
    ) {
        self.viewModel = ReactionDetailViewModel(reaction: reaction)
        self.soundListViewModel = ContentGridViewModel(
            menuOptions: [.sharingOptions(), .organizingOptions(), .playFromThisSound(), .detailsOptions()],
            currentListMode: currentListMode,
            toast: toast,
            floatingOptions: .constant(nil)
        )
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.medium)) {
                    ReactionDetailHeader(
                        title: viewModel.reaction.title,
                        subtitle: viewModel.subtitle,
                        imageUrl: viewModel.reaction.image,
                        attributionText: viewModel.reaction.attributionText,
                        attributionURL: viewModel.reaction.attributionURL
                    )
                    .frame(height: 260)
                    .padding(.bottom, 6)

//                    ContentGrid(
//                        viewModel: soundListViewModel,
//                        showNewTag: false,
//                        dataLoadingDidFail: viewModel.dataLoadingDidFail,
//                        reactionId: viewModel.reaction.id,
//                        containerSize: geometry.size,
//                        loadingView: LoadingView(),
//                        emptyStateView: EmptyStateView(
//                            reloadAction: {
//                                Task {
//                                    await viewModel.loadSounds()
//                                }
//                            }
//                        ),
//                        errorView: ErrorView(
//                            reactionNoLongerExists: viewModel.state == .reactionNoLongerExists,
//                            errorMessage: viewModel.errorMessage,
//                            tryAgainAction: {
//                                Task {
//                                    await viewModel.loadSounds()
//                                }
//                            }
//                        )
//                    )
//                    .environment(TrendsHelper())
//                    .padding(.horizontal, .spacing(.small))

                    Spacer()
                        .frame(height: .spacing(.large))
                }
                .toolbar {
                    ToolbarControls(
                        soundSortOption: $viewModel.soundSortOption,
                        playStopAction: { soundListViewModel.onPlayStopPlaylistSelected() },
                        startSelectingAction: { soundListViewModel.onEnterMultiSelectModeSelected() },
                        isPlayingPlaylist: soundListViewModel.isPlayingPlaylist,
                        soundArrayIsEmpty: soundArrayIsEmpty,
                        isSelecting: soundListViewModel.floatingOptions.wrappedValue != nil
                    )
                    .foregroundStyle(.white)
                    .opacity(toolbarControlsOpacity)
                    .disabled(soundArrayIsEmpty)
                    .onChange(of: viewModel.soundSortOption) {
                        viewModel.sortSounds(by: viewModel.soundSortOption)
                    }
                }
                .oneTimeTask {
                    await viewModel.loadSounds()
                }
                .onAppear {
                    Analytics().send(
                        originatingScreen: "ReactionDetailView",
                        action: "didViewReaction(\(viewModel.reaction.title))"
                    )
                }
            }
            .edgesIgnoringSafeArea(.top)
            .toast(soundListViewModel.toast)
            .floatingContentOptions(soundListViewModel.floatingOptions)
        }
    }
}

// MARK: - Subviews

extension ReactionDetailView {

    struct ToolbarControls: View {

        @Binding var soundSortOption: Int
        let playStopAction: () -> Void
        let startSelectingAction: () -> Void
        let isPlayingPlaylist: Bool
        let soundArrayIsEmpty: Bool
        let isSelecting: Bool

        var body: some View {
            HStack(spacing: 15) {
                Button {
                    playStopAction()
                } label: {
                    Image(systemName: isPlayingPlaylist ? "stop.fill" : "play.fill")
                }
                .disabled(soundArrayIsEmpty)

                Menu {
                    Section {
                        Button {
                            startSelectingAction()
                        } label: {
                            Label(
                                isSelecting ? "Cancelar Seleção" : "Selecionar",
                                systemImage: isSelecting ? "xmark.circle" : "checkmark.circle"
                            )
                        }
                    }

                    Section {
                        Picker("Ordenação de Sons", selection: $soundSortOption) {
                            ForEach(ReactionSoundSortOption.allCases, id: \.self) { option in
                                Text(option.description).tag(option.rawValue)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    struct LoadingView: View {

        var body: some View {
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
        }
    }

    struct EmptyStateView: View {

        let reloadAction: () -> Void

        var body: some View {
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
                    reloadAction()
                } label: {
                    Label("Recarregar", systemImage: "arrow.clockwise")
                }
                .padding(.bottom)

                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }

    struct ErrorView: View {

        let reactionNoLongerExists: Bool
        let errorMessage: String
        let tryAgainAction: () -> Void

        var body: some View {
            if reactionNoLongerExists {
                VStack(spacing: 40) {
                    Text("🗑️")
                        .font(.system(size: 68))

                    VStack(spacing: 36) {
                        Text("Reação Removida do Servidor")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("Essa Reação não existe mais no servidor. Por favor, volte para a lista de Reações e puxe a partir do topo para atualizá-la.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 30)

                    Spacer()
                }
            } else {
                VStack(spacing: 40) {
                    Text("☹️")
                        .font(.system(size: 86))
                    
                    VStack(spacing: 40) {
                        Text("Erro ao Carregar os Sons Dessa Reação")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                        
                        Button {
                            tryAgainAction()
                        } label: {
                            Label("Tentar Novamente", systemImage: "arrow.clockwise")
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ReactionDetailView(
        reaction: .acidMock,
        currentListMode: .constant(.regular),
        toast: .constant(nil)
    )
}
