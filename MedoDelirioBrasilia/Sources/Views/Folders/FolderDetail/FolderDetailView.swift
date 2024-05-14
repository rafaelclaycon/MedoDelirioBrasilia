//
//  FolderDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderDetailView: View {

    @StateObject private var viewModel: FolderDetailViewViewModel
    @StateObject private var soundListViewModel: SoundListViewModel<Sound>

    let folder: UserFolder

    @State private var currentSoundsListMode: SoundsListMode
    @State private var showingFolderInfoEditingView = false
    @State private var showingModalView = false

    // MARK: - Computed Properties

    private var showSortByDateAddedOption: Bool {
        guard let folderVersion = folder.version else { return false }
        return folderVersion == "2"
    }
    
    private var title: String {
        guard currentSoundsListMode == .regular else {
            if viewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if viewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, viewModel.selectionKeeper.count)
            }
        }
        return "\(folder.symbol)  \(folder.name)"
    }

    // MARK: - Initializer

    init(
        folder: UserFolder
    ) {
        self.folder = folder
        let viewModel = FolderDetailViewViewModel(folder: folder)

        self._viewModel = StateObject(wrappedValue: viewModel)
        self._currentSoundsListMode = State(initialValue: .regular)

        let soundListViewModel = SoundListViewModel<Sound>(
            data: viewModel.soundsPublisher,
            menuOptions: [.sharingOptions(), .playFromThisSound(), .removeFromFolder()],
            currentSoundsListMode: .constant(.regular), // $currentSoundsListMode
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
                emptyStateView: AnyView(
                    EmptyFolderView()
                        .padding(.horizontal, 30)
                ),
                headerView: AnyView(
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.getSoundCount())
                                .font(.callout)
                                .foregroundColor(.gray)
                                .bold()

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                )
            )
            .environmentObject(TrendsHelper())
        }
        .navigationTitle(title)
        .toolbar { trailingToolbarControls() }
        .onAppear {
            viewModel.reloadSounds()
        }
        .onDisappear {
            if viewModel.isPlayingPlaylist {
                soundListViewModel.stopPlaying()
            }
        }
        .sheet(isPresented: $showingFolderInfoEditingView) {
            FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
        }
    }

    // MARK: - Auxiliary Views

    @ViewBuilder func trailingToolbarControls() -> some View {
        HStack(spacing: 16) {
            if currentSoundsListMode == .regular {
                Button {
                    if viewModel.isPlayingPlaylist {
                        soundListViewModel.stopPlaying()
                    } else {
                        viewModel.playAllSoundsOneAfterTheOther()
                    }
                } label: {
                    Image(systemName: viewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
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
                        Label(currentSoundsListMode == .selection ? "Cancelar Seleção" : "Selecionar", systemImage: currentSoundsListMode == .selection ? "xmark.circle" : "checkmark.circle")
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
            .disabled(viewModel.isPlayingPlaylist || viewModel.sounds.isEmpty)
//            .onChange(of: viewModel.soundSortOption, perform: { soundSortOption in
//                switch soundSortOption {
//                case 1:
//                    viewModel.sortSoundsInPlaceByAuthorNameAscending()
//                case 2:
//                    viewModel.sortSoundsInPlaceByDateAddedDescending()
//                default:
//                    viewModel.sortSoundsInPlaceByTitleAscending()
//                }
//                try? LocalDatabase.shared.update(userSortPreference: soundSortOption, forFolderId: folder.id)
//            })
        }
    }
    
    @ViewBuilder func selectionControls() -> some View {
        if currentSoundsListMode == .regular {
            EmptyView()
        } else {
            HStack(spacing: 16) {
                Button {
                    currentSoundsListMode = .regular
                    viewModel.selectionKeeper.removeAll()
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
        )
    )
}
