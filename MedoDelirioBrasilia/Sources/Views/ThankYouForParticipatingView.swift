//
//  ThankYouForParticipatingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/09/23.
//

import SwiftUI

struct ThankYouForParticipatingView: View {
    var body: some View {
        VStack(spacing: 50) {
            Text("❤️")
                .font(.system(size: 120))

            Text("Obrigado!")
                .font(.title)
                .bold()

            Text("O período Beta da versão 7.0 acabou. Você já pode conferir a nova funcionalidade de sincronização de conteúdos na versão normal do app.\n\nMuito obrigado pela sua participação! Ela foi fundamental para o sucesso do projeto.")
                .multilineTextAlignment(.center)

            Button("Ver app normal na loja") {
                OpenUtility.open(link: "https://apps.apple.com/br/app/medo-e-del%C3%ADrio/id1625199878")
            }
            .largeRoundedRectangleBordered(colored: .blue)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ThankYouForParticipatingView()
}
