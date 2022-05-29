import SwiftUI

struct TrendsView: View {

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        Text("Sons Mais Compartilhados Por Mim")
                            .font(.title2)
                            .padding(.horizontal)
                        
                        Button("Get share logs") {
                            guard let logs = try? database.getAllShareLogs() else {
                                return
                            }
                            print(logs.count)
                            print(logs)
                        }
                        
                        Text("Sons Mais Compartilhados Pela Audiência (iOS)")
                            .font(.title2)
                            //.multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            
                            Text("Em Breve")
                                .font(.headline)
                                .padding(.vertical, 40)
                            
                            Spacer()
                        }
                        
                        Text("Apps Pelos Quais Você Mais Compartilha")
                            .font(.title2)
                            .padding(.horizontal)
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
