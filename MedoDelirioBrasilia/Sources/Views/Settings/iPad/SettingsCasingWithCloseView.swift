//
//  SettingsCasingWithCloseView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/07/22.
//

import SwiftUI

struct SettingsCasingWithCloseView: View {

    @Binding var isBeingShown: Bool
    @Environment(SettingsHelper.self) private var helper

    var body: some View {
        NavigationView {
            SettingsView(apiClient: APIClient.shared)
                .navigationTitle("Configurações")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                    Button("Fechar") {
                        self.isBeingShown = false
                    }
                )
                .environment(helper)
        }
    }
}

#Preview {
    SettingsCasingWithCloseView(isBeingShown: .constant(true))
}
