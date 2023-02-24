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
        ZStack {
            VStack {
                if viewModel.hasSoundsToDisplay {
                    GeometryReader { geometry in
                        ScrollView {
                            ScrollViewReader { proxy in
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
                                .padding(.vertical)
                                
                                LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                    ForEach(viewModel.sounds) { sound in
                                        SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", duration: sound.duration, isNew: sound.isNew ?? false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: $viewModel.nowPlayingKeeper, selectedItems: $viewModel.selectionKeeper, currentSoundsListMode: $viewModel.currentSoundsListMode.wrappedValue)
                                            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                            .onTapGesture {
                                                if viewModel.currentSoundsListMode.wrappedValue == .regular {
                                                    if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                        player?.togglePlay()
                                                        viewModel.nowPlayingKeeper.removeAll()
                                                        viewModel.doPlaylistCleanup()
                                                    } else {
                                                        viewModel.playSound(fromPath: sound.filename, withId: sound.id)
                                                    }
                                                } else {
                                                    if viewModel.selectionKeeper.contains(sound.id) {
                                                        viewModel.selectionKeeper.remove(sound.id)
                                                    } else {
                                                        viewModel.selectionKeeper.insert(sound.id)
                                                    }
                                                }
                                            }
                                            .contextMenu {
                                                Section {
                                                    Button {
                                                        viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                                                    } label: {
                                                        Label(Shared.shareSoundButtonText, systemImage: "square.and.arrow.up")
                                                    }
                                                    
                                                    Button {
                                                        viewModel.selectedSound = sound
                                                        showingModalView = true
                                                    } label: {
                                                        Label(Shared.shareAsVideoButtonText, systemImage: "film")
                                                    }
                                                }
                                                
                                                Section {
                                                    Button {
                                                        viewModel.playFrom(sound: sound)
                                                    } label: {
                                                        Label("Reproduzir a Partir Desse", systemImage: "play")
                                                    }
                                                }
                                                
                                                Section {
                                                    Button {
                                                        viewModel.selectedSound = sound
                                                        viewModel.showSoundRemovalConfirmation(soundTitle: sound.title)
                                                    } label: {
                                                        Label("Remover da Pasta", systemImage: "folder.badge.minus")
                                                    }
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 18)
                                .onChange(of: geometry.size.width) { newWidth in
                                    self.listWidth = newWidth
                                    columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                                }
                                .onChange(of: viewModel.nowPlayingKeeper) { nowPlayingKeeper in
                                    if viewModel.isPlayingPlaylist, !nowPlayingKeeper.isEmpty, let playingSoundId = nowPlayingKeeper.first {
                                        DispatchQueue.main.async {
                                            withAnimation {
                                                proxy.scrollTo(playingSoundId, anchor: .center)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    EmptyFolderView()
                        .padding(.horizontal, 30)
                }
            }
            .navigationTitle(title)
            .toolbar {
                selectionControls()
                
                Button {
                    if viewModel.isPlayingPlaylist {
                        viewModel.stopPlaying()
                    } else {
                        viewModel.playAllSoundsOneAfterTheOther()
                    }
                } label: {
                    Image(systemName: viewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
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
                        .disabled(viewModel.sounds.count == 0)
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
                .disabled(viewModel.isPlayingPlaylist)
                .onChange(of: viewModel.soundSortOption, perform: { soundSortOption in
                    switch soundSortOption {
                    case 1:
                        viewModel.sortSoundsInPlaceByAuthorNameAscending()
                    case 2:
                        viewModel.sortSoundsInPlaceByDateAddedDescending()
                    default:
                        viewModel.sortSoundsInPlaceByTitleAscending()
                    }
                    try? database.update(userSortPreference: soundSortOption, forFolderId: folder.id)
                })
            }
            .onAppear {
                viewModel.reloadSoundList(withFolderContents: try? database.getAllContentsInsideUserFolder(withId: folder.id), sortedBy: FolderSoundSortOption(rawValue: folder.userSortPreference ?? 0) ?? .titleAscending)
                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
            }
            .onDisappear {
                if currentSoundsListMode == .selection {
                    viewModel.stopSelecting()
                }
            }
            .sheet(isPresented: $showingFolderInfoEditingView) {
                FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .ok:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                    
                case .removeSingleSound:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .destructive(Text("Remover"), action: {
                        guard let sound = viewModel.selectedSound else {
                            return
                        }
                        viewModel.removeSoundFromFolder(folderId: folder.id, soundId: sound.id)
                    }), secondaryButton: .cancel(Text("Cancelar")))
                    
                case .removeMultipleSounds:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .destructive(Text("Remover"), action: {
                        // Need to get count before clearing the Set.
                        let selectedCount: Int = viewModel.selectionKeeper.count
                        viewModel.removeMultipleSoundsFromFolder(folderId: folder.id)
                        viewModel.stopSelecting()
                        viewModel.sendUsageMetricToServer(action: "didRemoveManySoundsFromFolder(\(selectedCount))", folderName: "\(folder.symbol) \(folder.name)")
                    }), secondaryButton: .cancel(Text("Cancelar")))
                }
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $showingModalView) {
                if #available(iOS 16.0, *) {
                    ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, contentAuthor: viewModel.selectedSound?.authorName ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: false)
                } else {
                    ShareAsVideoLegacyView(viewModel: ShareAsVideoLegacyViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: false)
                }
            }
            .onChange(of: shareAsVideo_Result.videoFilepath) { videoResultPath in
                if videoResultPath.isEmpty == false {
                    if shareAsVideo_Result.exportMethod == .saveAsVideo {
                        viewModel.showVideoSavedSuccessfullyToast()
                    } else {
                        viewModel.shareVideo(withPath: videoResultPath, andContentId: shareAsVideo_Result.contentId)
                    }
                }
            }
            
            if viewModel.displaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: viewModel.shareBannerMessage)
                        .padding()
                }
                .transition(.moveAndFade)
            }
        }
    }
    
    @ViewBuilder func selectionControls() -> some View {
        if currentSoundsListMode == .regular {
            EmptyView()
        } else {
            HStack {
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

struct FolderDetailView_Previews: PreviewProvider {

    static var previews: some View {
        FolderDetailView(viewModel: FolderDetailViewViewModel(currentSoundsListMode: .constant(.regular)), folder: UserFolder(symbol: "🤑", name: "Grupo da Economia", backgroundColor: "pastelBabyBlue"), currentSoundsListMode: .constant(.regular))
    }

}
