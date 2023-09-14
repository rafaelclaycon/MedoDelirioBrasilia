//
//  YoureOfflineView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/08/23.
//

import SwiftUI

struct YoureOfflineView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 8) {
                Text("Você está offline")
                    .bold()

                Text("Curta os sons sem problemas enquanto estiver offline. Novos conteúdos serão baixados quando você estiver online novamente.")
                    .opacity(0.5)
                    .font(.callout)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                print("Close")
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct YoureOfflineView_Previews: PreviewProvider {
    static var previews: some View {
        YoureOfflineView()
    }
}
