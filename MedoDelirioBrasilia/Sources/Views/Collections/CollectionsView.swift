import SwiftUI

struct CollectionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    @State var showingAddNewFolderView = false
    
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
                    VStack(alignment: .leading) {
                        Text("Escolhas dos Editores")
                            .font(.title2)
                            .padding(.leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: rows, spacing: 14) {
                                ForEach(viewModel.collections) { collection in
                                    NavigationLink {
                                        CollectionDetailView()
                                    } label: {
                                        CollectionCell(title: collection.title, imageURL: collection.imageURL)
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
                    viewModel.reloadCollectionList(withCollections: getLocalCollections())
                    viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                }
                .padding(.bottom)
            }
        }
    }
    
    private func getLocalCollections() -> [ContentCollection] {
        var array = [ContentCollection]()
        array.append(ContentCollection(title: "LGBT", imageURL: "http://blog.saude.mg.gov.br/wp-content/uploads/2021/06/28-06-lgbt.jpg"))
        array.append(ContentCollection(title: "Clássicos", imageURL: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg"))
        array.append(ContentCollection(title: "Sérios", imageURL: "https://images.trustinnews.pt/uploads/sites/5/2019/10/tres-tabus-que-o-homem-atual-ja-ultrapassou-2.jpeg"))
        array.append(ContentCollection(title: "Invasão Foro", imageURL: "https://i.scdn.co/image/0a32a3b9a4f798833f1c10aac18197f7b119e758"))
        array.append(ContentCollection(title: "Memes", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        return array
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}
