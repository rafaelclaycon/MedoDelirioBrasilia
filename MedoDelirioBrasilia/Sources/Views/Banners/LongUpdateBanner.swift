//
//  LongUpdateBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/12/23.
//

import SwiftUI

struct LongUpdateBanner: View {

    @Binding var completedNumber: Int
    @Binding var totalUpdateCount: Int

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "arrow.clockwise.icloud.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 42)
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 8) {
                Text("Atualização Longa Em Andamento")
                    .bold()
                    .multilineTextAlignment(.leading)

                Text("Novidades estão sendo baixadas. Por favor, deixe o **app aberto** até a atualização ser concluída.")
                    .opacity(0.8)
                    .font(.callout)

                ProgressView(
                    "\(completedNumber)/\(totalUpdateCount)",
                    value: Double(completedNumber),
                    total: Double(totalUpdateCount)
                )
                .padding(.top, 8)
                .padding(.bottom, 10)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
    }
}

#Preview {
    LongUpdateBanner(completedNumber: .constant(2), totalUpdateCount: .constant(10))
        .padding()
}
