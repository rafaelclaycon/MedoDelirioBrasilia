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
            
            if viewModel.personalTop10 == nil {
                HStack {
                    Spacer()

                    ProgressView()
                        .padding(.vertical, 40)

                    Spacer()
                }
            } else if viewModel.personalTop10?.count == 0 {
                VStack(spacing: 20) {
                    Spacer()

                    Text("☹️")
                        .font(.system(size: 64))

                    Text("Nenhum Dado")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Compartilhe sons na aba Sons para ver o seu ranking pessoal.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()
                }
            } else {
                VStack {
                    LazyVGrid(columns: columns, spacing: .zero) {
                        ForEach(viewModel.personalTop10!) { item in
                            TopChartRow(item: item)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            viewModel.reloadPersonalList()
        }
    }
}

struct MostSharedByMeView_Previews: PreviewProvider {

    static var previews: some View {
        MostSharedByMeView()
    }
}
