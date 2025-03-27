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

        let lastUpdateAttempt: String

        @State private var updates: [SyncLog] = []

        private var lastUpdateText: String {
            if lastUpdateAttempt == "" {
                return "A última tentativa de atualização não retornou resultados."
            } else {
                return "Última atualização \(lastUpdateAttempt.asRelativeDateTime ?? "")."
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

                HStack {
                    Text("Histórico:")
                        .bold()

                    Spacer()
                }
                .padding(.horizontal, 10)

                VStack(spacing: 15) {
                    ForEach(updates) { update in
                        SyncInfoCard(
                            imageName: update.logType == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                            imageColor: update.logType == .success ? .green : .orange,
                            title: update.description,
                            timestamp: update.dateTime.asRelativeDateTime ?? ""
                        )
                        .onTapGesture {
                            dump(update)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .onAppear {
                updates = LocalDatabase.shared.lastFewLogs()
            }
        }
    }

    private struct UpdateErrorView: View {

        let lastUpdateDate: String

        @State private var updates: [SyncLog] = []

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

                HStack {
                    Text("Histórico:")
                        .bold()

                    Spacer()
                }
                .padding(.horizontal, 10)

                LazyVStack {
                    ForEach(updates) { update in
                        SyncInfoCard(
                            imageName: update.logType == .error ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                            imageColor: update.logType == .error ? .orange : .green,
                            title: update.description,
                            timestamp: update.dateTime.asRelativeDateTime ?? ""
                        )
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onAppear {
                updates = LocalDatabase.shared.lastFewLogs()
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
