//
//  ColorSelectionCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct ColorSelectionCell: View {

    let color: Color
    let isSelected: Bool
    let colorSelectionAction: (String) -> Void

    @ScaledMetric private var borderCircle: CGFloat = 44
    @ScaledMetric private var innerCircle: CGFloat = 37
    @ScaledMetric private var borderWidth: CGFloat = 2

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .strokeBorder(color, lineWidth: borderWidth)
                    .frame(width: borderCircle, height: borderCircle)
                    .brightness(-0.2)
            }
            
            Circle()
                .fill(color)
                .frame(width: innerCircle, height: innerCircle)
        }
        .frame(width: borderCircle, height: borderCircle)
        .onTapGesture {
            colorSelectionAction(color.name ?? "pastelBabyBlue")
        }
    }
}

// MARK: - Previews

#Preview("Not Selected") {
    ColorSelectionCell(
        color: .pastelBabyBlue,
        isSelected: false,
        colorSelectionAction: { _ in }
    )
}

#Preview("Selected") {
    ColorSelectionCell(
        color: .pastelBabyBlue,
        isSelected: true,
        colorSelectionAction: { _ in }
    )
}
