//
//  ReactionDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ReactionDetailView: View {

    @StateObject var viewModel = ReactionDetailViewViewModel(state: .loading)
    @State var collection: ContentCollection
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .center) {
            switch viewModel.state {
            case .loading:
                loadingView()
            case .displayingData:
                listView()
            case .noDataToDisplay:
                noDataView()
            case .loadingError:
                loadingErrorView()
            }
        }
        .onAppear {
            viewModel.fetchCollections()
        }
    }
    
    @ViewBuilder private func loadingView() -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.3, anchor: .center)
            
            Text("CARREGANDO")
                .foregroundColor(.gray)
                .font(.callout)
        }
        .padding(.vertical, 100)
    }
    
    @ViewBuilder private func listView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                ForEach(viewModel.sounds) { sound in
                    SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", isNew: false, favorites: .constant(Set<String>()), highlighted: .constant(Set<String>()))
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                        .onTapGesture {
                            viewModel.playSound(fromPath: sound.filename)
                        }
                        .contextMenu(menuItems: {
                            Section {
                                Button {
                                    viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                                } label: {
                                    Label(Shared.shareSoundButtonText, systemImage: "square.and.arrow.up")
                                }
                                
                                Button {
                                    viewModel.selectedSound = sound
                                    //subviewToOpen = .shareAsVideoView
                                    //showingModalView = true
                                } label: {
                                    Label(Shared.shareAsVideoButtonText, systemImage: "film")
                                }
                            }
                            
                            Section {
                                Button {
                                    /*if viewModel.favoritesKeeper.contains(sound.id) {
                                        viewModel.removeFromFavorites(soundId: sound.id)
                                    } else {
                                        viewModel.addToFavorites(soundId: sound.id)
                                    }*/
                                } label: {
                                    //Label(viewModel.favoritesKeeper.contains(sound.id) ? "Remover dos Favoritos" : "Adicionar aos Favoritos", systemImage: viewModel.favoritesKeeper.contains(sound.id) ? "star.slash" : "star")
                                    Label("Adicionar aos Favoritos", systemImage: "star")
                                }
                                
                                Button {
                                    viewModel.selectedSound = sound
                                    let hasFolders = try? database.hasAnyUserFolder()
                                    guard hasFolders ?? false else {
                                        return //viewModel.showNoFoldersAlert()
                                    }
                                    //subviewToOpen = .addToFolderView
                                    //showingModalView = true
                                } label: {
                                    Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                }
//                                .onChange(of: showingModalView) { newValue in
//                                    if (newValue == false) && hadSuccessAddingToFolder {
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
//                                            withAnimation {
//                                                shouldDisplayAddedToFolderToast = true
//                                            }
//                                            TapticFeedback.success()
//                                        }
//
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                            withAnimation {
//                                                shouldDisplayAddedToFolderToast = false
//                                                folderName = nil
//                                                hadSuccessAddingToFolder = false
//                                            }
//                                        }
//                                    }
//                                }
                            }
                            
                            Section {
                                Button {
                                    guard let author = authorData.first(where: { $0.id == sound.authorId }) else {
                                        return
                                    }
                                    //authorToAutoOpen = author
                                    //autoOpenAuthor = true
                                } label: {
                                    Label("Ver Todos os Sons Desse Autor", systemImage: "person")
                                }
                                
                                Button {
                                    viewModel.selectedSound = sound
                                    //viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                                } label: {
                                    Label(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: sound.authorId), systemImage: "exclamationmark.bubble")
                                }
                            }
                        })
                }
            }
            .padding(.leading)
            .padding(.trailing)
        }
    }
    
    @ViewBuilder private func noDataView() -> some View {
        VStack(spacing: 10) {
            Text("Nenhum Som Nessa Coleção")
                .foregroundColor(.gray)
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
    }
    
    @ViewBuilder private func loadingErrorView() -> some View {
        VStack(spacing: 10) {
            Text("Erro ao Tentar Carregar Sons")
                .foregroundColor(.gray)
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
    }

}

struct CollectionDetailView_Previews: PreviewProvider {

    static var previews: some View {
        ReactionDetailView(collection: ContentCollection(title: "Teste", imageURL: .empty))
    }

}
