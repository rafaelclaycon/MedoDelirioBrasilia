//
//  FloatingSelectionOptionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/09/23.
//

import SwiftUI

struct FloatingSelectionOptionsView: View {

    var body: some View {
        HStack(spacing: 18) {
            Button {
                print("Favorite")
            } label: {
                Label("Favoritar", systemImage: "star")
            }

            Divider()

            Button {
                print("Folder")
            } label: {
                Label("Pasta", systemImage: "folder.badge.plus")
            }

            Divider()

            Button {
                print("Share")
            } label: {
                Label("Comp.", systemImage: "square.and.arrow.up")
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: 50)
        .background {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.systemBackground.opacity(0.75))
                //.shadow(color: .gray, radius: 2, y: 2)
        }
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(Color.brightGreen)

        FloatingSelectionOptionsView()
    }
}
