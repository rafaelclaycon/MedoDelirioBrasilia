import SwiftUI

struct SidebarView: View {

    @Binding var state: Screen?
    
    var body: some View {
        List {
            NavigationLink(
                destination: SoundsView(currentMode: .allSounds),
                tag: Screen.allSounds,
                selection: $state,
                label: {
                    Label("Todos os Sons", systemImage: "speaker.wave.2")
                })
            NavigationLink(
                destination: SoundsView(currentMode: .favorites),
                tag: Screen.favorites,
                selection: $state,
                label: {
                    Label("Favoritos", systemImage: "star")
                })
            NavigationLink(
                destination: SoundsView(currentMode: .byAuthor),
                tag: Screen.groupedByAuthor,
                selection: $state,
                label: {
                    Label("Agrupados por Autor", systemImage: "person")
                })
            NavigationLink(
                destination: CollectionsView(),
                tag: Screen.collections,
                selection: $state,
                label: {
                    Label("Coleções", systemImage: "rectangle.grid.2x2")
                })
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
            NavigationLink(
                destination: SettingsView(),
                tag: Screen.settings,
                selection: $state,
                label: {
                    Label("Ajustes", systemImage: "gearshape")
                })
            
            Section("Minhas Pastas") {
                NavigationLink(
                    destination: SettingsView(),
                    tag: Screen.allFolders,
                    selection: $state,
                    label: {
                        Label("Todas as Pastas", systemImage: "folder")
                    })
                
                NavigationLink(
                    destination: SettingsView(),
                    tag: Screen.allFolders,
                    selection: $state,
                    label: {
                        HStack(spacing: 15) {
                            SidebarFolderIcon(symbol: "🤑", backgroundColor: .pastelBrightGreen)
                            Text("Grupo da Adm")
                        }
                    })
                
                Button {
                    //
                } label: {
                    Label("Nova Pasta", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }

            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(LocalizableStrings.MainView.title)
    }

}

struct SidebarView_Previews: PreviewProvider {

    static var previews: some View {
        SidebarView(state: .constant(.allSounds))
    }

}
