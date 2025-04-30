//
//  Early2025PleaseDonateBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/25.
//

import SwiftUI

struct Early2025PleaseDonateBanner: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.small)) {
            HStack {
                Text("Sim, Esse É um Pedido de Pix")
                    .foregroundColor(.red)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .opacity(0.9)

                Spacer()
            }

            Text("Para poder publicar o app, todo ano a Apple cobra 99 dólares dos desenvolvedores. A renovação acontece agora em maio, então se o app te trouxe alguma alegria, por favor, considere um apoio.")
                .foregroundColor(.red)
                .opacity(0.8)
                .font(.callout)
        }
        .padding(.all, 20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.red)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory().setHasSeenPinReactionsBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

#Preview {
    Early2025PleaseDonateBanner(isBeingShown: .constant(true))
        .padding()
}
