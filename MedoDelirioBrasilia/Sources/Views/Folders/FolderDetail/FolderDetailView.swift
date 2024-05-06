//
//  FolderDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderDetailView: View {

    @StateObject var viewModel: FolderDetailViewViewModel
    @State var folder: UserFolder
    @State private var showingFolderInfoEditingView = false
    @Binding var currentSoundsListMode: SoundsListMode
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var showingModalView = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
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
    
    var body: some View {
        VStack {
            SoundList(
                viewModel: SoundListViewModel<Sound>(
                    data: viewModel.soundsPublisher,
                    menuOptions: [.sharingOptions(), .playFromThisSound(), .removeFromFolder()],
                    currentSoundsListMode: $currentSoundsListMode
                ),
                stopShowingFloatingSelector: .constant(nil),
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
        }
        .navigationTitle(title)
        .toolbar { trailingToolbarControls() }
        .onAppear {
            viewModel.reloadSoundList(
                withFolderContents: try? LocalDatabase.shared.getAllContentsInsideUserFolder(withId: folder.id),
                sortedBy: FolderSoundSortOption(rawValue: folder.userSortPreference ?? 0) ?? .titleAscending
            )

            columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
        }
        .onDisappear {
            if currentSoundsListMode == .selection {
                viewModel.stopSelecting()
            }
            if viewModel.isPlayingPlaylist {
                viewModel.stopPlaying()
            }
        }
        .sheet(isPresented: $showingFolderInfoEditingView) {
            FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
        }
    }

    @ViewBuilder func trailingToolbarControls() -> some View {
        HStack(spacing: 16) {
            if currentSoundsListMode == .regular {
                Button {
                    if viewModel.isPlayingPlaylist {
                        viewModel.stopPlaying()
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
                        viewModel.startSelecting()
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
            .onChange(of: viewModel.soundSortOption, perform: { soundSortOption in
                switch soundSortOption {
                case 1:
                    viewModel.sortSoundsInPlaceByAuthorNameAscending()
                case 2:
                    viewModel.sortSoundsInPlaceByDateAddedDescending()
                default:
                    viewModel.sortSoundsInPlaceByTitleAscending()
                }
                try? LocalDatabase.shared.update(userSortPreference: soundSortOption, forFolderId: folder.id)
            })
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
                
                Button {
                    viewModel.showRemoveMultipleSoundsConfirmation()
                } label: {
                    Label("Remover da Pasta", systemImage: "folder.badge.minus")
                }.disabled(viewModel.selectionKeeper.count == 0)
            }
        }
    }
}

#Preview {
    FolderDetailView(
        viewModel: .init(currentSoundsListMode: .constant(.regular)),
        folder: .init(symbol: "🤑", name: "Grupo da Economia", backgroundColor: "pastelBabyBlue"),
        currentSoundsListMode: .constant(.regular)
    )
}
