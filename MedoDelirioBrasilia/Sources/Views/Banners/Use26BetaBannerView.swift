//
//  Use26BetaBannerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/06/25.
//

import SwiftUI

struct Use26BetaBannerView: View {

    @Binding var isBeingShown: Bool
    @Binding var showFAQSheet: Bool

    @Environment(\.colorScheme) var colorScheme

    private let bannerColor: Color = .blue
    private let analyticsScreenName: String = "Use26BetaBannerView"

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.medium)) {
            HStack {
                Text("Ajude a Criar a Próxima Versão do Medo e Delírio")
                    .foregroundColor(bannerColor)
                    .bold()
                    .multilineTextAlignment(.leading)

                Spacer(minLength: .spacing(.medium))
            }

            Text("Você está usando a versão beta do \(UIDevice.systemMarketingName) 26. Quer testar o app com o novo visual do sistema? Baixe a versão beta.")
                .foregroundColor(bannerColor)
                .opacity(0.8)
                .font(.callout)

            VStack(spacing: .spacing(.large)) {
                Button {
                    Task {
                        await AnalyticsService().send(
                            originatingScreen: analyticsScreenName,
                            action: "tappedJoinBeta"
                        )

                        OpenUtility.open(link: "https://testflight.apple.com/join/rMQ3yVaX")
                    }
                } label: {
                    Text("Participar do Beta")
                }
                .tint(bannerColor)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)

                Button {
                    Task {
                        await AnalyticsService().send(
                            originatingScreen: analyticsScreenName,
                            action: "tappedMoreInfo"
                        )

                        showFAQSheet.toggle()
                    }
                } label: {
                    Text("Mais Informações")
                }
                .tint(bannerColor)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
        .padding(.all, 20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(bannerColor)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                Task {
                    await AnalyticsService().send(
                        originatingScreen: analyticsScreenName,
                        action: "didDismissBanner"
                    )

                    AppPersistentMemory().hasDismissediOS26BetaBanner(true)
                    isBeingShown = false
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(bannerColor)
            }
            .padding()
        }
        .onAppear {
            Task {
                await AnalyticsService().send(
                    originatingScreen: analyticsScreenName,
                    action: "didSeeBanner"
                )
            }
        }
    }
}

// MARK: - Subviews

extension Use26BetaBannerView {

    struct FrequentlyAskedQuestionsView: View {

        @Environment(\.dismiss) var dismiss

        private var deviceNameForSecondQuestion: String {
            if UIDevice.isMac {
                "Mac"
            } else {
                "aparelho"
            }
        }

        private var versionForSecondQuestion: String {
            if UIDevice.isMac {
                "macOS 14 ou 15"
            } else if UIDevice.isiPhone {
                "iOS 17 ou 18"
            } else {
                "iPadOS 17 ou 18"
            }
        }

        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: .spacing(.large)) {
                        Text("Por que a versão normal do app tem o visual antigo mesmo eu usando o beta do \(UIDevice.systemMarketingName)?")
                            .font(.title2)
                            .bold()

                        Text("Para que os apps obtenham o novo visual do iOS, eles precisam ser compilados com a última versão do Xcode (Xcode 26). Essa versão ainda está em beta e - até o lançamento da versão estável do \(UIDevice.systemMarketingName) ali por setembrou ou outubro - não é possível subir apps para a loja compilados com esse novo Xcode.\n\nÉ por isso que lancei uma nova versão do Medo e Delírio Beta. Essa versão pode ser compilada com o novo Xcode e ter o novo visual, já que serve apenas para testes.")

                        Text("Instalei o Medo e Delírio Beta em um \(deviceNameForSecondQuestion) com \(versionForSecondQuestion) e não obtive o novo visual. Por quê?")
                            .font(.title2)
                            .bold()

                        Text("O novo visual se aplica apenas quando duas condições são atendidas: o app foi compilado com o Xcode 26 e o usuário está rodando ele no \(UIDevice.systemMarketingName) 26. A mesma versão do app rodando em sistemas anteriores mantém o visual antigo.")

                        Text("Como eu posso ajudar?")
                            .font(.title2)
                            .bold()

                        Text("O \(UIDevice.systemMarketingName) 26 trouxe uma mudança grande de visual, usando o novo material Liquid Glass. Eu ainda estou estudando como adaptar o Medo e Delírio para esse novo visual e você pode ajudar testado o app na versão beta do sistema e dando feedback sobre pontos que talvez pareçam esquisitos e podem melhorar.\n\nVocê pode dar o feedback pelo TestFlight ou pelo e-mail nas Configurações. Obrigado!")

                        Text("O que muda da versão normal do app (essa) para a versão Beta?")
                            .font(.title2)
                            .bold()

                        Text("Minha intenção é que as duas sejam idênticas exceto pelo visual. Você terá acesso aos mesmos conteúdos, Reações e estatísticas que a versão de produção.\n\nVersões Beta anteriores e futuras não vão seguir essa regra, já que às vezes as mudanças sendo testadas dependem de uma nova versão do servidor.")
                    }
                    .padding(.top)
                    .padding(.horizontal, .spacing(.xxLarge))
                    .padding(.bottom, .spacing(.xxLarge))
                }
                .navigationTitle("Perguntas Frequentes sobre o Beta")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CloseButton {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    Task {
                        await AnalyticsService().send(
                            originatingScreen: "Use26BetaBannerView.FAQ",
                            action: "didViewBetaFAQ"
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    Use26BetaBannerView(
        isBeingShown: .constant(true),
        showFAQSheet: .constant(false)
    )
    .padding()
}
