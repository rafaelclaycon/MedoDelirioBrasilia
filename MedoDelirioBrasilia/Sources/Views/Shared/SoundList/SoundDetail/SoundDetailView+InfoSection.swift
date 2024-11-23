//
//  SoundDetailView+InfoSection.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/11/24.
//

import SwiftUI

extension SoundDetailView {

    struct InfoSection: View {

        let sound: Sound

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Informações")
                    .font(.title3)
                    .bold()

                InfoBlock(sound: sound)
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

        let sound: Sound

        var body: some View {
            VStack(spacing: 10) {
                InfoLine(title: "ID", information: sound.id)

                Divider()

                InfoLine(title: "Origem", information: (sound.isFromServer ?? false) ? "Servidor" : "Local")

                Divider()

                InfoLine(title: "Texto de pesquisa", information: sound.description)

                Divider()

                InfoLine(title: "Criado em", information: sound.dateAdded?.formatted() ?? "")

                Divider()

                InfoLine(title: "Duração", information: sound.duration < 1 ? "< 1 s" : "\(sound.duration.minuteSecondFormatted)")

                Divider()

                InfoLine(title: "Ofensivo", information: sound.isOffensive ? "Sim" : "Não")

//                Divider()
//
//                InfoLine(title: "Arquivo", information: "OK")
            }
        }
    }
}
