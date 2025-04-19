//
//  ContentToolbarOptionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/04/25.
//

import SwiftUI

struct ContentToolbarOptionsView: View {

    @Binding var contentSortOption: Int
    let contentListMode: ContentListMode
    let multiSelectAction: () -> Void
    let contentSortChangeAction: () -> Void

    var body: some View {
        Menu {
            Section {
                Button {
                    multiSelectAction()
                } label: {
                    Label(
                        contentListMode == .selection ? "Cancelar Seleção" : "Selecionar",
                        systemImage: contentListMode == .selection ? "xmark.circle" : "checkmark.circle"
                    )
                }
            }

            Section {
                Picker("Ordenação de Sons", selection: $contentSortOption) {
                    Text("Título")
                        .tag(0)

                    Text("Nome do(a) Autor(a)")
                        .tag(1)

                    Text("Mais Recentes no Topo")
                        .tag(2)

                    Text("Mais Curtos no Topo")
                        .tag(3)

                    Text("Mais Longos no Topo")
                        .tag(4)

                    if CommandLine.arguments.contains("-SHOW_MORE_DEV_OPTIONS") {
                        Text("Título Mais Longo no Topo")
                            .tag(5)

                        Text("Título Mais Curto no Topo")
                            .tag(6)
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .onChange(of: contentSortOption) {
            contentSortChangeAction()
        }
//        .disabled(
//            viewModel.currentViewMode == .favorites //&& viewModel.favorites?.count == 0 // TODO: Do we need to adapt this?
//        )
    }
}

#Preview {
    ContentToolbarOptionsView(
        contentSortOption: .constant(0),
        contentListMode: .regular,
        multiSelectAction: {},
        contentSortChangeAction: {}
    )
}
