//
//  SoundList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

struct SoundList: View {

    // MARK: - Dependencies

    @StateObject private var viewModel: SoundListViewModel<Sound>
    private var stopShowingFloatingSelector: Binding<Bool?>
    private var allowSearch: Bool
    private var allowRefresh: Bool
    private var showSoundCountAtTheBottom: Bool
    private var showExplicitDisabledWarning: Bool
    private var multiSelectFolderOperation: FolderOperation = .add
    private var syncAction: (() -> Void)?
    private let emptyStateView: AnyView
    private var headerView: AnyView?

    // MARK: - Stored Properties

    @State private var columns: [GridItem] = []
    private let phoneItemSpacing: CGFloat = 9
    private let padItemSpacing: CGFloat = 14
    @State private var showMultiSelectButtons: Bool = false
    @State private var multiSelectButtonsEnabled: Bool = false
    @State private var allSelectedAreFavorites: Bool = false

    @ScaledMetric private var explicitOffWarningTopPadding = 16
    @ScaledMetric private var explicitOffWarningBottomPadding = 20

    // MARK: - Computed Properties

    private var searchResults: [Sound] {
        switch viewModel.state {
        case .loaded(let sounds):
            if viewModel.searchText.isEmpty {
                return sounds
            } else {
                return sounds.filter { sound in
                    let searchString = "\(sound.description.lowercased().withoutDiacritics()) \(sound.authorName?.lowercased().withoutDiacritics() ?? "")"
                    return searchString.contains(viewModel.searchText.lowercased().withoutDiacritics())
                }
            }
        case .loading, .error:
            return []
        }
    }

    // MARK: - Environment

    @Environment(\.sizeCategory) var sizeCategory
    @EnvironmentObject var trendsHelper: TrendsHelper

    // MARK: - Initializer

    init(
        viewModel: SoundListViewModel<Sound>,
        stopShowingFloatingSelector: Binding<Bool?> = .constant(nil),
        allowSearch: Bool = false,
        allowRefresh: Bool = false,
        showSoundCountAtTheBottom: Bool = false,
        showExplicitDisabledWarning: Bool = false,
        syncAction: (() -> Void)? = nil,
        multiSelectFolderOperation: FolderOperation = .add,
        emptyStateView: AnyView,
        headerView: AnyView? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.stopShowingFloatingSelector = stopShowingFloatingSelector
        self.allowSearch = allowSearch
        self.allowRefresh = allowRefresh
        self.showSoundCountAtTheBottom = showSoundCountAtTheBottom
        self.showExplicitDisabledWarning = showExplicitDisabledWarning
        self.syncAction = syncAction
        self.multiSelectFolderOperation = multiSelectFolderOperation
        self.emptyStateView = emptyStateView
        self.headerView = headerView
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                VStack {
                    HStack(spacing: 10) {
                        ProgressView()

                        Text("Carregando sons...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)

            case .loaded(let sounds):
                if sounds.isEmpty {
                    VStack {
                        emptyStateView
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                } else {
                    ScrollView {
                        ScrollViewReader { proxy in
                            if let headerView {
                                headerView
                            }

                            LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                                if searchResults.isEmpty {
                                    NoSearchResultsView(searchText: $viewModel.searchText)
                                } else {
                                    ForEach(searchResults) { sound in
                                        SoundCell(
                                            sound: sound,
                                            favorites: $viewModel.favoritesKeeper,
                                            highlighted: $viewModel.highlightKeeper,
                                            nowPlaying: $viewModel.nowPlayingKeeper,
                                            selectedItems: $viewModel.selectionKeeper,
                                            currentSoundsListMode: viewModel.currentSoundsListMode
                                        )
                                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .padding(.horizontal, UIDevice.isiPhone ? 0 : 5)
                                        .onTapGesture {
                                            if viewModel.currentSoundsListMode.wrappedValue == .regular {
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
                                            if viewModel.currentSoundsListMode.wrappedValue != .selection {
                                                ForEach(viewModel.menuOptions, id: \.title) { section in
                                                    Section {
                                                        ForEach(section.options(sound)) { option in
                                                            Button {
                                                                option.action(sound, viewModel)
                                                            } label: {
                                                                Label(
                                                                    option.title(viewModel.favoritesKeeper.contains(sound.id)),
                                                                    systemImage: option.symbol(viewModel.favoritesKeeper.contains(sound.id))
                                                                )
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .if(allowSearch) {
                                $0
                                  .searchable(text: $viewModel.searchText)
                                  .disableAutocorrection(true)
                            }
                            .padding(.horizontal)
                            .padding(.top, 7)
                            .alert(isPresented: $viewModel.showAlert) {
                                switch viewModel.alertType {
                                case .soundFileNotFound:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .default(Text("Baixar Conteúdo Novamente"), action: {
                                            guard let content = viewModel.selectedSound else { return }
                                            viewModel.redownloadServerContent(withId: content.id)
                                        }),
                                        secondaryButton: .cancel(Text("Fechar"))
                                    )

                                case .issueSharingSound:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                                            viewModel.subviewToOpen = .soundIssueEmailPicker
                                            viewModel.showingModalView = true
                                        }),
                                        secondaryButton: .cancel(Text("Fechar"))
                                    )

                                case .optionIncompatibleWithWhatsApp:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .default(Text("Continuar"), action: {
                                            AppPersistentMemory.increaseShareManyMessageShowCountByOne()
                                            viewModel.shareSelected()
                                        }),
                                        secondaryButton: .cancel(Text("Cancelar"))
                                    )

                                case .issueExportingManySounds:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        dismissButton: .default(Text("OK"))
                                    )

                                case .removeMultipleSounds:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .destructive(Text("Remover"), action: {
                                            viewModel.removeManyFromFolder()
                                        }),
                                        secondaryButton: .cancel(Text("Cancelar"))
                                    )
                                }
                            }
                            .sheet(isPresented: $viewModel.showingModalView) {
                                switch viewModel.subviewToOpen {
                                case .shareAsVideo:
                                    ShareAsVideoView(
                                        viewModel: .init(content: viewModel.selectedSound!, subtitle: viewModel.selectedSound?.authorName ?? .empty),
                                        isBeingShown: $viewModel.showingModalView,
                                        result: $viewModel.shareAsVideoResult,
                                        useLongerGeneratingVideoMessage: false
                                    )

                                case .addToFolder:
                                    AddToFolderView(
                                        isBeingShown: $viewModel.showingModalView,
                                        hadSuccess: $viewModel.hadSuccessAddingToFolder,
                                        folderName: $viewModel.folderName,
                                        pluralization: $viewModel.pluralization,
                                        selectedSounds: viewModel.selectedSounds!
                                    )

                                case .soundDetail:
                                    SoundDetailView(
                                        isBeingShown: $viewModel.showingModalView,
                                        sound: viewModel.selectedSound ?? Sound(title: "")
                                    )

                                case .soundIssueEmailPicker:
                                    EmailAppPickerView(
                                        isBeingShown: $viewModel.showingModalView,
                                        didCopySupportAddress: .constant(false),
                                        subject: Shared.issueSuggestionEmailSubject,
                                        emailBody: Shared.issueSuggestionEmailBody
                                    )
                                }
                            }
                            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                                viewModel.iPadShareSheet
                            }
                            .onChange(of: viewModel.searchText) { text in
                                stopShowingFloatingSelector.wrappedValue = !text.isEmpty
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
                            .onChange(of: viewModel.showingModalView) { showingModalView in
                                if (viewModel.showingModalView == false) && viewModel.hadSuccessAddingToFolder {
                                    // Need to get count before clearing the Set.
                                    let selectedCount: Int = viewModel.selectionKeeper.count

                                    if viewModel.currentSoundsListMode.wrappedValue == .selection {
                                        viewModel.stopSelecting()
                                    }

                                    viewModel.displayToast(toastText: viewModel.pluralization.getAddedToFolderToastText(folderName: viewModel.folderName)) {
                                        viewModel.folderName = nil
                                        viewModel.hadSuccessAddingToFolder = false
                                    }

                                    if viewModel.pluralization == .plural {
                                        Analytics.sendUsageMetricToServer(
                                            originatingScreen: "SoundsView",
                                            action: "didAddManySoundsToFolder(\(selectedCount))"
                                        )
                                    }
                                }
                            }
                            .onChange(of: geometry.size.width) { newWidth in
                                updateGridLayout(with: newWidth)
                            }
                            .onChange(of: searchResults) { searchResults in
                                if searchResults.isEmpty {
                                    columns = [GridItem(.flexible())]
                                } else {
                                    updateGridLayout(with: geometry.size.width)
                                }
                            }
                            .onChange(of: viewModel.selectionKeeper.count) {
                                showMultiSelectButtons = viewModel.currentSoundsListMode.wrappedValue == .selection
                                guard viewModel.currentSoundsListMode.wrappedValue == .selection else { return }
                                multiSelectButtonsEnabled = $0 > 0
                                allSelectedAreFavorites = viewModel.allSelectedAreFavorites()
                            }
                            .onReceive(trendsHelper.$youCanScrollNow) { soundId in
                                if !soundId.isEmpty {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                        withAnimation {
                                            proxy.scrollTo(soundId, anchor: .center)
                                        }
                                        TapticFeedback.warning()
                                    }
                                }
                            }
                            .onAppear {
                                updateGridLayout(with: geometry.size.width)
                            }
                        }

                        if showExplicitDisabledWarning, UserSettings.getShowExplicitContent() == false {
                            ExplicitDisabledWarning(
                                text: UIDevice.isiPhone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac
                            )
                            .padding(.top, explicitOffWarningTopPadding)
                            .padding(.horizontal, explicitOffWarningBottomPadding)
                        }

                        if showSoundCountAtTheBottom, viewModel.searchText.isEmpty {
                            Text("\(sounds.count) SONS")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                                .padding(.bottom, UIDevice.isiPhone ? Shared.Constants.soundCountPhoneBottomPadding : Shared.Constants.soundCountPadBottomPadding)
                        }

                        Spacer()
                            .frame(height: 18)
                    }
                    .if(allowRefresh) {
                        $0.refreshable {
                            syncAction!()
                        }
                    }
                    //.border(.red, width: 1)
                }

            case .error:
                VStack {
                    HStack(spacing: 10) {
                        ProgressView()

                        Text("Erro ao carregar sons.")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .overlay {
            if viewModel.showToastView {
                VStack {
                    Spacer()

                    ToastView(
                        icon: viewModel.toastIcon,
                        iconColor: viewModel.toastIconColor,
                        text: viewModel.toastText
                    )
                    .padding(.horizontal)
                    .padding(
                        .bottom,
                        UIDevice.isiPhone && (stopShowingFloatingSelector.wrappedValue != nil) ? Shared.Constants.toastViewBottomPaddingPhone : Shared.Constants.toastViewBottomPaddingPad
                    )
                }
                .transition(.moveAndFade)
            }
            if showMultiSelectButtons {
                VStack {
                    Spacer()

                    FloatingSelectionOptionsView(
                        areButtonsEnabled: multiSelectButtonsEnabled,
                        allSelectedAreFavorites: allSelectedAreFavorites,
                        folderOperation: multiSelectFolderOperation,
                        shareIsProcessing: viewModel.shareManyIsProcessing,
                        favoriteAction: { viewModel.addRemoveManyFromFavorites() },
                        folderAction: {
                            if multiSelectFolderOperation == .add {
                                viewModel.addManyToFolder()
                            } else {
                                viewModel.showRemoveMultipleSoundsConfirmation()
                            }
                        },
                        shareAction: { viewModel.shareSelected() }
                    )
                }
            }
        }
    }

    // MARK: - Functions

    private func updateGridLayout(with newWidth: CGFloat) {
        columns = GridHelper.adaptableColumns(
            listWidth: newWidth,
            sizeCategory: sizeCategory,
            spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing
        )
    }
}

//#Preview {
//    SoundListView(
//        viewModel: .init(
//            soundsPublisher: .
//            options: [ContextMenuOption.shareSound]
//        ),
//        currentSoundsListMode: .constant(.regular)
//    )
//}