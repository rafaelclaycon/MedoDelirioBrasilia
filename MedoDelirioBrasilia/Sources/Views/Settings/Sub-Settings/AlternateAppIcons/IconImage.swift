//
//  IconImage.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/08/22.
//

import SwiftUI

struct IconImage: View {

    var icon: Icon

    private let cornerRadius: CGFloat = .spacing(.small)

    var body: some View {
        Label {
            Text(icon.rawValue)
        } icon: {
           Image(icon.imageNameForInsideTheApp)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.vertical)
        }
        .labelStyle(.iconOnly)
    }
}

#Preview {
    IconImage(icon: Icon.odioNojo)
}
