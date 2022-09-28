import SwiftUI

struct MostSharedByMeView: View {

    @StateObject private var viewModel = MostSharedByMeViewViewModel()
    
    let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Sons Mais Compartilhados Por Mim")
                .font(.title2)
                .padding(.horizontal)
                .padding(.top, 10)
            
            if viewModel.personalTop5 == nil {
                HStack {
                    Spacer()
                    
                    Text("Sem Dados")
                        .font(.headline)
                        .padding(.vertical, 40)
                    
                    Spacer()
                }
            } else {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.reloadPersonalList(withTopChartItems: podium.getTop5SoundsSharedByTheUser())
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Atualizar")
                            }
                        }
                        .padding(.trailing)
                        .padding(.top, 1)
                        .padding(.bottom, 10)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.personalTop5!) { item in
                            TopChartCellView(item: item)
                        }
                    }
                    .padding(.bottom)
                    
                    Text("Última consulta: hoje às 12:05")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            }
        }
    }

}

struct MostSharedByMeView_Previews: PreviewProvider {

    static var previews: some View {
        MostSharedByMeView()
    }

}
