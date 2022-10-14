import SwiftUI

struct MainView: View {

    @State var tabSelection: PhoneTab = .sounds
    @State var state: String? = Screen.allSounds.rawValue
    @State var isShowingSettingsSheet: Bool = false
    @State var updateSoundsList: Bool = false
    @State var isShowingFolderInfoEditingSheet: Bool = false
    @State var updateFolderList: Bool = false
    @State var soundIdToGoToFromTrends: String = .empty
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView(selection: $tabSelection) {
                NavigationView {
                    SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                              authorSortOption: AuthorSortOption.nameAscending.rawValue),
                               currentMode: .allSounds,
                               updateSoundsList: .constant(false),
                               soundIdToGoToFromTrends: $soundIdToGoToFromTrends)
                }
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
                .tag(PhoneTab.sounds)
                
                NavigationView {
                    CollectionsView(isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet)
                }
                .tabItem {
                    Label("Coleções", systemImage: "rectangle.grid.2x2.fill")
                }
                .tag(PhoneTab.collections)
                
                NavigationView {
                    SongsView()
                }
                .tabItem {
                    Label("Músicas", systemImage: "music.quarternote.3")
                }
                .tag(PhoneTab.songs)
                
                NavigationView {
                    TrendsView(tabSelection: $tabSelection, soundIdToGoToFromTrends: $soundIdToGoToFromTrends)
                }
                .tabItem {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(PhoneTab.trends)
                
                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(PhoneTab.settings)
            }
            .onContinueUserActivity(Shared.ActivityTypes.playAndShareSounds, perform: { _ in
                tabSelection = .sounds
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewCollections, perform: { _ in
                tabSelection = .collections
            })
            .onContinueUserActivity(Shared.ActivityTypes.playAndShareSongs, perform: { _ in
                tabSelection = .songs
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewTrends, perform: { _ in
                tabSelection = .trends
            })
        } else {
            NavigationView {
                SidebarView(state: $state,
                            isShowingSettingsSheet: $isShowingSettingsSheet,
                            updateSoundsList: $updateSoundsList,
                            isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet,
                            updateFolderList: $updateFolderList,
                            soundIdToGoToFromTrends: $soundIdToGoToFromTrends)
                SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                          authorSortOption: AuthorSortOption.nameAscending.rawValue),
                           currentMode: .allSounds,
                           updateSoundsList: $updateSoundsList,
                           soundIdToGoToFromTrends: $soundIdToGoToFromTrends)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .sheet(isPresented: $isShowingSettingsSheet, onDismiss: {
                updateSoundsList = true
            }) {
                SettingsCasingWithCloseView(isBeingShown: $isShowingSettingsSheet)
            }
            .sheet(isPresented: $isShowingFolderInfoEditingSheet, onDismiss: {
                updateFolderList = true
            }) {
                FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, selectedBackgroundColor: "pastelPurple")
            }
        }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
