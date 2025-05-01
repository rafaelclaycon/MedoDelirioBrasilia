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
        VStack(spacing: 20) {
            HStack {
                Text("Sons Mais Compartilhados")
                    .font(.title2)
                Spacer()
            }
            .padding(.horizontal)

            switch viewModel.viewState {
            case .loading:
                HStack {
                    Spacer()

                    ProgressView()
                        .padding(.vertical, 40)

                    Spacer()
                }

            case .loaded(let items):
                if items.isEmpty {
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
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(items) { item in
                                TopChartRow(item: item)
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                    .padding(.bottom, 20)
                }
            case .error(let errorMessage):
                Text(errorMessage)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadPersonalList()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MostSharedByMeView()
}
