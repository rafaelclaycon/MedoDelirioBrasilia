//
//  IntroducingReactionsView 2.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/09/24.
//

import SwiftUI

struct IntroducingiOS18ControlAndSiriIntentView: View {

    @Environment(\.dismiss) var dismiss

    private var systemName: String {
        UIDevice.isiPad ? "iPadOS 18" : "iOS 18"
    }

    private var isiOS18: Bool {
        if #available(iOS 18, *) {
             return true
        } else {
            return false
        }
    }

    private var firstPart: String {
        if isiOS18 {
            return "Como você já atualizou para o \(systemName), pode aproveitar"
        } else {
            return "Atualize o seu \(UIDevice.isiPad ? "iPad" : "iPhone") para o \(systemName) e aproveite"
        }
    }

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
                        Text("Novidades do \(systemName)")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("\(firstPart) duas novidades: o Controle Tocar Som Aleatório e o Atalho da Siri para fazer o mesmo.")
                            .multilineTextAlignment(.center)

                        DisclosureGroup {
                            ControlInstructions(isiOS18: isiOS18, systemName: systemName)
                                .padding(.top)
                        } label: {
                            Label("Como adicionar o Controle", systemImage: "switch.2")
                                .foregroundStyle(.blue)
                        }

                        DisclosureGroup {
                            SiriInstructions(isiOS18: isiOS18, systemName: systemName)
                                .padding(.top)
                        } label: {
                            Label("Como usar a Siri para tocar um som aleatório", systemImage: "waveform")
                                .foregroundStyle(.blue)
                        }

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

extension IntroducingiOS18ControlAndSiriIntentView {

    struct ControlInstructions: View {

        let isiOS18: Bool
        let systemName: String

        struct Step: Identifiable {
            let number: String
            let instruction: String
            var id: String {
                self.number
            }
        }

        private var firstPart: String {
            if isiOS18 {
                return "Siga"
            } else {
                return "Depois de atualizar, siga"
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
            VStack(alignment: .center, spacing: 40) {
                Text("\(firstPart) esses passos para inserir o controle Tocar Som Aleatório à sua Central de Controle e divirta-se com um som aleatório a cada toque.")

                VStack(alignment: .leading, spacing: 25) {
                    ForEach(steps) { step in
                        HStack(spacing: 15) {
                            NumberBadgeView(number: step.number, showBackgroundCircle: true)

                            Text(step.instruction)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }

                if UIDevice.hasNotch {
                    Text("Você também pode adicionar esse controle à sua Tela de Bloqueio.")
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    struct SiriInstructions: View {

        let isiOS18: Bool
        let systemName: String

        private let phrase: [String] = [
            "toque uma vírgula do Medo e Delírio",
            "toque um som do Medo e Delírio",
            "toque um som aleatório do Medo e Delírio"
        ]

        private var firstPart: String {
            if isiOS18 {
                return "Agora você também pode pedir para a Siri tocar um som aleatório do Medo e Delírio sem usar as mãos."
            } else {
                return "No \(systemName) você também poderá pedir para a Siri tocar um som aleatório do Medo e Delírio sem usar as mãos.*"
            }
        }

        var body: some View {
            VStack(alignment: .center, spacing: 40) {
                Text("\(firstPart) É só falar uma dessas frases:")

                VStack(alignment: .leading, spacing: 36) {
                    ForEach(phrase, id: \.self) {
                        FancySiriQuote(quote: $0)
                    }
                }
                .padding(.horizontal, 3)

                Text("* É necessário ter Falar com a Siri habilitado nos Ajustes e o idioma configurado para Português (Brasil).")
                    .multilineTextAlignment(.center)

                Text("Toque em **Permitir** caso a Siri questione se deseja autorizá-la a usar o Atalho.")
                    .multilineTextAlignment(.center)
            }
        }
    }

    struct FancySiriQuote: View {

        let quote: String

        @Environment(\.colorScheme) var colorScheme

        private var quotationMarkOpacity: CGFloat {
            colorScheme == .dark ? 0.3 : 0.24
        }

        private let colors: [Color] = [.pink, .orange]

        var body: some View {
            HStack(spacing: 25) {
                if #available(iOS 18, *) {
                    Image(systemName: "microphone.fill")
                        .foregroundStyle(colors.randomElement() ?? .black)
                        .font(.title)
                }

                Text(" E aí, Siri, \(quote)")
                    .bold()
                    .multilineTextAlignment(.leading)
                    .background(alignment: .topLeading) {
                        Image(systemName: "quote.opening")
                            .foregroundStyle(.gray)
                            .font(.title)
                            .opacity(quotationMarkOpacity)
                            .offset(x: -20, y: -17)
                    }
                    .background(alignment: .bottomTrailing) {
                        Image(systemName: "quote.closing")
                            .foregroundStyle(.gray)
                            .font(.title)
                            .opacity(quotationMarkOpacity)
                            .offset(x: 20, y: 17)
                    }
            }
        }
    }
}

#Preview {

    IntroducingiOS18ControlAndSiriIntentView.SiriInstructions(isiOS18: true, systemName: "iOS 18")
}
