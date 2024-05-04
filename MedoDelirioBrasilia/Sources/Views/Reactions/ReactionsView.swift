//
//  ReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct ReactionsView: View {

    @StateObject private var viewModel = ReactionsViewViewModel()

    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                VStack(spacing: 50) {
                    ProgressView()
                        .scaleEffect(2.0)

                    Text("Carregando Reações...")
                        .foregroundColor(.gray)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)

            case .loaded(let reactions):
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(reactions) { reaction in
                            NavigationLink {
                                ReactionDetailView(
                                    viewModel: .init(reaction: reaction)
                                )
                            } label: {
                                ReactionCell(reaction: reaction)
                            }
                        }
                    }
                    .padding()
                    .navigationTitle("Reações")
                }

            case .error(let errorString):
                VStack {
                    Text("Erro ao carregar as Reações. :(\n\n\(errorString)")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .oneTimeTask {
            await viewModel.loadList()
            //viewModel.state = .loaded(Reaction.allMocks)
        }
    }
}

#Preview {
    ReactionsView()
}
