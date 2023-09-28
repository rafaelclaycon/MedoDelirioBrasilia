//
//  MainView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ToastView: View {

    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        Label {
            Text(text)
                .foregroundColor(.black)
                .font(.callout)
                .bold()
        } icon: {
            Image(systemName: icon)
                .font(Font.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)
        }
        .labelStyle(.centerAligned)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.white)
                .shadow(color: .gray, radius: 2, y: 2)
        }
        .dynamicTypeSize(.xSmall ... .accessibility1)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Todos os dados atualizados."
            )

            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Conteúdo baixado com sucesso. Tente tocá-lo novamente."
            )

            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Sincronização concluída com sucesso."
            )

            ToastView(
                icon: "clock.fill",
                iconColor: .orange,
                text: "Aguarde mais um pouco para atualizar novamente."
            )

            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Som adicionado à pasta 🤑 Econoboys."
            )
            .padding(.horizontal)
        }
        .previewLayout(.fixed(width: 414, height: 100))
    }
}
