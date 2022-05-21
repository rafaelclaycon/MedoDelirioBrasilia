import SwiftUI

struct MainView: View {

    var body: some View {
        TabView {
            SoundsView()
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favoritos", systemImage: "star.fill")
                }
            
            SongsView()
                .tabItem {
                    Label("Músicas", systemImage: "music.quarternote.3")
                }
            
            TrendsView()
                .tabItem {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            AboutView()
                .tabItem {
                    Label("Sobre", systemImage: "info.circle")
                }
        }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
