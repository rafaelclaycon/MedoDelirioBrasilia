import SwiftUI

struct CollectionsView: View {

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Escolhas dos Editores")
                            .font(.title2)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Minhas Pastas")
                            .font(.title2)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("Coleções")
        }
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}
