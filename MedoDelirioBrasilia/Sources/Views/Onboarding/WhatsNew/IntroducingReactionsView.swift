//
//  IntroducingReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/05/24.
//

import SwiftUI

struct IntroducingReactionsView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 40) {
                    HeaderView()

                    VStack(alignment: .center, spacing: 30) {
                        VStack(spacing: 0) {
                            Text("Apresentando as ")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.primary)

                            Text("Reações")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.clear)
                                .overlay(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("Reações")
                                            .font(.largeTitle)
                                            .bold()
                                    )
                                )
                        }
                        .multilineTextAlignment(.center)

                        Text("Descubra os sons de um jeito novo.\n\nNa aba Reações, escolha a categoria que melhor define como você quer responder ou começar uma conversa. Em seguida, use um dos sons para responder a uma mensagem ou post rapidamente.\n\nAquele “Tadinha! Que barra!” ou “Mas isso é… É enganar!” que colocados na hora certa fazem toda a diferença.\n\nPara começar, toque na aba Reações na parte inferior da tela.")
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 50)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center) {
                    Button {
                        AppPersistentMemory().hasSeenReactionsWhatsNewScreen(true)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Que bom...")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .borderedProminentButton(colored: .green)

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.systemBackground)
            }
        }
    }
}

extension IntroducingReactionsView {

    struct HeaderView: View {

        @State private var state: LoadingState<[Reaction]> = .loading

        var body: some View {
            switch state {
            case .loading:
                VStack {
                    HStack(spacing: 12) {
                        ProgressView()

                        Text("CARREGANDO...")
                            .font(.footnote)
                            .bold()
                            .foregroundStyle(.gray)
                    }
                }
                .frame(height: 100)
                .onAppear {
                    Task {
                        await loadPreviews()
                    }
                }

            case .loaded(let reactions):
                HStack {
                    ForEach(reactions) { mock in
                        ReactionItem(reaction: mock)
                            .frame(width: 180)
                    }
                }
                .marquee(
                    spacing: 25,
                    delay: 0
                )

            case .error(_):
                VStack {
                    Text("Não foi possível carregar a pré-visualização das Reações.")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .frame(height: 100)
            }
        }

        private func loadPreviews() async {
            state = .loading

            do {
                let previews = try await ReactionRepository().allReactions()
                state = .loaded(previews)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    IntroducingReactionsView()
}
