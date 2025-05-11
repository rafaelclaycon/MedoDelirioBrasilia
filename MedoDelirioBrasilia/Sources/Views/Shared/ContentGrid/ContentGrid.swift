//
//  ContentGrid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

/// A generic view that displays a list of content (Sounds and Songs) with customizable states for loading, empty, and error conditions.
///
/// `ContentGrid` supports various customization options, including search functionality. It relies on `ContentGridViewModel` to manage its logic.
///
/// - Parameters:
///   - authorId: The author's ID when `ContentGrid` is inside `AuthorDetailView`. This is used to avoid reopening the same author more than once when a user taps the author's name in `ContentDetailView`.
///   - LoadingView: A view shown when data is loading.
///   - EmptyStateView: A view displayed when there are no sounds to show.
///   - ErrorView: A view displayed when data loading fails.
struct ContentGrid<
    LoadingView: View,
    EmptyStateView: View,
    ErrorView: View
>: View {

    // MARK: - Dependencies

    @State private var viewModel: ContentGridViewModel
    @State private var playableContentViewModel: PlayableContentViewModel

    private var state: LoadingState<[AnyEquatableMedoContent]>
    private var searchText: String?
    private let trendsService: TrendsServiceProtocol?
    private var contentGridIsSearching: Binding<Bool>
    private let showNewTag: Bool
    private let isFavoritesOnlyView: Bool
    private let authorId: String?
    private let reactionId: String?
    private let containerSize: CGSize
    private let scrollViewProxy: ScrollViewProxy?

    @ViewBuilder private let loadingView: LoadingView
    @ViewBuilder private let emptyStateView: EmptyStateView
    @ViewBuilder private let errorView: ErrorView

    // MARK: - Stored Properties

    @State private var columns: [GridItem] = []
    private let phoneItemSpacing: CGFloat = .spacing(.small)
    private let padItemSpacing: CGFloat = .spacing(.medium)
    @State private var showMultiSelectButtons: Bool = false
    @State private var multiSelectButtonsEnabled: Bool = false
    @State private var allSelectedAreFavorites: Bool = false

    // Add to Folder details
    @State private var addToFolderHelper = AddToFolderDetails()

    // MARK: - Environment

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.push) private var push
    @Environment(\.isSearching) private var isSearching

    // MARK: - Initializer

    init(
        state: LoadingState<[AnyEquatableMedoContent]>,
        viewModel: ContentGridViewModel,

        searchText: String? = nil,
        trendsService: TrendsServiceProtocol? = nil,
        contentGridIsSearching: Binding<Bool> = .constant(false),
        showNewTag: Bool = true,
        isFavoritesOnlyView: Bool = false,
        authorId: String? = nil,
        reactionId: String? = nil,
        containerSize: CGSize,
        scrollViewProxy: ScrollViewProxy? = nil,

        contentRepository: ContentRepositoryProtocol? = nil,
        userFolderRepository: UserFolderRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,

        loadingView: LoadingView,
        emptyStateView: EmptyStateView,
        errorView: ErrorView
    ) {
        self.state = state
        self.viewModel = viewModel
        self.searchText = searchText
        self.trendsService = trendsService
        self.contentGridIsSearching = contentGridIsSearching
        self.showNewTag = showNewTag
        self.isFavoritesOnlyView = isFavoritesOnlyView
        self.authorId = authorId
        self.reactionId = reactionId
        self.containerSize = containerSize
        self.scrollViewProxy = scrollViewProxy
        self.loadingView = loadingView
        self.emptyStateView = emptyStateView
        self.errorView = errorView

        self.playableContentViewModel = PlayableContentViewModel(
            contentRepository: contentRepository ?? FakeContentRepository(),
            userFolderRepository: userFolderRepository ?? FakeUserFolderRepository(),
            screen: .searchResultsView,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            toast: viewModel.toast,
            floatingOptions: viewModel.floatingOptions,
            analyticsService: analyticsService ?? FakeAnalyticsService()
        )
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            switch state {
            case .loading:
                loadingView
                    .frame(width: containerSize.width)
                    .frame(minHeight: containerSize.height)

            case .loaded(let loadedContent):
                if loadedContent.isEmpty {
                    emptyStateView
                } else if let searchText, let trendsService, isSearching {
                    if searchText.isEmpty {
                        SearchSuggestionsView(
                            recent: viewModel.searchService.recentSearches(),
                            trendsService: trendsService,
                            onRecentSelectedAction: {
                                //searchText = $0
                                print("Send to searchText: \($0)")
                            },
                            onReactionSelectedAction: {
                                push(GeneralNavigationDestination.reactionDetail($0))
                            },
                            containerWidth: containerSize.width,
                            onClearSearchesAction: {
                                viewModel.searchService.clearRecentSearches()
                            }
                        )
                    } else {
                        SearchResultsView(
                            viewModel: playableContentViewModel,
                            searchString: searchText,
                            results: viewModel.searchResults,
                            containerWidth: containerSize.width
                        )
                    }
                } else {
                    PlayableContentWrapperView(
                        showAlert: playableContentViewModel.showAlert,
                        showModalView: playableContentViewModel.showingModalView,
                        showiPadShareSheet: playableContentViewModel.isShowingShareSheet,
                        alertType: playableContentViewModel.alertType,
                        subviewToOpen: playableContentViewModel.subviewToOpen,
                        iPadShareSheet: playableContentViewModel.iPadShareSheet,
                        alertTitle: playableContentViewModel.alertTitle,
                        alertMessage: playableContentViewModel.alertMessage,
                        onRedownloadContentOptionSelected: playableContentViewModel.onRedownloadContentOptionSelected,
                        onReportContentIssueSelected: playableContentViewModel.onReportContentIssueSelected,
                        innerView: {
                            LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                                ForEach(loadedContent) { content in
                                    PlayableContentView(
                                        content: content,
                                        showNewTag: showNewTag,
                                        favorites: playableContentViewModel.favoritesKeeper,
                                        highlighted: viewModel.highlightKeeper,
                                        nowPlaying: playableContentViewModel.nowPlayingKeeper,
                                        selectedItems: viewModel.selectionKeeper,
                                        currentContentListMode: viewModel.currentListMode
                                    )
                                    .contentShape(
                                        .contextMenuPreview,
                                        RoundedRectangle(cornerRadius: .spacing(.large), style: .continuous)
                                    )
                                    .onTapGesture {
                                        playableContentViewModel.onContentSelected(content, loadedContent: loadedContent)
                                    }
        //                            .contextMenu {
        //                                if viewModel.currentListMode.wrappedValue != .selection {
        //                                    contextMenuOptionsView(
        //                                        content: content,
        //                                        menuOptions: viewModel.menuOptions,
        //                                        favorites: viewModel.favoritesKeeper,
        //                                        loadedContent: loadedContent
        //                                    )
        //                                }
        //                            }
                                }
                            }
                            .alert(isPresented: $viewModel.showAlert) {
                                switch viewModel.alertType {
                                case .issueExportingManySounds, .issueRemovingContentFromFolder:
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
                                            action: { Task { await viewModel.onRemoveMultipleContentSelected() } }
                                        ),
                                        secondaryButton: .cancel(Text("Cancelar"))
                                    )
                                }
                            }
//                            .sheet(isPresented: $viewModel.showingModalView) {
//                                switch viewModel.subviewToOpen {
//                                case .authorIssueEmailPicker(let content):
//                                    EmailAppPickerView(
//                                        isBeingShown: $viewModel.showingModalView,
//                                        toast: viewModel.toast,
//                                        subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, content.title),
//                                        emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, content.subtitle, content.id)
//                                    )
//                                }
//                            }
//                            .onChange(of: containerSize.width) {
//                                updateGridLayout()
//                            }
//                            .onChange(of: viewModel.selectionKeeper.count) {
//                                viewModel.onItemSelectionChanged()
//                            }
//                            .onChange(of: viewModel.scrollTo) {
//                                if !viewModel.scrollTo.isEmpty {
//                                    withAnimation {
//                                        scrollViewProxy?.scrollTo(viewModel.scrollTo, anchor: .center)
//                                    }
//                                }
//                            }
//                            .onAppear {
//                                updateGridLayout()
//                            }
//                        }
//                    )
                }

            case .error(_):
                errorView
            }
        }
        .onChange(of: searchText) {
            guard let searchText else { return }
            viewModel.onSearchStringChanged(newString: searchText)
        }
        .onChange(of: isSearching) {
            contentGridIsSearching.wrappedValue = isSearching
        }
    }

    // MARK: - Subviews

    @MainActor @ViewBuilder
    private func contextMenuOptionsView(
        content: AnyEquatableMedoContent,
        menuOptions: [ContextMenuSection],
        favorites: Set<String>,
        loadedContent: [AnyEquatableMedoContent]
    ) -> some View {
        ForEach(menuOptions, id: \.title) { section in
            Section {
                ForEach(section.options(content)) { option in
                    if option.appliesTo.contains(content.type) {
                        Button {
//                            option.action(
//                                viewModel,
//                                ContextMenuPassthroughData(
//                                    selectedContent: content,
//                                    loadedContent: loadedContent,
//                                    isFavoritesOnlyView: isFavoritesOnlyView
//                                )
//                            )
                        } label: {
                            Label(
                                option.title(favorites.contains(content.id)),
                                systemImage: option.symbol(favorites.contains(content.id))
                            )
                        }
                    }
                }
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
    ContentGrid(
        state: .loading,
        viewModel: ContentGridViewModel(
            contentRepository: FakeContentRepository(),
            searchService: SearchService(
                contentRepository: FakeContentRepository(),
                authorService: FakeAuthorService(),
                appMemory: FakeAppPersistentMemory(),
                userFolderRepository: FakeUserFolderRepository()
            ),
            userFolderRepository: UserFolderRepository(database: LocalDatabase()),
            screen: .mainContentView,
            menuOptions: [.sharingOptions()],
            currentListMode: .constant(.regular),
            toast: .constant(nil),
            floatingOptions: .constant(nil),
            analyticsService: AnalyticsService()
        ),
        containerSize: CGSize(width: 390, height: 1200),
        contentRepository: FakeContentRepository(),
        userFolderRepository: FakeUserFolderRepository(),
        analyticsService: FakeAnalyticsService(),
        loadingView: ProgressView(),
        emptyStateView: Text("No Sounds to Display"),
        errorView: Text("Error")
    )
    .padding(.horizontal, .spacing(.medium))
}
