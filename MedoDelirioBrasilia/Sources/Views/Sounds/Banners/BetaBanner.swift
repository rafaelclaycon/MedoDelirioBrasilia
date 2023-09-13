//
//  BetaBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import SwiftUI

struct BetaBanner: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "app.gift.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 8) {
                Text("Vem coisa boa por aí!")
                    .foregroundColor(.blue)
                    .bold()

                Text("Tá no ar o Beta da funcionalidade de *download* dos conteúdos. Isso mesmo, adeus atualizar pela loja para ter os últimos sons. Bora ajudar a testar?")
                    .foregroundColor(.blue)
                    .opacity(0.8)
                    .font(.callout)

                Button {
                    OpenUtility.open(link: testFlightLink)
                } label: {
                    Text("Baixar a versão Beta")
                }
                .tint(.blue)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.blue)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory.setHasSeenBetaBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

struct BetaBanner_Previews: PreviewProvider {
    static var previews: some View {
        BetaBanner(isBeingShown: .constant(true))
            .padding()
    }
}
