import SwiftUI

struct TrendsView: View {

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text("Em Breve")
                    
                    Button("Get share logs") {
                        guard let logs = try? database.getAllShareLogs() else {
                            return
                        }
                        print(logs.count)
                        print(logs[0])
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
