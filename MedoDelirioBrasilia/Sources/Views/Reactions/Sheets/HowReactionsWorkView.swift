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
                        Text("Apresentando as ")
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

                    Text("Descubra os sons de um jeito novo.\n\nEm 2 anos, fomos de 0 a mais de 1.200 sons. Essa quantidade trouxe, porém, problemas de descoberta. Os sons mais compartilhados são os adicionados a menos tempo ou os que mais grudaram na cabeça da galera, mas tem muita vírgula boa escondida! Pensando nisso, chegaram as Reações.\n\nEscolha a categoria que melhor define como você quer responder ou começar uma conversa. Em seguida, use um dos sons para responder a uma mensagem ou post rapidamente.\n\nAquele “Tadinha! Que barra!” ou “Mas isso é… É enganar!” que colocados na hora certa fazem toda a diferença.")
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
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
