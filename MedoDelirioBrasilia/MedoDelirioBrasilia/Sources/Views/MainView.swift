import SwiftUI

struct MainView: View {

    var body: some View {
        TabView {
            SoundsView()
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
            
//            AuthorsView()
//                .tabItem {
//                    Label("Autores", systemImage: "person.fill")
//                }
            
            SongsView()
                .tabItem {
                    Label("Músicas", systemImage: "music.quarternote.3")
                }
            
            TrendsView()
                .tabItem {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
        }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
