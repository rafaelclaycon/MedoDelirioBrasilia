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
                NavigationLink(destination: SoundHelpView(), isActive: $showingHelpScreen) { EmptyView() }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(searchResults) { sound in
                            SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
                                .onTapGesture {
                                    viewModel.playSound(fromPath: sound.filename)
                                }
                                .onLongPressGesture {
                                    //viewModel.shareSound(withPath: sound.filename)
                                    viewModel.soundForConfirmationDialog = sound
                                    viewModel.showConfirmationDialog = true
                                }
                        }
                    }
                    .searchable(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    if UserSettings.getShowOffensiveSounds() == false {
                        Text("Filtrando conteúdo sensível. Você pode mudar isso na aba Ajustes.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 15)
                            .padding(.horizontal, 20)
                    }
                    
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
            , trailing:
                Menu {
                    Section {
                        Picker(selection: $viewModel.sortOption, label: Text("Ordenação")) {
                            Text("Ordenar por Título")
                                .tag(0)

                            Text("Ordenar por Autor")
                                .tag(1)

                            Text("Adicionados por Último no Topo")
                                .tag(2)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            )
            .onAppear {
                viewModel.reloadList()
            }
            .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
                Button(viewModel.getFavoriteButtonTitle()) {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    if viewModel.isSelectedSoundAlreadyAFavorite() {
                        viewModel.removeFromFavorites(soundId: sound.id)
                    } else {
                        viewModel.addToFavorites(soundId: sound.id)
                    }
                }
                
                Button("Compartilhar") {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    viewModel.shareSound(withPath: sound.filename)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

}

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView()
    }

}
