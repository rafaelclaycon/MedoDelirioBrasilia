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
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isBeingShown = false
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "xmark")
                            } else {
                                Text("Fechar")
                            }
                        }
                    }
                }
                .environment(helper)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsCasingWithCloseView(isBeingShown: .constant(true))
}
