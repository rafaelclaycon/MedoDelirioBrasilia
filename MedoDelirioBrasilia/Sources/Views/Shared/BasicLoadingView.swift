//
//  BasicLoadingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/05/25.
//

import SwiftUI

struct BasicLoadingView: View {

    let text: String

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: .spacing(.small)) {
                ProgressView()

                Text(text)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, .spacing(.huge))
    }
}

#Preview {
    BasicLoadingView(text: "Carregando sons...")
}
