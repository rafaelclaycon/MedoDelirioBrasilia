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
    @State private var navBarTitle: String = .empty
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var showingModalView = false
    
    // Add to Folder vars
    @State private var showingAddToFolderModal = false
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var pluralization: WordPluralization = .singular
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    private var edgesToIgnore: SwiftUI.Edge.Set {
        return author.photo == nil ? [] : .top
    }
    
    private var shouldDisplayMenuOnToolbar: Bool {
        if #available(iOS 16, *) {
            return false
        } else {
            return true
        }
    }
    
    private var shouldDisplayMenuBesideAuthorName: Bool {
        !shouldDisplayMenuOnToolbar
    }
    
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        if offset > 0 {
            return imageHeight + offset
        }
        return imageHeight
    }
    
    private func getOffsetBeforeShowingTitle() -> CGFloat {
        author.photo == nil ? 50 : 250
    }
    
    private func updateNavBarTitle(_ offset: CGFloat) {
        if offset < getOffsetBeforeShowingTitle() {
            DispatchQueue.main.async {
                navBarTitle = author.name
            }
        } else {
            DispatchQueue.main.async {
                navBarTitle = .empty
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.sounds.count == 0 {
                    NoSoundsView()
                        .padding(.horizontal, 25)
                } else {
                    GeometryReader { scrollViewGeometry in
                        ScrollView {
                            if author.photo != nil {
                                GeometryReader { headerPhotoGeometry in
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
                                        .frame(width: headerPhotoGeometry.size.width, height: self.getHeightForHeaderImage(headerPhotoGeometry))
                                        .clipped()
                                        .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
                                }.frame(height: 250)
                            }
                            
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text(author.name)
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    if shouldDisplayMenuBesideAuthorName {
                                        moreOptionsMenu(isOnToolbar: false)
                                    }
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
                                                    viewModel.selectedSoundsForAddToFolder = [Sound]()
                                                    viewModel.selectedSoundsForAddToFolder?.append(sound)
                                                    showingAddToFolderModal = true
                                                } label: {
                                                    Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
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
                            .onChange(of: scrollViewGeometry.size.width) { newWidth in
                                self.listWidth = newWidth
                                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                            }
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("scroll")).minY)
                            })
                        }
                        .coordinateSpace(name: "scroll")
                    }
                    .edgesIgnoringSafeArea(edgesToIgnore)
                }
            }
            .navigationTitle(navBarTitle)
            .onPreferenceChange(ViewOffsetKey.self) { offset in
                updateNavBarTitle(offset)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if shouldDisplayMenuOnToolbar {
                    moreOptionsMenu(isOnToolbar: true)
                }
            }
            .onAppear {
                viewModel.reloadList(withSounds: soundData.filter({ $0.authorId == author.id }),
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds())
                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .ok:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                case .reportSoundIssue:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                        viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true
                    }), secondaryButton: .cancel(Text("Fechar")))
                case .askForNewSound:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Li e Entendi"), action: {
                        viewModel.showEmailAppPicker_askForNewSound = true
                    }), secondaryButton: .cancel(Text("Cancelar")))
                }
            }
            .sheet(isPresented: $showingAddToFolderModal) {
                AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, pluralization: $pluralization, selectedSounds: viewModel.selectedSoundsForAddToFolder ?? [Sound]())
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog, subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""), emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? ""))
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog, subject: Shared.issueSuggestionEmailSubject, emailBody: Shared.issueSuggestionEmailBody)
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_askForNewSound, subject: String(format: Shared.Email.AskForNewSound.subject, self.author.name), emailBody: Shared.Email.AskForNewSound.body)
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue, subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.author.name), emailBody: Shared.Email.AuthorDetailIssue.body)
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
            .onChange(of: showingAddToFolderModal) { showingAddToFolderModal in
                if (showingAddToFolderModal == false) && hadSuccessAddingToFolder {
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
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: viewModel.getAddedToFolderToastText(pluralization: pluralization, folderName: folderName))
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
    
    @ViewBuilder func moreOptionsMenu(isOnToolbar: Bool) -> some View {
        Menu {
            Section {
                Button {
                    viewModel.selectedSoundsForAddToFolder = viewModel.sounds
                    showingAddToFolderModal = true
                } label: {
                    Label("Adicionar Todos a Pasta", systemImage: "folder.badge.plus")
                }
            }
            
            Section {
                Button {
                    viewModel.showAskForNewSoundAlert()
                } label: {
                    Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                }
            }
            
            Section {
                Button {
                    viewModel.showEmailAppPicker_reportAuthorDetailIssue = true
                } label: {
                    Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
        } label: {
            if isOnToolbar {
                Image(systemName: "ellipsis.circle")
            } else {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
        }
        .disabled(viewModel.sounds.count == 0)
    }

}

struct ViewOffsetKey: PreferenceKey {

    typealias Value = CGFloat
    
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }

}

struct AuthorDetailView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorDetailView(viewModel: AuthorDetailViewViewModel(originatingScreenName: "originalScreen", authorName: "João da Silva"), author: Author(id: "A", name: "João", photo: nil))
    }

}
