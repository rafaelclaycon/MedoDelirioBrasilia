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

    let author: Author

    @State private var navBarTitle: String = .empty
    @Binding var currentSoundsListMode: SoundsListMode
    @State private var showSelectionControlsInToolbar = false
    @State private var showMenuOnToolbarForiOS16AndHigher = false
    
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
    
    private var isiOS15: Bool {
        if #available(iOS 16, *) {
            return false
        } else {
            return true
        }
    }
    
    private var shouldDisplayMenuBesideAuthorName: Bool {
        !isiOS15
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
    
    private func updateNavBarContent(_ offset: CGFloat) {
        if offset < getOffsetBeforeShowingTitle() {
            DispatchQueue.main.async {
                navBarTitle = title
                showSelectionControlsInToolbar = currentSoundsListMode == .selection
                showMenuOnToolbarForiOS16AndHigher = currentSoundsListMode == .regular
            }
        } else {
            DispatchQueue.main.async {
                navBarTitle = .empty
                showSelectionControlsInToolbar = false
                showMenuOnToolbarForiOS16AndHigher = false
            }
        }
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
        return author.name
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
                                    Text(title)
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    if shouldDisplayMenuBesideAuthorName {
                                        moreOptionsMenu(isOnToolbar: false)
                                    }
                                }
                                
                                if currentSoundsListMode == .selection {
                                    inlineSelectionControls()
                                } else {
                                    if author.description != nil {
                                        Text(author.description ?? "")
                                    }
                                    
                                    Text(viewModel.getSoundCount())
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .bold()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical)
                            
                            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                ForEach(viewModel.sounds) { sound in
                                    SoundCell(sound: sound,
                                              favorites: $viewModel.favoritesKeeper,
                                              highlighted: .constant(Set<String>()),
                                              nowPlaying: $viewModel.nowPlayingKeeper,
                                              selectedItems: $viewModel.selectionKeeper,
                                              currentSoundsListMode: $currentSoundsListMode)
                                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                        .onTapGesture {
                                            if currentSoundsListMode == .regular {
                                                if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                    AudioPlayer.shared?.togglePlay()
                                                    viewModel.nowPlayingKeeper.removeAll()
                                                } else {
                                                    viewModel.play(sound)
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
                                            if currentSoundsListMode != .selection {
                                                Section {
                                                    Button {
                                                        viewModel.share(sound: sound)
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
                                                        viewModel.selectedSounds = [Sound]()
                                                        viewModel.selectedSounds?.append(sound)
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
                                            }
                                        }
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
                updateNavBarContent(offset)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isiOS15 {
                    // On regular mode, just show the ... menu
                    if currentSoundsListMode == .regular {
                        moreOptionsMenu(isOnToolbar: true)
                    } else {
                        // On scroll, show Select controls if not at the top
                        if showSelectionControlsInToolbar {
                            toolbarSelectionControls()
                        } else {
                            // Otherwise, show just the ... menu
                            moreOptionsMenu(isOnToolbar: true)
                        }
                    }
                } else {
                    if showSelectionControlsInToolbar {
                        toolbarSelectionControls()
                    } else if showMenuOnToolbarForiOS16AndHigher {
                        moreOptionsMenu(isOnToolbar: true)
                    }
                }
            }
            .onAppear {
                viewModel.reloadList(
                    withSounds: try? LocalDatabase.shared.allSounds(forAuthor: author.id, isSensitiveContentAllowed: UserSettings.getShowExplicitContent()),
                    andFavorites: try? LocalDatabase.shared.favorites()
                )
                
                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)

                dump(author)
            }
            .onDisappear {
                if currentSoundsListMode == .selection {
                    viewModel.stopSelecting()
                }
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
                AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, pluralization: $pluralization, selectedSounds: viewModel.selectedSounds ?? [Sound]())
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                                   emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? ""))
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: Shared.issueSuggestionEmailSubject,
                                   emailBody: Shared.issueSuggestionEmailBody)
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_askForNewSound,
                                   didCopySupportAddress: .constant(false),
                                   subject: String(format: Shared.Email.AskForNewSound.subject, self.author.name),
                                   emailBody: Shared.Email.AskForNewSound.body)
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue,
                                   didCopySupportAddress: .constant(false),
                                   subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.author.name),
                                   emailBody: Shared.Email.AuthorDetailIssue.body)
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
            .onChange(of: showingAddToFolderModal) { showingAddToFolderModal in
                if (showingAddToFolderModal == false) && hadSuccessAddingToFolder {
                    // Need to get count before clearing the Set.
                    let selectedCount: Int = viewModel.selectionKeeper.count
                    
                    if currentSoundsListMode == .selection {
                        viewModel.stopSelecting()
                    }
                    
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
                    
                    if pluralization == .plural {
                        viewModel.sendUsageMetricToServer(action: "didAddManySoundsToFolder(\(selectedCount))", authorName: author.name)
                    }
                }
            }
            .onChange(of: viewModel.selectionKeeper.count) { selectionKeeperCount in
                if navBarTitle.isEmpty == false {
                    DispatchQueue.main.async {
                        navBarTitle = title
                    }
                }
            }
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: pluralization.getAddedToFolderToastText(folderName: folderName))
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
            if viewModel.sounds.count > 1 {
                Section {
                    Button {
                        viewModel.startSelecting()
                    } label: {
                        Label(currentSoundsListMode == .selection ? "Cancelar Seleção" : "Selecionar", systemImage: currentSoundsListMode == .selection ? "xmark.circle" : "checkmark.circle")
                    }
                }
            }
            
            Section {
                Button {
                    viewModel.stopSelecting()
                    viewModel.selectedSounds = viewModel.sounds
                    showingAddToFolderModal = true
                } label: {
                    Label("Adicionar Todos a Pasta", systemImage: "folder.badge.plus")
                }
                
                Button {
                    viewModel.stopSelecting()
                    viewModel.showAskForNewSoundAlert()
                } label: {
                    Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                }
                
                Button {
                    viewModel.stopSelecting()
                    viewModel.showEmailAppPicker_reportAuthorDetailIssue = true
                } label: {
                    Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
            
            if viewModel.sounds.count > 1 {
                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        Text("Título")
                            .tag(0)
                        
                        Text("Mais Recentes no Topo")
                            .tag(1)
                    }
                    .onChange(of: viewModel.soundSortOption, perform: { soundSortOption in
                        if soundSortOption == 0 {
                            viewModel.sortSoundsInPlaceByTitleAscending()
                        } else {
                            viewModel.sortSoundsInPlaceByDateAddedDescending()
                        }
                    })
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
    
    @ViewBuilder func inlineSelectionControls() -> some View {
        HStack(spacing: 25) {
            Button {
                cancelSelectionAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }
            
            Button {
                favoriteAction()
            } label: {
                Label("Favoritos", systemImage: viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
            }.disabled(viewModel.selectionKeeper.count == 0)
            
            Button {
                addToFolderAction()
            } label: {
                Label("Pasta", systemImage: "folder.badge.plus")
            }.disabled(viewModel.selectionKeeper.count == 0)
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder func toolbarSelectionControls() -> some View {
        HStack(spacing: 15) {
            Button {
                cancelSelectionAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }
            
            Button {
                favoriteAction()
            } label: {
                Image(systemName: viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
            }.disabled(viewModel.selectionKeeper.count == 0)
            
            Button {
                addToFolderAction()
            } label: {
                Image(systemName: "folder.badge.plus")
            }.disabled(viewModel.selectionKeeper.count == 0)
            
            moreOptionsMenu(isOnToolbar: true)
        }
    }
    
    private func cancelSelectionAction() {
        currentSoundsListMode = .regular
        viewModel.selectionKeeper.removeAll()
    }
    
    private func favoriteAction() {
        // Need to get count before clearing the Set.
        let selectedCount: Int = viewModel.selectionKeeper.count
        
        if viewModel.allSelectedAreFavorites() {
            viewModel.removeSelectedFromFavorites()
            viewModel.stopSelecting()
            viewModel.reloadList(
                withSounds: try? LocalDatabase.shared.allSounds(forAuthor: author.id, isSensitiveContentAllowed: UserSettings.getShowExplicitContent()),
                andFavorites: try? LocalDatabase.shared.favorites()
            )
            viewModel.sendUsageMetricToServer(action: "didRemoveManySoundsFromFavorites(\(selectedCount))", authorName: author.name)
        } else {
            viewModel.addSelectedToFavorites()
            viewModel.stopSelecting()
            viewModel.sendUsageMetricToServer(action: "didAddManySoundsToFavorites(\(selectedCount))", authorName: author.name)
        }
    }
    
    private func addToFolderAction() {
        viewModel.prepareSelectedToAddToFolder()
        showingAddToFolderModal = true
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
        AuthorDetailView(viewModel: AuthorDetailViewViewModel(originatingScreenName: "originalScreen", authorName: "João da Silva", currentSoundsListMode: .constant(.selection)),
                         author: Author(id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2", name: "Abraham Weintraub", photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg"),
                         currentSoundsListMode: .constant(.selection))
    }

}
