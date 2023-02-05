//
//  FolderDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderDetailView: View {

    @StateObject var viewModel = FolderDetailViewViewModel()
    @State var folder: UserFolder
    @State private var showingFolderInfoEditingView = false
    
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
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.hasSoundsToDisplay {
                    GeometryReader { geometry in
                        ScrollView {
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
                                    SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", isNew: sound.isNew ?? false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()), nowPlaying: $viewModel.nowPlayingKeeper)
                                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                        .onTapGesture {
                                            if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                player?.togglePlay()
                                                viewModel.nowPlayingKeeper.removeAll()
                                            } else {
                                                viewModel.playSound(fromPath: sound.filename, withId: sound.id)
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
                        }
                    }
                } else {
                    EmptyFolderView()
                        .padding(.horizontal, 30)
                }
            }
            .navigationTitle("\(folder.symbol)  \(folder.name)")
            .toolbar {
                Menu {
                    Section {
                        Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                            HStack {
                                Text("Título")
                                Image(systemName: "a.circle")
                            }
                            .tag(0)
                            
                            HStack {
                                Text("Nome do(a) Autor(a)")
                                Image(systemName: "person")
                            }
                            .tag(1)
                            
                            if showSortByDateAddedOption {
                                HStack {
                                    Text("Adição à Pasta (Mais Recentes no Topo)")
                                    Image(systemName: "calendar")
                                }
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
            .sheet(isPresented: $showingFolderInfoEditingView) {
                FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .singleOption:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                default:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .destructive(Text("Remover"), action: {
                        guard let sound = viewModel.selectedSound else {
                            return
                        }
                        viewModel.removeSoundFromFolder(folderId: folder.id, soundId: sound.id)
                    }), secondaryButton: .cancel(Text("Cancelar")))
                }
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $showingModalView) {
                ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: false)
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

}

struct FolderDetailView_Previews: PreviewProvider {

    static var previews: some View {
        FolderDetailView(folder: UserFolder(symbol: "🤑", name: "Grupo da Economia", backgroundColor: "pastelBabyBlue"))
    }

}
