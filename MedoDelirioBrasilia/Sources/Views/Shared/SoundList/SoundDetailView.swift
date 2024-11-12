//
//  SoundDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/09/23.
//

import SwiftUI

struct SoundDetailView: View {

    let sound: Sound

    @State private var isPlaying: Bool = false
    @State private var showSuggestOtherAuthorEmailAppPicker: Bool = false
    @State private var didCopySupportAddressOnEmailPicker: Bool = false
    @State private var showToastView: Bool = false
    @State private var soundStatistics: LoadingState<ContentShareCountStats> = .loading

    // Alerts
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    // MARK: - Environment Properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    // MARK: - Body
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
                            .padding(.vertical)

                        Button {
                            showSuggestOtherAuthorEmailAppPicker = true
                        } label: {
                            Label("Sugerir outro nome de autor", systemImage: "pencil.line")
                        }
                        .capsule(colored: colorScheme == .dark ? .primary : .gray)
                        .padding(.top, 2)
                    }

                    Text("Estatísticas")
                        .font(.title3)
                        .bold()

                    switch soundStatistics {
                    case .loading:
                        PodiumPair.LoadingView()
                    case .loaded(let stats):
                        PodiumPair.LoadedView(stats: stats)
                    case .error(_):
                        PodiumPair.LoadingErrorView(
                            retryAction: {
                                Task { await loadStatistics() }
                            }
                        )
                    }

                    Text("Informações")
                        .font(.title3)
                        .bold()

                    InfoBlock(sound: sound)

                    Spacer()
                }
                .padding()
                .navigationTitle("Detalhes do Som")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Fechar") {
                            dismiss()
                        }
                    }
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    // No buttons
                } message: {
                    Text(alertMessage)
                }
                .sheet(isPresented: $showSuggestOtherAuthorEmailAppPicker) {
                    EmailAppPickerView(isBeingShown: $showSuggestOtherAuthorEmailAppPicker,
                                       didCopySupportAddress: $didCopySupportAddressOnEmailPicker,
                                       subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, sound.title),
                                       emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, sound.authorName ?? "", sound.id))
                }
                .onChange(of: didCopySupportAddressOnEmailPicker) {
                    if $0 {
                        withAnimation {
                            showToastView = true
                        }
                        TapticFeedback.success()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showToastView = false
                            }
                        }
                        
                        didCopySupportAddressOnEmailPicker = false
                    }
                }
            }
            .overlay {
                if showToastView {
                    VStack {
                        Spacer()
                        
                        ToastView(
                            icon: "checkmark",
                            iconColor: .green,
                            text: "E-mail de suporte copiado com sucesso."
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    }
                    .transition(.moveAndFade)
                }
            }
            .task {
                await loadStatistics()
            }
        }
    }
}

// MARK: - Subviews

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

    struct InfoBlock: View {

        let sound: Sound

        var body: some View {
            VStack(spacing: 10) {
//                InfoLine(title: "ID", information: sound.id)
//
//                Divider()

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

    struct PodiumItem: View {

        let highlight: String
        let description: String

        var body: some View {
            VStack(spacing: 5) {
                Text(highlight)
                    .font(.title)
                    .bold()

                Text(description)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    struct PodiumPair {

        struct LoadingView: View {
            var body: some View {
                VStack(spacing: 15) {
                    ProgressView()

                    Text("Carregando estatísticas de compartilhamento...")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            }
        }

        struct LoadedView: View {

            let stats: ContentShareCountStats

            var body: some View {
                VStack(spacing: 30) {
                    HStack(spacing: 10) {
                        PodiumItem(
                            highlight: String.localizedStringWithFormat("%.0f", Double(stats.totalShareCount)),
                            description: "total de compartilhamentos"
                        )
                        .frame(minWidth: 0, maxWidth: .infinity)

                        Divider()

                        PodiumItem(
                            highlight: "\(stats.lastWeekShareCount)",
                            description: "compart. na última semana"
                        )
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }

                    if !stats.topMonth.isEmpty && !stats.topYear.isEmpty {
                        PodiumItem(
                            highlight: "\(monthDescription(stats.topMonth))/\(stats.topYear)",
                            description: "mês com mais compartilhamentos"
                        )
                    }
                }
            }

            private func monthDescription(_ input: String) -> String {
                switch input {
                case "01": return "jan"
                case "02": return "fev"
                case "03": return "mar"
                case "04": return "abr"
                case "05": return "mai"
                case "06": return "jun"
                case "07": return "jul"
                case "08": return "ago"
                case "09": return "set"
                case "10": return "out"
                case "11": return "nov"
                case "12": return "dez"
                default: return "-"
                }
            }
        }

        struct LoadingErrorView: View {

            let retryAction: () -> Void

            var body: some View {
                VStack(spacing: 15) {
                    Text("Não foi possível carregar as estatísticas de compartilhamento.")
                        .multilineTextAlignment(.center)

                    Button {
                        retryAction()
                    } label: {
                        Label("TENTAR NOVAMENTE", systemImage: "arrow.clockwise")
                            .font(.footnote)
                    }
                    .borderedButton(colored: .blue)
                }
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Functions

extension SoundDetailView {

    private func play(_ sound: Sound) {
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

    private func loadStatistics() async {
        soundStatistics = .loading
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/sound-share-count-stats-for/\(sound.id)")!
        do {
            let stats: ContentShareCountStats = try await NetworkRabbit.shared.get(from: url)
            soundStatistics = .loaded(stats)
        } catch {
            soundStatistics = .error(error.localizedDescription)
        }
    }

    private func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertTitle = Shared.contentNotFoundAlertTitle(sound.title)
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }

    private func showServerSoundNotAvailableAlert() {
        TapticFeedback.error()
        alertTitle = Shared.contentNotFoundAlertTitle(sound.title)
        alertMessage = Shared.serverContentNotAvailableMessage
        showAlert = true
    }
}

// MARK: - Preview

#Preview {
    SoundDetailView(
        sound: Sound(
            title: "A gente vai cansando",
            authorName: "Soraya Thronicke",
            description: "meu deus a gente vai cansando sabe"
        )
    )
}
