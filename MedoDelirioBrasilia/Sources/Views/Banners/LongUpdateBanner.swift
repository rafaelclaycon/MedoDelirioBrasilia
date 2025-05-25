//
//  LongUpdateBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/12/23.
//

import SwiftUI

struct LongUpdateBanner: View {

    let completedNumber: Int
    let totalUpdateCount: Int
    let updateNowAction: () -> Void
    let dismissBannerAction: () -> Void

    @State private var isDownloading: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    private var percentageText: String {
        guard
            completedNumber > 0,
            totalUpdateCount > 0,
            completedNumber <= totalUpdateCount
        else { return "" }
        let percentage: Int = Int((Double(completedNumber) / Double(totalUpdateCount)) * 100)
        return "\(percentage)%"
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            if isDownloading {
                HStack(spacing: 15) {
                    if #available(iOS 18.0, *) {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: .spacing(.huge))
                            .foregroundColor(.green)
                            .symbolEffect(.rotate, options: .speed(2))
                    } else {
                        Image(systemName: "arrow.clockwise.icloud.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: .spacing(.huge))
                            .foregroundColor(.green)
                    }

                    VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
                        Text("Atualização Longa Em Andamento")
                            .bold()
                            .multilineTextAlignment(.leading)

                        Text("Novidades estão sendo baixadas. Por favor, deixe o **app aberto** até a atualização ser concluída.")
                            .opacity(0.8)
                            .font(.callout)

                        ProgressView(
                            percentageText,
                            value: Double(completedNumber),
                            total: Double(totalUpdateCount)
                        )
                        .padding(.top, .spacing(.xSmall))
                        .padding(.bottom, .spacing(.xSmall))
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: .spacing(.medium)) {
                        Text("Atualizar Conteúdos")
                            .bold()
                            .multilineTextAlignment(.leading)

                        Text("Para ver as últimas novidades é necessário atualizar os conteúdos do app. A primeira atualização é a mais longa, cerca de 20 MB, e deve levar 3 minutos para baixar.")
                            .opacity(0.8)
                            .font(.callout)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: .spacing(.small)) {
                                AllowUpdateButton(title: "Atualizar agora") {
                                    isDownloading = true
                                    updateNowAction()
                                }

                                AllowUpdateButton(title: "Lembrar mais tarde") {
                                    dismissBannerAction()
                                }
                            }

                            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                                AllowUpdateButton(title: "Atualizar agora") {
                                    isDownloading = true
                                    updateNowAction()
                                }

                                AllowUpdateButton(title: "Lembrar mais tarde") {
                                    dismissBannerAction()
                                }
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: .spacing(.medium))
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
    }
}

// MARK: - Subviews

extension LongUpdateBanner {

    struct AllowUpdateButton: View {

        let title: String
        let action: () -> Void

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .bold()
                    .foregroundStyle(colorScheme == .dark ? Color.accentColor : Color.primary)
                    .padding(.vertical, .spacing(.xxxSmall))
                    .padding(.horizontal, .spacing(.xSmall))
            }
            .capsule(colored: .gray)
        }
    }
}

// MARK: - Preview

#Preview("Partial") {
    LongUpdateBanner(
        completedNumber: 2,
        totalUpdateCount: 10,
        updateNowAction: {},
        dismissBannerAction: {}
    )
    .padding()
}

#Preview("Complete") {
    LongUpdateBanner(
        completedNumber: 10,
        totalUpdateCount: 10,
        updateNowAction: {},
        dismissBannerAction: {}
    )
    .padding()
}

#Preview("Over") {
    LongUpdateBanner(
        completedNumber: 12,
        totalUpdateCount: 10,
        updateNowAction: {},
        dismissBannerAction: {}
    )
    .padding()
}

#Preview("Under") {
    LongUpdateBanner(
        completedNumber: -2,
        totalUpdateCount: 10,
        updateNowAction: {},
        dismissBannerAction: {}
    )
    .padding()
}
