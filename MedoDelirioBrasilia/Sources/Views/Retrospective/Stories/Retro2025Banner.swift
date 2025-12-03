//
//  Retro2025Banner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/10/24.
//

import SwiftUI

struct Retro2025Banner: View {

    @Binding var isBeingShown: Bool
    let openStoriesAction: () -> Void
    let showCloseButton: Bool

    var body: some View {
        VStack(alignment: .center, spacing: .spacing(.large)) {
            Text("Retrospectiva 2025")
                .font(.title2)
                .foregroundColor(.white)
                .bold()

            Text("Bora ver o que nós aprontamos juntos esse ano?")
                .font(.callout)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Button {
                openStoriesAction()
            } label: {
                Text("Bora!")
                    .font(.callout)
                    .foregroundStyle(.black)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                    }
            }
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing(.xxxLarge))
        .padding(.horizontal, 24)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.darkestGreen, .green, .yellow]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay(alignment: .topTrailing) {
            if showCloseButton {
                Button {
                    AppPersistentMemory().dismissedRetro2024Banner(true)
                    isBeingShown = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Retro2025Banner(
        isBeingShown: .constant(true),
        openStoriesAction: {},
        showCloseButton: true
    )
    .padding()
}
