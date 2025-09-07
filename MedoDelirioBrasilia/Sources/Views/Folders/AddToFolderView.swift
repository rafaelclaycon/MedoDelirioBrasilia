//
//  AddToFolderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct AddToFolderView: View {

    @State private var viewModel = AddToFolderViewModel(
        userFolderRepository: UserFolderRepository(database: LocalDatabase.shared)
    )

    @Binding var isBeingShown: Bool
    @Binding var details: AddToFolderDetails

    @State var selectedContent: [AnyEquatableMedoContent]
    @State private var newFolder: UserFolder?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    // MARK: - Computed Properties

    private var createNewFolderCellWidth: CGFloat {
        if UIDevice.isiPhone {
            return (UIScreen.main.bounds.size.width / 2) - 20
        } else {
            return 250
        }
    }

    private var selectedItemsText: String {
        if selectedContent.count == 1 {
            return "Som:  \(selectedContent.first!.title)"
        } else {
            return "\(selectedContent.count) itens selecionados"
        }
    }

    // MARK: - View Body

    var body: some View {
        NavigationView {
            if #available(iOS 26.0, *) {
                addView
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                isBeingShown.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }

                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                newFolder = UserFolder.newFolder()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
            } else {
                addView
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CloseButton {
                                isBeingShown.toggle()
                            }
                        }

                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                newFolder = UserFolder.newFolder()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Subviews

    var addView: some View {
        VStack(alignment: .center, spacing: .spacing(.large)) {
            ScrollView {
                VStack {
                    if viewModel.folders.count == 0 {
                        Text("Nenhuma Pasta")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.vertical, 200)
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.folders) { folder in
                                Button {
                                    guard let result = viewModel.onExistingFolderSelected(
                                        folder: folder,
                                        selectedContent: selectedContent
                                    ) else { return }
                                    details = result
                                    isBeingShown.toggle()
                                } label: {
                                    FolderView(folder: folder)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Adicionar a uma Pasta")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            switch viewModel.alertType {
            case .addOnlyNonOverlapping:
                return Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage),
                    primaryButton: .default(Text("Adicionar"), action: {
                        guard let result = viewModel.onAddOnlyNonExistingSelected() else { return }
                        details = result
                        isBeingShown.toggle()
                    }),
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
                folderRepository: UserFolderRepository(database: LocalDatabase.shared),
                dismissSheet: {
                    newFolder = nil
                    Task {
                        await viewModel.onNewFolderCreationSheetDismissed()
                    }
                }
            )
        }
    }
}

// MARK: - Preview

#Preview {
    AddToFolderView(
        isBeingShown: .constant(true),
        details: .constant(AddToFolderDetails()),
        selectedContent: [
            AnyEquatableMedoContent(Sound(title: "ABCD", description: ""))
        ]
    )
}
