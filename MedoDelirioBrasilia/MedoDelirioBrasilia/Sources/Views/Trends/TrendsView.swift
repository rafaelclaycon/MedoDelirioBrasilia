import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewViewModel()
    @State var showAlert = false
    @State var alertTitle = ""
    
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
                        
                        if viewModel.personalTop5 == nil {
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
                                    viewModel.reloadPersonalList(withTopChartItems: Podium.getTop5SoundsSharedByTheUser())
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
                                ForEach(viewModel.personalTop5!) { item in
                                    TopChartCellView(item: item)
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        /*HStack {
                            Spacer()
                            
                            Button("Testar Servidor") {
                                networkRabbit.getHelloFromServer { response in
                                    alertTitle = response
                                    showAlert = true
                                }
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text(alertTitle), dismissButton: .default(Text("OK")))
                            }
                            .tint(.accentColor)
                            .controlSize(.large)
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .padding()
                            
                            Spacer()
                        }*/
                        
                        Text("Sons Mais Compartilhados Pela Audiência (iOS)")
                            .font(.title2)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                viewModel.reloadAudienceList()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Atualizar")
                                }
                            }
                            .padding(.trailing)
                            .padding(.top, 1)
                        }
                        
                        if viewModel.audienceTop5 == nil {
                            HStack {
                                Spacer()
                                
                                Text("Sem Dados")
                                    .font(.headline)
                                    .padding(.vertical, 40)
                                
                                Spacer()
                            }
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.audienceTop5!) { item in
                                    TopChartCellView(item: item)
                                }
                            }
                            .padding(.bottom)
                        }
                        
//                        HStack {
//                            Spacer()
//
//                            Text("Em Breve")
//                                .font(.headline)
//                                .padding(.vertical, 40)
//
//                            Spacer()
//                        }
                        
                        Text("Apps Pelos Quais Você Mais Compartilha")
                            .font(.title2)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Tendências (Beta)")
            .onAppear {
                viewModel.reloadPersonalList(withTopChartItems: Podium.getTop5SoundsSharedByTheUser())
                viewModel.donateActivity()
            }
        }
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView()
    }

}
