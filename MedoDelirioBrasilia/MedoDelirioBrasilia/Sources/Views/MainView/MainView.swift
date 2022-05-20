import SwiftUI

struct MainView: View {

    @StateObject var viewModel = MainViewViewModel(sounds: soundData)
    @State var showingHelpAboutScreen = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: HelpAboutView(), isActive: $showingHelpAboutScreen) { EmptyView() }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.sounds) { sound in
                            SoundRow(title: sound.title, author: sound.authorName ?? "")
                                .onTapGesture {
                                    viewModel.playSound(fromPath: sound.filename)
                                }
                                .onLongPressGesture {
                                    viewModel.shareSound(withPath: sound.filename)
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(Text(LocalizableStrings.MainView.title))
            .navigationBarItems(leading:
                HStack {
                    Button(action: {
                        showingHelpAboutScreen = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                
                    Menu {
                        Section {
                            Picker(selection: $viewModel.sortOption, label: Text("Ordenação")) {
                                Text("Ordernar por Título")
                                    .tag(0)
                                
                                Text("Ordernar por Autor")
                                    .tag(1)
                                
                                Text("Adicionados por último no topo")
                                    .tag(2)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            )
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
