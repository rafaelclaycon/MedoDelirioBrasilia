import SwiftUI

struct SidebarView: View {

    @StateObject private var viewModel = SidebarViewViewModel()
    @Binding var state: String?
    @Binding var isShowingSettingsSheet: Bool
    @Binding var updateSoundsList: Bool
    @Binding var isShowingFolderInfoEditingSheet: Bool
    @Binding var updateFolderList: Bool
    
    // Trends
    @Binding var soundIdToGoToFromTrends: String
    
    var body: some View {
        List {
            Section("Sons") {
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(), authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .allSounds, updateSoundsList: $updateSoundsList, soundIdToGoToFromTrends: $soundIdToGoToFromTrends),
                    tag: Screen.allSounds.rawValue,
                    selection: $state,
                    label: {
                        Label("Todos os Sons", systemImage: "speaker.wave.2")
                    })
                
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(), authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .favorites, updateSoundsList: .constant(false), soundIdToGoToFromTrends: $soundIdToGoToFromTrends),
                    tag: Screen.favorites.rawValue,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    })
                
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue, authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .byAuthor, updateSoundsList: .constant(false), soundIdToGoToFromTrends: $soundIdToGoToFromTrends),
                    tag: Screen.groupedByAuthor.rawValue,
                    selection: $state,
                    label: {
                        Label("Por Autor", systemImage: "person")
                    })
                
                NavigationLink(
                    destination: CollectionsView(isShowingFolderInfoEditingSheet: .constant(false)),
                    tag: Screen.collections.rawValue,
                    selection: $state,
                    label: {
                        Label("Coleções", systemImage: "rectangle.grid.2x2")
                    })
            }
            
            Section("Mais") {
                NavigationLink(
                    destination: SongsView(),
                    tag: Screen.songs.rawValue,
                    selection: $state,
                    label: {
                        Label("Músicas", systemImage: "music.quarternote.3")
                    })
                
                NavigationLink(
                    destination: TrendsView(tabSelection: .constant(.trends), soundIdToGoToFromTrends: $soundIdToGoToFromTrends),
                    tag: Screen.trends.rawValue,
                    selection: $state,
                    label: {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                    })
            }
            
            Section("Minhas Pastas") {
                NavigationLink(
                    destination: AllFoldersView(isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet, updateFolderList: $updateFolderList),
                    tag: Screen.allFolders.rawValue,
                    selection: $state,
                    label: {
                        Label("Todas as Pastas", systemImage: "folder")
                    })
                
                ForEach(viewModel.folders) { folder in
                    NavigationLink(
                        destination: FolderDetailView(folder: folder),
                        tag: folder.id,
                        selection: $state,
                        label: {
                            HStack(spacing: 15) {
                                SidebarFolderIcon(symbol: folder.symbol, backgroundColor: folder.backgroundColor.toColor())
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
            viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
        }
        .onChange(of: updateFolderList) { shouldUpdate in
            if shouldUpdate {
                viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            }
        }
    }

}

struct SidebarView_Previews: PreviewProvider {

    static var previews: some View {
        SidebarView(state: .constant(Screen.allSounds.rawValue),
                    isShowingSettingsSheet: .constant(false),
                    updateSoundsList: .constant(false),
                    isShowingFolderInfoEditingSheet: .constant(false),
                    updateFolderList: .constant(false),
                    soundIdToGoToFromTrends: .constant(.empty))
    }

}
