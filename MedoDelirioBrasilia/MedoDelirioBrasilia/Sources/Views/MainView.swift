import SwiftUI

struct MainView: View {

    @StateObject var viewModel = MainViewViewModel(sounds: soundData)
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.sounds) { sound in
                            SoundRow(title: sound.title, author: sound.author)
                                .onTapGesture {
                                    viewModel.playSound(fromPath: sound.filename)
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Medo e Delírio")
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
