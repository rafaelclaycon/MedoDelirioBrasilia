import SwiftUI

struct MainView: View {

    @State private var tabSelection = 1
    @State var state: Screen? = .allSounds
    @State var updateSoundsList: Bool = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView(selection: $tabSelection) {
                NavigationView {
                    SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(), authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .allSounds, updateSoundsList: .constant(false))
                }
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
                .tag(1)
                
                NavigationView {
                    CollectionsView()
                }
                .tabItem {
                    Label("Coleções", systemImage: "rectangle.grid.2x2.fill")
                }
                .tag(2)
                
                NavigationView {
                    SongsView()
                }
                .tabItem {
                    Label("Músicas", systemImage: "music.quarternote.3")
                }
                .tag(3)
                
                NavigationView {
                    TrendsView()
                }
                .tabItem {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(4)
                
                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(5)
            }
            .onContinueUserActivity(Shared.ActivityTypes.playAndShareSounds, perform: { _ in
                tabSelection = 1
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewCollections, perform: { _ in
                tabSelection = 2
            })
            .onContinueUserActivity(Shared.ActivityTypes.playAndShareSongs, perform: { _ in
                tabSelection = 3
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewTrends, perform: { _ in
                tabSelection = 4
            })
        } else {
            NavigationView {
                SidebarView(state: $state, updateSoundsList: $updateSoundsList)
                SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(), authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .allSounds, updateSoundsList: $updateSoundsList)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
