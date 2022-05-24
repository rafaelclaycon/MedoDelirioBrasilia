import SwiftUI

struct SoundsView: View {

    @StateObject private var viewModel = SoundsViewViewModel()
    @State private var showingHelpScreen = false
    @State private var searchText = ""
    @State private var searchBar: UISearchBar?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var searchResults: [Sound] {
        if searchText.isEmpty {
            return viewModel.sounds
        } else {
            return viewModel.sounds.filter { sound in
                let searchString = "\(sound.description.lowercased().withoutDiacritics()) \(sound.authorName?.lowercased().withoutDiacritics() ?? "")"
                return searchString.contains(searchText.lowercased().withoutDiacritics())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: HelpView(), isActive: $showingHelpScreen) { EmptyView() }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(searchResults) { sound in
                            SoundCell(title: sound.title, author: sound.authorName ?? "")
                                .onTapGesture {
                                    viewModel.playSound(fromPath: sound.filename)
                                }
                                .onLongPressGesture {
                                    viewModel.shareSound(withPath: sound.filename)
                                }
                        }
                    }
                    .searchable(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    if searchText.isEmpty {
                        Text("\(viewModel.sounds.count) sons. Atualizado em \(soundsLastUpdateDate).")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .padding(.bottom, 18)
                    }
                }
            }
            .navigationTitle(Text(LocalizableStrings.MainView.title))
            .navigationBarItems(leading:
                Button(action: {
                    showingHelpScreen = true
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                    }
                }
//            , trailing:
//                Menu {
//                    Section {
//                        Picker(selection: $viewModel.sortOption, label: Text("Ordenação")) {
//                            Text("Ordernar por Título")
//                                .tag(0)
//
//                            Text("Ordernar por Autor")
//                                .tag(1)
//
//                            Text("Adicionados por Último no Topo")
//                                .tag(2)
//                        }
//                    }
//                } label: {
//                    Image(systemName: "arrow.up.arrow.down.circle")
//                }
            )
            .onAppear {
                viewModel.reloadList()
            }
        }
    }

}

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView()
    }

}
