//
//  MyFoldersiPhoneView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/11/22.
//

import SwiftUI

struct MyFoldersiPhoneView: View {

    @State private var isShowingFolderInfoEditingSheet: Bool = false
    @State private var folderForEditingOnSheet: UserFolder? = nil
    @State var updateFolderList: Bool = false // Does nothing, just here to satisfy FolderList :)
    @State var deleteFolderAide = DeleteFolderViewAide() // Same as above
    @State var folderIdForEditing: String = .empty
    @State var currentSoundsListMode: SoundsListMode = .regular
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(updateFolderList: $updateFolderList,
                           deleteFolderAide: $deleteFolderAide,
                           folderIdForEditing: $folderIdForEditing)
            }
            .padding(.horizontal)
            .padding(.top, 7)
            .padding(.bottom, 18)
        }
        .navigationTitle("Minhas Pastas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingFolderInfoEditingSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                    }
                }
                .onChange(of: isShowingFolderInfoEditingSheet) { isShowing in
                    if isShowing == false {
                        updateFolderList = true
                        folderForEditingOnSheet = nil
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFolderInfoEditingSheet) {
            if let folder = folderForEditingOnSheet {
                FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
            } else {
                FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, selectedBackgroundColor: Shared.Folders.defaultFolderColor)
            }
        }
        .onChange(of: folderIdForEditing) { folderIdForEditing in
            if folderIdForEditing.isEmpty == false {
                folderForEditingOnSheet = try? LocalDatabase.shared.getFolder(withId: folderIdForEditing)
                guard folderForEditingOnSheet != nil else { return }
                isShowingFolderInfoEditingSheet = true
                self.folderIdForEditing = .empty
            }
        }
    }

}

struct MyFoldersiPhoneView_Previews: PreviewProvider {

    static var previews: some View {
        MyFoldersiPhoneView()
    }

}
