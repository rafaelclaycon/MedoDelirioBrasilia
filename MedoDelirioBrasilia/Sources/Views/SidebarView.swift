import SwiftUI

struct SidebarView: View {

    @Binding var state: Screen?
    @State private var isShowingSettingsSheet: Bool = false
    @Binding var updateSoundsList: Bool
    
    var body: some View {
        List {
            Section("Sons") {
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(sortOption: UserSettings.getSoundSortOption()), currentMode: .allSounds, updateSoundsList: $updateSoundsList),
                    tag: Screen.allSounds,
                    selection: $state,
                    label: {
                        Label("Todos os Sons", systemImage: "speaker.wave.2")
                    })
                
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(sortOption: UserSettings.getSoundSortOption()), currentMode: .favorites, updateSoundsList: .constant(false)),
                    tag: Screen.favorites,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    })
                
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(sortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .byAuthor, updateSoundsList: .constant(false)),
                    tag: Screen.groupedByAuthor,
                    selection: $state,
                    label: {
                        Label("Por Autor", systemImage: "person")
                    })
                
                NavigationLink(
                    destination: CollectionsView(),
                    tag: Screen.collections,
                    selection: $state,
                    label: {
                        Label("Coleções", systemImage: "rectangle.grid.2x2")
                    })
            }
            
            NavigationLink(
                destination: SongsView(),
                tag: Screen.songs,
                selection: $state,
                label: {
                    Label("Músicas", systemImage: "music.quarternote.3")
                })
            
//            NavigationLink(
//                destination: TrendsView(),
//                tag: Screen.trends,
//                selection: $state,
//                label: {
//                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
//                })
            
//            Section("Minhas Pastas") {
//                NavigationLink(
//                    destination: AllFoldersView(),
//                    tag: Screen.allFolders,
//                    selection: $state,
//                    label: {
//                        Label("Todas as Pastas", systemImage: "folder")
//                    })
//                
//                NavigationLink(
//                    destination: SettingsView(),
//                    tag: Screen.settings,
//                    selection: $state,
//                    label: {
//                        HStack(spacing: 15) {
//                            SidebarFolderIcon(symbol: "🤑", backgroundColor: .pastelBrightGreen)
//                            Text("Grupo da Adm")
//                        }
//                    })
//                
//                Button {
//                    //
//                } label: {
//                    Label("Nova Pasta", systemImage: "plus")
//                        .foregroundColor(.accentColor)
//                }
//
//            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(LocalizableStrings.MainView.title)
        .toolbar {
            Button {
                self.isShowingSettingsSheet = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
        .sheet(isPresented: $isShowingSettingsSheet, onDismiss: {
            updateSoundsList = true
        }) {
            SettingsCasingWithCloseView(isBeingShown: $isShowingSettingsSheet)
        }
    }

}

struct SidebarView_Previews: PreviewProvider {

    static var previews: some View {
        SidebarView(state: .constant(.allSounds), updateSoundsList: .constant(false))
    }

}
