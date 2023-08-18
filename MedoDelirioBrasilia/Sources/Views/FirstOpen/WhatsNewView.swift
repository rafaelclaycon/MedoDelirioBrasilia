//
//  WhatsNewView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/02/23.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var isBeingShown: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 40) {
                Text("☺️")
                    .font(.system(size: 110))
                    .background(alignment: .bottomTrailing) {
                        ZStack {
                            Image("app-store-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)

                            Text("💧")
                                .font(.system(size: 26))
                                .offset(x: 15, y: -10)
                        }
                        .offset(x: 25)
                        .opacity(0.5)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Text("🎁")
                            .font(.system(size: 60))
                            .offset(x: -35, y: 20)
                    }

                Text("Atualizar pra Receber Novos Sons É Coisa do Passado")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("A moda agora é tudo aparecer baixado.")
                    .multilineTextAlignment(.center)

                Text("Você faz parte do Beta! Muito obrigado! Toque em Dar Feedback na tela principal e me envie um e-mail para receber o questionário.")
                    .multilineTextAlignment(.center)

                Button {
                    AppPersistentMemory.setHasSeen70WhatsNewScreen(to: true)
                    dismiss()
                } label: {
                    Text("Bora!")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 15))
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
        }
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isBeingShown: .constant(true))
    }
}
