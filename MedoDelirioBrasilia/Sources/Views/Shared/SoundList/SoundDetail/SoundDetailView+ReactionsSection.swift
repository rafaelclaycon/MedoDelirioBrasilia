//
//  SoundDetailView+ReactionsSection.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/11/24.
//

import SwiftUI

extension SoundDetailView {

    struct ReactionsSection: View {

        let state: LoadingState<[Reaction]>
        let openReactionAction: (Reaction) -> Void
        let suggestAction: () -> Void
        let reloadAction: () -> Void

        private var showSuggestOnTop: Bool {
            guard case .loaded(let reactions) = state else { return false }
            return reactions.count > 0
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Reações Em Que Aparece")
                        .font(.title3)
                        .bold()
                        .lineLimit(1)

                    Spacer()

                    if showSuggestOnTop {
                        Button {
                            suggestAction()
                        } label: {
                            Text("Sugerir")
                                .padding(.horizontal, .spacing(.xxxSmall))
                        }
                        .capsule(colored: .green)
                    }
                }
                .padding(.horizontal, .spacing(.medium))

                switch state {
                case .loading:
                    Reactions.LoadingView()
                        .padding(.horizontal, .spacing(.small))

                case .loaded(let reactions):
                    if reactions.count == 0 {
                        Reactions.NoDataView(suggestAction: suggestAction)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(reactions) { reaction in
                                    ReactionItem(reaction: reaction)
                                        .frame(width: UIDevice.isiPhone ? 180 : 200)
                                        .onTapGesture {
                                            openReactionAction(reaction)
                                        }
                                }
                            }
                            .padding(.horizontal, .spacing(.medium))
                        }
                    }

                case .error(_):
                    Reactions.LoadingErrorView(
                        retryAction: reloadAction
                    )
                    .padding(.horizontal, .spacing(.small))
                }
            }
        }
    }

    struct Reactions {

        struct LoadingView: View {

            var body: some View {
                HStack(spacing: 15) {
                    ProgressView()

                    Text("Carregando Reações...")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            }
        }

        struct NoDataView: View {

            let suggestAction: () -> Void

            var body: some View {
                VStack(spacing: .spacing(.xLarge)) {
                    Text("Esse som não aparece em nenhuma Reação.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)

                    Button {
                        suggestAction()
                    } label: {
                        Text("Sugerir Adição")
                            .padding(.spacing(.xxxSmall))
                    }
                    .capsule(colored: .green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing(.xSmall))
                .padding(.horizontal, .spacing(.xxLarge))
            }
        }

        struct LoadingErrorView: View {

            let retryAction: () -> Void

            var body: some View {
                VStack(spacing: 24) {
                    Text("Não foi possível carregar essa seção.")
                        .multilineTextAlignment(.center)

                    Button {
                        retryAction()
                    } label: {
                        Label("TENTAR NOVAMENTE", systemImage: "arrow.clockwise")
                            .font(.footnote)
                    }
                    .borderedButton(colored: .blue)
                }
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview

#Preview("Loading View") {
    SoundDetailView.ReactionsSection(
        state: .loading,
        openReactionAction: { _ in },
        suggestAction: {},
        reloadAction: {}
    )
}

#Preview("No Data View") {
    SoundDetailView.ReactionsSection(
        state: .loaded([]),
        openReactionAction: { _ in },
        suggestAction: {},
        reloadAction: {}
    )
}

#Preview("Loading Error") {
    SoundDetailView.ReactionsSection(
        state: .error(""),
        openReactionAction: { _ in },
        suggestAction: {},
        reloadAction: {}
    )
}

#Preview("Loaded View") {
    SoundDetailView.ReactionsSection(
        state: .loaded(Reaction.allMocks),
        openReactionAction: { _ in },
        suggestAction: {},
        reloadAction: {}
    )
}
