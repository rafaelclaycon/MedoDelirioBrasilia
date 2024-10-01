//
//  IntroducingReactionsView 2.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/09/24.
//

import SwiftUI

struct IntroducingPlayRandomSoundControlView: View {

    @Environment(\.dismiss) var dismiss

    struct Step: Identifiable {
        let number: String
        let instruction: String
        var id: String {
            self.number
        }
    }

    private let steps: [Step] = [
        .init(number: "1", instruction: "Abra a Central de Controle (\(UIDevice.hasNotch ? "deslize do topo direito para baixo" : "puxe da borda de baixo da tela para cima"))."),
        .init(number: "2", instruction: "Toque no + no canto superior esquerdo."),
        .init(number: "3", instruction: "Toque em Adicionar um Controle na parte de baixo da tela."),
        .init(number: "4", instruction: "Procure por \"Medo\" na barra de pesquisa e selecione o controle Tocar Som."),
        .init(number: "5", instruction: "Ajuste o tamanho e posição do controle do jeito que desejar.")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 40) {
                    Image("controlWhatsNew")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .center, spacing: 40) {
                        Text("Uma Surpresa a Um Toque de Distância")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("Já atualizou para o iOS 18? Siga os passos abaixo para inserir o controle Tocar Som Aleatório à sua Central de Controle e divirta-se com um som aleatório a cada toque.")
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(steps) { step in
                                HStack(spacing: 15) {
                                    NumberBadgeView(number: step.number, showBackgroundCircle: true)

                                    Text(step.instruction)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }

                        Text("Você também pode adicionar esse controle à sua Tela de Bloqueio.")
                            .multilineTextAlignment(.center)

                        Spacer()
                            .frame(height: 15)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 50)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center) {
                    Button {
                        AppPersistentMemory.hasSeenControlWhatsNewScreen(true)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Entendi")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .borderedProminentButton(colored: .green)

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.systemBackground)
            }
        }
    }
}
