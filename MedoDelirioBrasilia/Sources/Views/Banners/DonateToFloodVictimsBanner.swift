//
//  DonateToFloodVictimsBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/05/24.
//

import SwiftUI

struct DonateToFloodVictimsBanner: View {

    let bannerData: DynamicBanner
    let textCopyFeedback: (String) -> Void

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
            VStack(alignment: .leading, spacing: 8) {
                ForEach(bannerData.text, id: \.self) {
                    Text(markedDownText($0))
                        .foregroundColor(.red)
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
                        .tint(.red)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                    }
                }
                .padding(.top, 5)
            }
            .padding(.top)
        } label: {
            HStack(spacing: 15) {
                Image(systemName: bannerData.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36)
                    .foregroundColor(.red)

                Text(bannerData.title)
                    .foregroundColor(.red)
                    .bold()
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.all, 20)
        .foregroundStyle(.red)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.red)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay {
            if bannerData.title.isEmpty {
                HStack {
                    Spacer()

                    ProgressView()
                        .foregroundStyle(.red)

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    DonateToFloodVictimsBanner(
        bannerData: .init(symbol: "house", title: "Ajude", text: ["Text"], buttons: []),
        textCopyFeedback: { _ in }
    )
}
