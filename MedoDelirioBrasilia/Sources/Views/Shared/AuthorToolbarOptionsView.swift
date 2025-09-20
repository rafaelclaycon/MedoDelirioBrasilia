//
//  AuthorToolbarOptionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/04/25.
//

import SwiftUI

struct AuthorToolbarOptionsView: ToolbarContent {

    @Binding var authorSortOption: Int
    let onSortingChangedAction: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Section {
                    Picker("Ordenação de Autores", selection: $authorSortOption) {
                        Text("Nome")
                            .tag(0)

                        Text("Autores com Mais Sons no Topo")
                            .tag(1)

                        Text("Autores com Menos Sons no Topo")
                            .tag(2)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
            .onChange(of: authorSortOption) {
                onSortingChangedAction()
            }
        }
    }
}

#Preview {
    VStack {
        Text("View")
    }
    .toolbar {
        AuthorToolbarOptionsView(
            authorSortOption: .constant(0),
            onSortingChangedAction: {}
        )
    }
}
