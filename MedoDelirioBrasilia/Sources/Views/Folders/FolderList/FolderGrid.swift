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

    @State var viewModel: FolderGridViewModel
    @Binding var updateFolderList: Bool
    @Binding var folderForEditing: UserFolder?
    let contentRepository: ContentRepositoryProtocol
    let containerSize: CGSize

    // MARK: - State Properties

    @State private var currentContentListMode: ContentGridMode = .regular
    @State private var toast: Toast?
    @State private var floatingOptions: FloatingContentOptions?
    @State private var columns: [GridItem] = []

    private let phoneItemSpacing: CGFloat = .spacing(.medium)
    private let padItemSpacing: CGFloat = .spacing(.xLarge)

    // MARK: - Environment

    @Environment(DeleteFolderViewAide.self) private var deleteFolderAide
    @Environment(\.sizeCategory) private var sizeCategory

    // MARK: - Computed Properties

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
            switch viewModel.state {
            case .loading:
                VStack {
                    HStack(spacing: .spacing(.small)) {
                        ProgressView()

                        Text("Carregando Pastas...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .spacing(.huge))
                }

            case .loaded(let folders):
                if !folders.isEmpty {
                    if viewModel.displayJoinFolderResearchBanner {
                        JoinFolderResearchBannerView(
                            viewModel: JoinFolderResearchBannerView.ViewModel(state: .displayingRequestToJoin),
                            displayMe: $viewModel.displayJoinFolderResearchBanner
                        )
                        .padding(.bottom)
                    }

                    LazyVGrid(columns: columns, spacing: .spacing(.small)) {
                        ForEach(folders, id: \.changeHash) { folder in
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
                                Section {
                                    Button {
                                        folderForEditing = folder
                                    } label: {
                                        Label("Editar Pasta", systemImage: "pencil")
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

            case .error(let errorMessage):
                VStack {
                    Text("Erro ao carregar as Pastas. Informe o desenvolvedor.\n\nDetalhes: \(errorMessage)")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
            updateGridLayout()
        }
        .onChange(of: updateFolderList) {
            if updateFolderList {
                Task {
                    await viewModel.onReloadRequested()
                    updateFolderList = false
                }
            }
        }
        .onChange(of: deleteFolderAide.updateFolderList) {
            if deleteFolderAide.updateFolderList {
                Task {
                    await viewModel.onReloadRequested()
                    deleteFolderAide.updateFolderList = false
                }
            }
        }
        .onChange(of: containerSize.width) {
            updateGridLayout()
        }
    }

    // MARK: - Functions

    private func updateGridLayout() {
        columns = GridHelper.adaptableColumns(
            listWidth: containerSize.width,
            sizeCategory: sizeCategory,
            spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing
        )
    }
}

// MARK: - Preview

#Preview {
    let fakeDB = FakeLocalDatabase()

    fakeDB.folders = [
        UserFolder(
            symbol: "🤡",
            name: "Uso diario",
            backgroundColor: "pastelPurple",
            contentCount: 3
        ),
        UserFolder(
            symbol: "😅",
            name: "Meh",
            backgroundColor: "pastelPurple",
            contentCount: 3
        ),
        UserFolder(
            symbol: "🏙️",
            name: "Política",
            backgroundColor: "pastelPurple",
            contentCount: 0
        ),
        UserFolder(
            symbol: "🙅🏿‍♂️",
            name: "Anti-Racista",
            backgroundColor: "pastelRoyalBlue",
            contentCount: 3
        ),
        UserFolder(
            symbol: "✋",
            name: "Espera!",
            backgroundColor: "pastelPurple",
            contentCount: 3
        ),
        UserFolder(
            symbol: "🔥",
            name: "Queima!",
            backgroundColor: "pastelPurple",
            contentCount: 3
        )
    ]

    return GeometryReader { geometry in
        ScrollView {
            FolderGrid(
                viewModel: FolderGridViewModel(
                    userFolderRepository: UserFolderRepository(database: fakeDB),
                    userSettings: UserSettings(),
                    appMemory: AppPersistentMemory()
                ),
                updateFolderList: .constant(false),
                folderForEditing: .constant(nil),
                contentRepository: FakeContentRepository(),
                containerSize: geometry.size
            )
            .environment(DeleteFolderViewAide())
            .padding(.horizontal, .spacing(.medium))
        }
    }
}
