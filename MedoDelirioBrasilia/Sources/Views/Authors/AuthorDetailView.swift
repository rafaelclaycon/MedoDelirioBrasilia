//
//  AuthorDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI
import Kingfisher

struct AuthorDetailView: View {

    @StateObject var viewModel: ViewModel

    @Binding var currentSoundsListMode: SoundsListMode
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        ZStack {
            VStack {
                if viewModel.sounds.count == 0 {
                    NoSoundsView()
                        .padding(.horizontal, 25)
                } else {
                    GeometryReader { scrollViewGeometry in
                        ScrollView {
                            if viewModel.author.photo != nil {
                                GeometryReader { headerPhotoGeometry in
                                    KFImage(URL(string: viewModel.author.photo ?? .empty))
                                        .placeholder { NoAuthorPhotoView() }
                                        .resizable()
                                        .scaledToFill()
                                        .frame(
                                            width: headerPhotoGeometry.size.width,
                                            height: viewModel.getHeightForHeaderImage(headerPhotoGeometry)
                                        )
                                        .clipped()
                                        .offset(x: 0, y: viewModel.getOffsetForHeaderImage(headerPhotoGeometry))
                                }.frame(height: 250)
                            }

                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text(viewModel.title)
                                        .font(.title)
                                        .bold()

                                    Spacer()

                                    if viewModel.shouldDisplayMenuBesideAuthorName {
                                        moreOptionsMenu(isOnToolbar: false)
                                    }
                                }

                                if currentSoundsListMode == .selection {
                                    inlineSelectionControls()
                                } else {
                                    if viewModel.author.description != nil {
                                        Text(viewModel.author.description ?? "")
                                    }

                                    Text(viewModel.getSoundCount())
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .bold()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical)

                            LazyVGrid(
                                columns: viewModel.columns,
                                spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20
                            ) {
                                ForEach(viewModel.sounds) { sound in
                                    SoundCell(
                                        sound: sound,
                                        favorites: $viewModel.favoritesKeeper,
                                        highlighted: .constant(Set<String>()),
                                        nowPlaying: $viewModel.nowPlayingKeeper,
                                        selectedItems: $viewModel.selectionKeeper,
                                        currentSoundsListMode: $currentSoundsListMode
                                    )
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                    .onTapGesture {
                                        viewModel.playOrSelect(sound: sound, currentListMode: currentSoundsListMode)
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
                                                    viewModel.showingModalView = true
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
                                                    viewModel.showingAddToFolderModal = true
                                                } label: {
                                                    Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                                }
                                            }

                                            Section {
                                                Button {
                                                    viewModel.selectedSound = sound
                                                    viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                                                } label: {
                                                    Label(
                                                        SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: sound.authorId),
                                                        systemImage: "exclamationmark.bubble"
                                                    )
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
                                viewModel.columns = GridHelper.soundColumns(
                                    listWidth: viewModel.listWidth,
                                    sizeCategory: sizeCategory
                                )
                            }
                            .background(GeometryReader {
                                Color.clear.preference(
                                    key: ViewOffsetKey.self,
                                    value: $0.frame(in: .named("scroll")).minY
                                )
                            })
                        }
                        .coordinateSpace(name: "scroll")
                    }
                    .edgesIgnoringSafeArea(viewModel.edgesToIgnore)
                }
            }
            .navigationTitle(viewModel.navBarTitle)
            .onPreferenceChange(ViewOffsetKey.self) { offset in
                viewModel.updateNavBarContent(offset)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isiOS15 {
                    // On regular mode, just show the ... menu
                    if currentSoundsListMode == .regular {
                        moreOptionsMenu(isOnToolbar: true)
                    } else {
                        // On scroll, show Select controls if not at the top
                        if viewModel.showSelectionControlsInToolbar {
                            toolbarSelectionControls()
                        } else {
                            // Otherwise, show just the ... menu
                            moreOptionsMenu(isOnToolbar: true)
                        }
                    }
                } else {
                    if viewModel.showSelectionControlsInToolbar {
                        toolbarSelectionControls()
                    } else if viewModel.showMenuOnToolbarForiOS16AndHigher {
                        moreOptionsMenu(isOnToolbar: true)
                    }
                }
            }
            .onAppear {
                // TODO: Refactor this to be closer to SoundsView.
                viewModel.reloadList(
                    withSounds: try? LocalDatabase.shared.allSounds(
                        forAuthor: viewModel.author.id,
                        isSensitiveContentAllowed: UserSettings.getShowExplicitContent()
                    ),
                    andFavorites: try? LocalDatabase.shared.favorites()
                )

                viewModel.columns = GridHelper.soundColumns(listWidth: viewModel.listWidth, sizeCategory: sizeCategory)
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
            .sheet(isPresented: $viewModel.showingAddToFolderModal) {
                AddToFolderView(
                    isBeingShown: $viewModel.showingAddToFolderModal,
                    hadSuccess: $viewModel.hadSuccessAddingToFolder,
                    folderName: $viewModel.folderName,
                    pluralization: $viewModel.pluralization,
                    selectedSounds: viewModel.selectedSounds ?? [Sound]()
                )
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                EmailAppPickerView(
                    isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog,
                    didCopySupportAddress: .constant(false),
                    subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                    emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? "")
                )
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(
                    isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog,
                    didCopySupportAddress: .constant(false),
                    subject: Shared.issueSuggestionEmailSubject,
                    emailBody: Shared.issueSuggestionEmailBody
                )
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
                EmailAppPickerView(
                    isBeingShown: $viewModel.showEmailAppPicker_askForNewSound,
                    didCopySupportAddress: .constant(false),
                    subject: String(format: Shared.Email.AskForNewSound.subject, self.author.name),
                    emailBody: Shared.Email.AskForNewSound.body
                )
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
                EmailAppPickerView(
                    isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue,
                    didCopySupportAddress: .constant(false),
                    subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.author.name),
                    emailBody: Shared.Email.AuthorDetailIssue.body
                )
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $viewModel.showingModalView) {
                if #available(iOS 16.0, *) {
                    ShareAsVideoView(
                        viewModel: ShareAsVideoViewViewModel(content: viewModel.selectedSound!, subtitle: viewModel.selectedSound?.authorName ?? .empty),
                        isBeingShown: $viewModel.showingModalView,
                        result: $viewModel.shareAsVideo_Result,
                        useLongerGeneratingVideoMessage: false
                    )
                } else {
                    ShareAsVideoLegacyView(
                        viewModel: ShareAsVideoLegacyViewViewModel(content: viewModel.selectedSound!),
                        isBeingShown: $viewModel.showingModalView,
                        result: $viewModel.shareAsVideo_Result,
                        useLongerGeneratingVideoMessage: false
                    )
                }
            }
            .onChange(of: viewModel.shareAsVideoResult.videoFilepath) { videoResultPath in
                if videoResultPath.isEmpty == false {
                    if viewModel.shareAsVideoResult.exportMethod == .saveAsVideo {
                        viewModel.showVideoSavedSuccessfullyToast()
                    } else {
                        viewModel.shareVideo(
                            withPath: videoResultPath,
                            andContentId: viewModel.shareAsVideoResult.contentId,
                            title: viewModel.selectedSound?.title ?? ""
                        )
                    }
                }
            }
            .onChange(of: viewModel.showingAddToFolderModal) { showingAddToFolderModal in
                if (viewModel.showingAddToFolderModal == false) && viewModel.hadSuccessAddingToFolder {
                    // Need to get count before clearing the Set.
                    let selectedCount: Int = viewModel.selectionKeeper.count

                    if currentSoundsListMode == .selection {
                        viewModel.stopSelecting()
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        withAnimation {
                            viewModel.shouldDisplayAddedToFolderToast = true
                        }
                        TapticFeedback.success()
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            viewModel.shouldDisplayAddedToFolderToast = false
                            viewModel.folderName = nil
                            viewModel.hadSuccessAddingToFolder = false
                        }
                    }

                    if viewModel.pluralization == .plural {
                        viewModel.sendUsageMetricToServer(action: "didAddManySoundsToFolder(\(selectedCount))", authorName: viewModel.author.name)
                    }
                }
            }
            .onChange(of: viewModel.selectionKeeper.count) { selectionKeeperCount in
                if viewModel.navBarTitle.isEmpty == false {
                    DispatchQueue.main.async {
                        viewModel.navBarTitle = viewModel.title
                    }
                }
            }

            if viewModel.shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()

                    ToastView(
                        icon: "checkmark",
                        iconColor: .green,
                        text: viewModel.pluralization.getAddedToFolderToastText(folderName: viewModel.folderName)
                    )
                    .padding()
                }
                .transition(.moveAndFade)
            }

            if viewModel.displaySharedSuccessfullyToast {
                VStack {
                    Spacer()

                    ToastView(
                        icon: "checkmark",
                        iconColor: .green,
                        text: viewModel.shareBannerMessage
                    )
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
                    viewModel.showingAddToFolderModal = true
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
                viewModel.cancelSelectionAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }

            Button {
                viewModel.favoriteAction()
            } label: {
                Label("Favoritos", systemImage: viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
            }.disabled(viewModel.selectionKeeper.count == 0)

            Button {
                viewModel.addToFolderAction()
            } label: {
                Label("Pasta", systemImage: "folder.badge.plus")
            }.disabled(viewModel.selectionKeeper.count == 0)
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder func toolbarSelectionControls() -> some View {
        HStack(spacing: 15) {
            Button {
                viewModel.cancelSelectionAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }

            Button {
                viewModel.favoriteAction()
            } label: {
                Image(systemName: viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
            }.disabled(viewModel.selectionKeeper.count == 0)

            Button {
                viewModel.addToFolderAction()
            } label: {
                Image(systemName: "folder.badge.plus")
            }.disabled(viewModel.selectionKeeper.count == 0)

            moreOptionsMenu(isOnToolbar: true)
        }
    }
}

// swiftlint:disable line_length
#Preview {

    AuthorDetailView(
        viewModel: .init(
            author: .init(
                id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
                name: "Abraham Weintraub",
                photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg"
            ),
            currentSoundsListMode: .constant(.selection)
        ),
        currentSoundsListMode: .constant(.selection)
    )
}
// swiftlint:enable line_length
