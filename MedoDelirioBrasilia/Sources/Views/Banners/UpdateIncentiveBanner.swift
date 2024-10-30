//
//  UpdateIncentiveBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/11/23.
//

import SwiftUI

struct UpdateIncentiveBanner: View {

    @Binding var isBeingShown: Bool

    @State private var maxSystemVersion: String = ""

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "arrow.up.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 36)
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Não Perca as Últimas Novidades")
                        .foregroundColor(.red)
                        .bold()
                        .multilineTextAlignment(.leading)

                    Spacer()
                        .frame(width: 30)
                }

                Text("Seu \(UIDevice.isiPhone ? "iPhone" : "iPad") está rodando \(UIDevice.isiPhone ? "iOS" : "iPadOS") 15, porém suporta \(maxSystemVersion). Considere atualizar para usar o Compartilhar como Vídeo melhorado e a Retrospectiva 2023.")
                    .foregroundColor(.red)
                    .opacity(0.8)
                    .font(.callout)

                Button {
                    OpenUtility.open(link: "https://support.apple.com/pt-br/HT204204")
                } label: {
                    Text("Como atualizar?")
                }
                .tint(.red)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.red)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory().setHasSeenFirstUpdateIncentiveBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .onAppear {
            maxSystemVersion = UpdateIncentive.maxSupportedVersion(deviceModel: UIDevice.modelName) ?? ""

            if !AppPersistentMemory().getHasSentFirstUpdateIncentiveMetric() {
                Analytics.send(
                    originatingScreen: "UpdateIncentiveBanner",
                    action: "didShowUpdateIncentiveBanner(\(UIDevice.modelName), \(UIDevice.current.systemVersion))"
                )
                AppPersistentMemory().setHasSentFirstUpdateIncentiveMetric(to: true)
            }
        }
    }
}

#Preview {
    UpdateIncentiveBanner(isBeingShown: .constant(true))
        .padding()
}
