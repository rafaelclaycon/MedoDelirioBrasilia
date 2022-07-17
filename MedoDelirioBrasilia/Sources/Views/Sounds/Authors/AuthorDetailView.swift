import SwiftUI

struct AuthorDetailView: View {

    @StateObject private var viewModel = AuthorDetailViewViewModel()
    @State var author: Author
    
    // Add to Folder vars
    @State private var showingAddToFolderModal = false
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.sounds.count == 0 {
                    NoSoundsView()
                        .padding(.horizontal, 25)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.sounds) { sound in
                                SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
                                    .onTapGesture {
                                        viewModel.playSound(fromPath: sound.filename)
                                    }
                                    .onLongPressGesture {
                                        viewModel.soundForConfirmationDialog = sound
                                        viewModel.showConfirmationDialog = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 7)
                        
                        Text(viewModel.getSoundCount())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .padding(.bottom, 18)
                    }
                }
            }
            .navigationTitle(author.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.reloadList(withSounds: soundData.filter({ $0.authorId == author.id }),
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds())
            }
            .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
                Button(viewModel.getFavoriteButtonTitle()) {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    if viewModel.isSelectedSoundAlreadyAFavorite() {
                        viewModel.removeFromFavorites(soundId: sound.id)
                    } else {
                        viewModel.addToFavorites(soundId: sound.id)
                    }
                }
                
                Button(Shared.addToFolderButtonText) {
                    let hasFolders = try? database.hasAnyUserFolder()
                    guard hasFolders ?? false else {
                        return viewModel.showNoFoldersAlert()
                    }
                    guard viewModel.soundForConfirmationDialog != nil else {
                        return
                    }
                    showingAddToFolderModal = true
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
                
                Button(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: viewModel.soundForConfirmationDialog?.authorId ?? .empty)) {
                    viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                }
                
                Button(Shared.shareButtonText) {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                }
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
                AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, selectedSoundName: viewModel.soundForConfirmationDialog!.title, selectedSoundId: viewModel.soundForConfirmationDialog!.id)
            }
            .onChange(of: viewModel.showConfirmationDialog) { show in
                if show {
                    TapticFeedback.open()
                }
            }
            .confirmationDialog(Shared.pickAMailApp, isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog, titleVisibility: .visible) {
                Mailman.getMailClientOptions(subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.soundForConfirmationDialog?.title ?? ""),
                                             body: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.soundForConfirmationDialog?.authorName ?? "", viewModel.soundForConfirmationDialog?.id ?? ""))
            }
            .confirmationDialog(Shared.pickAMailApp, isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog, titleVisibility: .visible) {
                Mailman.getMailClientOptions(subject: Shared.issueSuggestionEmailSubject, body: Shared.issueSuggestionEmailBody)
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: "Som adicionado à pasta \(folderName ?? "").")
                        .padding()
                }
                .transition(.moveAndFade)
            }
            
            if viewModel.shouldDisplaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: Shared.soundSharedSuccessfullyMessage)
                        .padding()
                }
                .transition(.moveAndFade)
            }
        }
    }

}

struct AuthorDetailView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorDetailView(author: Author(id: "A", name: "João"))
    }

}
