//
//  ContentUpdateStatusView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/08/23.
//

import SwiftUI

/// Displays a sheet with Content Update status and history.
struct ContentUpdateStatusView: View {

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
                }
            }
            .navigationTitle("Atualização de Conteúdos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ContentUpdateStatusView.KnowMoreView()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

extension ContentUpdateStatusView {

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
            VStack(spacing: .spacing(.xxLarge)) {
                InfoHeader(
                    symbol: "checkmark",
                    color: .green,
                    title: "Conteúdos atualizados",
                    subtitle: lastUpdateText
                )
                .padding(.horizontal, .spacing(.xSmall))

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

        private let checkConnection = "Verifique a sua conexão à Internet."

        private var title: String {
            if lastUpdateDate == "all" {
                return "Nunca atualizado"
            } else {
                return "Última atualização com sucesso \(lastUpdateDate.asRelativeDateTime ?? "")"
            }
        }

        private var subtitle: String {
            if lastUpdateDate == "all" {
                return "A última tentativa de atualização não obteve resultados. " + checkConnection
            } else {
                return "Houve um problema na última tentativa de atualização. " + checkConnection
            }
        }

        var body: some View {
            VStack(spacing: .spacing(.xxLarge)) {
                InfoHeader(
                    symbol: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: title,
                    subtitle: subtitle
                )
                .padding(.horizontal, .spacing(.xSmall))

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

    private struct InfoHeader: View {

        let symbol: String
        let color: Color
        let title: String
        let subtitle: String

        @ScaledMetric private var iconWidth: CGFloat = 40

        var body: some View {
            HStack(spacing: .spacing(.large)) {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
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
                            imageName: update.logType == .error ? "exclamationmark.triangle" : "checkmark",
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
    ContentUpdateStatusView(lastUpdateAttempt: "", lastUpdateDate: "all")
        .environment(SyncValues())
}

#Preview("Update OK") {
    ContentUpdateStatusView(lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
        .environment(SyncValues(syncStatus: .done))
}

#Preview("Update Error - Never Updated") {
    ContentUpdateStatusView(lastUpdateAttempt: "", lastUpdateDate: "all")
        .environment(SyncValues(syncStatus: .updateError))
}

#Preview("Update Error") {
    ContentUpdateStatusView(lastUpdateAttempt: "", lastUpdateDate: "2025-07-11T20:29:46.562Z")
        .environment(SyncValues(syncStatus: .updateError))
}
