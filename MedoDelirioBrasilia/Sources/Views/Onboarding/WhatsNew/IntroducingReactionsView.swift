//
//  IntroducingReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/05/24.
//

import SwiftUI

struct IntroducingReactionsView: View {

    @Binding var isBeingShown: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 40) {
                    HStack {
                        ForEach(Reaction.allMocks) { mock in
                            ReactionItem(reaction: mock)
                                .frame(width: 180)
                                //.shadow(radius: 20, y: -2)
                        }
                    }
                    .marquee(
                        spacing: 25,
                        delay: 0
                    )

                    VStack(alignment: .center, spacing: 40) {
                        Text("Apresentando as Reações")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("Descubra os sons do app de um jeito novo. Na aba Reações, escolha a categoria que melhor define como você quer responder ou começar uma conversa. Em seguida, use um dos sons para responder a uma mensagem ou post rapidamente.\n\nAquele “Tadinha! Que barra!” ou “Mas isso é… É enganar!” que, colocados na hora certa, fazem toda a diferença. Para começar, toque na aba Reações na parte inferior da tela.")
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 50)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center) {
                    Button {
                        AppPersistentMemory.hasSeenReactionsWhatsNewScreen(true)
                        isBeingShown.toggle()
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

#Preview {
    IntroducingReactionsView(isBeingShown: .constant(true))
}
