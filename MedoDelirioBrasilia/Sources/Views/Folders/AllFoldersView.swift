import SwiftUI

struct AllFoldersView: View {

    @Binding var isShowingFolderInfoEditingSheet: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList()
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
    }

}

struct AllFoldersView_Previews: PreviewProvider {

    static var previews: some View {
        AllFoldersView(isShowingFolderInfoEditingSheet: .constant(false))
    }

}
