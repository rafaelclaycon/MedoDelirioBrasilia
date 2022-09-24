import SwiftUI

struct AuthorDetailView: View {

    @StateObject private var viewModel = AuthorDetailViewViewModel()
    @State var author: Author
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    // Add to Folder vars
    @State private var showingAddToFolderModal = false
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.sounds.count == 0 {
                    NoSoundsView()
                        .padding(.horizontal, 25)
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                ForEach(viewModel.sounds) { sound in
                                    SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
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
                                                    //showingModalView = true
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
                                                    let hasFolders = try? database.hasAnyUserFolder()
                                                    guard hasFolders ?? false else {
                                                        return viewModel.showNoFoldersAlert()
                                                    }
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
                            .padding(.top, 7)
                            .onChange(of: geometry.size.width) { newWidth in
                                self.listWidth = newWidth
                                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                            }
                            
                            Text(viewModel.getSoundCount())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                                .padding(.bottom, 18)
                        }
                    }
                }
            }
            .navigationTitle(author.name)
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
        AuthorDetailView(author: Author(id: "A", name: "João", photo: nil))
    }

}
