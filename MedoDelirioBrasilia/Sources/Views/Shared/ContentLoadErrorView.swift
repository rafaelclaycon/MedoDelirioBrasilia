//
//  NoContentView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/04/25.
//

import SwiftUI

struct ContentLoadErrorView: View {

    var body: some View {
        VStack {
            HStack(spacing: .spacing(.small)) {
                ProgressView()

                Text("Erro ao carregar conteúdo.")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentLoadErrorView()
}
