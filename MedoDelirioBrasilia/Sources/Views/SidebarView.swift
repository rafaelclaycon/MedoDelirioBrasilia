import SwiftUI

struct SidebarView: View {

    @Binding var state: Screen?
    
    var body: some View {
        List {
            NavigationLink(
                destination: SoundsView(),
                tag: Screen.sounds,
                selection: $state,
                label: {
                    Label("Sons", systemImage: "speaker.wave.3")
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
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(LocalizableStrings.MainView.title)
    }

}

struct SidebarView_Previews: PreviewProvider {

    static var previews: some View {
        SidebarView(state: .constant(.sounds))
    }

}
