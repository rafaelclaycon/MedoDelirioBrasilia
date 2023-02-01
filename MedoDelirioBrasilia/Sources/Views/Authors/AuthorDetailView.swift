//
//  AuthorDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI
import Kingfisher

struct AuthorDetailView: View {

    @StateObject var viewModel: AuthorDetailViewViewModel
    @State var author: Author
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var showingModalView = false
    
    // Add to Folder vars
    @State private var showingAddToFolderModal = false
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    private var edgesToIgnore: SwiftUI.Edge.Set {
        return author.photo == nil ? [] : .top
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.sounds.count == 0 {
                    NoSoundsView()
                        .padding(.horizontal, 25)
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            if author.photo != nil {
                                KFImage(URL(string: author.photo ?? .empty))
                                    .placeholder {
                                        Image(systemName: "photo.on.rectangle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                            .foregroundColor(.gray)
                                            .opacity(0.3)
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            }
                            
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text(author.name)
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                }
                                
                                if author.description != nil {
                                    Text(author.description ?? "")
                                }
                                
                                Text(viewModel.getSoundCount())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .bold()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical)
                            
                            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                ForEach(viewModel.sounds) { sound in
                                    SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", isNew: sound.isNew ?? false, favorites: $viewModel.favoritesKeeper, highlighted: .constant(Set<String>()), nowPlaying: $viewModel.nowPlayingKeeper)
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
                                        .contextMenu(menuItems: {
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
                                                    if viewModel.favoritesKeeper.contains(sound.id) {
                                                        viewModel.removeFromFavorites(soundId: sound.id)
                                                    } else {
                                                        viewModel.addToFavorites(soundId: sound.id)
                                                    }
                                                } label: {
                                                    Label(viewModel.favoritesKeeper.contains(sound.id) ? "Remover dos Favoritos" : "Adicionar aos Favoritos", systemImage: viewModel.favoritesKeeper.contains(sound.id) ? "star.slash" : "star")
                                                }
                                                
                                                Button {
                                                    viewModel.selectedSound = sound
                                                    showingAddToFolderModal = true
                                                } label: {
                                                    Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                                }
                                                .onChange(of: showingAddToFolderModal) { newValue in
                                                    if (newValue == false) && hadSuccessAddingToFolder {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                                            withAnimation {
                                                                shouldDisplayAddedToFolderToast = true
                                                            }
                                                            TapticFeedback.success()
                                                        }
                                                        
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                            withAnimation {
                                                                shouldDisplayAddedToFolderToast = false
                                                                folderName = nil
                                                                hadSuccessAddingToFolder = false
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            Section {
                                                Button {
                                                    viewModel.selectedSound = sound
                                                    viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                                                } label: {
                                                    Label(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: sound.authorId), systemImage: "exclamationmark.bubble")
                                                }
                                            }
                                        })
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
                    .edgesIgnoringSafeArea(edgesToIgnore)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.reloadList(withSounds: soundData.filter({ $0.authorId == author.id }),
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds())
                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .singleOption:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                default:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                        viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true
                    }), secondaryButton: .cancel(Text("Fechar")))
                }
            }
            .sheet(isPresented: $showingAddToFolderModal) {
                AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, selectedSoundName: viewModel.selectedSound!.title, selectedSoundId: viewModel.selectedSound!.id)
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog, subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""), emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? ""))
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog, subject: Shared.issueSuggestionEmailSubject, emailBody: Shared.issueSuggestionEmailBody)
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
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: "Som adicionado à pasta \(folderName ?? "").")
                        .padding()
                }
                .transition(.moveAndFade)
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

struct AuthorDetailView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorDetailView(viewModel: AuthorDetailViewViewModel(originatingScreenName: "originalScreen", authorName: "João da Silva"), author: Author(id: "A", name: "João", photo: nil))
    }

}
