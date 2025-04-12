//
//  FolderDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderDetailView: View {

    @StateObject private var viewModel: FolderDetailViewViewModel
    @StateObject private var contentListViewModel: ContentListViewModel<[AnyEquatableMedoContent]>

    let folder: UserFolder

    private var currentSoundsListMode: Binding<SoundsListMode>
    @State private var showingFolderInfoEditingView = false
    @State private var showingModalView = false

    // MARK: - Computed Properties

    private var showSortByDateAddedOption: Bool {
        guard let folderVersion = folder.version else { return false }
        return folderVersion == "2"
    }
    
    private var title: String {
        guard currentSoundsListMode.wrappedValue == SoundsListMode.regular else {
            if contentListViewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if contentListViewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, contentListViewModel.selectionKeeper.count)
            }
        }
        return "\(folder.symbol)  \(folder.name)"
    }

    // MARK: - Initializer

    init(
        folder: UserFolder,
        currentSoundsListMode: Binding<SoundsListMode>
    ) {
        self.folder = folder
        let viewModel = FolderDetailViewViewModel(
            folder: folder,
            database: LocalDatabase.shared
        )

        self._viewModel = StateObject(wrappedValue: viewModel)
        self.currentSoundsListMode = currentSoundsListMode

        let soundListViewModel = ContentListViewModel<[AnyEquatableMedoContent]>(
            data: viewModel.soundsPublisher,
            menuOptions: [.sharingOptions(), .playFromThisSound(), .removeFromFolder()],
            currentSoundsListMode: currentSoundsListMode,
            refreshAction: { viewModel.onPulledToRefresh() },
            insideFolder: folder
        )

        self._contentListViewModel = StateObject(wrappedValue: soundListViewModel)
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    ContentList(
                        viewModel: contentListViewModel,
                        multiSelectFolderOperation: .remove,
                        showNewTag: false,
                        dataLoadingDidFail: viewModel.dataLoadingDidFail,
                        containerSize: geometry.size,
                        headerView: {
                            VStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(viewModel.soundCount)
                                            .font(.callout)
                                            .foregroundColor(.gray)
                                            .bold()

                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top)
                            }
                        },
                        loadingView:
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Carregando sons...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        ,
                        emptyStateView:
                            VStack {
                                EmptyFolderView()
                                    .padding(.horizontal, .spacing(.xxLarge))
                                    .padding(.vertical, .spacing(.huge))
                            }
                        ,
                        errorView:
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Erro ao carregar sons.")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                    )
                    .environment(TrendsHelper())
                }
                .navigationTitle(title)
                .toolbar { trailingToolbarControls() }
                .onAppear {
                    viewModel.onViewAppeared()
                }
                .onDisappear {
                    contentListViewModel.onViewDisappeared()
                }
                .sheet(isPresented: $showingFolderInfoEditingView) {
                    FolderInfoEditingView(
                        folder: folder,
                        folderRepository: UserFolderRepository(),
                        dismissSheet: {
                            showingFolderInfoEditingView = false
                        }
                    )
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder func trailingToolbarControls() -> some View {
        HStack(spacing: 16) {
            if currentSoundsListMode.wrappedValue == .regular {
                Button {
                    contentListViewModel.onPlayStopPlaylistSelected()
                } label: {
                    Image(systemName: contentListViewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
                }
                .disabled(viewModel.content.isEmpty)
            } else {
                selectionControls()
            }

            Menu {
                Section {
                    Button {
                        contentListViewModel.onEnterMultiSelectModeSelected()
                    } label: {
                        Label(
                            currentSoundsListMode.wrappedValue == .selection ? "Cancelar Seleção" : "Selecionar",
                            systemImage: currentSoundsListMode.wrappedValue == .selection ? "xmark.circle" : "checkmark.circle"
                        )
                    }
                }

                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        Text("Título")
                            .tag(0)

                        Text("Nome do(a) Autor(a)")
                            .tag(1)

                        if showSortByDateAddedOption {
                            Text("Adição à Pasta (Mais Recentes no Topo)")
                                .tag(2)
                        }
                    }
                    .onChange(of: viewModel.soundSortOption) {
                        viewModel.onContentSortOptionChanged()
                    }
                    .disabled(viewModel.content.isEmpty)
                }

                //                    Section {
                //                        Button {
                //                            showingFolderInfoEditingView = true
                //                        } label: {
                //                            Label("Exportar", systemImage: "square.and.arrow.up")
                //                        }
                //
                //                        Button {
                //                            showingFolderInfoEditingView = true
                //                        } label: {
                //                            Label("Importar", systemImage: "square.and.arrow.down")
                //                        }
                //                    }

                //                    Section {
                //                        Button {
                //                            showingFolderInfoEditingView = true
                //                        } label: {
                //                            Label("Editar Pasta", systemImage: "pencil")
                //                        }
                //
                //                        Button(role: .destructive, action: {
                //                            //viewModel.dummyCall()
                //                        }, label: {
                //                            HStack {
                //                                Text("Apagar Pasta")
                //                                Image(systemName: "trash")
                //                            }
                //                        })
                //                    }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(contentListViewModel.isPlayingPlaylist || viewModel.content.isEmpty)
        }
    }
    
    @ViewBuilder func selectionControls() -> some View {
        if currentSoundsListMode.wrappedValue == .regular {
            EmptyView()
        } else {
            HStack(spacing: 16) {
                Button {
                    currentSoundsListMode.wrappedValue = .regular
                    contentListViewModel.selectionKeeper.removeAll()
                } label: {
                    Text("Cancelar")
                        .bold()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FolderDetailView(
        folder: .init(
            symbol: "🤑",
            name: "Grupo da Economia",
            backgroundColor: "pastelBabyBlue",
            changeHash: "abcdefg"
        ),
        currentSoundsListMode: .constant(.regular)
    )
}
