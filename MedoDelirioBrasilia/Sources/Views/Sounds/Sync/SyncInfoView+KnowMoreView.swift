//
//  SyncInfoView+KnowMoreView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/08/23.
//

import SwiftUI

extension SyncInfoView {

    struct KnowMoreView: View {

        private var tapOrClickText: String {
            UIDevice.isMac ? "Clique" : "Toque"
        }

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("O que é?")
                        .font(.title2)
                        .bold()

                    Text("Quando o app foi lançado em maio de 2022, os sons eram colocados dentro do pacote do app, tornando obrigatório que o app fosse atualizado para que novos conteúdos chegassem até vocês.\n\nA partir de setembro de 2023, com a introdução do sistema de sincronização na versão 7, novos sons aparecem automaticamente na lista quando o seu \(UIDevice.deviceGenericName) está conectado à Internet.\n\nChega de ter que atualizar o app na App Store para receber novos sons.")

                    Text("Tá mas e daí?")
                        .font(.title2)
                        .bold()

                    Text("E daí que isso deu uma trabalheira do cão kkkk Mas falando sério: O sistema de sincronização de dados do app, do servidor ao app até o sistema de subir arquivos para o servidor, foi desenvolvido por mim usando a linguagem **Swift**.")

                    HStack {
                        Spacer()

                        Image(decorative: "swiftLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        Spacer()
                    }
                    .padding(.bottom, 3)

                    Text("Verificar se isso era possível foi tema do meu Projeto Final do curso de Análise e Desenvolvimento de Sistemas e é inovador por Swift ser majoritariamente uma linguagem de *front-end* (usada para fazer telas).\n\nObrigado a todos que participaram da fase Beta e responderam ao questionário! A participação de vocês foi crítica para o sucesso do projeto. ❤️")

                    Button("Saber mais sobre Swift") {
                        OpenUtility.open(link: "https://tinyurl.com/yujyu5a3")
                    }
                    .largeRoundedRectangleBordered(colored: Color(hex: "#de5d43"))

                    Text("Todos os códigos relacionados ao app são abertos e estão disponíveis para estudo e colaboração. \(tapOrClickText) abaixo para vê-los no meu GitHub.")

                    Button("Abrir GitHub") {
                        OpenUtility.open(link: "https://github.com/rafaelclaycon")
                    }
                    .largeRoundedRectangleBordered(colored: .purple)
                }
                .padding(.vertical)
                .padding(.horizontal, 30)
            }
            .navigationTitle("Sobre o sistema de sincronização")
            .onAppear {
                Analytics().send(action: "didViewSyncSystemAboutScreen")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SyncInfoView.KnowMoreView()
}
