//
//  SidebarView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 16/07/22.
//

import SwiftUI

struct SidebarView: View {

    // MARK: - External Dependencies

    @Binding var state: PadScreen?
    @Binding var isShowingSettingsSheet: Bool
    @Binding var folderForEditing: UserFolder?
    @Binding var updateFolderList: Bool
    @Binding var currentContentListMode: ContentGridMode
    @Binding var toast: Toast?
    @Binding var floatingOptions: FloatingContentOptions?
    let contentRepository: ContentRepositoryProtocol
    let trendsService: TrendsServiceProtocol

    // MARK: - View State

    @State private var viewModel = SidebarViewModel(
        userFolderRepository: UserFolderRepository(database: LocalDatabase.shared)
    )

    @Environment(SettingsHelper.self) private var settingsHelper
    @Environment(SyncValues.self) private var syncValues

    // Trends
    @Environment(TrendsHelper.self) private var trendsHelper
    @Environment(\.push) private var push

    // MARK: - View Body

    var body: some View {
        List {
            Section {
                NavigationLink(
                    destination: MainContentView(
                        viewModel: MainContentViewModel(
                            currentViewMode: .all,
                            contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentContentListMode: $currentContentListMode,
                            toast: $toast,
                            floatingOptions: $floatingOptions,
                            syncValues: syncValues,
                            contentRepository: contentRepository,
                            analyticsService: AnalyticsService()
                        ),
                        currentContentListMode: $currentContentListMode,
                        toast: $toast,
                        floatingOptions: $floatingOptions,
                        openSettingsAction: {},
                        contentRepository: contentRepository,
                        bannerRepository: BannerRepository(),
                        trendsService: trendsService,
                        userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
                        analyticsService: AnalyticsService()
                    ).environment(trendsHelper).environment(settingsHelper),
                    tag: PadScreen.allSounds,
                    selection: $state,
                    label: {
                        Label(Shared.TabInfo.name(.allSounds), systemImage: Shared.TabInfo.symbol(.allSounds))
                    }
                )

                NavigationLink(
                    destination: StandaloneFavoritesView(
                        viewModel: StandaloneFavoritesViewModel(
                            contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                            toast: $toast,
                            floatingOptions: $floatingOptions,
                            contentRepository: contentRepository
                        ),
                        currentContentListMode: $currentContentListMode,
                        openSettingsAction: {},
                        contentRepository: contentRepository
                    ),
                    tag: PadScreen.favorites,
                    selection: $state,
                    label: {
                        Label(Shared.TabInfo.name(.favorites), systemImage: Shared.TabInfo.symbol(.favorites))
                    }
                )

                NavigationLink(
                    destination: TrendsView(
                        audienceViewModel: MostSharedByAudienceView.ViewModel(trendsService: trendsService),
                        tabSelection: .constant(.trends),
                        activePadScreen: $state
                    ).environment(trendsHelper),
                    tag: PadScreen.trends,
                    selection: $state,
                    label: {
                        Label(Shared.TabInfo.name(PadScreen.trends), systemImage: Shared.TabInfo.symbol(PadScreen.trends))
                    }
                )
            }
            
            Section("Minhas Pastas") {
                NavigationLink(
                    destination: StandaloneFolderGridView(
                        folderForEditing: $folderForEditing,
                        updateFolderList: $updateFolderList,
                        contentRepository: contentRepository
                    ),
                    tag: PadScreen.allFolders,
                    selection: $state,
                    label: {
                        Label(Shared.TabInfo.name(.allFolders), systemImage: Shared.TabInfo.symbol(.allFolders))
                    }
                )

                switch viewModel.state {
                case .loading:
                    ProgressView()

                case .loaded(let folders):
                    ForEach(folders) { folder in
                        NavigationLink(
                            destination: FolderDetailView(
                                viewModel: FolderDetailViewModel(
                                    folder: folder,
                                    contentRepository: contentRepository
                                ),
                                folder: folder,
                                currentContentListMode: $currentContentListMode,
                                toast: $toast,
                                floatingOptions: $floatingOptions,
                                contentRepository: contentRepository
                            ),
                            tag: .specificFolder,
                            selection: $state,
                            label: {
                                HStack(spacing: 15) {
                                    SidebarFolderIcon(
                                        symbol: folder.symbol,
                                        backgroundColor: folder.backgroundColor.toPastelColor()
                                    )

                                    Text(folder.name)
                                }
                            }
                        )
                    }

                case .error(_):
                    Text("Erro carregando as pastas.")
                }

                Button {
                    folderForEditing = UserFolder.newFolder()
                } label: {
                    Label("Nova Pasta", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(LocalizableStrings.MainView.title)
        .toolbar {
            Button {
                isShowingSettingsSheet = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
        .onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
        .onChange(of: updateFolderList) {
            if updateFolderList {
                Task {
                    await viewModel.onFoldersChanged()
                }
                updateFolderList = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SidebarView(
        state: .constant(PadScreen.allSounds),
        isShowingSettingsSheet: .constant(false),
        folderForEditing: .constant(nil),
        updateFolderList: .constant(false),
        currentContentListMode: .constant(.regular),
        toast: .constant(nil),
        floatingOptions: .constant(nil),
        contentRepository: FakeContentRepository(),
        trendsService: TrendsService(
            database: FakeLocalDatabase(),
            apiClient: FakeAPIClient(),
            contentRepository: FakeContentRepository()
        )
    )
}
