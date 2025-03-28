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

    @EnvironmentObject private var syncValues: SyncValues

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

struct SyncInfoView_Previews: PreviewProvider {

    static let syncValuesUpdating: SyncValues = SyncValues()
    static let syncValuesDone: SyncValues = SyncValues(syncStatus: .done)
    static let syncValuesUpdateError: SyncValues = SyncValues(syncStatus: .updateError)

    static var previews: some View {
        Group {
            SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "all")
                .environmentObject(syncValuesUpdating)

            SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesDone)

            SyncInfoView(lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesUpdateError)
        }
    }
}
