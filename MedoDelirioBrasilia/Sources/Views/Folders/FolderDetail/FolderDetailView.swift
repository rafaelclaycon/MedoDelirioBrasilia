//
//  FolderDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderDetailView: View {

    @StateObject private var viewModel: FolderDetailViewViewModel
    @StateObject private var soundListViewModel: SoundListViewModel<[Sound]>

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
            if soundListViewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if soundListViewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, soundListViewModel.selectionKeeper.count)
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
        let viewModel = FolderDetailViewViewModel(folder: folder)

        self._viewModel = StateObject(wrappedValue: viewModel)
        self.currentSoundsListMode = currentSoundsListMode

        let soundListViewModel = SoundListViewModel<[Sound]>(
            data: viewModel.soundsPublisher,
            menuOptions: [.sharingOptions(), /*.playFromThisSound(),*/ .removeFromFolder()],
            currentSoundsListMode: currentSoundsListMode,
            refreshAction: { viewModel.reloadSounds() },
            insideFolder: folder
        )

        self._soundListViewModel = StateObject(wrappedValue: soundListViewModel)
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            SoundList(
                viewModel: soundListViewModel,
                multiSelectFolderOperation: .remove,
                isFolder: true,
                dataLoadingDidFail: viewModel.dataLoadingDidFail,
                headerView: {
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
                    EmptyFolderView()
                        .padding(.horizontal, 30)
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
            .environmentObject(TrendsHelper())
        }
        .navigationTitle(title)
        .toolbar { trailingToolbarControls() }
        .onAppear {
            viewModel.reloadSounds()
        }
        .onDisappear {
            if soundListViewModel.isPlayingPlaylist {
                soundListViewModel.stopPlaying()
            }
        }
        .sheet(isPresented: $showingFolderInfoEditingView) {
            FolderInfoEditingView(
                symbol: folder.symbol,
                folderName: folder.name,
                selectedBackgroundColor: folder.backgroundColor,
                isEditing: true,
                folderIdWhenEditing: folder.id
            )
        }
    }

    // MARK: - Auxiliary Views

    @ViewBuilder func trailingToolbarControls() -> some View {
        HStack(spacing: 16) {
            if currentSoundsListMode.wrappedValue == .regular {
                Button {
                    soundListViewModel.playStopPlaylist()
                } label: {
                    Image(systemName: soundListViewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
                }
                .disabled(viewModel.sounds.isEmpty)
            } else {
                selectionControls()
            }

            Menu {
                Section {
                    Button {
                        soundListViewModel.startSelecting()
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
                    .onChange(of: viewModel.soundSortOption) { sortOption in
                        viewModel.sortSounds(by: sortOption)
                    }
                    .disabled(viewModel.sounds.isEmpty)
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
            .disabled(soundListViewModel.isPlayingPlaylist || viewModel.sounds.isEmpty)
        }
    }
    
    @ViewBuilder func selectionControls() -> some View {
        if currentSoundsListMode.wrappedValue == .regular {
            EmptyView()
        } else {
            HStack(spacing: 16) {
                Button {
                    currentSoundsListMode.wrappedValue = .regular
                    soundListViewModel.selectionKeeper.removeAll()
                } label: {
                    Text("Cancelar")
                        .bold()
                }
            }
        }
    }
}

#Preview {
    FolderDetailView(
        folder: .init(
            symbol: "🤑",
            name: "Grupo da Economia",
            backgroundColor: "pastelBabyBlue"
        ),
        currentSoundsListMode: .constant(.regular)
    )
}
