//
//  FloatingSelectionOptionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/09/23.
//

import SwiftUI

struct FloatingSelectionOptionsView: View {

    let areButtonsEnabled: Bool
    let allSelectedAreFavorites: Bool
    let shareIsProcessing: Bool

    let favoriteAction: () -> Void
    let folderAction: () -> Void
    let shareAction: () -> Void

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
                    Text(UIDevice.isiPhone ? "Pasta" : "Adicionar a Pasta")
                        .bold()
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

//#Preview {
//    ZStack {
//        Rectangle()
//            .fill(Color.brightGreen)
//
//        FloatingSelectionOptionsView(
//            areButtonsEnabled: .constant(false),
//            favoriteTitle: .constant("Favoritar"),
//            favoriteSystemImage: .constant("star"),
//            shareIsProcessing: .constant(true),
//            favoriteAction: { },
//            folderAction: { },
//            shareAction: { }
//        )
//    }
//}
