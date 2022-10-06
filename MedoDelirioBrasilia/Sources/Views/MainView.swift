import SwiftUI

struct MainView: View {

    @State private var tabSelection = 1
    @State var state: String? = Screen.allSounds.rawValue
    @State var isShowingSettingsSheet: Bool = false
    @State var updateSoundsList: Bool = false
    @State var isShowingFolderInfoEditingSheet: Bool = false
    @State var updateFolderList: Bool = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView(selection: $tabSelection) {
                NavigationView {
                    SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                              authorSortOption: AuthorSortOption.nameAscending.rawValue),
                               currentMode: .allSounds,
                               updateSoundsList: .constant(false))
                }
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
                .tag(1)
                
                NavigationView {
                    CollectionsView(isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet)
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
                
//                NavigationView {
//                    TrendsView()
//                }
//                .tabItem {
//                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
//                }
//                .tag(4)
                
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
                SidebarView(state: $state,
                            isShowingSettingsSheet: $isShowingSettingsSheet,
                            updateSoundsList: $updateSoundsList,
                            isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet,
                            updateFolderList: $updateFolderList)
                SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                          authorSortOption: AuthorSortOption.nameAscending.rawValue),
                           currentMode: .allSounds,
                           updateSoundsList: $updateSoundsList)
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
