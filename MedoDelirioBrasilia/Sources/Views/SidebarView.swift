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
    @Binding var isShowingFolderInfoEditingSheet: Bool
    @Binding var updateFolderList: Bool
    @Binding var currentSoundsListMode: SoundsListMode
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var syncValues: SyncValues

    // Trends
    @EnvironmentObject var trendsHelper: TrendsHelper
    
    var body: some View {
        List {
            Section("Sons") {
                NavigationLink(
                    destination: SoundsView(
                        viewModel: SoundsViewViewModel(
                            currentViewMode: .allSounds,
                            soundSortOption: UserSettings.getSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode
                    ).environmentObject(trendsHelper).environmentObject(settingsHelper).environmentObject(networkMonitor),
                    tag: PadScreen.allSounds,
                    selection: $state,
                    label: {
                        Label("Todos os Sons", systemImage: "speaker.wave.2")
                    })
                
                NavigationLink(
                    destination: SoundsView(
                        viewModel: SoundsViewViewModel(
                            currentViewMode: .favorites,
                            soundSortOption: UserSettings.getSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode
                    ).environmentObject(trendsHelper).environmentObject(settingsHelper).environmentObject(networkMonitor),
                    tag: PadScreen.favorites,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    })
                
                NavigationLink(
                    destination: SoundsView(
                        viewModel: SoundsViewViewModel(
                            currentViewMode: .byAuthor,
                            soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode
                        ).environmentObject(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.groupedByAuthor,
                    selection: $state,
                    label: {
                        Label("Por Autor", systemImage: "person")
                    })
                
                NavigationLink(
                    destination: TrendsView(tabSelection: .constant(.trends),
                                            activePadScreen: $state).environmentObject(trendsHelper),
                    tag: PadScreen.trends,
                    selection: $state,
                    label: {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                    })
                
//                NavigationLink(
//                    destination: CollectionsView(),
//                    tag: PadScreen.collections,
//                    selection: $state,
//                    label: {
//                        Label("Coleções", systemImage: "rectangle.grid.2x2")
//                    })
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
                    destination: AllFoldersiPadView(isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet, updateFolderList: $updateFolderList),
                    tag: PadScreen.allFolders,
                    selection: $state,
                    label: {
                        Label("Todas as Pastas", systemImage: "folder")
                    })
                
                ForEach(viewModel.folders) { folder in
                    NavigationLink(
                        destination: FolderDetailView(viewModel: FolderDetailViewViewModel(currentSoundsListMode: $currentSoundsListMode), folder: folder, currentSoundsListMode: $currentSoundsListMode),
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
                    isShowingFolderInfoEditingSheet = true
                } label: {
                    Label("Nova Pasta", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(LocalizableStrings.MainView.title)
        .toolbar {
            Button {
                isShowingSettingsSheet = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
        .onAppear {
            viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.getAllUserFolders())
        }
        .onChange(of: updateFolderList) { shouldUpdate in
            if shouldUpdate {
                viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.getAllUserFolders())
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(
            state: .constant(PadScreen.allSounds),
            isShowingSettingsSheet: .constant(false),
            isShowingFolderInfoEditingSheet: .constant(false),
            updateFolderList: .constant(false),
            currentSoundsListMode: .constant(.regular)
        )
    }
}
