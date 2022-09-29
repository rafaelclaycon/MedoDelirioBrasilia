import SwiftUI

struct AllFoldersView: View {

    @Binding var isShowingFolderInfoEditingSheet: Bool
    @Binding var updateFolderList: Bool
    @State var deleteFolderAid = DeleteFolderViewAid()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(updateFolderList: $updateFolderList, deleteFolderAid: $deleteFolderAid)
            }
            .padding(.horizontal)
            .padding(.top, 7)
            .padding(.bottom, 18)
        }
        .navigationTitle("Pastas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingFolderInfoEditingSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Nova Pasta")
                    }
                }
            }
        }
        .alert(isPresented: $deleteFolderAid.showAlert) {
            Alert(title: Text(deleteFolderAid.alertTitle), message: Text(deleteFolderAid.alertMessage), primaryButton: .destructive(Text("Apagar"), action: {
                guard deleteFolderAid.folderIdForDeletion.isEmpty == false else {
                    return
                }
                try? database.deleteUserFolder(withId: deleteFolderAid.folderIdForDeletion)
                //viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            }), secondaryButton: .cancel(Text("Cancelar")))
        }
    }

}

struct AllFoldersView_Previews: PreviewProvider {

    static var previews: some View {
        AllFoldersView(isShowingFolderInfoEditingSheet: .constant(false), updateFolderList: .constant(false))
    }

}
