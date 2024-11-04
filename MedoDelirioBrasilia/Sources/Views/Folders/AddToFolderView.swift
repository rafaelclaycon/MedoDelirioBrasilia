//
//  AddToFolderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct AddToFolderView: View {

    @StateObject private var viewModel: ViewModel

    @Binding var folderName: String?

    @State public var selectedSounds: [Sound]
    @State private var newFolder: UserFolder?

    @State private var soundsThatCanBeAdded: [Sound]? = nil
    @State private var folderForSomeSoundsAlreadyInFolder: UserFolder? = nil

    private var createNewFolderCellWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (UIScreen.main.bounds.size.width / 2) - 20
        } else {
            return 250
        }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let dismissSheet: () -> Void

    // MARK: - Initializer

    init(
        selectedSounds: [Sound],
        repository: UserFolderRepositoryProtocol,
        onSuccessAction: (String, WordPluralization) -> Void,
        dismissSheet: () -> Void
    ) {
        self._viewModel = ViewModel(
            repository: repository,
            selectedSounds: selectedSounds
        )
        self.dismissSheet = dismissSheet
    }

    // MARK: - View Body

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                HeaderView(
                    soundText: viewModel.soundText
                )

//                FoldersAreTagsBannerView()
//                    .padding(.horizontal)
//                    .padding(.bottom, -10)

                ScrollView {
                    HStack {
                        Button {
                            newFolder = UserFolder.newFolder()
                        } label: {
                            CreateFolderCell()
                        }
                        .foregroundColor(.primary)
                        .frame(width: createNewFolderCellWidth)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)

                    HStack {
                        Text("Minhas Pastas")
                            .font(.title2)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.folders.count == 0 {
                        Text("Nenhuma Pasta")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.vertical, 200)
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.folders) { folder in
                                Button {
                                    viewModel.onFolderSelected()
                                } label: {
                                    FolderCell(
                                        symbol: folder.symbol,
                                        name: folder.name,
                                        backgroundColor: folder.backgroundColor.toPastelColor()
                                    )
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Adicionar a Pasta")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancelar") {
                    dismissSheet()
                }
            )
            .onAppear {
                viewModel.onViewLoaded()
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .twoOptions:
                    return Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage),
                        primaryButton: .default(Text("Adicionar"), action: { viewModel.onAddRemainingSelected() }),
                        secondaryButton: .cancel(Text("Cancelar"))
                    )

                default:
                    return Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(item: $newFolder) { folder in
                FolderInfoEditingView(
                    folder: folder,
                    folderRepository: UserFolderRepository(),
                    dismissSheet: {
                        newFolder = nil
                        viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
                    }
                )
            }
        }
    }
}

// MARK: - Subviews

extension AddToFolderView {

    struct HeaderView: View {

        let soundText: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: "speaker.wave.3.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .padding(.leading, 7)

                Text(soundText)
                    .bold()
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 2)
        }
    }
}

// MARK: - Preview

#Preview {
    AddToFolderView(
        selectedSounds: [Sound(title: "ABCD", description: "")],
        repository: UserFolderRepository(),
        onSuccessAction: { _,_ in },
        dismissSheet: {}
    )
}
