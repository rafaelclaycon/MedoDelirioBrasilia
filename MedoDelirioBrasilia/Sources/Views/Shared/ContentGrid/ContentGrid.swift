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
/// sound counts, explicit content warnings, and more. It relies on `ContentGridViewModel` to manage its data and state.
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

    private var state: LoadingState<[AnyEquatableMedoContent]>
    @State private var viewModel: ContentGridViewModel
    private var searchTextIsEmpty: Binding<Bool?>
    private let allowSearch: Bool
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
    private let phoneItemSpacing: CGFloat = 9
    private let padItemSpacing: CGFloat = 14
    @State private var showMultiSelectButtons: Bool = false
    @State private var multiSelectButtonsEnabled: Bool = false
    @State private var allSelectedAreFavorites: Bool = false

    // Add to Folder details
    @State private var addToFolderHelper = AddToFolderDetails()

    // MARK: - Computed Properties

    private var searchResults: [AnyEquatableMedoContent] {
        switch state {
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

    // MARK: - Initializer

    init(
        state: LoadingState<[AnyEquatableMedoContent]>,
        viewModel: ContentGridViewModel,

        searchTextIsEmpty: Binding<Bool?> = .constant(nil),
        allowSearch: Bool = false,
        showNewTag: Bool = true,
        isFavoritesOnlyView: Bool = false,
        authorId: String? = nil,
        reactionId: String? = nil,
        containerSize: CGSize,
        scrollViewProxy: ScrollViewProxy? = nil,

        loadingView: LoadingView,
        emptyStateView: EmptyStateView,
        errorView: ErrorView
    ) {
        self.state = state
        self.viewModel = viewModel
        self.searchTextIsEmpty = searchTextIsEmpty
        self.allowSearch = allowSearch
        self.showNewTag = showNewTag
        self.isFavoritesOnlyView = isFavoritesOnlyView
        self.authorId = authorId
        self.reactionId = reactionId
        self.containerSize = containerSize
        self.scrollViewProxy = scrollViewProxy
        self.loadingView = loadingView
        self.emptyStateView = emptyStateView
        self.errorView = errorView
    }

    // MARK: - View Body

    var body: some View {
        switch state {
        case .loading:
            loadingView
                .frame(width: containerSize.width)
                .frame(minHeight: containerSize.height)

        case .loaded(let loadedContent):
            if loadedContent.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                    if searchResults.isEmpty {
                        NoSearchResultsView(searchText: viewModel.searchText)
                    } else {
                        ForEach(searchResults) { content in
                            PlayableContentView(
                                content: content,
                                showNewTag: showNewTag,
                                favorites: viewModel.favoritesKeeper,
                                highlighted: viewModel.highlightKeeper,
                                nowPlaying: viewModel.nowPlayingKeeper,
                                selectedItems: viewModel.selectionKeeper,
                                currentContentListMode: viewModel.currentListMode
                            )
                            .contentShape(
                                .contextMenuPreview,
                                RoundedRectangle(cornerRadius: .spacing(.large), style: .continuous)
                            )
                            .onTapGesture {
                                viewModel.onContentSelected(content, loadedContent: loadedContent)
                            }
                            .contextMenu {
                                if viewModel.currentListMode.wrappedValue != .selection {
                                    contextMenuOptionsView(
                                        content: content,
                                        menuOptions: viewModel.menuOptions,
                                        favorites: viewModel.favoritesKeeper,
                                        loadedContent: loadedContent
                                    )
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
                                action: { Task { await viewModel.onRemoveMultipleContentSelected() } }
                            ),
                            secondaryButton: .cancel(Text("Cancelar"))
                        )
                    }
                }
                .sheet(isPresented: $viewModel.showingModalView) {
                    switch viewModel.subviewToOpen {
                    case .shareAsVideo:
                        ShareAsVideoView(
                            viewModel: ShareAsVideoViewModel(
                                content: viewModel.selectedContentSingle!,
                                subtitle: viewModel.selectedContentSingle!.subtitle,
                                contentType: viewModel.typeForShareAsVideo(),
                                result: $viewModel.shareAsVideoResult
                            ),
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
                    searchTextIsEmpty.wrappedValue = viewModel.searchText.isEmpty
                }
                .onChange(of: viewModel.shareAsVideoResult.videoFilepath) {
                    viewModel.onDidExitShareAsVideoSheet()
                }
                .onChange(of: viewModel.showingModalView) {
                    if (viewModel.showingModalView == false) && addToFolderHelper.hadSuccess {
                        Task {
                            await viewModel.onAddedContentToFolderSuccessfully(
                                folderName: addToFolderHelper.folderName ?? "",
                                pluralization: addToFolderHelper.pluralization
                            )
                            addToFolderHelper = AddToFolderDetails()
                        }
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
                .onChange(of: viewModel.selectionKeeper.count) {
                    viewModel.onItemSelectionChanged()
                }
                .onChange(of: viewModel.scrollTo) {
                    if !viewModel.scrollTo.isEmpty {
                        withAnimation {
                            scrollViewProxy?.scrollTo(viewModel.scrollTo, anchor: .center)
                        }
                    }
                }
                .onChange(of: viewModel.authorToOpen) {
                    guard let author = viewModel.authorToOpen else { return }
                    push(GeneralNavigationDestination.authorDetail(author))
                    viewModel.authorToOpen = nil
                }
                .onAppear {
                    viewModel.onViewAppeared()
                    updateGridLayout()
                }
            }

        case .error(_):
            errorView
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
                            option.action(
                                viewModel,
                                ContextMenuPassthroughData(
                                    selectedContent: content,
                                    loadedContent: loadedContent,
                                    isFavoritesOnlyView: isFavoritesOnlyView
                                )
                            )
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
            userFolderRepository: UserFolderRepository(database: LocalDatabase()),
            screen: .mainContentView,
            menuOptions: [.sharingOptions()],
            currentListMode: .constant(.regular),
            toast: .constant(nil),
            floatingOptions: .constant(nil),
            analyticsService: AnalyticsService()
        ),
        containerSize: CGSize(width: 390, height: 1200),
        loadingView: ProgressView(),
        emptyStateView: Text("No Sounds to Display"),
        errorView: Text("Error")
    )
    .padding(.horizontal, .spacing(.medium))
}
