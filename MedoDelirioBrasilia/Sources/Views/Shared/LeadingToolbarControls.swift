//
//  LeadingToolbarControls.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/04/25.
//

import SwiftUI

struct LeadingToolbarControls: View {

    let isSelecting: Bool
    let cancelAction: () -> Void
    let openSettingsAction: () -> Void

    var body: some View {
        if isSelecting {
            Button {
                cancelAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }
        } else {
            if UIDevice.isiPhone {
                Button {
                    openSettingsAction()
                } label: {
                    Image(systemName: "gearshape")
                }
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    LeadingToolbarControls(
        isSelecting: false,
        cancelAction: {},
        openSettingsAction: {}
    )
}
