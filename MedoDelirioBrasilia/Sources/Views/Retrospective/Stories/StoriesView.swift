//
//  StoriesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/10/24.
//

import SwiftUI

struct StoriesView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Dashes")
                .foregroundStyle(.white)

            FirstStory()

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.black)
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
            }
        }
    }
}

extension StoriesView {

    struct FirstStory: View {
        var body: some View {
            VStack {
                Spacer()

                Text("Juntos doamos")

                Text("R$ 1.600")

                Text("para pessoas desabrigadas no Rio Grande do Sul.")

                Spacer()
            }
        }
    }
}

#Preview {
    StoriesView()
}
