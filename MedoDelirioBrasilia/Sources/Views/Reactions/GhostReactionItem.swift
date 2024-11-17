//
//  GhostReactionItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/24.
//

import SwiftUI

struct GhostReactionItem: View {

    let reaction: Reaction

    // MARK: - Computed Properties

    private var cellHeight: CGFloat {
        UIDevice.isiPhone ? 100 : 120
    }

    private var reduceTextSize: Bool {
        UIDevice.isSmallDevice && reaction.title.count > 8
    }

    // MARK: - View Body

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(height: cellHeight)
            .overlay {
                Text("Reação Removida")
                    .foregroundColor(.gray)
                    .bold()
                    .multilineTextAlignment(.center)
            }
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    GhostReactionItem(reaction: .acidMock)
}
