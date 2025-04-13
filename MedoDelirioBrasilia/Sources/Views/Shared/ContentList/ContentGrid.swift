//
//  ContentGrid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

/// A generic view that displays a list of sounds with customizable states for loading, empty, and error conditions.
///
/// `ContentGrid` supports various customization options, including search functionality, multi-selection, and conditional UI elements like
/// sound counts, explicit content warnings, and more. It relies on `ContentListViewModel` to manage its data and state.
///
/// - Parameters:
///   - authorId: The author's ID when `ContentGrid` is inside `AuthorDetailView`. This is used to avoid reopening the same author more than once when a user taps the author's name in `ContentDetailView`.
///   - HeaderView: A view displayed at the top of the list, such as a custom header or title.
///   - LoadingView: A view shown when data is loading.
///   - EmptyStateView: A view displayed when there are no sounds to show.
///   - ErrorView: A view displayed when data loading fails.
struct ContentGrid<
    HeaderView: View,
    LoadingView: View,
    EmptyStateView: View,
    ErrorView: View
>: View {

    // MARK: - Dependencies

    @StateObject private var viewModel: ContentListViewModel<[AnyEquatableMedoContent]>
    private var soundSearchTextIsEmpty: Binding<Bool?>
    private var allowSearch: Bool
    private var showSoundCountAtTheBottom: Bool
    private var showExplicitDisabledWarning: Bool
    private var multiSelectFolderOperation: FolderOperation = .add
    private var showNewTag: Bool
    private var dataLoadingDidFail: Bool
    private let authorId: String?
    private let reactionId: String?
    private let containerSize: CGSize

    @ViewBuilder private let headerView: HeaderView?
    @ViewBuilder private let loadingView: LoadingView
    @ViewBuilder private let emptyStateView: EmptyStateView
    @ViewBuilder private let errorView: ErrorView

    // MARK: - Stored Properties

    @State private var columns: [GridItem] = []
    private let phoneItemSpacing: CGFloat = 9
    private let padItemSpacing: CGFloat = 14
    @State private var showMultiSelectButtons: Bool = false
    @State private var multiSelectButtonsEnabled: Bool = false
    @State private var allSelectedAreFavorites: Bool = false

    // Add to Folder details
    @State private var addToFolderHelper = AddToFolderDetails()

    @ScaledMetric private var explicitOffWarningTopPadding = 16
    @ScaledMetric private var explicitOffWarningBottomPadding = 20

    // MARK: - Computed Properties

    private var searchResults: [AnyEquatableMedoContent] {
        switch viewModel.state {
        case .loaded(let content):
            if viewModel.searchText.isEmpty {
                return content
            } else {
                return content.filter { item in
                    let searchString = "\(item.description.lowercased().withoutDiacritics()) \(item.subtitle.lowercased().withoutDiacritics())"
                    return searchString.contains(viewModel.searchText.lowercased().withoutDiacritics())
                }
            }
        case .loading, .error:
            return []
        }
    }

    // MARK: - Environment

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.push) private var push
    @Environment(TrendsHelper.self) private var trendsHelper

    // MARK: - Initializer

    init(
        viewModel: ContentListViewModel<[AnyEquatableMedoContent]>,
        soundSearchTextIsEmpty: Binding<Bool?> = .constant(nil),
        allowSearch: Bool = false,
        showSoundCountAtTheBottom: Bool = false,
        showExplicitDisabledWarning: Bool = false,
        multiSelectFolderOperation: FolderOperation = .add,
        showNewTag: Bool = true,
        dataLoadingDidFail: Bool,
        authorId: String? = nil,
        reactionId: String? = nil,
        containerSize: CGSize,
        headerView: (() -> HeaderView)? = nil,
        loadingView: LoadingView,
        emptyStateView: EmptyStateView,
        errorView: ErrorView
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.soundSearchTextIsEmpty = soundSearchTextIsEmpty
        self.allowSearch = allowSearch
        self.showSoundCountAtTheBottom = showSoundCountAtTheBottom
        self.showExplicitDisabledWarning = showExplicitDisabledWarning
        self.multiSelectFolderOperation = multiSelectFolderOperation
        self.showNewTag = showNewTag
        self.dataLoadingDidFail = dataLoadingDidFail
        self.authorId = authorId
        self.reactionId = reactionId
        self.containerSize = containerSize
        self.headerView = headerView?()
        self.loadingView = loadingView
        self.emptyStateView = emptyStateView
        self.errorView = errorView
    }

    // MARK: - View Body

    var body: some View {
        if dataLoadingDidFail {
            VStack {
                if let headerView {
                    headerView
                }
                errorView
            }
            .frame(width: containerSize.width)
            .frame(minHeight: containerSize.height)
        } else {
            switch viewModel.state {
            case .loading:
                VStack {
                    if let headerView {
                        headerView
                    }
                    loadingView
                }
                .frame(width: containerSize.width)
                .frame(minHeight: containerSize.height)

            case .loaded(let loadedContent):
                if loadedContent.isEmpty {
                    VStack {
                        if let headerView {
                            headerView
                        }
                        Spacer()
                        emptyStateView
                        Spacer()
                    }
                    .frame(width: containerSize.width)
                    .frame(minHeight: containerSize.height)
                } else {
                    VStack {
                        if let headerView {
                            headerView
                        }

                        LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                            if searchResults.isEmpty {
                                NoSearchResultsView(searchText: $viewModel.searchText)
                            } else {
                                ForEach(searchResults) { content in
                                    PlayableContentView(
                                        content: content,
                                        showNewTag: showNewTag,
                                        favorites: $viewModel.favoritesKeeper,
                                        highlighted: $viewModel.highlightKeeper,
                                        nowPlaying: $viewModel.nowPlayingKeeper,
                                        selectedItems: $viewModel.selectionKeeper,
                                        currentContentListMode: viewModel.currentListMode
                                    )
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .onTapGesture {
                                        viewModel.onContentSelected(content)
                                    }
                                    .contextMenu {
                                        if viewModel.currentListMode.wrappedValue != .selection {
                                            ForEach(viewModel.menuOptions, id: \.title) { section in
                                                Section {
                                                    ForEach(section.options(content)) { option in
                                                        Button {
                                                            option.action(content, viewModel)
                                                        } label: {
                                                            Label(
                                                                option.title(viewModel.favoritesKeeper.contains(content.id)),
                                                                systemImage: option.symbol(viewModel.favoritesKeeper.contains(content.id))
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
                                    primaryButton: .default(
                                        Text("Baixar Novamente"),
                                        action: { viewModel.onRedownloadContentOptionSelected() }
                                    ),
                                    secondaryButton: .cancel(Text("Fechar"))
                                )

                            case .issueSharingSound:
                                return Alert(
                                    title: Text(viewModel.alertTitle),
                                    message: Text(viewModel.alertMessage),
                                    primaryButton: .default(
                                        Text("Relatar Problema por E-mail"),
                                        action: { viewModel.onReportContentIssueSelected() }
                                    ),
                                    secondaryButton: .cancel(Text("Fechar"))
                                )

                            case .issueExportingManySounds, .unableToRedownloadSound, .issueRemovingSoundFromFolder:
                                return Alert(
                                    title: Text(viewModel.alertTitle),
                                    message: Text(viewModel.alertMessage),
                                    dismissButton: .default(Text("OK"))
                                )

                            case .removeSingleSound:
                                return Alert(
                                    title: Text(viewModel.alertTitle),
                                    message: Text(viewModel.alertMessage),
                                    primaryButton: .destructive(
                                        Text("Remover"),
                                        action: { viewModel.onRemoveSingleContentSelected() }
                                    ),
                                    secondaryButton: .cancel(Text("Cancelar"))
                                )

                            case .removeMultipleSounds:
                                return Alert(
                                    title: Text(viewModel.alertTitle),
                                    message: Text(viewModel.alertMessage),
                                    primaryButton: .destructive(
                                        Text("Remover"),
                                        action: { viewModel.onRemoveMultipleContentSelected() }
                                    ),
                                    secondaryButton: .cancel(Text("Cancelar"))
                                )
                            }
                        }
                        .sheet(isPresented: $viewModel.showingModalView) {
                            switch viewModel.subviewToOpen {
                            case .shareAsVideo:
                                ShareAsVideoView(
                                    viewModel: ShareAsVideoViewViewModel(
                                        content: viewModel.selectedContentSingle!,
                                        subtitle: viewModel.selectedContentSingle!.subtitle,
                                        contentType: viewModel.typeForShareAsVideo()
                                    ),
                                    result: $viewModel.shareAsVideoResult,
                                    useLongerGeneratingVideoMessage: viewModel.selectedContentSingle!.type == .song
                                )

                            case .addToFolder:
                                AddToFolderView(
                                    isBeingShown: $viewModel.showingModalView,
                                    details: $addToFolderHelper,
                                    selectedContent: viewModel.selectedContentMultiple ?? []
                                )

                            case .contentDetail:
                                ContentDetailView(
                                    content: viewModel.selectedContentSingle ?? AnyEquatableMedoContent(Sound(title: "")),
                                    openAuthorDetailsAction: { author in
                                        guard author.id != self.authorId else { return }
                                        viewModel.showingModalView.toggle()
                                        push(GeneralNavigationDestination.authorDetail(author))
                                    },
                                    authorId: authorId,
                                    openReactionAction: { reaction in
                                        viewModel.showingModalView.toggle()
                                        push(GeneralNavigationDestination.reactionDetail(reaction))
                                    },
                                    reactionId: reactionId,
                                    dismissAction: { viewModel.showingModalView = false }
                                )

                            case .soundIssueEmailPicker:
                                EmailAppPickerView(
                                    isBeingShown: $viewModel.showingModalView,
                                    toast: viewModel.toast,
                                    subject: Shared.issueSuggestionEmailSubject,
                                    emailBody: Shared.issueSuggestionEmailBody
                                )

                            case .authorIssueEmailPicker(let content):
                                EmailAppPickerView(
                                    isBeingShown: $viewModel.showingModalView,
                                    toast: viewModel.toast,
                                    subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, content.title),
                                    emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, content.subtitle, content.id)
                                )
                            }
                        }
                        .sheet(isPresented: $viewModel.isShowingShareSheet) {
                            viewModel.iPadShareSheet
                        }
                        .onChange(of: viewModel.searchText) {
                            soundSearchTextIsEmpty.wrappedValue = viewModel.searchText.isEmpty
                        }
                        .onChange(of: viewModel.shareAsVideoResult.videoFilepath) {
                            viewModel.onDidExitShareAsVideoSheet()
                        }
                        .onChange(of: viewModel.showingModalView) {
                            if (viewModel.showingModalView == false) && addToFolderHelper.hadSuccess {
                                viewModel.onAddedContentToFolderSuccessfully(
                                    folderName: addToFolderHelper.folderName ?? "",
                                    pluralization: addToFolderHelper.pluralization
                                )
                                addToFolderHelper = AddToFolderDetails()
                            }
                        }
                        .onChange(of: containerSize.width) {
                            updateGridLayout()
                        }
                        .onChange(of: searchResults) {
                            if searchResults.isEmpty {
                                columns = [GridItem(.flexible())]
                            } else {
                                updateGridLayout()
                            }
                        }
                         //                                .onChange(of: viewModel.selectionKeeper.count) {
                         //                                    showMultiSelectButtons = viewModel.currentContentListMode.wrappedValue == .selection
                         //                                    guard viewModel.currentContentListMode.wrappedValue == .selection else { return }
                         //                                    multiSelectButtonsEnabled = viewModel.selectionKeeper.count > 0
                         //                                    allSelectedAreFavorites = viewModel.allSelectedAreFavorites()
                         //                                }
//                                        .onChange(of: trendsHelper.soundIdToGoTo) {
//                                            if !trendsHelper.soundIdToGoTo.isEmpty {
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
//                                                    withAnimation {
//                                                        proxy.scrollTo(trendsHelper.soundIdToGoTo, anchor: .center)
//                                                    }
//                                                    TapticFeedback.warning()
//                                                    trendsHelper.soundIdToGoTo = ""
//                                                }
//                                            }
//                                        }
//                        .onChange(of: viewModel.scrollTo) {
//                            if !viewModel.scrollTo.isEmpty {
//                                withAnimation {
//                                    proxy.scrollTo(viewModel.scrollTo, anchor: .center)
//                                }
//                            }
//                        }
                        .onChange(of: viewModel.authorToOpen) {
                            guard let author = viewModel.authorToOpen else { return }
                            push(GeneralNavigationDestination.authorDetail(author))
                            viewModel.authorToOpen = nil
                        }
                        .onAppear {
                            updateGridLayout()
                        }

                        if showExplicitDisabledWarning, !UserSettings().getShowExplicitContent() {
                            ExplicitDisabledWarning(
                                text: UIDevice.isiPhone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac
                            )
                            .padding(.top, explicitOffWarningTopPadding)
                            .padding(.horizontal, explicitOffWarningBottomPadding)
                        }

                        if showSoundCountAtTheBottom, viewModel.searchText.isEmpty {
                            Text("\(loadedContent.count) ITENS")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top, .spacing(.small))
                                .padding(.bottom, Shared.Constants.soundCountPadBottomPadding)
                        }

                        Spacer()
                            .frame(height: .spacing(.large))
                    }
//                    .overlay {
//                        if showMultiSelectButtons {
//                            VStack {
//                                Spacer()
//
//                                FloatingSelectionOptionsView(
//                                    areButtonsEnabled: multiSelectButtonsEnabled,
//                                    allSelectedAreFavorites: allSelectedAreFavorites,
//                                    folderOperation: multiSelectFolderOperation,
//                                    shareIsProcessing: viewModel.shareManyIsProcessing,
//                                    favoriteAction: { viewModel.onAddRemoveManyFromFavoritesSelected() },
//                                    folderAction: { viewModel.onAddRemoveManyFromFolderSelected(multiSelectFolderOperation) },
//                                    shareAction: { viewModel.onShareManySelected() }
//                                )
//                            }
//                        }
//                    }
                }

            case .error(_):
                VStack {
                    if let headerView {
                        headerView
                    }
                    errorView
                }
                .frame(width: containerSize.width)
                .frame(minHeight: containerSize.height)
            }
        }
    }

    // MARK: - Functions

    private func updateGridLayout() {
        columns = GridHelper.adaptableColumns(
            listWidth: containerSize.width,
            sizeCategory: sizeCategory,
            spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing
        )
    }
}

// MARK: - Preview

#Preview {
    ContentGrid<
        EmptyView, ProgressView, Text, Text
    >(
        viewModel: .init(
            data: MockContentListViewModel().allSoundsPublisher,
            menuOptions: [.sharingOptions()],
            currentListMode: .constant(.regular),
            toast: .constant(nil)
        ),
        dataLoadingDidFail: false,
        containerSize: CGSize(width: 390, height: 1200),
        loadingView: ProgressView(),
        emptyStateView: Text("No Sounds to Display"),
        errorView: Text("Error")
    )
}
