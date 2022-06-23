import SwiftUI

struct CollectionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    @State var collections = ["Clássicos", "LGBT", "Sérios", "Casimiro", "Memes", "Melancia", "Quarteto", "Sabor", "Teto", "Fazenda", "Inflamar"]
    @State var showingAddNewFolderView = false
    @State var showingCollectionDetailView = false
    
    @State var showingFolderDetailView = false
    
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    NavigationLink(destination: CollectionDetailView(), isActive: $showingCollectionDetailView) { EmptyView() }
                    
                    VStack(alignment: .leading) {
                        Text("Escolhas dos Editores")
                            .font(.title2)
                            .padding(.leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: rows, spacing: 14) {
                                ForEach(collections, id: \.self) { collection in
                                    CollectionCell(title: collection)
                                        .onTapGesture {
                                            showingCollectionDetailView = true
                                        }
                                }
                            }
                            .frame(height: 210)
                            .padding(.leading)
                            .padding(.trailing)
                        }
                    }
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Minhas Pastas")
                                .font(.title2)
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddNewFolderView = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Nova Pasta")
                                }
                            }
                            .onChange(of: showingAddNewFolderView) { newValue in
                                if newValue == false {
                                    viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                                }
                            }
                        }
                        
                        if viewModel.hasFoldersToDisplay {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.folders) { folder in
                                    NavigationLink {
                                        FolderDetailView(folder: folder)
                                    } label: {
                                        FolderCell(symbol: folder.symbol, title: folder.title, backgroundColor: folder.backgroundColor.toColor())
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        } else {
                            HStack {
                                Spacer()
                                
                                VStack(spacing: 10) {
                                    Text("Nenhuma Pasta Criada")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Toque em Nova Pasta acima para criar uma nova pasta de sons.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 40)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                }
                .navigationTitle("Coleções")
                .sheet(isPresented: $showingAddNewFolderView) {
                    AddNewFolderView(isBeingShown: $showingAddNewFolderView)
                }
                .onAppear {
                    viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                }
                .padding(.bottom)
            }
        }
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}
