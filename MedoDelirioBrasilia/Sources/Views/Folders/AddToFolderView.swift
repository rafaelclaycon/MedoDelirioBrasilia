//
//  AddToFolderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct AddToFolderView: View {

    @StateObject private var viewModel = AddToFolderViewViewModel()
    @Binding var isBeingShown: Bool
    @Binding var hadSuccess: Bool
    @Binding var folderName: String?
    @State var selectedSoundName: String
    @State var selectedSoundId: String
    @State private var isShowingCreateNewFolderScreen: Bool = false
    
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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding(.leading, 7)
                    
                    Text("Som:  \(selectedSoundName)")
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
                            isShowingCreateNewFolderScreen = true
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
                                    guard viewModel.soundIsNotYetOnFolder(folderId: folder.id, contentId: selectedSoundId) else {
                                        return viewModel.showSoundAlredyInFolderAlert(folderName: folder.name)
                                    }
                                    try? database.insert(contentId: selectedSoundId, intoUserFolder: folder.id)
                                    folderName = "\(folder.symbol) \(folder.name)"
                                    hadSuccess = true
                                    isBeingShown = false
                                } label: {
                                    FolderCell(symbol: folder.symbol, name: folder.name, backgroundColor: folder.backgroundColor.toColor())
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
                viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $isShowingCreateNewFolderScreen) {
                FolderInfoEditingView(isBeingShown: $isShowingCreateNewFolderScreen, selectedBackgroundColor: Shared.Folders.defaultFolderColor)
            }
            .onChange(of: isShowingCreateNewFolderScreen) { isShowingCreateNewFolderScreen in
                if isShowingCreateNewFolderScreen == false {
                    viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                }
            }
        }
    }

}

struct AddToFolderView_Previews: PreviewProvider {

    static var previews: some View {
        AddToFolderView(isBeingShown: .constant(true), hadSuccess: .constant(false), folderName: .constant(nil), selectedSoundName: "Aham, sei", selectedSoundId: "ABCD")
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
    }

}
