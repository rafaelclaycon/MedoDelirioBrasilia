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
    
    private let borderCircle: CGFloat = 44
    private let innerCircle: CGFloat = 37
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .strokeBorder(color, lineWidth: 2)
                    .frame(width: borderCircle, height: borderCircle)
                    .saturation(1.5)
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
