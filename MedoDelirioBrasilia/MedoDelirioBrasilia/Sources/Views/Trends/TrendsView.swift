import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewViewModel()
    
    let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Sons Mais Compartilhados Por Mim")
                            .font(.title2)
                            .padding(.horizontal)
                        
                        if viewModel.topChartItems == nil {
                            HStack {
                                Spacer()
                                
                                Text("Sem Dados")
                                    .font(.headline)
                                    .padding(.vertical, 40)
                                
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                
                                Button {
                                    viewModel.reloadList(withTopChartItems: Logger.getTop5Sounds())
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Atualizar")
                                    }
                                }
                                .padding(.trailing)
                                .padding(.top, 1)
                            }
                            
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.topChartItems!) { item in
                                    TopChartCellView(item: item)
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        Text("Sons Mais Compartilhados Pela Audiência (iOS)")
                            .font(.title2)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            
                            Text("Em Breve")
                                .font(.headline)
                                .padding(.vertical, 40)
                            
                            Spacer()
                        }

//                        Text("Apps Pelos Quais Você Mais Compartilha")
//                            .font(.title2)
//                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Tendências")
            .onAppear {
                viewModel.reloadList(withTopChartItems: Logger.getTop5Sounds())
            }
        }
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView()
    }

}
