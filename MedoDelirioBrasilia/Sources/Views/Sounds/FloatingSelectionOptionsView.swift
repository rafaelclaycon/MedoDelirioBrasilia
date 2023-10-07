//
//  FloatingSelectionOptionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/09/23.
//

import SwiftUI

struct FloatingSelectionOptionsView: View {

    @Binding var areButtonsEnabled: Bool
    @Binding var favoriteTitle: String
    @Binding var favoriteSystemImage: String
    @Binding var shareIsProcessing: Bool

    let favoriteAction: () -> Void
    let folderAction: () -> Void
    let shareAction: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button {
                favoriteAction()
            } label: {
                Label {
                    Text(favoriteTitle).bold()
                } icon: {
                    Image(systemName: favoriteSystemImage)
                }
            }
            .disabled(!areButtonsEnabled)

            Divider()

            Button {
                folderAction()
            } label: {
                Label {
                    Text("Pasta").bold()
                } icon: {
                    Image(systemName: "folder.badge.plus")
                }
            }
            .disabled(!areButtonsEnabled)

            Divider()

            if shareIsProcessing {
                ProgressView()
                    .frame(width: 80)
            } else {
                Button {
                    shareAction()
                } label: {
                    Label {
                        Text("Exportar").bold()
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(!areButtonsEnabled)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: 50)
        .background {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.systemBackground)
                .shadow(color: .gray, radius: 2, y: 2)
        }
        .padding(.bottom)
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(Color.brightGreen)

        FloatingSelectionOptionsView(
            areButtonsEnabled: .constant(false),
            favoriteTitle: .constant("Favoritar"),
            favoriteSystemImage: .constant("star"),
            shareIsProcessing: .constant(true),
            favoriteAction: { },
            folderAction: { },
            shareAction: { }
        )
    }
}
