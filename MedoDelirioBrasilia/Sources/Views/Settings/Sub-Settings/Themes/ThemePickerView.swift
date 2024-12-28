//
//  ThemePickerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/12/24.
//

import SwiftUI

struct ThemePickerView: View {

    @State private var currentTheme: UITheme = .default

    var body: some View {
        NavigationStack {
            List(UITheme.allCases, id: \.self) { theme in
                HStack(spacing: 10) {
                    Image(systemName: theme == currentTheme ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(.blue)

                    Text(theme.rawValue)
                }
                .onTapGesture {
                    currentTheme = theme
                }
            }
        }
        .navigationTitle("Tema")
        .onAppear {
            currentTheme = UserSettings().theme()
        }
        .onDisappear {
            UserSettings().theme(currentTheme)
        }
    }
}

#Preview {
    ThemePickerView()
}
