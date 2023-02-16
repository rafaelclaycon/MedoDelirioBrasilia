//
//  MostSharedByMeView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import SwiftUI

struct MostSharedByMeView: View {

    @StateObject private var viewModel = MostSharedByMeViewViewModel()
    
    let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Sons Mais Compartilhados Por Mim 🙎")
                    .font(.title2)
                Spacer()
            }
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
                VStack {
//                    HStack {
//                        Spacer()
//                        
//                        Button {
//                            //viewModel.reloadPersonalList(withTopChartItems: <#T##[TopChartItem]?#>)
//                        } label: {
//                            HStack {
//                                Image(systemName: "arrow.triangle.2.circlepath")
//                                Text("Atualizar")
//                            }
//                        }
//                        .padding(.trailing)
//                        .padding(.top, 1)
//                        .padding(.bottom, 10)
//                    }
                    
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.personalTop5!) { item in
                            TopChartRow(item: item)
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
        .onAppear {
            viewModel.reloadPersonalList(withTopChartItems: podium.getTop5SoundsSharedByTheUser())
        }
    }

}

struct MostSharedByMeView_Previews: PreviewProvider {

    static var previews: some View {
        MostSharedByMeView()
    }

}
