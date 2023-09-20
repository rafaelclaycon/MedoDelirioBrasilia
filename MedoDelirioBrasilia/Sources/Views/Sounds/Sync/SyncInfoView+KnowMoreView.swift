//
//  SyncInfoView+KnowMoreView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/08/23.
//

import SwiftUI

extension SyncInfoView {
    struct KnowMoreView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("O que é?")
                        .font(.title2)
                        .bold()

                    Text("A partir de agora novos sons aparecerão automaticamente na lista quando o seu \(UIDevice.deviceGenericName) estiver conectado à Internet. Você não terá mais que atualizar o app na App Store para receber novos sons.")

                    Text("O que torna esse sistema único?")
                        .font(.title2)
                        .bold()

                    HStack {
                        Spacer()

                        Image(decorative: "swiftLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        Spacer()
                    }
                    .padding(.vertical, 6)

                    Text("O sistema de sincronização de dados do Medo e Delírio iOS, do servidor ao app até o sistema de subir arquivos para o servidor, foi desenvolvido por mim usando **Swift**.\n\nIsso é inovador por Swift ser majoritariamente uma linguagem de *front-end*. O desafio de fazer isso acontecer é o Projeto Final do meu curso tecnólogo de Análise e Desenvolvimento de Sistemas.\n\nObrigado a todos que participaram da fase Beta e responderam ao questionário. A participação de vocês foi crítica para o sucesso do projeto! ❤️")

                    Button("O que é Swift?") {
                        OpenUtility.open(link: "https://tinyurl.com/yujyu5a3")
                    }
                    .largeRoundedRectangleBordered(colored: Color(hex: "#de5d43"))
                }
                .padding(.vertical)
                .padding(.horizontal, 30)
            }
            .navigationTitle("Sobre o sistema de sincronização")
        }
    }
}

struct KnowMoreView_Previews: PreviewProvider {
    static var previews: some View {
        SyncInfoView.KnowMoreView()
    }
}
