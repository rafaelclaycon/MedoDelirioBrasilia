//
//  DynamicBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/05/24.
//

import SwiftUI

struct DynamicBanner: View {

    let bannerData: DynamicBannerData
    let textCopyFeedback: (String) -> Void

    private let mainColor: Color = .blue

    @State private var isExpanded: Bool = false

    private func markedDownText(_ text: String) -> AttributedString {
        do {
            return try .init(markdown: text)
        } catch {
            return .init()
        }
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: .spacing(.small)) {
                ForEach(bannerData.text, id: \.self) {
                    Text(markedDownText($0))
                        .foregroundColor(mainColor)
                        .opacity(0.8)
                        .font(.callout)
                }

                VStack(alignment: .leading, spacing: 15) {
                    ForEach(bannerData.buttons, id: \.title) { button in
                        Button {
                            switch button.type {
                            case .copyText:
                                UIPasteboard.general.string = button.data
                                textCopyFeedback(button.additionalData ?? "")
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }

                            case .openLink:
                                OpenUtility.open(link: button.data)
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }
                            }
                        } label: {
                            Text(button.title)
                        }
                        .tint(mainColor)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                    }
                }
                .padding(.top, 5)
            }
            .padding(.top)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: bannerData.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(mainColor)

                Text(bannerData.title)
                    .font(.callout)
                    .foregroundColor(mainColor)
                    .bold()
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .foregroundStyle(mainColor)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(mainColor)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay {
            if bannerData.title.isEmpty {
                HStack {
                    Spacer()

                    ProgressView()
                        .scaleEffect(1.1)

                    Spacer()
                }
            }
        }
    }
}

#Preview("Loading") {
    DynamicBanner(
        bannerData: DynamicBannerData(
            symbol: "",
            title: "",
            text: [],
            buttons: []
        ),
        textCopyFeedback: { _ in
        }
    )
    .padding(.horizontal, .spacing(.medium))
}

#Preview("Loaded") {
    DynamicBanner(
        bannerData: DynamicBannerData(
            symbol: "heart.square.fill",
            title: "Apoie o app",
            text: [
                "Oi! Para manter o app funcionando e trazer novidades, precisamos renovar nossa licença anual de desenvolvedor. Se o app tem sido útil para você, considere fazer uma contribuição do valor que puder."
            ],
            buttons: [
                DynamicBannerButton(
                    title: "Fazer uma doação única via Pix",
                    type: .copyText,
                    data: "",
                    additionalData: nil
                ),
                DynamicBannerButton(
                    title: "Apoiar mensalmente (a partir de R$ 5)",
                    type: .openLink,
                    data: "",
                    additionalData: nil
                )
            ]
        ),
        textCopyFeedback: { _ in
        }
    )
    .padding(.horizontal, .spacing(.medium))
}
