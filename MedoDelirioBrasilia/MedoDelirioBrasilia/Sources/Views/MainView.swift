import SwiftUI

struct MainView: View {

    @StateObject var viewModel = MainViewViewModel(sounds: soundData)
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.sounds) { sound in
                    SoundRow(title: sound.title, author: sound.author)
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
