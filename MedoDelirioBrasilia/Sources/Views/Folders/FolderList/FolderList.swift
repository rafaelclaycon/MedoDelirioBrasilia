//
//  FolderList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/09/22.
//

import SwiftUI

/// Sub-view loaded inside the Collections tab on iPhone and the All Folders tab on iPad and Mac.
struct FolderList: View {

    @StateObject private var viewModel = FolderListViewModel()
    @State var displayJoinFolderResearchBanner: Bool = false
    @Binding var updateFolderList: Bool
    @Binding var deleteFolderAid: DeleteFolderViewAide
    @Binding var folderIdForEditing: String
    @EnvironmentObject var deleteFolderAidiPhone: DeleteFolderViewAideiPhone
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    private var noFoldersScrollHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let screenWidth = UIScreen.main.bounds.height
            if screenWidth < 600 {
                return 0
            } else if screenWidth < 800 {
                return 50
            } else {
                return 100
            }
        } else {
            return 100
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.hasFoldersToDisplay {
                if displayJoinFolderResearchBanner {
                    JoinFolderResearchBannerView(viewModel: JoinFolderResearchBannerViewViewModel(state: .displayingRequestToJoin),
                                                 displayMe: $displayJoinFolderResearchBanner)
                        .padding(.bottom)
                }
                
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.folders, id: \.editingIdentifyingId) { folder in
                        NavigationLink {
                            FolderDetailView(folder: folder)
                        } label: {
                            FolderCell(symbol: folder.symbol, name: folder.name, backgroundColor: folder.backgroundColor.toColor())
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                        }
                        .foregroundColor(.primary)
                        .contextMenu {
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                Section {
                                    Button {
                                        folderIdForEditing = folder.id
                                    } label: {
                                        Label("Editar Pasta", systemImage: "pencil")
                                    }
                                }
                            }
                            
                            Section {
                                Button(role: .destructive, action: {
                                    if UIDevice.current.userInterfaceIdiom == .phone {
                                        let folderName = "\(folder.symbol) \(folder.name)"
                                        deleteFolderAidiPhone.alertTitle = "Apagar \"\(folderName)\""
                                        deleteFolderAidiPhone.alertMessage = "Tem certeza de que deseja apagar a pasta \"\(folderName)\"? Os sons não serão apagados."
                                        deleteFolderAidiPhone.folderIdForDeletion = folder.id
                                        deleteFolderAidiPhone.showAlert = true
                                    } else {
                                        let folderName = "\(folder.symbol) \(folder.name)"
                                        deleteFolderAid.alertTitle = "Apagar \"\(folderName)\""
                                        deleteFolderAid.alertMessage = "Tem certeza de que deseja apagar a pasta \"\(folderName)\"? Os sons não serão apagados."
                                        deleteFolderAid.folderIdForDeletion = folder.id
                                        deleteFolderAid.showAlert = true
                                    }
                                }, label: {
                                    HStack {
                                        Text("Apagar Pasta")
                                        Image(systemName: "trash")
                                    }
                                })
                            }
                        }
                    }
                }
            } else {
                NoFoldersView()
                    .padding(.vertical, noFoldersScrollHeight)
            }
        }
        .onAppear {
            viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            
            if AppPersistentMemory.getHasJoinedFolderResearch() {
                displayJoinFolderResearchBanner = false
            } else if let hasDismissed = AppPersistentMemory.getHasDismissedJoinFolderResearchBanner() {
                if hasDismissed {
                    displayJoinFolderResearchBanner = false
                } else {
                    if AppPersistentMemory.getHasSentFolderResearchInfo() {
                        displayJoinFolderResearchBanner = false
                    } else {
                        displayJoinFolderResearchBanner = true
                    }
                }
                displayJoinFolderResearchBanner = hasDismissed == false
            } else {
                displayJoinFolderResearchBanner = true
            }
            
            viewModel.donateActivity()
        }
        .onChange(of: updateFolderList) { shouldUpdate in
            refreshFolderList(shouldUpdate)
        }
        .onChange(of: deleteFolderAidiPhone.updateFolderList) { shouldUpdate in
            refreshFolderList(shouldUpdate)
        }
    }
    
    private func refreshFolderList(_ shouldUpdate: Bool) {
        if shouldUpdate {
            viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            updateFolderList = false
        }
    }

}

struct FolderList_Previews: PreviewProvider {

    static var previews: some View {
        FolderList(updateFolderList: .constant(false),
                   deleteFolderAid: .constant(DeleteFolderViewAide()),
                   folderIdForEditing: .constant(.empty))
    }

}
