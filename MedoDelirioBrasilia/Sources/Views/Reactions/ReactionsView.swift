//
//  ReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct ReactionsView: View {

    @StateObject private var viewModel = ReactionsViewViewModel()

    // iPad Grid Layout
    //@State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = []
    @Environment(\.sizeCategory) var sizeCategory

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
                    LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? 12 : 20) {
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
                    .onAppear {
                        print("THIAGO ON APPEAR: \(geometry.size.width)")
                        columns = GridHelper.adaptableColumns(
                            listWidth: geometry.size.width,
                            sizeCategory: sizeCategory,
                            spacing: UIDevice.isiPhone ? 12 : 20
                        )
                    }
                    .onChange(of: geometry.size.width) { newWidth in
                        //self.listWidth = newWidth
                        print("THIAGO ON CHANGE: \(geometry.size.width)")
                        columns = GridHelper.adaptableColumns(
                            listWidth: newWidth,
                            sizeCategory: sizeCategory,
                            spacing: UIDevice.isiPhone ? 12 : 20
                        )
                    }
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
        .toolbar {
            Button {
                viewModel.isShowingSheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $viewModel.isShowingSheet) {
            AddReactionView(isBeingShown: $viewModel.isShowingSheet)
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
