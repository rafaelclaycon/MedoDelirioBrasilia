//
//  ReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct ReactionsView: View {

    @StateObject private var viewModel = ViewModel(reactionRepository: ReactionRepository())

    // iPad Grid Layout
    @State private var columns: [GridItem] = []
    @Environment(\.sizeCategory) var sizeCategory

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                LoadingView(
                    width: geometry.size.width,
                    height: geometry.size.height
                )

            case .loaded(let reactionGroup):
                if reactionGroup.regular.isEmpty {
                    EmptyView(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                } else {
                    LoadedView(
                        pinnedReactions: reactionGroup.pinned,
                        otherReactions: reactionGroup.regular,
                        columns: columns,
                        pullToRefreshAction: {
                            Task {
                                await viewModel.onPullToRefresh()
                            }
                        },
                        pinAction: { viewModel.onPinReactionSelected(reaction: $0) },
                        unpinAction: { reaction in
                            Task {
                                await viewModel.onUnpinReactionSelected(reaction: reaction)
                            }
                        }
                    )
                    .onAppear {
                        columns = GridHelper.adaptableColumns(
                            listWidth: geometry.size.width,
                            sizeCategory: sizeCategory,
                            spacing: UIDevice.isiPhone ? 12 : 20
                        )

                        Analytics().send(
                            originatingScreen: "ReactionsView",
                            action: "didViewReactionsTab"
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

            case .error(let errorString):
                ErrorView(
                    error: errorString,
                    tryAgainAction: {
                        Task {
                            await viewModel.onTryAgainSelected()
                        }
                    },
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .toolbar {
            if case .loaded = viewModel.state {
                ToolbarControls(
                    showHowReactionsWorkAction: { viewModel.showHowReactionsWorkSheet.toggle() },
                    showAddStuffSheetAction: { viewModel.showAddStuffSheet.toggle() }
                )
            }
        }
        .sheet(isPresented: $viewModel.showHowReactionsWorkSheet) {
            HowReactionsWorkView()
        }
        .sheet(isPresented: $viewModel.showAddStuffSheet) {
            AddReactionView()
        }
        .oneTimeTask {
            await viewModel.onViewLoaded()
        }
        .alert(
            "Não Foi Possível Fixar a Reação Selecionada",
            isPresented: $viewModel.showIssueSavingPinAlert,
            actions: { Button("OK", role: .cancel, action: {}) },
            message: { Text("Tente novamente mais tarde.") }
        )
        .alert(
            "Não Foi Possível Desafixar a Reação Selecionada",
            isPresented: $viewModel.showIssueRemovingPinAlert,
            actions: { Button("OK", role: .cancel, action: {}) },
            message: { Text("Tente novamente mais tarde.") }
        )
    }
}

// MARK: - Subviews

extension ReactionsView {

    struct ToolbarControls: View {

        let showHowReactionsWorkAction: () -> Void
        let showAddStuffSheetAction: () -> Void

        var body: some View {
            HStack(spacing: 15) {
                Button {
                    showHowReactionsWorkAction()
                } label: {
                    Image(systemName: "questionmark")
                }

                Button {
                    showAddStuffSheetAction()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    struct LoadingView: View {

        let width: CGFloat
        let height: CGFloat

        var body: some View {
            VStack(spacing: 50) {
                ProgressView()
                    .scaleEffect(2.0)

                Text("Carregando Reações...")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.gray)
            }
            .frame(width: width)
            .frame(minHeight: height)
        }
    }

    struct EmptyView: View {

        let width: CGFloat
        let height: CGFloat

        var body: some View {
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
            .frame(width: width)
            .frame(minHeight: height)
            .navigationTitle("Reações")
        }
    }

    struct ErrorView: View {

        let error: String
        let tryAgainAction: () -> Void
        let width: CGFloat
        let height: CGFloat

        var body: some View {
            VStack(spacing: 30) {
                Text("☹️")
                    .font(.system(size: 86))

                Text("Erro ao Carregar as Reações")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)

                Button {
                    tryAgainAction()
                } label: {
                    Label("Tentar Novamente", systemImage: "arrow.clockwise")
                }
            }
            .padding(.horizontal, 20)
            .frame(width: width)
            .frame(minHeight: height)
        }
    }
}

// MARK: - Preview

#Preview {
    ReactionsView()
}
