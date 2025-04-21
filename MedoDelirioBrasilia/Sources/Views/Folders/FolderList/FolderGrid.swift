//
//  FolderGrid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/09/22.
//

import SwiftUI

/// Subview loaded inside the Sounds tab on iPhone and the All Folders tab on iPad and Mac.
struct FolderGrid: View {

    // MARK: - External Dependencies

    @Binding var updateFolderList: Bool
    @Binding var folderForEditing: UserFolder?
    let contentRepository: ContentRepositoryProtocol

    // MARK: - State Properties

    @State private var viewModel = FolderGridViewModel(
        userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
        userSettings: UserSettings(),
        appMemory: AppPersistentMemory()
    )

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
            if !viewModel.folders.isEmpty {
                if viewModel.displayJoinFolderResearchBanner {
                    JoinFolderResearchBannerView(
                        viewModel: JoinFolderResearchBannerView.ViewModel(state: .displayingRequestToJoin),
                        displayMe: $viewModel.displayJoinFolderResearchBanner
                    )
                    .padding(.bottom)
                }
                
                LazyVGrid(columns: columns, spacing: .spacing(.small)) {
                    ForEach(viewModel.folders, id: \.changeHash) { folder in
                        NavigationLink {
                            FolderDetailView(
                                viewModel: FolderDetailViewModel(
                                    folder: folder,
                                    contentRepository: contentRepository
                                ),
                                folder: folder,
                                currentContentListMode: $currentContentListMode,
                                toast: $toast,
                                floatingOptions: $floatingOptions,
                                contentRepository: contentRepository
                            )
                        } label: {
                            FolderView(folder: folder)
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
            viewModel.onViewAppeared()
        }
        .onChange(of: updateFolderList) {
            if updateFolderList {
                viewModel.onReloadRequested()
                updateFolderList = false
            }
        }
        .onChange(of: deleteFolderAide.updateFolderList) {
            if deleteFolderAide.updateFolderList {
                viewModel.onReloadRequested()
                deleteFolderAide.updateFolderList = false
            }
        }
        //.alert
    }
}

// MARK: - Preview

#Preview {
    FolderGrid(
        updateFolderList: .constant(false),
        folderForEditing: .constant(nil),
        contentRepository: FakeContentRepository()
    )
}
