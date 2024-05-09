//
//  DonateToFloodVictimsBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/05/24.
//

import SwiftUI

struct DonateToFloodVictimsBanner: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            VStack {
                Image(systemName: "house")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36)
                    .foregroundColor(.red)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Ajude vítimas das enchentes no RS")
                    .foregroundColor(.red)
                    .bold()

                Text("Muitas instituições e pessoas estão pedindo Pix e eu sei que isso satura, então serei direto: estou organizando doações para pessoas que tiveram a casa invadida pela água e perderam seus pertences, móveis, eletrodomésticos. **Todas as doações feitas para o e-mail do app em maio serão revertidas para pessoas nessas condições.**\n\nO destino das doações será o mais transparente possível, divulgado no fio linkado abaixo.")
                    .foregroundColor(.red)
                    .opacity(0.8)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 15) {
                    Button {
                        OpenUtility.open(link: "https://apoia.se/app-medo-delirio-ios")
                    } label: {
                        Text("Copiar chave Pix")
                    }
                    .tint(.red)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)

                    Button {
                        OpenUtility.open(link: "https://apoia.se/app-medo-delirio-ios")
                    } label: {
                        Text("Ver fio transparência")
                    }
                    .tint(.red)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.red)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
    }
}

#Preview {
    DonateToFloodVictimsBanner(isBeingShown: .constant(true))
}
