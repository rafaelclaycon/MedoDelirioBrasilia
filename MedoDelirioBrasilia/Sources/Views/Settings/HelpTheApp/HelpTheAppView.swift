//
//  LargeCreatorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/06/22.
//

import SwiftUI

struct HelpTheAppView: View {

    let donors: [Donor]?
    @Binding var toast: Toast?

    var body: some View {
        Section("Ajude o app") {
            VStack(alignment: .center, spacing: .spacing(.large)) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 150)
                    .background {
                        Image("help_the_app_header")
                            .resizable()
                            .scaledToFill()
                            .mask {
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .systemBackground]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            }
                            .scaleEffect(1.2)
                    }

                VStack(alignment: .leading, spacing: .spacing(.xLarge)) {
                    VStack(alignment: .leading, spacing: .spacing(.medium)) {
                        Text("App & comunidade, juntos desde 2022")
                            .font(.title2)
                            .bold()

                        Text("Esse trabalho é voluntário, porém envolve custos mensais com servidor e anuais com a Apple. Bora manter o app sem propagandas? Toda contribuição é bem-vinda!")
                            .font(.callout)
                    }

                    ProgressView(value: 1071, total: 1462) {
                        Text("ARRECADADO VS GASTOS 2025")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.gray)
                    } currentValueLabel: {
                        Text("R$ 1.071 / R$ 1.462")
                    }

                    ProgressView(
                        value: 115,
                        total: 500,
                        label: {
                            Text("META APOIA.SE")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.gray)
                        },
                        currentValueLabel: {
                            Text("R$ 115 / R$ 500")
                        }
                    )
                    .tint(.red)

                    DonateButtons(toast: $toast)

                    if let donors {
                        VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
                            Text("UM OFERECIMENTO:")
                                .font(.footnote)
                                .bold()

                            DonorsView(donors: donors)
                                .marquee()
                        }
                    }
                }
            }
            .padding(.bottom, .spacing(.xxSmall))
        }
    }
}

// MARK: - Subviews

extension HelpTheAppView {

    struct DonateButtons: View {

        @Binding var toast: Toast?

        private let pixKey: String = "medodeliriosuporte@gmail.com"

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.large)) {
                Button {
                    Task {
                        UIPasteboard.general.string = pixKey
                        toast = Toast(message: randomThankYouString(), type: .thankYou)
                        await HelpTheAppView.DonateButtons.sendAnalytics(for: "didCopyPixKey")
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Fazer uma doação única via Pix")
                            .bold()
                        Spacer()
                    }
                }
                .borderedProminentButton(colored: .green)

                Button {
                    Task {
                        OpenUtility.open(link: "https://apoia.se/app-medo-delirio-ios")
                        await HelpTheAppView.DonateButtons.sendAnalytics(for: "didTapApoiaseButton")
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Apoiar mensalmente (a partir de R$ 5)")
                            .bold()
                        Spacer()
                    }
                }
                .borderedProminentButton(colored: .red)
            }
        }

        private func randomThankYouString() -> String {
            let ending = [
                "Obrigado!",
                "Tem que manter isso, viu?",
                "Alegria!",
                "Éééé!",
                "Vamos apoiar o circo!",
                "Olha-Que-Legal!",
                "Ai, que delícia!",
                "Maravilhoso!",
                "Vamo, comunistada!",
                "Bora!"
            ].randomElement() ?? ""
            return "Chave copiada. \(ending)"
        }

        private static func sendAnalytics(for action: String) async {
            await AnalyticsService().send(
                originatingScreen: "SettingsView",
                action: action
            )
        }
    }
}

// MARK: - Preview

#Preview {
    Form {
        HelpTheAppView(
            donors: [
                Donor(name: "Bruno P. G. P."),
                Donor(name: "Clarissa P. S.", hasDonatedBefore: true),
                Donor(name: "Pedro Henrique B. P.")
            ],
            toast: .constant(nil)
        )
    }
}

#Preview("Donate Buttons") {
    HelpTheAppView.DonateButtons(toast: .constant(nil))
}
