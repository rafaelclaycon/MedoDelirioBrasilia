//
//  FolderList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/09/22.
//

import SwiftUI

/// Subview loaded inside the Sounds tab on iPhone and the All Folders tab on iPad and Mac.
struct FolderList: View {

    // MARK: - External Dependencies

    @Binding var updateFolderList: Bool
    @Binding var folderForEditing: UserFolder?

    // MARK: - State Properties

    @StateObject private var viewModel = FolderListViewModel()
    @State private var displayJoinFolderResearchBanner: Bool = false
    @State private var currentContentListMode: ContentListMode = .regular
    @State private var toast: Toast?
    @State private var floatingOptions: FloatingContentOptions?

    // MARK: - Environment

    @EnvironmentObject var deleteFolderAide: DeleteFolderViewAide

    // MARK: - Computed Properties

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

    // MARK: - View Body

    var body: some View {
        VStack {
            if viewModel.hasFoldersToDisplay {
                if displayJoinFolderResearchBanner {
                    JoinFolderResearchBannerView(
                        viewModel: JoinFolderResearchBannerView.ViewModel(state: .displayingRequestToJoin),
                        displayMe: $displayJoinFolderResearchBanner
                    )
                    .padding(.bottom)
                }
                
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.folders, id: \.changeHash) { folder in
                        NavigationLink {
                            FolderDetailView(
                                folder: folder,
                                currentContentListMode: $currentContentListMode,
                                toast: $toast,
                                floatingOptions: $floatingOptions
                            )
                        } label: {
                            FolderCell(
                                symbol: folder.symbol,
                                name: folder.name,
                                backgroundColor: folder.backgroundColor.toPastelColor()
                            )
                            .padding(.horizontal, UIDevice.isiPhone ? 0 : 5)
                        }
                        .foregroundColor(.primary)
                        .contextMenu {
                            if UIDevice.isiPhone {
                                Section {
                                    Button {
                                        folderForEditing = folder
                                    } label: {
                                        Label("Editar Pasta", systemImage: "pencil")
                                    }
                                }
                            }

                            Section {
                                Button(role: .destructive, action: {
                                    let folderName = "\(folder.symbol) \(folder.name)"
                                    deleteFolderAide.alertTitle = "Apagar \"\(folderName)\""
                                    deleteFolderAide.alertMessage = "Tem certeza de que deseja apagar a pasta \"\(folderName)\"? Os conteúdos não serão apagados."
                                    deleteFolderAide.folderIdForDeletion = folder.id
                                    deleteFolderAide.showAlert = true
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
            viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
            
            if UserSettings().getHasJoinedFolderResearch() {
                displayJoinFolderResearchBanner = false
            } else if let hasDismissed = AppPersistentMemory().getHasDismissedJoinFolderResearchBanner() {
                if hasDismissed {
                    displayJoinFolderResearchBanner = false
                } else {
                    if AppPersistentMemory().getHasSentFolderResearchInfo() {
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
        .onChange(of: updateFolderList) {
            refreshFolderList(updateFolderList)
        }
        .onChange(of: deleteFolderAide.updateFolderList) {
            refreshFolderList(deleteFolderAide.updateFolderList)
        }
    }

    // MARK: - Functions

    private func refreshFolderList(_ shouldUpdate: Bool) {
        if shouldUpdate {
            viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
            updateFolderList = false
            deleteFolderAide.updateFolderList = false
        }
    }
}

// MARK: - Preview

#Preview {
    FolderList(
        updateFolderList: .constant(false),
        folderForEditing: .constant(nil)
    )
}
