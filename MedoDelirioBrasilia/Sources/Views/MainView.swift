import SwiftUI

struct MainView: View {

    @State private var tabSelection = 1

    var body: some View {
        TabView(selection: $tabSelection) {
            SoundsView()
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
                .tag(1)
            
            CollectionsView()
                .tabItem {
                    Label("Coleções", systemImage: "rectangle.grid.2x2.fill")
                }
                .tag(2)
            
            SongsView()
                .tabItem {
                    Label("Músicas", systemImage: "music.quarternote.3")
                }
                .tag(3)
            
//            TrendsView()
//                .tabItem {
//                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
//                }
//                .tag(4)
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .onContinueUserActivity(Shared.playAndShareSoundsActivityTypeName, perform: { _ in
            tabSelection = 1
        })
        .onContinueUserActivity(Shared.viewCollectionsActivityTypeName, perform: { _ in
            tabSelection = 2
        })
        .onContinueUserActivity(Shared.playAndShareSongsActivityTypeName, perform: { _ in
            tabSelection = 3
        })
        .onContinueUserActivity(Shared.viewTrendsActivityTypeName, perform: { _ in
            tabSelection = 4
        })
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
