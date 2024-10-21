//
//  ReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct ReactionsView: View {

    @StateObject private var viewModel = ReactionsViewViewModel()

    @State private var currentSoundsListMode: SoundsListMode = .regular

    // iPad Grid Layout
    @State private var columns: [GridItem] = []
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.push) var push

    let colors: [Color] = [.red, .purple, .pink, .orange, .green, .brown, .blue, .cyan, .gray, .mint]

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                VStack(spacing: 50) {
                    ProgressView()
                        .scaleEffect(2.0)

                    Text("Carregando Reações...")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.gray)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)

            case .loaded(let reactions):
                if reactions.isEmpty {
                    VStack(spacing: 30) {
                        Text("😮")
                            .font(.system(size: 86))

                        Text("Nenhuma Reação")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("Parece que você chegou muito cedo. Volte daqui a pouco.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 20)
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                    .navigationTitle("Reações")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? 12 : 20) {
                            ForEach(reactions) { reaction in
                                ReactionItem(reaction: reaction)
                                    .onTapGesture {
                                        push(GeneralNavigationDestination.reactionDetail(reaction))
                                    }
                            }
                        }
                        .padding()
                        .navigationTitle("Reações")
                        .onAppear {
                            columns = GridHelper.adaptableColumns(
                                listWidth: geometry.size.width,
                                sizeCategory: sizeCategory,
                                spacing: UIDevice.isiPhone ? 12 : 20
                            )
                        }
                        .onChange(of: geometry.size.width) { newWidth in
                            columns = GridHelper.adaptableColumns(
                                listWidth: newWidth,
                                sizeCategory: sizeCategory,
                                spacing: UIDevice.isiPhone ? 12 : 20
                            )
                        }
                    }
                }

            case .error(let errorString):
                VStack(spacing: 30) {
                    Text("☹️")
                        .font(.system(size: 86))

                    Text("Erro ao Carregar as Reações")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(errorString)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)

                    Button {
                        Task {
                            await viewModel.loadList()
                        }
                    } label: {
                        Label("Tentar Novamente", systemImage: "arrow.clockwise")
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .toolbar {
            if case .loaded = viewModel.state {
                Button {
                    viewModel.isShowingSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingSheet) {
            AddReactionView(isBeingShown: $viewModel.isShowingSheet)
        }
        .oneTimeTask {
            await viewModel.loadList()
        }
    }
}

#Preview {
    ReactionsView()
}
