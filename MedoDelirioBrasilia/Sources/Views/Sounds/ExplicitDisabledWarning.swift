//
//  ExplicitDisabledWarning.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/23.
//

import SwiftUI

struct ExplicitDisabledWarning: View {

    let text: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Label(
            text,
            systemImage: "exclamationmark.triangle"
        )
        .foregroundStyle(.red)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.red)
                .opacity(colorScheme == .dark ? 0.25 : 0.15)
        }
    }
}

#Preview {
    ExplicitDisabledWarning(text: Shared.contentFilterMessageForSoundsiPhone)
        .padding()
}
