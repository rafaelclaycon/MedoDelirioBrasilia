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

#Preview {
    StoriesView()
}
