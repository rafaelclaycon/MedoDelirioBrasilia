//
//  MostSharedByMeView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import SwiftUI

struct MostSharedByMeView: View {

    @State private var viewModel = MostSharedByMeViewViewModel()

    @State private var showRetrospectiveStories: Bool = false
    @State private var showRetroBanner: Bool = true
    @State private var userHasStats: Bool = false

    let columns = [
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: .spacing(.large)) {
            HStack {
                Text("Sons Mais Compartilhados")
                    .font(.title2)
                Spacer()
            }
            .padding(.horizontal)

            switch viewModel.viewState {
            case .loading:
                LoadingView()

            case .loaded(let items):
                if items.isEmpty {
                    NoDataView()
                } else {
                    VStack {
                        if showRetroBanner && userHasStats {
                            Retro2025Banner(
                                style: .small,
                                openStoriesAction: {
                                    showRetrospectiveStories = true
                                },
                               dismissAction: {
                                   AppPersistentMemory().dismissedRetro2025BannerInTrends(true)
                                   showRetroBanner = false
                               }
                            )
                            .padding(.horizontal, .spacing(.medium))
                            .padding(.bottom, .spacing(.small))
                        }

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
                await viewModel.onViewAppeared()
            }

            showRetroBanner = !AppPersistentMemory().hasDismissedRetro2025BannerInTrends()
            userHasStats = LocalDatabase.shared.totalShareCount() > 0
        }
    }
}

extension MostSharedByMeView {

    struct LoadingView: View {

        var body: some View {
            HStack {
                Spacer()

                ProgressView()
                    .padding(.vertical, .spacing(.xxxLarge))

                Spacer()
            }
        }
    }

    struct NoDataView: View {

        var body: some View {
            VStack(spacing: .spacing(.large)) {
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
        }
    }
}

// MARK: - Preview

#Preview {
    MostSharedByMeView()
}
