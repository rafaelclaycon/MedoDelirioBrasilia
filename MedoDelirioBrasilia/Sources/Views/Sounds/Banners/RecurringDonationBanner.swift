//
//  RecurringDonationBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/08/23.
//

import SwiftUI

struct RecurringDonationBanner: View {
    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "dollarsign.arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 36)
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                Text("Chegamos ao Apoia.se!")
                    .foregroundColor(.red)
                    .bold()

                Text("O app Medo e Delírio iOS acaba de entrar para o Apoia.se. Curte o meu trabalho aqui? Considere doar de forma recorrente por lá.")
                    .foregroundColor(.red)
                    .opacity(0.8)
                    .font(.callout)

                Button {
                    OpenUtility.open(link: "https://apoia.se/app-medo-delirio-ios")
                } label: {
                    Text("Ver campanha")
                }
                .tint(.red)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.red)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory.setHasSeenRecurringDonationBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
            .padding()
        }
    }
}

struct RecurringDonationBanner_Previews: PreviewProvider {
    static var previews: some View {
        RecurringDonationBanner(isBeingShown: .constant(true))
            .padding()
    }
}
