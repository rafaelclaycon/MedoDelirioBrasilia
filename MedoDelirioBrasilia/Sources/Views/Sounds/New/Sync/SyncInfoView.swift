//
//  SyncInfoView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/08/23.
//

import SwiftUI

struct SyncInfoView: View {
    @Binding var isBeingShown: Bool

    let lastUpdateDate: String

    private var lastUpdateText: String {
        if lastUpdateDate == "all" {
            return "A última tentativa de sincronização não retornou resultados.\n\nRelaxa, isso só significa que ainda não existem novos conteúdos no servidor. Você não precisa fazer nada."
        } else {
            return "Última sincronização em \(lastUpdateDate.formattedDate)."
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Image(systemName: "clock.arrow.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90)
                        .foregroundColor(.green)

                    VStack(spacing: 15) {
                        Text("Sincronização de conteúdos habilitada.")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)

                        NavigationLink {
                            SyncInfoView.KnowMoreView()
                        } label: {
                            Label("Saiba mais", systemImage: "info.circle")
                        }
                    }

                    Text(lastUpdateText)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Fechar") {
                    self.isBeingShown = false
                }
            )
        }
    }
}

struct CarueView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SyncInfoView(isBeingShown: .constant(true), lastUpdateDate: "all")

            SyncInfoView(isBeingShown: .constant(true), lastUpdateDate: "2023-08-11T20:29:46.562Z")
        }
    }
}
