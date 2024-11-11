//
//  AddToFolderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct AddToFolderView: View {

    @StateObject private var viewModel = AddToFolderViewModel(database: LocalDatabase.shared)

    @Binding var isBeingShown: Bool
    @Binding var hadSuccess: Bool
    @Binding var folderName: String?
    @Binding var pluralization: WordPluralization

    @State var selectedSounds: [Sound]
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
    
    private func getSoundText() -> String {
        if selectedSounds.count == 1 {
            return "Som:  \(selectedSounds.first!.title)"
        } else {
            return "\(selectedSounds.count) sons selecionados"
        }
    }

    // MARK: - View Body

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding(.leading, 7)
                    
                    Text(getSoundText())
                        .bold()
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 2)
                
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
                                    do {
                                        soundsThatCanBeAdded = viewModel.canBeAddedToFolder(sounds: selectedSounds, folderId: folder.id)

                                        let soundsAlreadyInFolder = selectedSounds.count - (soundsThatCanBeAdded?.count ?? 0)

                                        if selectedSounds.count == soundsThatCanBeAdded?.count {
                                            try selectedSounds.forEach { sound in
                                                try LocalDatabase.shared.insert(contentId: sound.id, intoUserFolder: folder.id)
                                            }
                                            try UserFolderRepository().update(folder)

                                            folderName = "\(folder.symbol) \(folder.name)"
                                            pluralization = selectedSounds.count > 1 ? .plural : .singular
                                            hadSuccess = true
                                            isBeingShown = false
                                        } else if soundsAlreadyInFolder == 1, selectedSounds.count == 1 {
                                            viewModel.showSingleSoundAlredyInFolderAlert(folderName: folder.name)
                                        } else if soundsAlreadyInFolder == selectedSounds.count {
                                            viewModel.showAllSoundsAlredyInFolderAlert(folderName: folder.name)
                                        } else {
                                            folderForSomeSoundsAlreadyInFolder = folder
                                            viewModel.showSomeSoundsAlreadyInFolderAlert(soundCountAlreadyInFolder: soundsAlreadyInFolder, folderName: folder.name)
                                        }
                                    } catch {
                                        viewModel.showIssueSavingAlert(error.localizedDescription)
                                    }
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
                    self.isBeingShown = false
                }
            )
            .onAppear {
                viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .twoOptions:
                    return Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage),
                        primaryButton: .default(Text("Adicionar"), action: {
                            do {
                                try soundsThatCanBeAdded?.forEach { sound in
                                    try LocalDatabase.shared.insert(contentId: sound.id, intoUserFolder: folderForSomeSoundsAlreadyInFolder?.id ?? .empty)
                                }

                                if let folder = folderForSomeSoundsAlreadyInFolder {
                                    try UserFolderRepository().update(folder)
                                    folderName = "\(folder.symbol) \(folder.name)"
                                }
                                pluralization = soundsThatCanBeAdded?.count ?? 0 > 1 ? .plural : .singular
                                hadSuccess = true
                                isBeingShown = false
                            } catch {
                                viewModel.showIssueSavingAlert(error.localizedDescription)
                            }
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

// MARK: - Preview

#Preview {
    AddToFolderView(
        isBeingShown: .constant(true),
        hadSuccess: .constant(false),
        folderName: .constant(nil),
        pluralization: .constant(.singular),
        selectedSounds: [Sound(title: "ABCD", description: "")]
    )
}
