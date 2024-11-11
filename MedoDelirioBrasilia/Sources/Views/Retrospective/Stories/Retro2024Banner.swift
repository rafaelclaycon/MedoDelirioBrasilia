//
//  Retro2024Banner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/10/24.
//

import SwiftUI

struct Retro2024Banner: View {

    let openStoriesAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Retrospectiva 2024")
                .foregroundColor(.white)
                .bold()

            Text("Bora ver o que nós aprontamos juntos esse ano?")
                //.foregroundColor(colorScheme == .dark ? .green : .darkerGreen)
                .font(.callout)

            Button {
                openStoriesAction()
            } label: {
                Text("Ver minha retrospectiva")
                    .foregroundStyle(.white)
            }
            //.tint(colorScheme == .dark ? .green : .darkerGreen)
            .controlSize(.regular)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            if #available(iOS 18, *) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        MeshGradient(
                            width: 3,
                            height: 3,
                            points: [
                                .init(0, 0), .init(0.5, 0), .init(1, 0),
                                .init(0, 0.5), .init(0.2, 0.7), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ],
                            colors: [
                                .pink, .yellow, .blue,
                                .pink, .yellow, .blue,
                                .pink, .yellow, .blue
                            ]
                        )
                    )

            } else {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.green)
            }
        }
//        .overlay(alignment: .topTrailing) {
//            if showCloseButton {
//                Button {
//                    AppPersistentMemory.setHasSeenRetroBanner(to: true)
//                    isBeingShown = false
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.green)
//                }
//                .padding()
//            }
//        }
    }
}

#Preview {
    Retro2024Banner(openStoriesAction: {})
}
