import SwiftUI

struct TrendsView: View {

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        Text("Sons Mais Compartilhados Por Mim")
                            .font(.title2)
                        
                        Button("Get share logs") {
                            guard let logs = try? database.getAllShareLogs() else {
                                return
                            }
                            print(logs.count)
                            print(logs[0])
                        }
                        
                        Text("Sons Mais Compartilhados Pela Audiência")
                            .font(.title2)
                        
                        Text("Apps Mais Usados Para Compartilhar")
                            .font(.title2)
                    }
                }
            }
            .navigationTitle("Tendências")
        }
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView()
    }

}
