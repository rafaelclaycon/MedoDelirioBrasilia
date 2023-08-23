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

    @EnvironmentObject private var syncValues: SyncValues

    var body: some View {
        NavigationView {
            ScrollView {
                switch syncValues.syncStatus {
                case .updating:
                    UpdatingView()
                case .done:
                    AllOkView(lastUpdateDate: lastUpdateDate)
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
                    //.foregroundColor(.green)

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

        @State private var errors: [SyncLog] = []

        private var lastUpdateText: String {
            if lastUpdateDate == "all" {
                return "A última tentativa de sincronização não retornou resultados.\n\nRelaxa, isso só significa que ainda não existem novos conteúdos no servidor. Você não precisa fazer nada."
            } else {
                return "Última sincronização com sucesso em \(lastUpdateDate.formattedDate)."
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

                Text("Últimos 5 registros de erro:")
                    .font(.headline)

                LazyVStack {
                    ForEach(errors) { error in
                        SyncInfoCard(imageName: "exclamationmark.triangle", imageColor: .gray, title: error.description, timestamp: error.dateTime.formattedDate)
                            .padding(.vertical, 5)
                    }
                }

                Text(lastUpdateText)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onAppear {
                errors = LocalDatabase.shared.getLastTenRecords()
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
            SyncInfoView(isBeingShown: .constant(true), lastUpdateDate: "all")
                .environmentObject(syncValuesUpdating)

            SyncInfoView(isBeingShown: .constant(true), lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesDone)

            SyncInfoView(isBeingShown: .constant(true), lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesNoInternet)

            SyncInfoView(isBeingShown: .constant(true), lastUpdateDate: "2023-08-11T20:29:46.562Z")
                .environmentObject(syncValuesUpdateError)
        }
    }
}
