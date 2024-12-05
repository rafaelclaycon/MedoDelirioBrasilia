//
//  GaugeProgressStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/12/24.
//

import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {

    var strokeColor = Color.green
    var strokeWidth = 3.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .opacity(0.5)

            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
