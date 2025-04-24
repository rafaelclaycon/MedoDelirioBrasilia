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
    @Binding var currentContentListMode: ContentListMode
    @Binding var toast: Toast?
    @Binding var floatingOptions: FloatingContentOptions?
    let contentRepository: ContentRepositoryProtocol

    // MARK: - View State

    @StateObject private var viewModel = SidebarViewViewModel()
    @EnvironmentObject private var settingsHelper: SettingsHelper
    @EnvironmentObject private var syncValues: SyncValues

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
                            contentRepository: contentRepository
                        ),
                        currentContentListMode: $currentContentListMode,
                        toast: $toast,
                        floatingOptions: $floatingOptions,
                        openSettingsAction: {},
                        contentRepository: contentRepository
                    ).environment(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.allSounds,
                    selection: $state,
                    label: {
                        Label("Sons", systemImage: "speaker.wave.2")
                    }
                )

                NavigationLink(
                    destination: StandaloneFavoritesView(
                        viewModel: StandaloneFavoritesViewModel(
                            contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                            contentRepository: contentRepository
                        ),
                        currentContentListMode: $currentContentListMode,
                        openSettingsAction: {},
                        toast: $toast,
                        contentRepository: contentRepository
                    ),
                    tag: PadScreen.favorites,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    }
                )

                NavigationLink(
                    destination: TrendsView(
                        tabSelection: .constant(.trends),
                        activePadScreen: $state
                    ).environment(trendsHelper),
                    tag: PadScreen.trends,
                    selection: $state,
                    label: {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
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
                        Label("Todas as Pastas", systemImage: "folder")
                    }
                )

                ForEach(viewModel.folders) { folder in
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
            viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
        }
        .onChange(of: updateFolderList) {
            if updateFolderList {
                viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
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
        contentRepository: FakeContentRepository()
    )
}
