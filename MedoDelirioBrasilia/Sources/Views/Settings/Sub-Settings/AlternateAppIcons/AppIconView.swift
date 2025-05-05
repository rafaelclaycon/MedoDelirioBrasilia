//
//  AppIconView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/08/22.
//

import SwiftUI

struct AppIconView: View {

    let icon: Icon

    @Binding var selectedItem: String
    @Environment(\.colorScheme) var colorScheme

    var isSelected: Bool {
        selectedItem == icon.id
    }

    private let circleSize: CGFloat = 24.0

    var body: some View {
        HStack(spacing: .spacing(.xLarge)) {
            IconImage(icon: icon)

            Text(icon.marketingName)

            Spacer()
            
            if isSelected {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: circleSize, height: circleSize)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .font(.callout)
                        .frame(width: circleSize, height: circleSize)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    AppIconView(icon: Icon.primary, selectedItem: .constant(Icon.primary.id))
        .padding()
}

#Preview {
    AppIconView(icon: Icon.medoDelicia, selectedItem: .constant(Icon.primary.id))
        .padding()
}
