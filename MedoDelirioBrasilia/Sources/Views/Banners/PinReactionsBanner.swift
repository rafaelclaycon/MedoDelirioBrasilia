//
//  PinReactionsBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/24.
//

import SwiftUI

struct PinReactionsBanner: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Fixar no Topo")
                    .foregroundColor(.blue)
                    .bold()
                    .multilineTextAlignment(.leading)

                Spacer()
            }

            Text("Segure as suas Reações preferidas e escolha Fixar no Topo para facilitar o acesso.")
                .foregroundColor(.blue)
                .opacity(0.8)
                .font(.callout)
        }
        .padding(.all, 20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.blue)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory.shared.setHasSeenPinReactionsBanner(to: true)
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
    PinReactionsBanner(isBeingShown: .constant(true))
}
