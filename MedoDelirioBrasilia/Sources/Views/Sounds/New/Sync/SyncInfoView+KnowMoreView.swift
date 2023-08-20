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

                    Text("A partir de agora novos sons aparecerão automaticamente na lista quando o teu \(UIDevice.deviceGenericName) estiver conectado à Internet. Você não terá mais que atualizar o app na App Store para receber novos sons.")

                    Text("O que torna esse sistema único?")
                        .font(.title2)
                        .bold()

                    Text("O sistema de sincronização de dados do Medo e Delírio iOS, do servidor ao app até o sistema de subir arquivos para o servidor, foi desenvolvido por mim usando **Swift**.\n\nAlém de loucura da minha cabeça, tornei esse desafio o Projeto Final do meu curso tecnólogo de Análise e Desenvolvimento de Sistemas.\n\nPor favor, colabore participando da pesquisa que ocorrerá durante o Beta. A tua participação é crítica para eu ganhar nota 😄. A forma de participar é respondendo questionários que serão enviados para o teu e-mail durante o período de testes que irá **de agosto a novembro de 2023**.")

                    Button("O que é Swift?") {
                        OpenUtility.open(link: "https://tinyurl.com/yujyu5a3")
                    }
                    .largeRoundedRectangleBordered(colored: Color(hex: "#de5d43"))

                    Button("Fuxique o meu LinkedIn") {
                        OpenUtility.open(link: "https://www.linkedin.com/in/rafaelschmitt/")
                    }
                    .largeRoundedRectangleBordered(colored: .blue)
                }
                .padding()
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
