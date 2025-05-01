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
        HStack(spacing: 15) {
            Image(systemName: "arrow.clockwise.icloud.fill")
                .resizable()
                .scaledToFit()
                .frame(width: .spacing(.huge))
                .foregroundColor(.green)

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
        .padding()
        .background {
            RoundedRectangle(cornerRadius: .spacing(.medium))
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
    }
}

// MARK: - Preview

#Preview("Partial") {
    LongUpdateBanner(
        completedNumber: 2,
        totalUpdateCount: 10
    )
    .padding()
}

#Preview("Complete") {
    LongUpdateBanner(
        completedNumber: 10,
        totalUpdateCount: 10
    )
    .padding()
}

#Preview("Over") {
    LongUpdateBanner(
        completedNumber: 12,
        totalUpdateCount: 10
    )
    .padding()
}

#Preview("Under") {
    LongUpdateBanner(
        completedNumber: -2,
        totalUpdateCount: 10
    )
    .padding()
}
