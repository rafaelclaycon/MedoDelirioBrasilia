import SwiftUI

struct CollectionsView: View {

    @State var collections = ["Clássicos", "LGBT", "Sérios", "Casimiro", "Memes", "Melancia", "Quarteto", "Sabor", "Teto", "Fazenda", "Inflamar"]
    @State var showingAddNewFolderView = false
    @State var showingCollectionDetailView = false
    
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
                        }
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 10) {
                                Text("Nenhuma Pasta Criada")
                                    //.font(.headline)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                
                                Text("Toque em Nova Pasta acima para criar uma nova pasta de sons.")
                                    //.font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                            
                            Spacer()
                        }
                        
//                        LazyVGrid(columns: columns, spacing: 14) {
//                            ForEach(collections, id: \.self) { collection in
//                                FolderCell(title: collection)
//                            }
//                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                }
                .navigationTitle("Coleções")
                .sheet(isPresented: $showingAddNewFolderView) {
                    AddNewFolderView(isBeingShown: $showingAddNewFolderView)
                }
            }
        }
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}
