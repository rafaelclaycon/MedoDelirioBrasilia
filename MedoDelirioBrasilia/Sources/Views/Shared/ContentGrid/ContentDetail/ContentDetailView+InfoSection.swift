//
//  ContentDetailView+InfoSection.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/11/24.
//

import SwiftUI

extension ContentDetailView {

    struct InfoSection: View {

        let content: AnyEquatableMedoContent
        let idSelectedAction: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Informações")
                    .font(.title3)
                    .bold()

                InfoBlock(
                    content: content,
                    idSelectedAction: idSelectedAction
                )
            }
        }
    }

    struct InfoLine: View {

        let title: String
        let information: String

        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Spacer()

                    Text(information)
                        .font(.footnote)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
        }
    }

    struct InfoBlock: View {

        let content: AnyEquatableMedoContent
        let idSelectedAction: () -> Void

        var body: some View {
            VStack(spacing: 10) {
                InfoLine(title: "ID", information: content.id)
                    .onTapGesture {
                        idSelectedAction()
                    }

                Divider()

                InfoLine(title: "Tipo", information: content.type == .sound ? "Som" : "Música")

                Divider()

                InfoLine(title: "Origem", information: (content.isFromServer ?? false) ? "Servidor" : "Local")

                Divider()

                InfoLine(title: "Texto de pesquisa", information: content.description)

                Divider()

                InfoLine(title: "Criado em", information: content.dateAdded?.formatted() ?? "")

                Divider()

                InfoLine(title: "Duração", information: content.duration < 1 ? "< 1 s" : "\(content.duration.minuteSecondFormatted)")

                Divider()

                InfoLine(title: "Ofensivo", information: content.isOffensive ? "Sim" : "Não")

//                Divider()
//
//                InfoLine(title: "Arquivo", information: "OK")
            }
        }
    }
}
