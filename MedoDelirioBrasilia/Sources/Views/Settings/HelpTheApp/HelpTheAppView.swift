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
    let apiClient: APIClientProtocol

    @State private var moneyInfo: [MoneyInfo]?
    @State private var showDonorInfoView: Bool = false

    var body: some View {
        Section("Ajude o app") {
            VStack(alignment: .center, spacing: .spacing(.large)) {
                ImageView()

                VStack(alignment: .leading, spacing: .spacing(.xLarge)) {
                    VStack(alignment: .leading, spacing: .spacing(.medium)) {
                        Text("Desenvolvedor & comunidade, juntos desde 2022")
                            .font(.title2)
                            .bold()

                        if let donors {
                            VStack(alignment: .center, spacing: .spacing(.large)) {
                                DonorsView(donors: donors)
                                    .marquee()

                                HStack(spacing: .spacing(.small)) {
                                    Text("ÚLTIMAS DOAÇÕES")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)

                                    Button {
                                        showDonorInfoView.toggle()
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }

                        Text("Esse projeto é mantido através de doações dos usuários. Essas doações cobrem os custos de operação (mensalidades de servidor, anuidade da Apple) e me incentivam a seguir melhorando o app todos os anos. Gosto muito da nossa parceria, bora manter ela?")
                            .font(.callout)
                            .padding(.top, .spacing(.xxxSmall))
                    }

                    if let moneyInfo {
                        MoneyInfoView(info: moneyInfo)
                            .padding(.top, -4)
                    }

                    DonateButtons(toast: $toast)
                }
            }
            .padding(.bottom, .spacing(.xxSmall))
        }
        .task {
            await loadMoneyInfo()
        }
        .sheet(isPresented: $showDonorInfoView) {
            DonorTypeInfoView()
                .presentationDetents([.medium])
        }
    }

    private func loadMoneyInfo() async {
        guard moneyInfo == nil else { return }
        do {
            moneyInfo = try await apiClient.moneyInfo()
        } catch {
            debugPrint(error)
        }
    }
}

// MARK: - Subviews

extension HelpTheAppView {

    struct ImageView: View {

        var body: some View {
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
        }
    }

    struct MoneyInfoView: View {

        let info: [MoneyInfo]

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.xLarge)) {
                ForEach(info, id: \.title) { info in
                    ProgressView(value: info.currentValue, total: info.totalValue) {
                        Text(info.title)
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.gray)
                    } currentValueLabel: {
                        Text(info.subtitle)
                    }
                    .tint(info.barColor)
                }
            }
        }
    }

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
                .borderedButton(colored: .green)

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
                .borderedButton(colored: .red)
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

    struct DonorTypeInfoView: View {

        @ViewBuilder
        private func row(donor: Donor, text: String) -> some View {
            HStack(spacing: .spacing(.medium)) {
                DonorView(donor: donor)

                Text(text)
            }
        }

        @Environment(\.dismiss) var dismiss

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: .spacing(.medium)) {
                        row(donor: Donor(name: "Cristiano B."), text: "Usuário fez uma doação única via Pix.")

                        row(donor: Donor(name: "Pedro D."), text: "Usuário repetiu uma doação única via Pix.")

                        row(donor: Donor(name: "Jair B."), text: "Usuário doa menos de R$ 30 todos os meses pelo Apoia.se.")

                        row(donor: Donor(name: "Alexandre M."), text: "Usuário doa R$ 30 ou mais todos os meses pelo Apoia.se.")
                    }
                }
            }
            .navigationTitle("Tipos de Doação")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Fechar") {
                    dismiss()
                }
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
            toast: .constant(nil),
            apiClient: APIClient(serverPath: "")
        )
    }
}

#Preview("Donate Buttons") {
    HelpTheAppView.DonateButtons(toast: .constant(nil))
}
