//
//  FeatureFlagsSettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

struct FeatureFlagsSettingsView: View {

    @State private var flagStates: [FeatureFlag: Bool] = {
        var states: [FeatureFlag: Bool] = [:]
        for flag in FeatureFlag.allCases {
            states[flag] = FeatureFlag.isEnabled(flag)
        }
        return states
    }()

    var body: some View {
        Section("Feature Flags") {
            ForEach(FeatureFlag.allCases, id: \.self) { flag in
                Toggle(isOn: binding(for: flag)) {
                    VStack(alignment: .leading, spacing: .spacing(.xxxSmall)) {
                        Text(flag.displayName)

                        Text(flag.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func binding(for flag: FeatureFlag) -> Binding<Bool> {
        Binding(
            get: { flagStates[flag] ?? false },
            set: { newValue in
                flagStates[flag] = newValue
                FeatureFlag.setEnabled(flag, to: newValue)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    Form {
        FeatureFlagsSettingsView()
    }
}
