import SwiftUI

struct MainView: View {

    var body: some View {
        ScrollView {
            VStack {
                Image("Banner")
                    .resizable()
                    .frame(width: 350, height: 197)
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
