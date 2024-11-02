//
//  SidebarView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 16/07/22.
//

import SwiftUI

struct SidebarView: View {

    @StateObject private var viewModel = SidebarViewViewModel()
    @Binding var state: PadScreen?
    @Binding var isShowingSettingsSheet: Bool
    @Binding var folderForEditing: UserFolder?
    @Binding var updateFolderList: Bool
    @Binding var currentSoundsListMode: SoundsListMode
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var syncValues: SyncValues

    // Trends
    @EnvironmentObject var trendsHelper: TrendsHelper
    @Environment(\.push) var push

    var body: some View {
        List {
            Section("Sons") {
                NavigationLink(
                    destination: MainSoundContainer(
                        viewModel: .init(
                            currentViewMode: .allSounds,
                            soundSortOption: UserSettings().mainSoundListSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode,
                        showSettings: .constant(false)
                    ).environmentObject(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.allSounds,
                    selection: $state,
                    label: {
                        Label("Todos os Sons", systemImage: "speaker.wave.2")
                    })
                
                NavigationLink(
                    destination: MainSoundContainer(
                        viewModel: .init(
                            currentViewMode: .favorites,
                            soundSortOption: UserSettings().mainSoundListSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode,
                        showSettings: .constant(false)
                    ).environmentObject(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.favorites,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    })

                // FIXME: Bring Reactions to iPad in the future.
//                NavigationLink(
//                    destination: ReactionsView(),
//                    tag: PadScreen.reactions,
//                    selection: $state,
//                    label: {
//                        Label("Reações", systemImage: "rectangle.grid.2x2")
//                    }
//                )

                // FIXME: Bring Authors back to iPad in the future.
//                NavigationLink(
//                    destination: SoundsView(
//                        viewModel: SoundsViewViewModel(
//                            currentViewMode: .byAuthor,
//                            soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
//                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
//                            currentSoundsListMode: $currentSoundsListMode,
//                            syncValues: syncValues
//                        ),
//                        currentSoundsListMode: $currentSoundsListMode
//                        ).environmentObject(trendsHelper).environmentObject(settingsHelper),
//                    tag: PadScreen.groupedByAuthor,
//                    selection: $state,
//                    label: {
//                        Label("Por Autor", systemImage: "person")
//                    })
                
                NavigationLink(
                    destination: TrendsView(tabSelection: .constant(.trends),
                                            activePadScreen: $state).environmentObject(trendsHelper),
                    tag: PadScreen.trends,
                    selection: $state,
                    label: {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                    })
            }
            
            Section("Mais") {
                NavigationLink(
                    destination: SongsView().environmentObject(settingsHelper),
                    tag: PadScreen.songs,
                    selection: $state,
                    label: {
                        Label("Músicas", systemImage: "music.quarternote.3")
                    })
            }
            
            Section("Minhas Pastas") {
                NavigationLink(
                    destination: AllFoldersiPadView(
                        folderForEditing: $folderForEditing,
                        updateFolderList: $updateFolderList
                    ),
                    tag: PadScreen.allFolders,
                    selection: $state,
                    label: {
                        Label("Todas as Pastas", systemImage: "folder")
                    })
                
                ForEach(viewModel.folders) { folder in
                    NavigationLink(
                        destination: FolderDetailView(
                            folder: folder,
                            currentSoundsListMode: $currentSoundsListMode
                        ),
                        tag: .specificFolder,
                        selection: $state,
                        label: {
                            HStack(spacing: 15) {
                                SidebarFolderIcon(symbol: folder.symbol, backgroundColor: folder.backgroundColor.toPastelColor())
                                Text(folder.name)
                            }
                        })
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
        .onChange(of: updateFolderList) { shouldUpdate in
            if shouldUpdate {
                viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
            }
        }
    }
}

#Preview {
    SidebarView(
        state: .constant(PadScreen.allSounds),
        isShowingSettingsSheet: .constant(false),
        folderForEditing: .constant(nil),
        updateFolderList: .constant(false),
        currentSoundsListMode: .constant(.regular)
    )
}
