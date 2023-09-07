//
//  SoundDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/09/23.
//

import SwiftUI

struct SoundDetailView: View {

    @Binding var isBeingShown: Bool

    let sound: Sound

    @State private var isPlaying: Bool = false

    // Alerts
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Spacer()

                        AlbumCoverPlayView(isPlaying: $isPlaying)
                            .onTapGesture {
                                play(sound)
                            }

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(sound.title)
                            .font(.title2)

                        Text(sound.authorName ?? "")
                            .foregroundColor(.gray)
                    }



                    //                Button("Baixar som novamente") {
                    //                    //
                    //                }
                    //                .miniButton(colored: .green)

                    Divider()

                    Text("Informações")
                        .font(.title3)
                        .bold()

                    VStack {
                        InfoLine(title: "Origem", information: (sound.isFromServer ?? false) ? "Servidor" : "Local")

                        Divider()

                        InfoLine(title: "Texto de pesquisa", information: sound.description)

                        Divider()

                        InfoLine(title: "Criado em", information: sound.dateAdded?.formatted() ?? "")

                        Divider()

                        InfoLine(title: "Duração", information: sound.duration < 1 ? "< 1 s" : "\(sound.duration.minuteSecondFormatted)")

                        Divider()

                        InfoLine(title: "Ofensivo", information: sound.isOffensive ? "Sim" : "Não")
                        //
                        //                    Divider()
                        //
                        //                    InfoLine(title: "Arquivo", information: "OK")
                    }
                }
                .padding()
                .navigationTitle("Detalhes do Som")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Fechar") {
                            isBeingShown = false
                        }
                    }
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    // No buttons
                } message: {
                    Text(alertMessage)
                }

            }
        }
    }

    func play(_ sound: Sound) {
        do {
            let url = try sound.fileURL()

            isPlaying = true

            AudioPlayer.shared = AudioPlayer(url: url, update: { state in
                if state?.activity == .stopped {
                    self.isPlaying = false
                }
            })

            AudioPlayer.shared?.togglePlay()
        } catch {
            if sound.isFromServer ?? false {
                showServerSoundNotAvailableAlert()
            } else {
                showUnableToGetSoundAlert()
            }
        }
    }

    func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }

    func showServerSoundNotAvailableAlert() {
        TapticFeedback.error()
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.serverSoundNotAvailableMessage
        showAlert = true
    }
}

extension SoundDetailView {

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
}

struct SoundDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SoundDetailView(
            isBeingShown: .constant(true),
            sound: Sound(
                title: "A gente vai cansando",
                authorName: "Soraya Thronicke",
                description: "meu deus a gente vai cansando sabe"
            )
        )
    }
}
