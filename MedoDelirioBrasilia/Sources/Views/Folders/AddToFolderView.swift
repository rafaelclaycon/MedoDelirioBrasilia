import SwiftUI

struct AddToFolderView: View {

    @StateObject private var viewModel = AddToFolderViewViewModel()
    @Binding var isBeingShown: Bool
    @State var selectedSoundName: String
    @State var selectedSoundId: String
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 20) {
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .padding(.leading)
                    
                    Text(selectedSoundName)
                        .bold()
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal)
                
                ScrollView {
                    HStack {
                        Button {
                            print("Add")
                        } label: {
                            FolderCell(symbol: "📂", title: "Nova Pasta...", backgroundColor: .gray, backgroundOpacity: 0.15, height: 100)
                        }
                        .foregroundColor(.primary)
                        .frame(width: (UIScreen.main.bounds.size.width / 2) - 20)
                        
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
                    
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.folders) { folder in
                            Button {
                                try? database.insert(contentId: selectedSoundId, intoUserFolder: folder.id)
                                isBeingShown = false
                            } label: {
                                FolderCell(symbol: folder.symbol, title: folder.title, backgroundColor: folder.backgroundColor.toColor())
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Adicionar a Pasta")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isBeingShown = false
                }) {
                    Text("Cancelar")
                }
            )
            .onAppear {
                viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            }
        }
    }

}

struct AddToFolderView_Previews: PreviewProvider {

    static var previews: some View {
        AddToFolderView(isBeingShown: .constant(true), selectedSoundName: "Aham, sei", selectedSoundId: "ABCD")
    }

}
