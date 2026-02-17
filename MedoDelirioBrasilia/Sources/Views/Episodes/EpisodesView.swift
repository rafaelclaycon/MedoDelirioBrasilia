//
//  EpisodesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

struct EpisodesView: View {

    var body: some View {
        ContentUnavailableView(
            "Em Breve",
            systemImage: "radio",
            description: Text("A funcionalidade de Episódios está em desenvolvimento.")
        )
        .navigationTitle("Episódios")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EpisodesView()
    }
}
