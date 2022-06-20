import SwiftUI

struct CollectionsView: View {

    @State var collections = ["Clássicos", "LGBT", "Sérios", "Casimiro", "Memes", "Melancia", "Quarteto", "Sabor", "Teto", "Fazenda", "Inflamar"]
    @State var showingModalView = false
    
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
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Escolhas dos Editores")
                        .font(.title2)
                        //.padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 14) {
                            ForEach(collections, id: \.self) { collection in
                                CollectionCell(title: collection)
                            }
                        }
                        .frame(height: 210)
                    }
                }
                .padding(.leading)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Minhas Pastas")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button(action: {
                            showingModalView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Nova Pasta")
                            }
                        }
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(collections, id: \.self) { collection in
                                FolderCell(title: collection)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
            .navigationTitle("Coleções")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}
