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

                                Button {
                                    showDonorInfoView.toggle()
                                } label: {
                                    HStack(spacing: .spacing(.small)) {
                                        Text("ÚLTIMAS DOAÇÕES")
                                            .font(.footnote)

                                        Image(systemName: "info.circle")
                                    }
                                    .foregroundStyle(.gray)
                                }
                            }
                        }

                        Text("Esse projeto é mantido através de doações dos usuários. Essas doações cobrem os custos de operação (mensalidades de servidor, anuidade da Apple) e me incentivam a seguir melhorando o app todos os anos. Gosto muito da nossa parceria, bora manter ela?")
                            .padding(.top, .spacing(.xxxSmall))
                    }

                    if let moneyInfo {
                        MoneyInfoView(info: moneyInfo)
                            .padding(.top, -4)
                    }

                    if #available(iOS 26.0, *) {
                        DonateButtons(toast: $toast)
                    }
                }
            }
            .padding(.bottom, .spacing(.xxSmall))
        }
        .task {
            await loadMoneyInfo()
        }
        .sheet(isPresented: $showDonorInfoView) {
            NavigationStack {
                DonorTypeInfoView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            CloseButton {
                                showDonorInfoView.toggle()
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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

    @available(iOS 26.0, *)
    struct DonateButtons: View {

        @Binding var toast: Toast?

        private let pixKey: String = "medodeliriosuporte@gmail.com"

        var body: some View {
            VStack(alignment: .center, spacing: .spacing(.large)) {
                Button {
                    Task {
                        OpenUtility.open(link: "https://apoia.se/app-medo-delirio-ios")
                        await HelpTheAppView.DonateButtons.sendAnalytics(for: "didTapApoiaseButton")
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Apoiar mensalmente")
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, .spacing(.xxSmall))
                }
                .buttonStyle(.glassProminent)
                .tint(.red)

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
                    .padding(.vertical, .spacing(.xxSmall))
                }
                //.borderedButton(colored: .green)
                .buttonStyle(.glass)
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
            VStack(alignment: .center, spacing: .spacing(.medium)) {
                DonorView(donor: donor)

                Text(text)
                    .multilineTextAlignment(.center)
            }
        }

        @Environment(\.dismiss) var dismiss

        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: .spacing(.large)) {
                    row(
                        donor: Donor(name: "Cristiano B."),
                        text: "Usuário fez uma doação única via Pix."
                    )

                    Divider()

                    row(
                        donor: Donor(name: "Pedro D.", hasDonatedBefore: true),
                        text: "O mesmo usuário fez uma nova doação única via Pix, independente do valor."
                    )

                    Divider()

                    row(
                        donor: Donor(name: "Jair B.", isRecurringDonorBelow30: true),
                        text: "Usuário doa até R$ 29 todos os meses pelo Apoia.se."
                    )

                    Divider()

                    row(
                        donor: Donor(name: "Alexandre M.", isRecurringDonor30OrOver: true),
                        text: "Usuário doa R$ 30 ou mais todos os meses pelo Apoia.se."
                    )
                }
                .padding(.horizontal, .spacing(.large))
                .padding(.vertical, .spacing(.small))
            }
            .navigationTitle("Tipos de Doação")
            .navigationBarTitleDisplayMode(.inline)
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
    if #available(iOS 26.0, *) {
        HelpTheAppView.DonateButtons(toast: .constant(nil))
    } else {
        // Fallback on earlier versions
    }
}
