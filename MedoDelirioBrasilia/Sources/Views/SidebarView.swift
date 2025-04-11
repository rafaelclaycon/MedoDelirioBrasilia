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
    @Binding var currentSoundsListMode: SoundsListMode

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
                        viewModel: .init(
                            currentViewMode: .all,
                            soundSortOption: UserSettings().mainSoundListSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode,
                        openSettingsAction: {}
                    ).environment(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.allSounds,
                    selection: $state,
                    label: {
                        Label("Sons", systemImage: "speaker.wave.2")
                    })
                
                NavigationLink(
                    destination: MainContentView(
                        viewModel: .init(
                            currentViewMode: .favorites,
                            soundSortOption: UserSettings().mainSoundListSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues,
                            isAllowedToSync: false
                        ),
                        currentSoundsListMode: $currentSoundsListMode,
                        openSettingsAction: {}
                    ).environment(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.favorites,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    })
                
                NavigationLink(
                    destination: TrendsView(
                        tabSelection: .constant(.trends),
                        activePadScreen: $state
                    ).environment(trendsHelper),
                    tag: PadScreen.trends,
                    selection: $state,
                    label: {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
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
        currentSoundsListMode: .constant(.regular)
    )
}
