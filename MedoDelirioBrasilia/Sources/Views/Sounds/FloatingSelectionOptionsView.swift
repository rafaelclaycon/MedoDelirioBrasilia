//
//  FloatingSelectionOptionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/09/23.
//

import SwiftUI

struct FloatingSelectionOptionsView: View {

    // MARK: - Dependencies

    let areButtonsEnabled: Bool
    let allSelectedAreFavorites: Bool
    let folderOperation: FolderOperation
    let shareIsProcessing: Bool

    let favoriteAction: () -> Void
    let folderAction: () -> Void
    let shareAction: () -> Void

    // MARK: - Computed Properties

    private var favoriteSymbol: String {
        allSelectedAreFavorites ? "star.slash" : "star"
    }

    private var favoriteTitle: String {
        if allSelectedAreFavorites {
            return UIDevice.isiPhone ? "Desfav." : "Desfavoritar"
        } else {
            return "Favoritar"
        }
    }

    private var folderSymbol: String {
        folderOperation == .add ? "folder.badge.plus" : "folder.badge.minus"
    }

    private var folderTitle: String {
        if UIDevice.isiPhone {
            return "Pasta"
        } else {
            return folderOperation == .add ? "Adicionar a Pasta" : "Remover da Pasta"
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 14) {
            Button {
                favoriteAction()
            } label: {
                Label {
                    Text(favoriteTitle).bold()
                } icon: {
                    Image(systemName: favoriteSymbol)
                }
            }
            .disabled(!areButtonsEnabled)

            Divider()

            Button {
                folderAction()
            } label: {
                Label {
                    Text(folderTitle)
                        .bold()
                } icon: {
                    Image(systemName: folderSymbol)
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
                        Text(UIDevice.isiPhone ? "Comp." : "Compartilhar")
                            .bold()
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(!areButtonsEnabled)
                .disabled(!UIDevice.isiPhone)
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
        .disabled(shareIsProcessing)
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(Color.brightGreen)

        FloatingSelectionOptionsView(
            areButtonsEnabled: true,
            allSelectedAreFavorites: false,
            folderOperation: .add,
            shareIsProcessing: false,
            favoriteAction: { },
            folderAction: { },
            shareAction: { }
        )
    }
}
