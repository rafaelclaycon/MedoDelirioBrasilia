//
//  SyncInfoView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/08/23.
//

import SwiftUI

struct SyncInfoView: View {

    @Binding var isBeingShown: Bool

    let lastUpdateAttempt: String
    let lastUpdateDate: String

    @EnvironmentObject private var syncValues: SyncValues

    var body: some View {
        NavigationView {
            ScrollView {
                switch syncValues.syncStatus {
                case .updating:
                    UpdatingView()
                case .done:
                    AllOkView(lastUpdateAttempt: lastUpdateAttempt)
                case .noInternet:
                    NoInternetView(lastUpdateDate: lastUpdateDate)
                case .updateError:
                    UpdateErrorView(lastUpdateDate: lastUpdateDate)
                }
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

extension SyncInfoView {

    struct UpdatingView: View {

        var body: some View {
            VStack(spacing: 30) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding()

                Text("Sincronização em andamento...")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Por favor, aguarde a sincronização ser concluída.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
    }

    struct AllOkView: View {

        let lastUpdateAttempt: String

        @State private var updates: [SyncLog] = []

        private var lastUpdateText: String {
            if lastUpdateAttempt == "" {
                return "A última tentativa de sincronização não retornou resultados.\n\nRelaxa, isso só significa que ainda não existem novos conteúdos no servidor. Você não precisa fazer nada."
            } else {
                return "Última sincronização \(lastUpdateAttempt.asRelativeDateTime ?? "")."
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
                    Text("Sincronização de Conteúdos Habilitada")
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

    struct NoInternetView: View {

        let lastUpdateDate: String

        private var lastUpdateText: String {
            if lastUpdateDate == "all" {
                return "A última tentativa de sincronização não retornou resultados.\n\nRelaxa, isso só significa que ainda não existem novos conteúdos no servidor. Você não precisa fazer nada."
            } else {
                return "Última sincronização em \(lastUpdateDate.formattedDate)."
            }
        }

        var body: some View {
            VStack(spacing: 30) {
                Image(systemName: "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)

                VStack(spacing: 15) {
                    Text("Você está offline.")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Novos conteúdos serão baixados quando você estiver online novamente.")
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
    }

    struct UpdateErrorView: View {

        let lastUpdateDate: String

        @State private var updates: [SyncLog] = []

        private var lastUpdateText: String {
            if lastUpdateDate == "all" {
                return "A última tentativa de sincronização não retornou resultados.\n\nRelaxa, isso só significa que ainda não existem novos conteúdos no servidor. Você não precisa fazer nada."
            } else {
                return "Última sincronização com sucesso \(lastUpdateDate.asRelativeDateTime ?? "")."
            }
        }

        var body: some View {
            VStack(spacing: 30) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .foregroundColor(.orange)

                Text("Houve um problema na última tentativa de sincronização.")
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
    static let syncValuesNoInternet: SyncValues = SyncValues(syncStatus: .noInternet)
    static let syncValuesUpdateError: SyncValues = SyncValues(syncStatus: .updateError)

    static var previews: some View {
        Group {
            SyncInfoView(isBeingShown: .constant(true), lastUpdateAttempt: "", lastUpdateDate: "all")
                .environmentObject(syncValuesUpdating)

            SyncInfoView(isBeingShown: .constant(true), lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesDone)

            SyncInfoView(isBeingShown: .constant(true), lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesNoInternet)

            SyncInfoView(isBeingShown: .constant(true), lastUpdateAttempt: "", lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesUpdateError)
        }
    }
}
