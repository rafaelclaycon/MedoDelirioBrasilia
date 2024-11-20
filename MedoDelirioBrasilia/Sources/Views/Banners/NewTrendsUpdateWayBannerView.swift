//
//  NewTrendsUpdateWayBannerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/12/23.
//

import SwiftUI

struct NewTrendsUpdateWayBannerView: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("A Maneira de Atualizar a Lista Mudou")
                    .foregroundColor(.blue)
                    .bold()
                    .multilineTextAlignment(.leading)

                Spacer()
                    .frame(width: 30)
            }

            Text("Da mesma forma que na lista principal de sons, puxe de cima para baixo na lista para atualizar.")
                .foregroundColor(.blue)
                .opacity(0.8)
                .font(.callout)
        }
        .padding(.all, 20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.blue)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory().setHasSeenNewTrendsUpdateWayBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

#Preview {
    NewTrendsUpdateWayBannerView(isBeingShown: .constant(true))
        .padding()
}
