//
//  SidebarView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 16/07/22.
//

import SwiftUI

struct SidebarView: View {

    @StateObject private var viewModel = SidebarViewViewModel()
    @Binding var state: PadScreen?
    @Binding var isShowingSettingsSheet: Bool
    @Binding var isShowingFolderInfoEditingSheet: Bool
    //@Binding var updateFolderList: Bool
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var foldersHelper: SettingsHelper
    
    // Trends
    @EnvironmentObject var trendsHelper: TrendsHelper
    
    var body: some View {
        List {
            Section("Sons") {
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                                           authorSortOption: AuthorSortOption.nameAscending.rawValue),
                                            currentMode: .allSounds).environmentObject(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.allSounds,
                    selection: $state,
                    label: {
                        Label("Todos os Sons", systemImage: "speaker.wave.2")
                    })
                
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(), authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .favorites).environmentObject(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.favorites,
                    selection: $state,
                    label: {
                        Label("Favoritos", systemImage: "star")
                    })
                
                NavigationLink(
                    destination: SoundsView(viewModel: SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue, authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .byAuthor).environmentObject(trendsHelper).environmentObject(settingsHelper),
                    tag: PadScreen.groupedByAuthor,
                    selection: $state,
                    label: {
                        Label("Por Autor", systemImage: "person")
                    })
                
                NavigationLink(
                    destination: TrendsView(tabSelection: .constant(.trends),
                                            activePadScreen: $state).environmentObject(trendsHelper),
                    tag: PadScreen.trends,
                    selection: $state,
                    label: {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                    })
                
//                NavigationLink(
//                    destination: CollectionsView(),
//                    tag: PadScreen.collections,
//                    selection: $state,
//                    label: {
//                        Label("Coleções", systemImage: "rectangle.grid.2x2")
//                    })
            }
            
            Section("Mais") {
                NavigationLink(
                    destination: SongsView().environmentObject(settingsHelper),
                    tag: PadScreen.songs,
                    selection: $state,
                    label: {
                        Label("Músicas", systemImage: "music.quarternote.3")
                    })
            }
            
            Section("Minhas Pastas") {
                NavigationLink(
                    destination: AllFoldersiPadView(isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet),
                    tag: PadScreen.allFolders,
                    selection: $state,
                    label: {
                        Label("Todas as Pastas", systemImage: "folder")
                    })
                
                ForEach(viewModel.folders) { folder in
                    NavigationLink(
                        destination: FolderDetailView(folder: folder),
                        tag: .specificFolder,
                        selection: $state,
                        label: {
                            HStack(spacing: 15) {
                                SidebarFolderIcon(symbol: folder.symbol, backgroundColor: folder.backgroundColor.toColor())
                                Text(folder.name)
                            }
                        })
                    .contextMenu {
                        //if UIDevice.current.userInterfaceIdiom == .phone {
                            Section {
                                Button {
                                    //folderIdForEditing = folder.id
                                } label: {
                                    Label("Editar Detalhes da Pasta", systemImage: "pencil")
                                }
                            }
                        //}
                        
                        Section {
                            Button(role: .destructive, action: {
//                                if UIDevice.current.userInterfaceIdiom == .phone {
//                                    let folderName = "\(folder.symbol) \(folder.name)"
//                                    deleteFolderAideiPhone.alertTitle = "Apagar \"\(folderName)\""
//                                    deleteFolderAideiPhone.alertMessage = "Tem certeza de que deseja apagar a pasta \"\(folderName)\"? Os sons não serão apagados."
//                                    deleteFolderAideiPhone.folderIdForDeletion = folder.id
//                                    deleteFolderAideiPhone.showAlert = true
//                                } else {
//                                    let folderName = "\(folder.symbol) \(folder.name)"
//                                    deleteFolderAide.alertTitle = "Apagar \"\(folderName)\""
//                                    deleteFolderAide.alertMessage = "Tem certeza de que deseja apagar a pasta \"\(folderName)\"? Os sons não serão apagados."
//                                    deleteFolderAide.folderIdForDeletion = folder.id
//                                    deleteFolderAide.showAlert = true
//                                }
                            }, label: {
                                HStack {
                                    Text("Apagar Pasta")
                                    Image(systemName: "trash")
                                }
                            })
                        }
                    }
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
        .onReceive(foldersHelper.$updateFolderList) { updateFolderList in
            if updateFolderList {
                viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            }
        }
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
    }

}

struct SidebarView_Previews: PreviewProvider {

    static var previews: some View {
        SidebarView(state: .constant(PadScreen.allSounds),
                    isShowingSettingsSheet: .constant(false),
                    isShowingFolderInfoEditingSheet: .constant(false))
    }

}
