//
//  SyncInfoView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/08/23.
//

import SwiftUI

struct SyncInfoView: View {

    let lastUpdateAttempt: String
    let lastUpdateDate: String

    @Environment(SyncValues.self) private var syncValues
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                switch syncValues.syncStatus {
                case .updating:
                    UpdatingView()
                case .done:
                    AllOkView(lastUpdateAttempt: lastUpdateAttempt)
                case .updateError:
                    UpdateErrorView(lastUpdateDate: lastUpdateDate)
                case .pendingFirstUpdate:
                    PendingFirstUpdateView()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Fechar") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Subviews

extension SyncInfoView {

    private struct UpdatingView: View {

        var body: some View {
            VStack(spacing: 30) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding()

                Text("Atualização de conteúdos em andamento...")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Por favor, aguarde a atualização ser concluída.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
    }

    private struct AllOkView: View {

        @State var lastUpdateAttempt: String

        @State private var updates: [SyncLog] = []
        @State private var hiddenUpdates: Int = 0
        @State private var lastUpdateText: String = ""

        private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

        private func updateLastUpdateText() {
            if lastUpdateAttempt == "" {
                lastUpdateText = "A última tentativa de atualização não retornou resultados."
            } else {
                guard let date = lastUpdateAttempt.iso8601withFractionalSeconds else {
                    return lastUpdateText = ""
                }
                guard date.minutesPassed(1) else {
                    return lastUpdateText = "Atualizado agora há pouco."
                }
                lastUpdateText = "Última atualização \(lastUpdateAttempt.asRelativeDateTime ?? "")."
            }
        }

        var body: some View {
            VStack(spacing: 30) {
                Image(systemName: "clock.arrow.2.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90)
                    .foregroundColor(.green)

                VStack(spacing: 15) {
                    Text("Atualização Automática de Conteúdos Habilitada")
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

                HistoryView(
                    updates: updates,
                    hiddenUpdatesCount: hiddenUpdates
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .onAppear {
                updateLastUpdateText()
                updates = LocalDatabase.shared.lastFewSyncLogs()
                hiddenUpdates = LocalDatabase.shared.totalSyncLogCount()
            }
            .onReceive(timer) { time in
                updateLastUpdateText()
            }
        }
    }

    private struct UpdateErrorView: View {

        let lastUpdateDate: String

        @State private var updates: [SyncLog] = []
        @State private var hiddenUpdates: Int = 0

        private var lastUpdateText: String {
            if lastUpdateDate == "all" {
                return "A última tentativa de atualização não retornou resultados."
            } else {
                return "Última atualização com sucesso \(lastUpdateDate.asRelativeDateTime ?? "").\n\nGaranta que o seu dispositivo está conectado à Internet. Caso o problema persista, entre em contato com o desenvolvedor."
            }
        }

        var body: some View {
            VStack(spacing: 30) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .foregroundColor(.orange)

                Text("Houve um problema na última tentativa de atualização.")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(lastUpdateText)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                HistoryView(
                    updates: updates,
                    hiddenUpdatesCount: hiddenUpdates
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onAppear {
                updates = LocalDatabase.shared.lastFewSyncLogs()
                hiddenUpdates = LocalDatabase.shared.totalSyncLogCount()
            }
        }
    }

    private struct PendingFirstUpdateView: View {

        var body: some View {
            VStack(spacing: 30) {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .foregroundColor(.gray)

                Text("Aguardando Primeira Atualização")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Button {

                } label: {
                    Text("Atualizar Agora")
                        .bold()
                        .padding(.horizontal, .spacing(.medium))
                }
                .borderedButton(colored: .accentColor)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private struct HistoryView: View {

        let updates: [SyncLog]
        let hiddenUpdatesCount: Int

        var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Text("Histórico:")
                        .bold()

                    Spacer()
                }
                .padding(.horizontal, 10)

                LazyVStack(spacing: 15) {
                    ForEach(updates) { update in
                        SyncInfoCard(
                            imageName: update.logType == .error ? "exclamationmark.triangle" : "checkmark.circle",
                            imageColor: update.logType == .error ? .orange : .green,
                            title: update.description,
                            timestamp: update.dateTime.asRelativeDateTime ?? ""
                        )
                        .onTapGesture {
                            dump(update)
                        }
                    }
                }

                if hiddenUpdatesCount > 0 {
                    Text("E outras \(hiddenUpdatesCount) atualizações registradas.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Updating") {
    let syncValuesUpdating: SyncValues = SyncValues()
    return SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "all")
        .environment(syncValuesUpdating)
}

#Preview("Done") {
    let syncValuesDone: SyncValues = SyncValues(syncStatus: .done)
    return SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
        .environment(syncValuesDone)
}

#Preview("Update Error") {
    let syncValuesUpdateError: SyncValues = SyncValues(syncStatus: .updateError)
    return SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
        .environment(syncValuesUpdateError)
}

#Preview("First Update Not Allowed") {
    let syncValuesUpdateError: SyncValues = SyncValues(syncStatus: .pendingFirstUpdate)
    return SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "")
        .environment(syncValuesUpdateError)
}
