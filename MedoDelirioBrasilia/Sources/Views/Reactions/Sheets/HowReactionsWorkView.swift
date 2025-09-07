//
//  HowReactionsWorkView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/11/24.
//

import SwiftUI

struct HowReactionsWorkView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 30) {
                    VStack(spacing: 0) {
                        Text("Sobre as ")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)

                        Text("Reações")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.clear)
                            .overlay(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text("Reações")
                                        .font(.largeTitle)
                                        .bold()
                                )
                            )
                    }
                    .multilineTextAlignment(.center)

                    Text("A aba Reações é um jeito diferente de descubrir as vírgulas sonoras.\n\nEm 3 anos, chegamos a mais de 1.400 vírgulas, mas muitas acabam escondidas. Para facilitar a descoberta, criamos as Reações: escolha uma categoria e responda rápido com o som perfeito.\n\nUm “Tadinha! Que barra!” ou “Mas isso é… É enganar!” na hora certa muda tudo.")
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HowReactionsWorkView()
}
