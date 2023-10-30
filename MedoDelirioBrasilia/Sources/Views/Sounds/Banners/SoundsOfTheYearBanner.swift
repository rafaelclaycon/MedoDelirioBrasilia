//
//  SoundsOfTheYearBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/10/23.
//

import SwiftUI

struct SoundsOfTheYearBanner: View {

    @Binding var isBeingShown: Bool
    let buttonAction: () -> Void

    @State private var soundCount: Int = 0

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "airpodsmax")
                .resizable()
                .scaledToFit()
                .frame(width: 36)
                .foregroundColor(colorScheme == .dark ? .green : .darkerGreen)

            VStack(alignment: .leading, spacing: 8) {
                Text("Retrospectiva 2023")
                    .foregroundColor(colorScheme == .dark ? .green : .darkerGreen)
                    .bold()

                Text("O ano está acabando e nós compartilhamos \(soundCount) sons juntos para dar conta da loucura que é o Brasil. Exiba os sons que te ajudaram a aturar 2023 nas suas redes.")
                    .foregroundColor(colorScheme == .dark ? .green : .darkerGreen)
                    .font(.callout)

                Button {
                    buttonAction()
                } label: {
                    Text("Ver minha retrospectiva")
                }
                .tint(colorScheme == .dark ? .green : .darkerGreen)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .padding(.top, 5)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.green)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                //AppPersistentMemory.setHasSeenRecurringDonationBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.green)
            }
            .padding()
        }
        .onAppear {
            soundCount = LocalDatabase.shared.sharedSoundsCount()
        }
    }
}

#Preview {
    SoundsOfTheYearBanner(
        isBeingShown: .constant(true),
        buttonAction: { }
    )
    .padding()
}
